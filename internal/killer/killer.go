package killer

import (
	"fmt"
	"runtime"
	"time"

	"github.com/greywen/KillClaws/internal/platform"
	"github.com/greywen/KillClaws/internal/types"
)

// Kill removes a detected Claw product from the system.
func Kill(product types.ClawProduct, verbose bool) types.UninstallResult {
	result := types.UninstallResult{Product: product.Name, Success: true}

	if !product.Detected {
		return result
	}

	// 1. Stop processes
	for _, proc := range product.Processes {
		if verbose {
			fmt.Printf("  Stopping process: %s\n", proc)
		}
		// Graceful first
		err := platform.KillProcess(proc, false)
		if err != nil {
			// Wait a moment then force kill
			time.Sleep(2 * time.Second)
			_ = platform.KillProcess(proc, true)
		}
		result.StoppedProcs = append(result.StoppedProcs, proc)
	}

	// 2. Remove services
	for _, svc := range product.Services {
		if verbose {
			fmt.Printf("  Removing service: %s\n", svc)
		}
		err := removeService(svc)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("service %s: %v", svc, err))
		} else {
			result.RemovedSvcs = append(result.RemovedSvcs, svc)
		}
	}

	// 3. Uninstall packages
	for _, pkg := range product.Packages {
		if verbose {
			fmt.Printf("  Uninstalling package: %s (%s)\n", pkg.Name, pkg.Manager)
		}
		err := uninstallPackage(pkg)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("package %s/%s: %v", pkg.Manager, pkg.Name, err))
		}
	}

	// 4. Remove files
	for _, path := range product.Paths {
		if verbose {
			fmt.Printf("  Removing: %s\n", path)
		}
		size := platform.DirSize(path)
		err := platform.RemoveAll(path)
		if err != nil {
			result.Errors = append(result.Errors, fmt.Sprintf("path %s: %v", path, err))
		} else {
			result.RemovedPaths = append(result.RemovedPaths, path)
			result.FreedBytes += size
		}
	}

	if len(result.Errors) > 0 {
		result.Success = false
	}

	return result
}

// removeService removes a system service based on its type prefix.
func removeService(svc string) error {
	switch {
	case len(svc) > 8 && svc[:8] == "launchd:":
		label := svc[8:]
		return platform.UnloadLaunchAgent(label)
	case len(svc) > 8 && svc[:8] == "systemd:":
		serviceName := svc[8:]
		err := platform.StopServiceSystemd(serviceName)
		if err != nil {
			return err
		}
		return platform.DaemonReloadSystemd()
	case len(svc) > 9 && svc[:9] == "schtasks:":
		taskName := svc[9:]
		return platform.DeleteScheduledTask(taskName)
	}
	return fmt.Errorf("unknown service type: %s", svc)
}

// uninstallPackage removes a global package using its package manager.
func uninstallPackage(pkg types.PackageRef) error {
	switch pkg.Manager {
	case "npm":
		return platform.RunCommandSilent("npm", "rm", "-g", pkg.Name)
	case "pnpm":
		return platform.RunCommandSilent("pnpm", "remove", "-g", pkg.Name)
	case "bun":
		return platform.RunCommandSilent("bun", "remove", "-g", pkg.Name)
	case "pip", "pip3":
		return platform.RunCommandSilent(pkg.Manager, "uninstall", "-y", pkg.Name)
	}
	return fmt.Errorf("unknown package manager: %s", pkg.Manager)
}

// TryOfficialUninstall attempts to use OpenClaw's built-in uninstaller first.
func TryOfficialUninstall(verbose bool) bool {
	if !platform.IsCommandAvailable("openclaw") {
		return false
	}
	if verbose {
		fmt.Println("  Attempting official OpenClaw uninstall...")
	}

	args := []string{"uninstall", "--all", "--yes", "--non-interactive"}
	if runtime.GOOS == "windows" {
		// On Windows, openclaw may be in WSL2
		args = []string{"uninstall", "--all", "--yes", "--non-interactive"}
	}

	err := platform.RunCommandSilent("openclaw", args...)
	return err == nil
}
