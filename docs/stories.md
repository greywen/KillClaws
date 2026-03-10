# KillClaws — Epics & Stories

## Epic 1: Project Foundation

### Story 1.1: Go Project Skeleton
- Initialize go.mod with module path `github.com/greywen/KillClaws`
- Create directory structure: cmd/, internal/, docs/, scripts/, .github/workflows/
- Add .gitignore for Go projects
- **AC**: `go build ./...` succeeds

### Story 1.2: CI Pipeline
- GitHub Actions workflow for build + unit test on 3 platforms
- Matrix: ubuntu-latest, macos-latest, windows-latest
- **AC**: CI green on all 3 platforms

---

## Epic 2: Core Detection Engine

### Story 2.1: Type Definitions
- Define `ClawProduct` struct (name, detected, paths, services, processes, disk usage)
- Define `ScanResult` containing all products
- Define `Platform` interface for OS-specific operations

### Story 2.2: Platform Abstraction
- Implement file existence checks, process listing, service queries per OS
- Windows: registry, schtasks, tasklist
- macOS: launchctl, plist, /Applications
- Linux: systemctl, systemd service files

### Story 2.3: OpenClaw Detector (P0)
- Check: processes, ~/.openclaw/, npm global, services, /Applications/OpenClaw.app, Docker, legacy paths
- **AC**: Correctly detects OpenClaw on all 3 platforms

### Story 2.4: QClaw Detector (P1)
- Check: /Applications/QClaw.app, ~/.qclaw/, processes
- **AC**: Correctly detects QClaw on macOS

### Story 2.5: WorkBuddy Detector (P1)
- Check: install dirs, %APPDATA%\WorkBuddy, /Applications/WorkBuddy.app
- **AC**: Correctly detects WorkBuddy

### Story 2.6: ZeroClaw + PicoClaw Detectors (P2)
- Check: binary in PATH, ~/.zeroclaw/, ~/.picoclaw/
- **AC**: Correctly detects both

---

## Epic 3: Uninstall Engine

### Story 3.1: Process Killer
- Find and stop Claw processes by name
- Graceful (SIGTERM/taskkill) → wait 5s → force (SIGKILL/taskkill /F)
- **AC**: All Claw processes terminated

### Story 3.2: Service Remover
- macOS: launchctl bootout + remove plist
- Linux: systemctl disable --now + remove service file + daemon-reload
- Windows: schtasks /Delete
- **AC**: No Claw services remain

### Story 3.3: File Cleaner
- Remove all detected directories and files
- Platform-specific: macOS ~/Library/ cleanup, Windows %APPDATA% cleanup
- **AC**: All Claw directories removed

### Story 3.4: Package Uninstaller
- npm rm -g openclaw (detect npm/pnpm/bun)
- pip uninstall kimi-cli (if installed)
- **AC**: No Claw packages in global installs

### Story 3.5: Docker Cleaner (Optional)
- Find and remove openclaw Docker containers + images
- **AC**: No openclaw Docker artifacts

---

## Epic 4: CLI Interface

### Story 4.1: Scan Command
- `killclaws scan` — display detected products
- `killclaws scan --json` — JSON output
- **AC**: Clean output format, exit 0

### Story 4.2: Uninstall Command (Default)
- `killclaws` — interactive scan → confirm → uninstall → verify
- `killclaws --yes` — skip confirmation
- `killclaws --dry-run` — preview only
- **AC**: Full flow works end-to-end

### Story 4.3: Selective Uninstall
- `--only openclaw,qclaw`
- `--exclude zeroclaw`
- **AC**: Only specified products affected

### Story 4.4: Verbose + Version + Help
- `--verbose` flag for detailed logging
- `--version` flag
- `--help` with usage examples
- **AC**: All flags work correctly

---

## Epic 5: Testing & CI

### Story 5.1: Unit Tests
- Test each detector with mocked file system
- Test platform detection logic
- **AC**: >80% coverage on core modules

### Story 5.2: E2E Tests (GitHub Actions)
- Install OpenClaw → run killclaws → verify clean removal
- Matrix: ubuntu-latest, macos-latest, windows-latest
- **AC**: All E2E tests green

### Story 5.3: Cross-Compilation + Release
- Build binaries for linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64
- GitHub Release with artifacts
- **AC**: All binaries compile and run

---

## Epic 6: Documentation

### Story 6.1: README
- Installation instructions
- Usage examples
- Supported products table
- **AC**: README renders correctly on GitHub
