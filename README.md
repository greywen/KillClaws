# 🦞🔪 KillClaws

**One command to remove all Claw AI products from your system.**

**一条命令，卸载系统中所有 Claw AI 产品。**

[![CI](https://github.com/greywen/KillClaws/actions/workflows/ci.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/ci.yml)
[![E2E](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml)
[![Release](https://img.shields.io/github/v/release/greywen/KillClaws)](https://github.com/greywen/KillClaws/releases/latest)

---

The Claw ecosystem (OpenClaw, QClaw, WorkBuddy, ZeroClaw, PicoClaw, KimiCLI, etc.) has exploded in popularity. Many users installed multiple products to try them out, granting extensive permissions along the way. **KillClaws** scans your system, shows what's installed, lets you pick which to remove, and cleans everything up — configs, packages, services, binaries — in one command.

Claw 生态（OpenClaw、QClaw、WorkBuddy、ZeroClaw、PicoClaw、KimiCLI 等）近期爆火。很多用户只是尝鲜，却给了大量权限，导致一系列安全隐患。**KillClaws** 一键扫描系统中已安装的 Claw 产品，显示详细信息，让你选择要卸载哪些，然后彻底清理——配置文件、包管理器安装包、后台服务、二进制文件——全部搞定。

---

## Supported Products / 支持的产品

| Product / 产品 | Developer / 开发者 | What Gets Removed / 清理内容 |
|---|---|---|
| **OpenClaw** | Community OSS | npm/pnpm/bun package, services (launchd/systemd/schtasks), configs, macOS .app, legacy paths (~/.clawdbot, ~/.molthub, ~/clawd) |
| **QClaw** | Tencent | App, configs (~/.qclaw), Library/AppData dirs |
| **WorkBuddy** | Tencent | npm package (@tencent-ai/codebuddy-code), app, configs, Library/AppData dirs |
| **ZeroClaw** | Community | Binary, configs (~/.zeroclaw) |
| **PicoClaw** | Sipeed | Binary, configs (~/.picoclaw) |
| **KimiCLI** | Moonshot AI | pip package (kimi-cli), binary, configs (~/.kimi) |

## Supported Platforms / 支持的平台

| Platform / 平台 | Version / 版本 | Script / 脚本 |
|---|---|---|
| **Windows** | 10 / 11 (PowerShell 5.1+) | `killclaws.ps1` / `killclaws.bat` |
| **macOS** | Apple Silicon + Intel | `killclaws.sh` / `killclaws.command` |
| **Linux** | Ubuntu, Debian, Fedora, Arch, etc. | `killclaws.sh` |

---

## Quick Start / 快速开始

### 🪟 Windows

#### Method 1: Double-click / 方法一：双击运行（推荐）

1. Go to [Releases](https://github.com/greywen/KillClaws/releases/latest) page, download `killclaws.bat` and `killclaws.ps1`

   前往 [Releases](https://github.com/greywen/KillClaws/releases/latest) 页面，下载 `killclaws.bat` 和 `killclaws.ps1`

2. Put both files in the **same folder** (e.g. Desktop or Downloads)

   将两个文件放在**同一目录**下（例如桌面或下载文件夹）

3. **Double-click `killclaws.bat`** — it will launch automatically

   **双击 `killclaws.bat`** — 自动启动运行

> 💡 You can also download only `killclaws.bat` — it will auto-download `killclaws.ps1` from GitHub when it can't find it locally.
>
> 💡 也可以只下载 `killclaws.bat`，如果同目录下没有 `killclaws.ps1`，它会自动从 GitHub 下载最新版本。

#### Method 2: One-liner in PowerShell / 方法二：PowerShell 一行命令

Open PowerShell (press `Win+X` → "Windows PowerShell") and paste:

打开 PowerShell（按 `Win+X` → "Windows PowerShell"），粘贴以下命令：

```powershell
irm https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 | iex
```

#### Method 3: Download and run manually / 方法三：手动下载运行

```powershell
# Download / 下载
Invoke-WebRequest -Uri https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 -OutFile killclaws.ps1

# Run / 运行
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

---

### 🍎 macOS

#### Method 1: Double-click / 方法一：双击运行（推荐）

1. Go to [Releases](https://github.com/greywen/KillClaws/releases/latest) page, download `killclaws.command` and `killclaws.sh`

   前往 [Releases](https://github.com/greywen/KillClaws/releases/latest) 页面，下载 `killclaws.command` 和 `killclaws.sh`

2. Put both files in the **same folder**

   将两个文件放在**同一目录**下

3. **Double-click `killclaws.command`** — Terminal will open and run it

   **双击 `killclaws.command`** — 终端会自动打开并运行

> 💡 First time running? macOS may show "unidentified developer" warning. Go to **System Settings → Privacy & Security** and click "Open Anyway".
>
> 💡 首次运行可能提示"无法验证开发者"。前往**系统设置 → 隐私与安全性**，点击"仍要打开"即可。

> 💡 You can also download only `killclaws.command` — it will auto-download `killclaws.sh` if not found locally.
>
> 💡 也可以只下载 `killclaws.command`，如果同目录下没有 `killclaws.sh`，它会自动从 GitHub 下载。

#### Method 2: One-liner in Terminal / 方法二：终端一行命令

Open Terminal (press `Cmd+Space`, type "Terminal") and paste:

打开终端（按 `Cmd+Space`，输入 "Terminal"），粘贴以下命令：

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### Method 3: Download and run manually / 方法三：手动下载运行

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

### 🐧 Linux

#### Method 1: One-liner (recommended) / 方法一：一行命令（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### Method 2: Download and run manually / 方法二：手动下载运行

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

## Usage / 使用说明

### Command-line Options / 命令行参数

#### Linux / macOS (`killclaws.sh`)

```bash
./killclaws.sh              # Interactive mode / 交互模式：扫描 → 选择 → 卸载
./killclaws.sh --scan       # Scan only / 仅扫描，显示已安装的产品
./killclaws.sh --yes        # Remove all without prompting / 不询问，直接卸载全部
./killclaws.sh --dry-run    # Preview removal / 预览模式，不实际删除
./killclaws.sh --help       # Show help / 显示帮助
```

#### Windows (`killclaws.ps1`)

```powershell
.\killclaws.ps1             # Interactive mode / 交互模式：扫描 → 选择 → 卸载
.\killclaws.ps1 -Scan       # Scan only / 仅扫描
.\killclaws.ps1 -Yes        # Remove all without prompting / 不询问，直接卸载全部
.\killclaws.ps1 -DryRun     # Preview removal / 预览模式
.\killclaws.ps1 -Help       # Show help / 显示帮助
```

### Step-by-step Walkthrough / 使用流程详解

#### Step 1: Scan / 第一步：扫描

Run the script. It automatically scans for all installed Claw products:

运行脚本后会自动扫描所有已安装的 Claw 产品：

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

#### Step 2: Select / 第二步：选择

You'll be prompted to choose which products to remove:

系统会提示你选择要卸载的产品：

```
Select products to remove (comma-separated numbers, all, or q to quit):
```

| Input / 输入 | Meaning / 含义 |
|---|---|
| `1` | Remove product #1 only / 只卸载第 1 个产品 |
| `1,2` | Remove products #1 and #2 / 卸载第 1 和第 2 个 |
| `all` | Remove all detected products / 卸载所有检测到的产品 |
| `q` | Quit without removing / 退出，不做任何操作 |

#### Step 3: Confirm / 第三步：确认

Before removing, you'll see a confirmation prompt:

卸载前会显示确认提示：

```
Remove OpenClaw, KimiCLI ? [y/N]
```

Type `y` to proceed, or anything else to cancel.

输入 `y` 确认卸载，输入其他内容或直接回车取消。

#### Step 4: Done / 第四步：完成

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

## How It Works / 工作原理

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Scan   │ ──▸ │ Display │ ──▸ │ Select  │ ──▸ │ Remove  │
│  扫描   │     │  展示   │     │  选择   │     │  卸载   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

1. **Scan / 扫描** — Checks config directories (`~/.openclaw`, `~/.qclaw`, etc.), package managers (npm/pip), running processes, system services, and platform-specific locations (macOS `~/Library`, Windows `AppData`).

   检查配置目录、包管理器（npm/pip）、运行中的进程、系统服务以及系统特定路径（macOS `~/Library`、Windows `AppData`）。

2. **Display / 展示** — Shows a numbered list with details: directory sizes, installed packages, active processes, registered services.

   以编号列表展示详细信息：目录大小、已安装的包、活跃进程、注册的服务。

3. **Select / 选择** — Choose which products to remove (individual, multiple, or all). Use `--yes` to skip this step.

   选择要卸载的产品（单个、多个或全部）。使用 `--yes` 可跳过此步骤。

4. **Remove / 卸载** — Stops running processes, unloads services (launchd/systemd/schtasks), uninstalls packages, deletes config and data directories.

   停止运行中的进程、卸载服务（launchd/systemd/schtasks）、卸载软件包、删除配置和数据目录。

---

## Post-Removal Reminders / 卸载后注意事项

After running KillClaws, you may still need to manually:

运行 KillClaws 后，你可能还需要手动：

- **Revoke API keys / 撤销 API 密钥** — OpenAI, Anthropic, Moonshot, etc.
- **Disconnect chat bots / 断开聊天机器人** — WhatsApp, Telegram, Discord, Slack
- **Remove OAuth tokens / 移除 OAuth 令牌** — In platform security settings / 在平台安全设置中操作
- **Remove browser extensions / 删除浏览器扩展** — OpenClaw Chrome extension, etc.

---

## Troubleshooting / 常见问题

### Windows: "Running scripts is disabled on this system"

This happens when PowerShell's execution policy blocks scripts.

当 PowerShell 执行策略阻止脚本运行时会出现此错误。

**Solution / 解决方法:** Use `killclaws.bat` (double-click) — it automatically bypasses this restriction. Or run:

使用 `killclaws.bat`（双击运行）——它会自动绕过此限制。或者运行：

```powershell
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

### Windows: "killclaws.ps1 opens in Notepad"

`.ps1` files are associated with Notepad by default on Windows.

Windows 默认将 `.ps1` 文件关联到记事本。

**Solution / 解决方法:** Don't double-click `.ps1` directly. Use `killclaws.bat` instead — it's the double-click launcher.

不要直接双击 `.ps1` 文件。请使用 `killclaws.bat`——它是专门的双击启动器。

### macOS: "unidentified developer" warning

macOS Gatekeeper blocks files from unknown developers.

macOS 看门人会阻止来自未知开发者的文件。

**Solution / 解决方法:** Go to **System Settings → Privacy & Security**, find the blocked file, and click **Open Anyway**.

前往**系统设置 → 隐私与安全性**，找到被阻止的文件，点击**仍要打开**。

### macOS: "permission denied" when running killclaws.sh

The script doesn't have execute permission.

脚本没有执行权限。

**Solution / 解决方法:**

```bash
chmod +x killclaws.sh
./killclaws.sh
```

### Linux: "curl: command not found"

curl is not installed on your system.

系统未安装 curl。

**Solution / 解决方法:**

```bash
# Ubuntu/Debian
sudo apt install curl

# Fedora
sudo dnf install curl

# Arch
sudo pacman -S curl
```

### Nothing was detected / 没有检测到任何产品

KillClaws looks for specific config directories and packages. If a product was already partially removed, it may not be detected. Check manually:

KillClaws 通过特定的配置目录和安装包来检测。如果产品已被部分卸载，可能无法检测到。可以手动检查：

```bash
# Linux/macOS
ls -la ~/.openclaw ~/.qclaw ~/.workbuddy ~/.zeroclaw ~/.picoclaw ~/.kimi 2>/dev/null
```

```powershell
# Windows
Get-ChildItem ~\.openclaw, ~\.qclaw, ~\.workbuddy, ~\.zeroclaw, ~\.picoclaw, ~\.kimi -ErrorAction SilentlyContinue
```

---

## File Description / 文件说明

| File / 文件 | Description / 说明 |
|---|---|
| `killclaws.sh` | Main script for Linux/macOS / Linux/macOS 主脚本 |
| `killclaws.ps1` | Main script for Windows / Windows 主脚本 |
| `killclaws.bat` | Windows double-click launcher (runs .ps1) / Windows 双击启动器（运行 .ps1） |
| `killclaws.command` | macOS double-click launcher (runs .sh) / macOS 双击启动器（运行 .sh） |
| `killclaws-*.zip` | Archive containing all scripts / 包含所有脚本的压缩包 |
| `killclaws-*.tar.gz` | Archive containing all scripts / 包含所有脚本的压缩包 |
| `checksums.txt` | SHA256 checksums for verification / SHA256 校验和 |

---

## License / 许可证

MIT
