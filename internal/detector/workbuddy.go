package detector

import (
	"os"
	"path/filepath"
	"runtime"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// WorkBuddyDetector detects Tencent WorkBuddy installations.
type WorkBuddyDetector struct{}

func (d *WorkBuddyDetector) Name() string { return "WorkBuddy" }

func (d *WorkBuddyDetector) Detect() types.ClawProduct {
	p := types.ClawProduct{Name: d.Name()}
	home := platform.HomeDir()

	// Check processes
	procs := platform.FindProcessesByName("WorkBuddy")
	if len(procs) > 0 {
		p.Processes = procs
		p.Detected = true
	}

	// Config directories
	configPaths := []string{
		filepath.Join(home, ".workbuddy"),
	}

	switch runtime.GOOS {
	case "darwin":
		configPaths = append(configPaths,
			filepath.Join(home, "Library", "Application Support", "WorkBuddy"),
			filepath.Join(home, "Library", "Caches", "WorkBuddy"),
		)
		if platform.MacAppExists("WorkBuddy.app") {
			p.Paths = append(p.Paths, "/Applications/WorkBuddy.app")
			p.Detected = true
		}
	case "windows":
		appData := os.Getenv("APPDATA")
		localAppData := os.Getenv("LOCALAPPDATA")
		programFiles := os.Getenv("ProgramFiles")
		if appData != "" {
			configPaths = append(configPaths, filepath.Join(appData, "WorkBuddy"))
		}
		if localAppData != "" {
			configPaths = append(configPaths, filepath.Join(localAppData, "WorkBuddy"))
			configPaths = append(configPaths, filepath.Join(localAppData, "Programs", "WorkBuddy"))
		}
		if programFiles != "" {
			configPaths = append(configPaths, filepath.Join(programFiles, "Tencent", "WorkBuddy"))
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
