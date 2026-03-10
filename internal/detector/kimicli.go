package detector

import (
	"path/filepath"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// KimiCLIDetector detects Moonshot AI's kimi-cli (local CLI tool).
type KimiCLIDetector struct{}

func (d *KimiCLIDetector) Name() string { return "KimiCLI" }

func (d *KimiCLIDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// pip package
	if platform.IsCommandAvailable("pip") {
		out, err := platform.RunCommand("pip", "show", "kimi-cli")
		if err == nil && len(out) > 0 {
			p.Packages = append(p.Packages, types.PackageRef{Manager: "pip", Name: "kimi-cli"})
			p.Detected = true
		}
	}
	if platform.IsCommandAvailable("pip3") {
		out, err := platform.RunCommand("pip3", "show", "kimi-cli")
		if err == nil && len(out) > 0 && len(p.Packages) == 0 {
			p.Packages = append(p.Packages, types.PackageRef{Manager: "pip3", Name: "kimi-cli"})
			p.Detected = true
		}
	}

	// Config directory
	configDir := filepath.Join(home, ".kimi")
	if platform.PathExists(configDir) {
		p.Paths = append(p.Paths, configDir)
		p.DiskUsage += platform.DirSize(configDir)
		p.Detected = true
	}

	// Binary in PATH
	if platform.IsCommandAvailable("kimi") {
		p.Detected = true
	}

	return p
}
