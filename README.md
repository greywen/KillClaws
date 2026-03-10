# 🦞🔪 KillClaws

**One command to remove all Claw products from your system.**

[![CI](https://github.com/greywen/KillClaws/actions/workflows/ci.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/ci.yml)
[![E2E](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml)

The Claw ecosystem (OpenClaw, QClaw, WorkBuddy, ArkClaw, KimiClaw, etc.) has exploded since January 2026. Many users installed multiple products to try them out, granting extensive permissions. KillClaws scans your system for all installed Claw products and removes them cleanly in one command.

## Supported Products

| Product | Developer | Detection | Uninstall |
|---------|-----------|-----------|-----------|
| **OpenClaw** | Community OSS | ✅ Full | ✅ Full (npm + services + configs + macOS App + legacy paths) |
| **QClaw** | Tencent | ✅ Full | ✅ Full (app + configs) |
| **WorkBuddy** | Tencent | ✅ Full | ✅ Full (app + configs) |
| **ZeroClaw** | Community | ✅ Full | ✅ Full (binary + configs) |
| **PicoClaw** | Sipeed | ✅ Full | ✅ Full (binary + configs) |
| **KimiCLI** | Moonshot AI | ✅ Full | ✅ Full (pip + configs) |

## Supported Platforms

- **macOS** (Apple Silicon + Intel)
- **Linux** (Ubuntu, Debian, Fedora, Arch, etc.)
- **Windows** (native + WSL2)

## Installation

### Download Binary

Download from [GitHub Releases](https://github.com/greywen/KillClaws/releases).

### Build from Source

```bash
go install github.com/greywen/KillClaws/cmd/killclaws@latest
```

Or clone and build:

```bash
git clone https://github.com/greywen/KillClaws.git
cd KillClaws
go build -o killclaws ./cmd/killclaws
```

## Usage

### Scan (see what's installed)

```bash
killclaws scan              # Human-readable output
killclaws scan --json       # JSON output for automation
```

### Remove all Claw products

```bash
killclaws                   # Interactive: scan → confirm → remove
killclaws --yes             # Skip confirmation
killclaws --dry-run         # Preview only, change nothing
```

### Selective removal

```bash
killclaws --only openclaw           # Only remove OpenClaw
killclaws --only openclaw,qclaw     # Remove specific products
killclaws --exclude zeroclaw        # Remove all except ZeroClaw
```

### Other

```bash
killclaws --verbose         # Detailed output
killclaws --version         # Show version
killclaws help              # Show help
```

## What Gets Removed

### OpenClaw (most complex)

| Artifact | Path |
|----------|------|
| State + config | `~/.openclaw/` |
| Legacy ClawdBot | `~/.clawdbot/` |
| Legacy MoltBot | `~/.molthub/` |
| Legacy workspace | `~/clawd/` |
| npm global package | `openclaw` |
| macOS App | `/Applications/OpenClaw.app` |
| macOS LaunchAgent | `~/Library/LaunchAgents/ai.openclaw.gateway.plist` |
| Linux systemd | `~/.config/systemd/user/openclaw-gateway.service` |
| Windows schtasks | `OpenClaw Gateway` scheduled task |

### QClaw / WorkBuddy

| Artifact | Path |
|----------|------|
| macOS App | `/Applications/QClaw.app` or `/Applications/WorkBuddy.app` |
| Config | `~/.qclaw/` or `~/.workbuddy/` |
| macOS Library | `~/Library/Application Support/QClaw/` etc. |
| Windows data | `%APPDATA%\QClaw\` etc. |

### ZeroClaw / PicoClaw

| Artifact | Path |
|----------|------|
| Config | `~/.zeroclaw/` or `~/.picoclaw/` |
| Binary | In `$PATH` |

## Post-Removal Reminders

After running KillClaws, you may still need to manually:

- **Revoke API keys** — OpenAI, Anthropic, Moonshot, etc.
- **Disconnect chat bots** — WhatsApp, Telegram, Discord, Slack
- **Remove OAuth tokens** — In platform security settings
- **Remove browser extensions** — OpenClaw Chrome extension

## Development

```bash
# Build
go build -o killclaws ./cmd/killclaws

# Test
go test ./... -v

# Cross-compile
GOOS=linux GOARCH=amd64 go build -o dist/killclaws-linux-amd64 ./cmd/killclaws
```

## License

MIT
