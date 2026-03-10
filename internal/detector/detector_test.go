package detector

import "testing"

func TestAllDetectors(t *testing.T) {
	detectors := AllDetectors()
	if len(detectors) == 0 {
		t.Fatal("AllDetectors() returned empty slice")
	}

	// Verify all expected detectors are present
	expected := map[string]bool{
		"OpenClaw":  false,
		"QClaw":     false,
		"WorkBuddy": false,
		"ZeroClaw":  false,
		"PicoClaw":  false,
		"KimiCLI":   false,
	}

	for _, d := range detectors {
		name := d.Name()
		if _, ok := expected[name]; !ok {
			t.Errorf("Unexpected detector: %s", name)
		}
		expected[name] = true
	}

	for name, found := range expected {
		if !found {
			t.Errorf("Missing detector: %s", name)
		}
	}
}

func TestDetectorsReturnCorrectNames(t *testing.T) {
	detectors := AllDetectors()
	for _, d := range detectors {
		name := d.Name()
		if name == "" {
			t.Error("Detector name should not be empty")
		}

		// Detect should not panic on a clean system
		product := d.Detect()
		if product.Name != name {
			t.Errorf("Detect().Name = %q, want %q", product.Name, name)
		}
	}
}

func TestOpenClawDetector_CleanSystem(t *testing.T) {
	d := &OpenClawDetector{}
	p := d.Detect()
	if p.Name != "OpenClaw" {
		t.Errorf("Name = %q, want OpenClaw", p.Name)
	}
	// On a clean CI system, nothing should be detected
	// (this test documents expected behavior, not asserts detection=false
	// since the test runner machine may have openclaw installed)
}

func TestContains(t *testing.T) {
	tests := []struct {
		s, substr string
		want      bool
	}{
		{"hello world", "world", true},
		{"hello world", "xyz", false},
		{"", "x", false},
		{"x", "", false},
		{"openclaw@1.0.0", "openclaw", true},
	}
	for _, tt := range tests {
		if got := contains(tt.s, tt.substr); got != tt.want {
			t.Errorf("contains(%q, %q) = %v, want %v", tt.s, tt.substr, got, tt.want)
		}
	}
}
