package scanner

import (
	"runtime"

	"github.com/greywen/KillClaws/internal/detector"
	"github.com/greywen/KillClaws/internal/types"
)

// Scan runs all detectors and returns the combined result.
func Scan() types.ScanResult {
	return ScanWith(detector.AllDetectors())
}

// ScanWith runs specific detectors and returns results.
func ScanWith(detectors []detector.Detector) types.ScanResult {
	result := types.ScanResult{
		Platform: platformName(),
	}
	for _, d := range detectors {
		product := d.Detect()
		result.Products = append(result.Products, product)
	}
	return result
}

// ScanOnly runs detectors for specific product names.
func ScanOnly(names []string) types.ScanResult {
	nameSet := make(map[string]bool)
	for _, n := range names {
		nameSet[normalize(n)] = true
	}

	var selected []detector.Detector
	for _, d := range detector.AllDetectors() {
		if nameSet[normalize(d.Name())] {
			selected = append(selected, d)
		}
	}
	return ScanWith(selected)
}

// ScanExclude runs all detectors except the specified ones.
func ScanExclude(names []string) types.ScanResult {
	nameSet := make(map[string]bool)
	for _, n := range names {
		nameSet[normalize(n)] = true
	}

	var selected []detector.Detector
	for _, d := range detector.AllDetectors() {
		if !nameSet[normalize(d.Name())] {
			selected = append(selected, d)
		}
	}
	return ScanWith(selected)
}

func platformName() string {
	return runtime.GOOS + "/" + runtime.GOARCH
}

func normalize(s string) string {
	out := make([]byte, 0, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c >= 'A' && c <= 'Z' {
			c += 32
		}
		out = append(out, c)
	}
	return string(out)
}
