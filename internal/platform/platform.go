package platform

import (
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

// HomeDir returns the user's home directory.
func HomeDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return home
}

// ExpandPath expands ~ to home directory.
func ExpandPath(path string) string {
	if strings.HasPrefix(path, "~/") {
		return filepath.Join(HomeDir(), path[2:])
	}
	return path
}

// PathExists checks if a file or directory exists.
func PathExists(path string) bool {
	_, err := os.Stat(ExpandPath(path))
	return err == nil
}

// DirSize calculates the total size of a directory in bytes.
func DirSize(path string) int64 {
	var size int64
	expanded := ExpandPath(path)
	_ = filepath.Walk(expanded, func(_ string, info os.FileInfo, err error) error {
		if err != nil {
			return nil // skip errors
		}
		if !info.IsDir() {
			size += info.Size()
		}
		return nil
	})
	return size
}

// RemoveAll removes a path and all its contents. Returns error if it fails.
func RemoveAll(path string) error {
	expanded := ExpandPath(path)
	if !PathExists(expanded) {
		return nil
	}
	return os.RemoveAll(expanded)
}

// IsCommandAvailable checks if a command exists in PATH.
func IsCommandAvailable(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

// RunCommand runs a command and returns stdout, ignoring errors.
func RunCommand(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	out, err := cmd.CombinedOutput()
	return strings.TrimSpace(string(out)), err
}

// RunCommandSilent runs a command and returns only the error.
func RunCommandSilent(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = nil
	cmd.Stderr = nil
	return cmd.Run()
}

// FindProcessesByName returns PIDs of processes matching the given name.
func FindProcessesByName(name string) []string {
	switch runtime.GOOS {
	case "windows":
		return findProcessesWindows(name)
	default:
		return findProcessesUnix(name)
	}
}

// KillProcess kills a process by PID.
func KillProcess(pid string, force bool) error {
	switch runtime.GOOS {
	case "windows":
		return killProcessWindows(pid, force)
	default:
		return killProcessUnix(pid, force)
	}
}

// GOOS returns the current OS.
func GOOS() string {
	return runtime.GOOS
}
