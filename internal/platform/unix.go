package platform

import (
	"strings"
)

func findProcessesUnix(name string) []string {
	out, err := RunCommand("ps", "aux")
	if err != nil {
		return nil
	}
	var pids []string
	for _, line := range strings.Split(out, "\n") {
		lower := strings.ToLower(line)
		if strings.Contains(lower, strings.ToLower(name)) && !strings.Contains(lower, "killclaws") {
			fields := strings.Fields(line)
			if len(fields) >= 2 {
				pids = append(pids, fields[1])
			}
		}
	}
	return pids
}

func killProcessUnix(pid string, force bool) error {
	if force {
		return RunCommandSilent("kill", "-9", pid)
	}
	return RunCommandSilent("kill", pid)
}

// ServiceExistsSystemd checks if a systemd user service exists.
func ServiceExistsSystemd(serviceName string) bool {
	_, err := RunCommand("systemctl", "--user", "is-enabled", serviceName)
	return err == nil
}

// StopServiceSystemd stops and disables a systemd user service.
func StopServiceSystemd(serviceName string) error {
	_ = RunCommandSilent("systemctl", "--user", "stop", serviceName)
	_ = RunCommandSilent("systemctl", "--user", "disable", serviceName)
	return nil
}

// DaemonReloadSystemd reloads the systemd user daemon.
func DaemonReloadSystemd() error {
	return RunCommandSilent("systemctl", "--user", "daemon-reload")
}
