package detector

import (
	"path/filepath"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// ZeroClawDetector detects ZeroClaw (Rust rewrite) installations.
type ZeroClawDetector struct{}

func (d *ZeroClawDetector) Name() string { return "ZeroClaw" }

func (d *ZeroClawDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// Binary in PATH
	if platform.IsCommandAvailable("zeroclaw") {
		p.Detected = true
		p.Processes = append(p.Processes, "zeroclaw")
	}

	// Config directory
	configDir := filepath.Join(home, ".zeroclaw")
	if platform.PathExists(configDir) {
		p.Paths = append(p.Paths, configDir)
		p.DiskUsage += platform.DirSize(configDir)
		p.Detected = true
	}

	// Running processes
	procs := platform.FindProcessesByName("zeroclaw")
	if len(procs) > 0 {
		p.Processes = procs
		p.Detected = true
	}

	return p
}

// PicoClawDetector detects PicoClaw (Go IoT build) installations.
type PicoClawDetector struct{}

func (d *PicoClawDetector) Name() string { return "PicoClaw" }

func (d *PicoClawDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// Binary in PATH
	if platform.IsCommandAvailable("picoclaw") {
		p.Detected = true
		p.Processes = append(p.Processes, "picoclaw")
	}

	// Config directory
	configDir := filepath.Join(home, ".picoclaw")
	if platform.PathExists(configDir) {
		p.Paths = append(p.Paths, configDir)
		p.DiskUsage += platform.DirSize(configDir)
		p.Detected = true
	}

	// Running processes
	procs := platform.FindProcessesByName("picoclaw")
	if len(procs) > 0 {
		p.Processes = procs
		p.Detected = true
	}

	return p
}
