# 🦞🔪 KillClaws

**One command to remove all Claw AI products from your system.**

[![CI](https://github.com/greywen/KillClaws/actions/workflows/ci.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/ci.yml)
[![E2E](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml)
[![Release](https://img.shields.io/github/v/release/greywen/KillClaws)](https://github.com/greywen/KillClaws/releases/latest)

[🇨🇳 中文文档](README.zh-CN.md)

---

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

| Platform | Version | Script |
|----------|---------|--------|
| **Windows** | 10 / 11 (PowerShell 5.1+) | `killclaws.ps1` / `killclaws.bat` |
| **macOS** | Apple Silicon + Intel | `killclaws.sh` / `killclaws.command` |
| **Linux** | Ubuntu, Debian, Fedora, Arch, etc. | `killclaws.sh` |

---

## Quick Start

### 🪟 Windows

#### Method 1: Double-click (Recommended)

1. Go to [Releases](https://github.com/greywen/KillClaws/releases/latest) page, download `killclaws.bat` and `killclaws.ps1`
2. Put both files in the **same folder** (e.g. Desktop or Downloads)
3. **Double-click `killclaws.bat`** — it will launch automatically

> 💡 You can also download only `killclaws.bat` — it will auto-download `killclaws.ps1` from GitHub when it can't find it locally.

#### Method 2: One-liner in PowerShell

Open PowerShell (press `Win+X` → "Windows PowerShell") and paste:

```powershell
irm https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 | iex
```

#### Method 3: Download and run manually

```powershell
# Download
Invoke-WebRequest -Uri https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 -OutFile killclaws.ps1

# Run
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

---

### 🍎 macOS

#### Method 1: Double-click (Recommended)

1. Go to [Releases](https://github.com/greywen/KillClaws/releases/latest) page, download `killclaws.command` and `killclaws.sh`
2. Put both files in the **same folder**
3. **Double-click `killclaws.command`** — Terminal will open and run it

> 💡 First time running? macOS may show "unidentified developer" warning. Go to **System Settings → Privacy & Security** and click "Open Anyway".

> 💡 You can also download only `killclaws.command` — it will auto-download `killclaws.sh` if not found locally.

#### Method 2: One-liner in Terminal

Open Terminal (press `Cmd+Space`, type "Terminal") and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### Method 3: Download and run manually

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

### 🐧 Linux

#### Method 1: One-liner (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### Method 2: Download and run manually

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

## Usage

### Command-line Options

#### Linux / macOS (`killclaws.sh`)

```bash
./killclaws.sh              # Interactive: scan → select → remove
./killclaws.sh --scan       # Scan only, show what's installed
./killclaws.sh --yes        # Remove all detected products without prompting
./killclaws.sh --dry-run    # Preview what would be removed
./killclaws.sh --help       # Show help
```

#### Windows (`killclaws.ps1`)

```powershell
.\killclaws.ps1             # Interactive: scan → select → remove
.\killclaws.ps1 -Scan       # Scan only
.\killclaws.ps1 -Yes        # Remove all without prompting
.\killclaws.ps1 -DryRun     # Preview removal actions
.\killclaws.ps1 -Help       # Show help
```

### Step-by-step Walkthrough

#### Step 1: Scan

Run the script. It automatically scans for all installed Claw products:

```
KillClaws v2.3.1 — Windows

Scanning for Claw products...

Found 2 Claw product(s):

  [1] OpenClaw
      dir  ~/.openclaw (58.6 MB)
      pkg  npm: openclaw
      svc  Scheduled Task: OpenClaw Gateway

  [2] KimiCLI
      dir  ~/.kimi (2.1 MB)
      pkg  pip: kimi-cli
```

#### Step 2: Select

You'll be prompted to choose which products to remove:

```
Select products to remove (comma-separated numbers, all, or q to quit):
```

| Input | Meaning |
|-------|---------|
| `1` | Remove product #1 only |
| `1,2` | Remove products #1 and #2 |
| `all` | Remove all detected products |
| `q` | Quit without removing |

#### Step 3: Confirm

Before removing, you'll see a confirmation prompt:

```
Remove OpenClaw, KimiCLI ? [y/N]
```

Type `y` to proceed, or anything else to cancel.

#### Step 4: Done

```
  ✓ Stopped process openclaw (PID 12345)
  ✓ Removed scheduled task: OpenClaw Gateway
  ✓ Uninstalled: npm rm -g openclaw
  ✓ Removed ~/.openclaw
  ✓ Uninstalled: pip uninstall -y kimi-cli
  ✓ Removed ~/.kimi

Done! Removed 2 product(s).

Reminders:
  - Revoke API keys (OpenAI, Anthropic, Moonshot, etc.)
  - Remove browser extensions
  - Disconnect chat bot integrations
```

---

## How It Works

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Scan   │ ──▸ │ Display │ ──▸ │ Select  │ ──▸ │ Remove  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

1. **Scan** — Checks config directories (`~/.openclaw`, `~/.qclaw`, etc.), package managers (npm/pip), running processes, system services, and platform-specific locations (macOS `~/Library`, Windows `AppData`).
2. **Display** — Shows a numbered list with details: directory sizes, installed packages, active processes, registered services.
3. **Select** — Choose which products to remove (individual, multiple, or all). Use `--yes` to skip this step.
4. **Remove** — Stops running processes, unloads services (launchd/systemd/schtasks), uninstalls packages, deletes config and data directories.

---

## Post-Removal Reminders

After running KillClaws, you may still need to manually:

- **Revoke API keys** — OpenAI, Anthropic, Moonshot, etc.
- **Disconnect chat bots** — WhatsApp, Telegram, Discord, Slack
- **Remove OAuth tokens** — In platform security settings
- **Remove browser extensions** — OpenClaw Chrome extension, etc.

---

## Troubleshooting

### Windows: "Running scripts is disabled on this system"

This happens when PowerShell's execution policy blocks scripts.

**Solution:** Use `killclaws.bat` (double-click) — it automatically bypasses this restriction. Or run:

```powershell
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

### Windows: "killclaws.ps1 opens in Notepad"

`.ps1` files are associated with Notepad by default on Windows.

**Solution:** Don't double-click `.ps1` directly. Use `killclaws.bat` instead — it's the double-click launcher.

### macOS: "unidentified developer" warning

macOS Gatekeeper blocks files from unknown developers.

**Solution:** Go to **System Settings → Privacy & Security**, find the blocked file, and click **Open Anyway**.

### macOS: "permission denied" when running killclaws.sh

The script doesn't have execute permission.

**Solution:**

```bash
chmod +x killclaws.sh
./killclaws.sh
```

### Linux: "curl: command not found"

curl is not installed on your system.

**Solution:**

```bash
# Ubuntu/Debian
sudo apt install curl

# Fedora
sudo dnf install curl

# Arch
sudo pacman -S curl
```

### Nothing was detected

KillClaws looks for specific config directories and packages. If a product was already partially removed, it may not be detected. Check manually:

```bash
# Linux/macOS
ls -la ~/.openclaw ~/.qclaw ~/.workbuddy ~/.zeroclaw ~/.picoclaw ~/.kimi 2>/dev/null
```

```powershell
# Windows
Get-ChildItem ~\.openclaw, ~\.qclaw, ~\.workbuddy, ~\.zeroclaw, ~\.picoclaw, ~\.kimi -ErrorAction SilentlyContinue
```

---

## File Description

| File | Description |
|------|-------------|
| `killclaws.sh` | Main script for Linux/macOS |
| `killclaws.ps1` | Main script for Windows |
| `killclaws.bat` | Windows double-click launcher (runs .ps1) |
| `killclaws.command` | macOS double-click launcher (runs .sh) |
| `killclaws-*.zip` | Archive containing all scripts |
| `killclaws-*.tar.gz` | Archive containing all scripts |
| `checksums.txt` | SHA256 checksums for verification |

---

## License

MIT
