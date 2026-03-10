package detector

import (
	"path/filepath"
	"runtime"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// OpenClawDetector detects OpenClaw installations.
type OpenClawDetector struct{}

func (d *OpenClawDetector) Name() string { return "OpenClaw" }

func (d *OpenClawDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// 1. Check config/state directories
	configPaths := []string{
		filepath.Join(home, ".openclaw"),
		filepath.Join(home, "clawd"),       // legacy workspace
		filepath.Join(home, ".clawdbot"),    // legacy clawdbot
		filepath.Join(home, ".molthub"),     // legacy moltbot
	}
	for _, path := range configPaths {
		if platform.PathExists(path) {
			p.Paths = append(p.Paths, path)
			p.DiskUsage += platform.DirSize(path)
			p.Detected = true
		}
	}

	// 2. Check npm global package
	for _, mgr := range []string{"npm", "pnpm", "bun"} {
		if platform.IsCommandAvailable(mgr) {
			out, err := platform.RunCommand(mgr, "list", "-g", "openclaw")
			if err == nil && len(out) > 0 && contains(out, "openclaw") {
				p.Packages = append(p.Packages, types.PackageRef{Manager: mgr, Name: "openclaw"})
				p.Detected = true
			}
		}
	}

	// 3. Check running processes
	procs := platform.FindProcessesByName("openclaw")
	if len(procs) > 0 {
		p.Processes = procs
		p.Detected = true
	}

	// 4. Platform-specific checks
	switch runtime.GOOS {
	case "darwin":
		d.detectDarwin(&p, home)
	case "linux":
		d.detectLinux(&p, home)
	case "windows":
		d.detectWindows(&p)
	}

	return p
}

func (d *OpenClawDetector) detectDarwin(p *types.ClawProduct, home string) {
	// macOS App
	if platform.MacAppExists("OpenClaw.app") {
		p.Paths = append(p.Paths, "/Applications/OpenClaw.app")
		p.Detected = true
	}

	// LaunchAgent
	for _, label := range []string{"ai.openclaw.gateway", "com.openclaw.gateway"} {
		if platform.LaunchAgentExists(label) {
			p.Services = append(p.Services, "launchd:"+label)
			p.Detected = true
		}
	}

	// Library support dirs
	libPaths := []string{
		filepath.Join(home, "Library", "Application Support", "OpenClaw"),
		filepath.Join(home, "Library", "Caches", "OpenClaw"),
		filepath.Join(home, "Library", "Preferences", "ai.openclaw.gateway.plist"),
	}
	for _, path := range libPaths {
		if platform.PathExists(path) {
			p.Paths = append(p.Paths, path)
			p.Detected = true
		}
	}
}

func (d *OpenClawDetector) detectLinux(p *types.ClawProduct, home string) {
	// systemd user service
	svcFile := filepath.Join(home, ".config", "systemd", "user", "openclaw-gateway.service")
	if platform.PathExists(svcFile) {
		p.Services = append(p.Services, "systemd:openclaw-gateway.service")
		p.Paths = append(p.Paths, svcFile)
		p.Detected = true
	}
}

func (d *OpenClawDetector) detectWindows(p *types.ClawProduct) {
	// Scheduled task
	for _, taskName := range []string{"OpenClaw Gateway", "openclaw-gateway"} {
		if platform.ScheduledTaskExists(taskName) {
			p.Services = append(p.Services, "schtasks:"+taskName)
			p.Detected = true
		}
	}
}

func contains(s, substr string) bool {
	return len(s) > 0 && len(substr) > 0 && stringContains(s, substr)
}

func stringContains(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
