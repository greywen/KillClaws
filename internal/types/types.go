package types

// ClawProduct represents a detected Claw product on the system.
type ClawProduct struct {
	Name       string       `json:"name"`
	Detected   bool         `json:"detected"`
	Paths      []string     `json:"paths,omitempty"`
	Services   []string     `json:"services,omitempty"`
	Processes  []string     `json:"processes,omitempty"`
	Packages   []PackageRef `json:"packages,omitempty"`
	DiskUsage  int64        `json:"disk_usage_bytes,omitempty"`
	Containers []string     `json:"containers,omitempty"`
}

// PackageRef identifies an installed package.
type PackageRef struct {
	Manager string `json:"manager"` // "npm", "pnpm", "bun", "pip"
	Name    string `json:"name"`
}

// ScanResult holds the complete scan output.
type ScanResult struct {
	Products []ClawProduct `json:"products"`
	Platform string        `json:"platform"`
}

// DetectedCount returns how many products were found.
func (s *ScanResult) DetectedCount() int {
	count := 0
	for _, p := range s.Products {
		if p.Detected {
			count++
		}
	}
	return count
}

// UninstallResult holds the result of an uninstall operation.
type UninstallResult struct {
	Product        string   `json:"product"`
	Success        bool     `json:"success"`
	RemovedPaths   []string `json:"removed_paths,omitempty"`
	StoppedProcs   []string `json:"stopped_processes,omitempty"`
	RemovedSvcs    []string `json:"removed_services,omitempty"`
	Errors         []string `json:"errors,omitempty"`
	FreedBytes     int64    `json:"freed_bytes"`
}
