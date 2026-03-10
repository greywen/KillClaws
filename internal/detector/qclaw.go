package detector

import (
	"os"
	"path/filepath"
	"runtime"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// QClawDetector detects Tencent QClaw installations.
type QClawDetector struct{}

func (d *QClawDetector) Name() string { return "QClaw" }

func (d *QClawDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// Check processes
	procs := platform.FindProcessesByName("QClaw")
	if len(procs) > 0 {
		p.Processes = procs
		p.Detected = true
	}

	// Config directories
	configPaths := []string{
		filepath.Join(home, ".qclaw"),
	}

	switch runtime.GOOS {
	case "darwin":
		configPaths = append(configPaths,
			filepath.Join(home, "Library", "Application Support", "QClaw"),
			filepath.Join(home, "Library", "Caches", "QClaw"),
		)
		if platform.MacAppExists("QClaw.app") {
			p.Paths = append(p.Paths, "/Applications/QClaw.app")
			p.Detected = true
		}
	case "windows":
		appData := os.Getenv("APPDATA")
		localAppData := os.Getenv("LOCALAPPDATA")
		if appData != "" {
			configPaths = append(configPaths, filepath.Join(appData, "QClaw"))
		}
		if localAppData != "" {
			configPaths = append(configPaths, filepath.Join(localAppData, "QClaw"))
			configPaths = append(configPaths, filepath.Join(localAppData, "Programs", "QClaw"))
		}
	}

	for _, path := range configPaths {
		if platform.PathExists(path) {
			p.Paths = append(p.Paths, path)
			p.DiskUsage += platform.DirSize(path)
			p.Detected = true
		}
	}

	return p
}
