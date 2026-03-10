# KillClaws — Product Requirements Document

## 1. Overview

**Product Name**: KillClaws
**Version**: 1.0.0
**Type**: Cross-platform CLI tool
**Language**: Go

### 1.1 Problem Statement

The "Claw" ecosystem (OpenClaw, QClaw, WorkBuddy, ArkClaw, KimiClaw, JVSClaw, ZeroClaw, PicoClaw, MaxClaw) has exploded in popularity since January 2026. Many users installed multiple Claw products to try them out, granting extensive system permissions. Now they want to cleanly remove all traces but face:

1. **Hidden background services** — OpenClaw installs systemd/launchd/schtasks services that persist after deletion
2. **Scattered config files** — `~/.openclaw/`, `~/.qclaw/`, `~/.zeroclaw/`, legacy `~/.clawdbot/`, `~/.molthub/`, `~/clawd/`
3. **Multiple install methods** — npm global, curl scripts, .dmg, .exe installers, Docker
4. **No unified uninstall** — Each product has different removal steps; some lack uninstall commands entirely

### 1.2 Solution

A single CLI binary that:
- **Scans** the system for all installed Claw products
- **Reports** what was found (files, services, processes, disk usage)
- **Removes** everything with one command
- **Verifies** clean removal

### 1.3 Target Users

- Developers who tried multiple Claw products
- Sysadmins managing team machines
- Privacy-conscious users wanting complete cleanup

## 2. Supported Products

| Priority | Product | Developer | Install Type | Platforms |
|----------|---------|-----------|-------------|-----------|
| P0 | OpenClaw | Community OSS | npm global + service + macOS App | macOS, Linux, Windows(WSL2) |
| P1 | QClaw | Tencent | .dmg installer | macOS (Windows TBD) |
| P1 | WorkBuddy | Tencent | Desktop installer | Windows, macOS |
| P2 | ZeroClaw | Community OSS | Single binary | All |
| P2 | PicoClaw | Sipeed | Single binary | All |
| P3 | KimiClaw | Moonshot AI | Cloud (BYOC has local OpenClaw) | N/A (cloud) |
| P3 | ArkClaw | ByteDance | Cloud SaaS | N/A (cloud) |
| P3 | JVSClaw | Alibaba Cloud | Cloud + mobile app | N/A (cloud) |
| P3 | MaxClaw | MiniMax | Cloud SaaS | N/A (cloud) |

## 3. Supported Platforms

- **macOS** (Apple Silicon + Intel) — primary
- **Linux** (Ubuntu/Debian, Fedora/RHEL, Arch) — primary
- **Windows** (native + WSL2) — primary

## 4. Functional Requirements

### 4.1 Scan Mode (`killclaws scan`)

- Detect all installed Claw products by checking:
  - Running processes
  - File system paths (config dirs, app bundles, binaries)
  - System services (launchd, systemd, schtasks)
  - npm global packages
  - Docker containers/images
- Output: human-readable table or `--json` for automation
- **Must not modify anything**

### 4.2 Uninstall Mode (`killclaws` / `killclaws --yes`)

Execution order:
1. Scan for all installed products
2. Display findings and ask for confirmation (unless `--yes`)
3. Stop running processes (graceful → force)
4. Remove system services
5. Uninstall packages (npm, pip)
6. Delete files and directories
7. Clean platform-specific artifacts (registry, plist, etc.)
8. Verify removal by re-scanning
9. Display summary + manual action reminders

### 4.3 Selective Mode

- `--only <product,...>` — only uninstall specified products
- `--exclude <product,...>` — skip specified products
- `--dry-run` — show what would be removed without doing it

### 4.4 Safety

- Never delete files outside known Claw paths
- Prompt before destructive actions (overridable with `--yes`)
- `--dry-run` mode for preview
- Verbose logging with `--verbose`

## 5. Non-Functional Requirements

- Single static binary, zero runtime dependencies
- < 10MB binary size
- Scan completes in < 5 seconds
- Full uninstall completes in < 30 seconds
- Exit code 0 on success, non-zero on failure

## 6. Out of Scope (v1.0)

- GUI interface
- Auto-update mechanism
- Cloud account cleanup (API key revocation, OAuth token revocation)
- Browser extension removal (Chrome/Firefox OpenClaw extension)
- VS Code extension removal

## 7. Success Metrics

- All CI E2E tests pass on macOS, Linux, Windows
- Zero files remaining after uninstall on all platforms
- < 10MB binary size
