package platform

import (
	"os"
	"path/filepath"
	"strings"
)

// LaunchAgentExists checks if a macOS launch agent plist exists.
func LaunchAgentExists(label string) bool {
	plistPath := filepath.Join(HomeDir(), "Library", "LaunchAgents", label+".plist")
	return PathExists(plistPath)
}

// UnloadLaunchAgent unloads and removes a macOS launch agent.
func UnloadLaunchAgent(label string) error {
	uid := os.Getuid()
	uidStr := strings.TrimSpace(func() string {
		if uid >= 0 {
			out, _ := RunCommand("id", "-u")
			return out
		}
		return "501"
	}())

	// Try bootout first (modern approach)
	_ = RunCommandSilent("launchctl", "bootout", "gui/"+uidStr+"/"+label)
	// Fallback to unload
	plistPath := filepath.Join(HomeDir(), "Library", "LaunchAgents", label+".plist")
	_ = RunCommandSilent("launchctl", "unload", plistPath)
	// Remove the plist file
	return os.Remove(plistPath)
}

// MacAppExists checks if a .app bundle exists in /Applications.
func MacAppExists(appName string) bool {
	return PathExists(filepath.Join("/Applications", appName))
}

// RemoveMacApp removes a .app bundle from /Applications.
func RemoveMacApp(appName string) error {
	return RemoveAll(filepath.Join("/Applications", appName))
}
