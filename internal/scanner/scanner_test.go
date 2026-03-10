package scanner

import "testing"

func TestNormalize(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{"OpenClaw", "openclaw"},
		{"QClaw", "qclaw"},
		{"ZEROCLAW", "zeroclaw"},
		{"already_lower", "already_lower"},
		{"", ""},
	}

	for _, tt := range tests {
		got := normalize(tt.input)
		if got != tt.want {
			t.Errorf("normalize(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

func TestScan(t *testing.T) {
	result := Scan()
	if result.Platform == "" {
		t.Error("Platform should not be empty")
	}
	if len(result.Products) == 0 {
		t.Error("Should have at least one product in results")
	}
}

func TestScanOnly(t *testing.T) {
	result := ScanOnly([]string{"OpenClaw"})
	if len(result.Products) != 1 {
		t.Errorf("ScanOnly([\"OpenClaw\"]) returned %d products, want 1", len(result.Products))
	}
	if len(result.Products) > 0 && result.Products[0].Name != "OpenClaw" {
		t.Errorf("Expected OpenClaw, got %s", result.Products[0].Name)
	}
}

func TestScanExclude(t *testing.T) {
	all := Scan()
	excluded := ScanExclude([]string{"OpenClaw"})
	if len(excluded.Products) != len(all.Products)-1 {
		t.Errorf("ScanExclude should return %d products, got %d",
			len(all.Products)-1, len(excluded.Products))
	}
	for _, p := range excluded.Products {
		if normalize(p.Name) == "openclaw" {
			t.Error("OpenClaw should be excluded")
		}
	}
}
