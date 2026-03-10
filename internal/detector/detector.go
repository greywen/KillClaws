package detector

import (
	"github.com/greywen/KillClaws/internal/types"
)

// Detector is the interface that all Claw product detectors implement.
type Detector interface {
	// Name returns the product name.
	Name() string
	// Detect scans the system for this product and returns findings.
	Detect() types.ClawProduct
}

// AllDetectors returns all registered detectors.
func AllDetectors() []Detector {
	return []Detector{
		&OpenClawDetector{},
		&QClawDetector{},
		&WorkBuddyDetector{},
		&ZeroClawDetector{},
		&PicoClawDetector{},
		&KimiCLIDetector{},
	}
}
