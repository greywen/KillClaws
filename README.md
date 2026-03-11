# 🦞🔪 KillClaws

**One command to remove all Claw AI products from your system.**

[![CI](https://github.com/greywen/KillClaws/actions/workflows/ci.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/ci.yml)
[![E2E](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml)

The Claw ecosystem (OpenClaw, QClaw, WorkBuddy, ZeroClaw, PicoClaw, KimiCLI, etc.) has exploded in popularity. Many users installed multiple products to try them out, granting extensive permissions along the way. **KillClaws** scans your system, shows what's installed, lets you pick which to remove, and cleans everything up — configs, packages, services, binaries — in one command.

## Supported Products

| Product | Developer | What Gets Removed |
|---------|-----------|-------------------|
| **OpenClaw** | Community OSS | npm/pnpm/bun package, services (launchd/systemd/schtasks), configs, macOS .app, legacy paths (~/.clawdbot, ~/.molthub, ~/clawd) |
| **QClaw** | Tencent | App, configs (~/.qclaw), Library/AppData dirs |
| **WorkBuddy** | Tencent | npm package (@tencent-ai/codebuddy-code), app, configs, Library/AppData dirs |
| **ZeroClaw** | Community | Binary, configs (~/.zeroclaw) |
| **PicoClaw** | Sipeed | Binary, configs (~/.picoclaw) |
| **KimiCLI** | Moonshot AI | pip package (kimi-cli), binary, configs (~/.kimi) |

## Supported Platforms

- **Linux** (Ubuntu, Debian, Fedora, Arch, etc.)
- **macOS** (Apple Silicon + Intel)
- **Windows** (PowerShell 5.1+)

## Quick Start

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

Or download and run manually:

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

### macOS (双击运行)

从 [Releases](https://github.com/greywen/KillClaws/releases) 下载 `killclaws.command`，双击即可在终端中运行。

> `.command` 会自动查找同目录下的 `killclaws.sh`，如果不存在则自动从 GitHub 下载最新版本。

### Windows (双击运行)

从 [Releases](https://github.com/greywen/KillClaws/releases) 下载 `killclaws.bat`，双击即可运行。

> `.bat` 会自动查找同目录下的 `killclaws.ps1`，如果不存在则自动从 GitHub 下载最新版本。

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 | iex
```

Or download and run manually:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 -OutFile killclaws.ps1
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

## Usage

### Linux / macOS (`killclaws.sh`)

```bash
./killclaws.sh              # Interactive: scan → select → remove
./killclaws.sh --scan       # Scan only, show what's installed
./killclaws.sh --yes        # Remove all detected products without prompting
./killclaws.sh --dry-run    # Preview what would be removed
./killclaws.sh --help       # Show help
```

### Windows (`killclaws.ps1`)

```powershell
.\killclaws.ps1             # Interactive: scan → select → remove
.\killclaws.ps1 -Scan       # Scan only
.\killclaws.ps1 -Yes        # Remove all without prompting
.\killclaws.ps1 -DryRun     # Preview removal actions
.\killclaws.ps1 -Help       # Show help
```

## How It Works

1. **Scan** — Detects installed Claw products by checking config directories, package managers (npm/pip), running processes, services, and platform-specific locations.
2. **Display** — Shows a numbered list of detected products with details (paths, sizes, running processes).
3. **Select** — You choose which products to remove (or use `--yes` to remove all).
4. **Remove** — Stops processes, unloads services, uninstalls packages, and deletes config/data directories.

## Post-Removal Reminders

After running KillClaws, you may still need to manually:

- **Revoke API keys** — OpenAI, Anthropic, Moonshot, etc.
- **Disconnect chat bots** — WhatsApp, Telegram, Discord, Slack
- **Remove OAuth tokens** — In platform security settings
- **Remove browser extensions** — OpenClaw Chrome extension, etc.

## License

MIT
