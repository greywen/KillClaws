package types

import "testing"

func TestScanResult_DetectedCount(t *testing.T) {
	tests := []struct {
		name     string
		products []ClawProduct
		want     int
	}{
		{
			name:     "empty",
			products: nil,
			want:     0,
		},
		{
			name: "none detected",
			products: []ClawProduct{
				{Name: "OpenClaw", Detected: false},
				{Name: "QClaw", Detected: false},
			},
			want: 0,
		},
		{
			name: "some detected",
			products: []ClawProduct{
				{Name: "OpenClaw", Detected: true},
				{Name: "QClaw", Detected: false},
				{Name: "ZeroClaw", Detected: true},
			},
			want: 2,
		},
		{
			name: "all detected",
			products: []ClawProduct{
				{Name: "OpenClaw", Detected: true},
				{Name: "QClaw", Detected: true},
			},
			want: 2,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			sr := &ScanResult{Products: tt.products}
			if got := sr.DetectedCount(); got != tt.want {
				t.Errorf("DetectedCount() = %d, want %d", got, tt.want)
			}
		})
	}
}
