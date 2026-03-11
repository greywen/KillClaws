# 🦞🔪 KillClaws

**一条命令，卸载系统中所有 Claw AI 产品。**

[![CI](https://github.com/greywen/KillClaws/actions/workflows/ci.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/ci.yml)
[![E2E](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml/badge.svg)](https://github.com/greywen/KillClaws/actions/workflows/e2e.yml)
[![Release](https://img.shields.io/github/v/release/greywen/KillClaws)](https://github.com/greywen/KillClaws/releases/latest)

[🇬🇧 English](README.md)

---

Claw 生态（OpenClaw、QClaw、WorkBuddy、ZeroClaw、PicoClaw、KimiCLI 等）近期爆火。很多用户只是尝鲜，却给了大量权限，导致一系列安全隐患。**KillClaws** 一键扫描系统中已安装的 Claw 产品，显示详细信息，让你选择要卸载哪些，然后彻底清理——配置文件、包管理器安装包、后台服务、二进制文件——全部搞定。

## 支持的产品

| 产品 | 开发者 | 清理内容 |
|------|--------|----------|
| **OpenClaw** | 社区开源 | npm/pnpm/bun 包、服务（launchd/systemd/计划任务）、配置文件、macOS .app、旧路径（~/.clawdbot、~/.molthub、~/clawd） |
| **QClaw** | 腾讯 | 应用、配置文件（~/.qclaw）、Library/AppData 目录 |
| **WorkBuddy** | 腾讯 | npm 包（@tencent-ai/codebuddy-code）、应用、配置文件、Library/AppData 目录 |
| **ZeroClaw** | 社区 | 二进制文件、配置文件（~/.zeroclaw） |
| **PicoClaw** | 矽速科技 | 二进制文件、配置文件（~/.picoclaw） |
| **KimiCLI** | 月之暗面 | pip 包（kimi-cli）、二进制文件、配置文件（~/.kimi） |

## 支持的平台

| 平台 | 版本 | 脚本 |
|------|------|------|
| **Windows** | 10 / 11（PowerShell 5.1+） | `killclaws.ps1` / `killclaws.bat` |
| **macOS** | Apple Silicon + Intel | `killclaws.sh` / `killclaws.command` |
| **Linux** | Ubuntu、Debian、Fedora、Arch 等 | `killclaws.sh` |

---

## 快速开始

### 🪟 Windows

#### 方法一：双击运行（推荐）

1. 前往 [Releases](https://github.com/greywen/KillClaws/releases/latest) 页面，下载 `killclaws.bat` 和 `killclaws.ps1`
2. 将两个文件放在**同一目录**下（例如桌面或下载文件夹）
3. **双击 `killclaws.bat`** — 自动启动运行

> 💡 也可以只下载 `killclaws.bat`，如果同目录下没有 `killclaws.ps1`，它会自动从 GitHub 下载最新版本。

#### 方法二：PowerShell 一行命令

打开 PowerShell（按 `Win+X` → 选择 "Windows PowerShell"），粘贴以下命令：

```powershell
irm https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 | iex
```

#### 方法三：手动下载运行

```powershell
# 下载
Invoke-WebRequest -Uri https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 -OutFile killclaws.ps1

# 运行
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

---

### 🍎 macOS

#### 方法一：双击运行（推荐）

1. 前往 [Releases](https://github.com/greywen/KillClaws/releases/latest) 页面，下载 `killclaws.command` 和 `killclaws.sh`
2. 将两个文件放在**同一目录**下
3. **双击 `killclaws.command`** — 终端会自动打开并运行

> 💡 首次运行可能提示"无法验证开发者"。前往 **系统设置 → 隐私与安全性**，点击"仍要打开"即可。

> 💡 也可以只下载 `killclaws.command`，如果同目录下没有 `killclaws.sh`，它会自动从 GitHub 下载。

#### 方法二：终端一行命令

打开终端（按 `Cmd+Space`，输入 "Terminal"），粘贴以下命令：

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### 方法三：手动下载运行

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

### 🐧 Linux

#### 方法一：一行命令（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh | bash
```

#### 方法二：手动下载运行

```bash
curl -fsSL -o killclaws.sh https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh
chmod +x killclaws.sh
./killclaws.sh
```

---

## 使用说明

### 命令行参数

#### Linux / macOS（`killclaws.sh`）

```bash
./killclaws.sh              # 交互模式：扫描 → 选择 → 卸载
./killclaws.sh --scan       # 仅扫描，显示已安装的产品
./killclaws.sh --yes        # 不询问，直接卸载全部
./killclaws.sh --dry-run    # 预览模式，不实际删除
./killclaws.sh --help       # 显示帮助
```

#### Windows（`killclaws.ps1`）

```powershell
.\killclaws.ps1             # 交互模式：扫描 → 选择 → 卸载
.\killclaws.ps1 -Scan       # 仅扫描
.\killclaws.ps1 -Yes        # 不询问，直接卸载全部
.\killclaws.ps1 -DryRun     # 预览模式
.\killclaws.ps1 -Help       # 显示帮助
```

### 使用流程详解

#### 第一步：扫描

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

#### 第二步：选择

系统会提示你选择要卸载的产品：

```
Select products to remove (comma-separated numbers, all, or q to quit):
```

| 输入 | 含义 |
|------|------|
| `1` | 只卸载第 1 个产品 |
| `1,2` | 卸载第 1 和第 2 个 |
| `all` | 卸载所有检测到的产品 |
| `q` | 退出，不做任何操作 |

#### 第三步：确认

卸载前会显示确认提示：

```
Remove OpenClaw, KimiCLI ? [y/N]
```

输入 `y` 确认卸载，输入其他内容或直接回车取消。

#### 第四步：完成

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

## 工作原理

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  扫描   │ ──▸ │  展示   │ ──▸ │  选择   │ ──▸ │  卸载   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
```

1. **扫描** — 检查配置目录（`~/.openclaw`、`~/.qclaw` 等）、包管理器（npm/pip）、运行中的进程、系统服务以及系统特定路径（macOS `~/Library`、Windows `AppData`）。
2. **展示** — 以编号列表展示详细信息：目录大小、已安装的包、活跃进程、注册的服务。
3. **选择** — 选择要卸载的产品（单个、多个或全部）。使用 `--yes` 可跳过此步骤。
4. **卸载** — 停止运行中的进程、卸载服务（launchd/systemd/计划任务）、卸载软件包、删除配置和数据目录。

---

## 卸载后注意事项

运行 KillClaws 后，你可能还需要手动：

- **撤销 API 密钥** — OpenAI、Anthropic、Moonshot 等
- **断开聊天机器人** — WhatsApp、Telegram、Discord、Slack
- **移除 OAuth 令牌** — 在各平台安全设置中操作
- **删除浏览器扩展** — OpenClaw Chrome 扩展等

---

## 常见问题

### Windows："无法加载文件，因为在此系统上禁止运行脚本"

PowerShell 执行策略阻止了脚本运行。

**解决方法：** 使用 `killclaws.bat`（双击运行）——它会自动绕过此限制。或者运行：

```powershell
powershell -ExecutionPolicy Bypass -File killclaws.ps1
```

### Windows：双击 killclaws.ps1 打开了记事本

Windows 默认将 `.ps1` 文件关联到记事本。

**解决方法：** 不要直接双击 `.ps1` 文件。请使用 `killclaws.bat`——它是专门的双击启动器。

### macOS：提示"无法验证开发者"

macOS 看门人会阻止来自未知开发者的文件。

**解决方法：** 前往 **系统设置 → 隐私与安全性**，找到被阻止的文件，点击"仍要打开"。

### macOS：运行 killclaws.sh 提示"permission denied"

脚本没有执行权限。

**解决方法：**

```bash
chmod +x killclaws.sh
./killclaws.sh
```

### Linux："curl: command not found"

系统未安装 curl。

**解决方法：**

```bash
# Ubuntu/Debian
sudo apt install curl

# Fedora
sudo dnf install curl

# Arch
sudo pacman -S curl
```

### 没有检测到任何产品

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

## 文件说明

| 文件 | 说明 |
|------|------|
| `killclaws.sh` | Linux/macOS 主脚本 |
| `killclaws.ps1` | Windows 主脚本 |
| `killclaws.bat` | Windows 双击启动器（运行 .ps1） |
| `killclaws.command` | macOS 双击启动器（运行 .sh） |
| `killclaws-*.zip` | 包含所有脚本的压缩包 |
| `killclaws-*.tar.gz` | 包含所有脚本的压缩包 |
| `checksums.txt` | SHA256 校验和 |

---

## 许可证

MIT
