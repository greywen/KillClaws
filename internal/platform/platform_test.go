package platform

import (
	"os"
	"path/filepath"
	"testing"
)

func TestHomeDir(t *testing.T) {
	home := HomeDir()
	if home == "" {
		t.Fatal("HomeDir() returned empty string")
	}
	if _, err := os.Stat(home); err != nil {
		t.Fatalf("HomeDir() returned non-existent path: %s", home)
	}
}

func TestExpandPath(t *testing.T) {
	home := HomeDir()
	tests := []struct {
		input string
		want  string
	}{
		{"~/test", filepath.Join(home, "test")},
		{"/absolute/path", "/absolute/path"},
		{"relative/path", "relative/path"},
	}

	for _, tt := range tests {
		got := ExpandPath(tt.input)
		if got != tt.want {
			t.Errorf("ExpandPath(%q) = %q, want %q", tt.input, got, tt.want)
		}
	}
}

func TestPathExists(t *testing.T) {
	// Current directory should exist
	if !PathExists(".") {
		t.Error("PathExists(\".\") should be true")
	}

	// Non-existent path
	if PathExists("/this/path/definitely/does/not/exist/killclaws_test_xyz") {
		t.Error("PathExists should be false for non-existent path")
	}
}

func TestDirSize(t *testing.T) {
	// Create a temp directory with a file
	dir := t.TempDir()
	testFile := filepath.Join(dir, "test.txt")
	data := []byte("hello killclaws test data")
	if err := os.WriteFile(testFile, data, 0644); err != nil {
		t.Fatal(err)
	}

	size := DirSize(dir)
	if size < int64(len(data)) {
		t.Errorf("DirSize() = %d, want >= %d", size, len(data))
	}
}

func TestRemoveAll(t *testing.T) {
	dir := t.TempDir()
	testDir := filepath.Join(dir, "to_remove")
	os.MkdirAll(filepath.Join(testDir, "sub"), 0755)
	os.WriteFile(filepath.Join(testDir, "file.txt"), []byte("data"), 0644)

	err := RemoveAll(testDir)
	if err != nil {
		t.Fatalf("RemoveAll() error: %v", err)
	}

	if PathExists(testDir) {
		t.Error("Directory should be removed")
	}
}

func TestRemoveAll_NonExistent(t *testing.T) {
	err := RemoveAll("/this/path/does/not/exist/killclaws_test_remove")
	if err != nil {
		t.Errorf("RemoveAll on non-existent path should not error, got: %v", err)
	}
}

func TestIsCommandAvailable(t *testing.T) {
	// "go" should be available since we're running go test
	if !IsCommandAvailable("go") {
		t.Error("IsCommandAvailable(\"go\") should be true")
	}

	// This command definitely doesn't exist
	if IsCommandAvailable("killclaws_nonexistent_command_xyz") {
		t.Error("should be false for nonexistent command")
	}
}

func TestRunCommand(t *testing.T) {
	out, err := RunCommand("go", "version")
	if err != nil {
		t.Fatalf("RunCommand(\"go\", \"version\") error: %v", err)
	}
	if out == "" {
		t.Error("Expected non-empty output from go version")
	}
}
