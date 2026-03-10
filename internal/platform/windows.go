package platform

import (
	"strings"
)

func findProcessesWindows(name string) []string {
	out, err := RunCommand("tasklist", "/FO", "CSV", "/NH")
	if err != nil {
		return nil
	}
	var pids []string
	for _, line := range strings.Split(out, "\n") {
		lower := strings.ToLower(line)
		if strings.Contains(lower, strings.ToLower(name)) {
			// CSV format: "name.exe","PID","Session Name","Session#","Mem Usage"
			fields := strings.Split(line, ",")
			if len(fields) >= 2 {
				pid := strings.Trim(fields[1], "\" ")
				pids = append(pids, pid)
			}
		}
	}
	return pids
}

func killProcessWindows(pid string, force bool) error {
	if force {
		return RunCommandSilent("taskkill", "/F", "/PID", pid)
	}
	return RunCommandSilent("taskkill", "/PID", pid)
}

// ScheduledTaskExists checks if a Windows scheduled task exists.
func ScheduledTaskExists(taskName string) bool {
	out, _ := RunCommand("schtasks", "/Query", "/TN", taskName)
	return !strings.Contains(out, "ERROR")
}

// DeleteScheduledTask removes a Windows scheduled task.
func DeleteScheduledTask(taskName string) error {
	return RunCommandSilent("schtasks", "/Delete", "/TN", taskName, "/F")
}
