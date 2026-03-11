# KillClaws — One command to remove all Claw AI products (Windows)
# Usage: powershell -ExecutionPolicy Bypass -File killclaws.ps1 [-Scan] [-Yes] [-DryRun]
param(
    [switch]$Scan,
    [switch]$Yes,
    [switch]$DryRun,
    [switch]$Help,
    [switch]$Version
)

$ErrorActionPreference = "Continue"
$KCVersion = "2.0.0"

# ── Colors ──────────────────────────────────────────────────────────
function Write-C($color, $text) { Write-Host $text -ForegroundColor $color -NoNewline }
function Write-Ok($text)   { Write-Host "  " -NoNewline; Write-C Green "✓"; Write-Host " $text" }
function Write-Warn($text) { Write-Host "  " -NoNewline; Write-C Yellow "⚠"; Write-Host " $text" }
function Write-Fail($text) { Write-Host "  " -NoNewline; Write-C Red "✗"; Write-Host " $text" }

# ── Helpers ─────────────────────────────────────────────────────────
function Test-CmdExists($cmd) {
    return $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Get-DirSizeHuman($path) {
    if (Test-Path $path) {
        $bytes = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($null -eq $bytes) { return "0 B" }
        if ($bytes -gt 1MB) { return "{0:N1} MB" -f ($bytes / 1MB) }
        if ($bytes -gt 1KB) { return "{0:N1} KB" -f ($bytes / 1KB) }
        return "$bytes B"
    }
    return "0 B"
}

function Stop-ProcessByName($name) {
    $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($procs) {
        foreach ($p in $procs) {
            if ($DryRun) {
                Write-Ok "[dry-run] Would stop process $name (PID $($p.Id))"
            } else {
                try {
                    $p | Stop-Process -Force -ErrorAction SilentlyContinue
                    Write-Ok "Stopped process $name (PID $($p.Id))"
                } catch {
                    Write-Warn "Failed to stop $name (PID $($p.Id))"
                }
            }
        }
        return $true
    }
    return $false
}

function Remove-PathSafe($path) {
    if (Test-Path $path) {
        if ($DryRun) {
            Write-Ok "[dry-run] Would remove $path"
        } else {
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                Write-Ok "Removed $path"
            } catch {
                Write-Fail "Failed to remove $path"
            }
        }
    }
}

# ── Detection ───────────────────────────────────────────────────────
# Returns hashtable: @{ Found=$true; Details=@("line1","line2") }

function Detect-OpenClaw {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    # Config directories
    $dirs = @(
        @{ Path="$home\.openclaw"; Label="~\.openclaw" },
        @{ Path="$home\clawd"; Label="~\clawd (legacy workspace)" },
        @{ Path="$home\.clawdbot"; Label="~\.clawdbot (legacy)" },
        @{ Path="$home\.molthub"; Label="~\.molthub (legacy)" }
    )
    foreach ($d in $dirs) {
        if (Test-Path $d.Path) {
            $sz = Get-DirSizeHuman $d.Path
            $details += "      dir  $($d.Label) ($sz)"
            $found = $true
        }
    }

    # npm global
    foreach ($mgr in @("npm", "pnpm", "bun")) {
        if (Test-CmdExists $mgr) {
            $out = & $mgr list -g openclaw 2>$null
            if ($out -match "openclaw") {
                $details += "      pkg  ${mgr}: openclaw"
                $found = $true
            }
        }
    }

    # Processes
    $procs = Get-Process -Name "*openclaw*" -ErrorAction SilentlyContinue
    if ($procs) {
        $pids = ($procs | ForEach-Object { $_.Id }) -join ","
        $details += "      proc openclaw (PID $pids)"
        $found = $true
    }

    # Windows scheduled tasks
    foreach ($taskName in @("OpenClaw Gateway", "openclaw-gateway")) {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            $details += "      svc  Scheduled Task: $taskName"
            $found = $true
        }
    }

    # AppData paths
    $appDataPaths = @(
        "$env:APPDATA\OpenClaw",
        "$env:LOCALAPPDATA\OpenClaw",
        "$env:LOCALAPPDATA\Programs\OpenClaw"
    )
    foreach ($p in $appDataPaths) {
        if (Test-Path $p) {
            $sz = Get-DirSizeHuman $p
            $details += "      dir  $p ($sz)"
            $found = $true
        }
    }

    return @{ Found=$found; Details=$details }
}

function Detect-QClaw {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.qclaw") {
        $sz = Get-DirSizeHuman "$home\.qclaw"
        $details += "      dir  ~\.qclaw ($sz)"
        $found = $true
    }

    $procs = Get-Process -Name "*qclaw*" -ErrorAction SilentlyContinue
    if ($procs) {
        $details += "      proc QClaw process running"
        $found = $true
    }

    $paths = @("$env:APPDATA\QClaw", "$env:LOCALAPPDATA\QClaw", "$env:LOCALAPPDATA\Programs\QClaw")
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $sz = Get-DirSizeHuman $p
            $details += "      dir  $p ($sz)"
            $found = $true
        }
    }

    return @{ Found=$found; Details=$details }
}

function Detect-WorkBuddy {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.workbuddy") {
        $sz = Get-DirSizeHuman "$home\.workbuddy"
        $details += "      dir  ~\.workbuddy ($sz)"
        $found = $true
    }

    $procs = Get-Process -Name "*workbuddy*" -ErrorAction SilentlyContinue
    if ($procs) {
        $details += "      proc WorkBuddy process running"
        $found = $true
    }

    # npm global
    foreach ($mgr in @("npm", "pnpm", "bun")) {
        if (Test-CmdExists $mgr) {
            $out = & $mgr list -g "@tencent-ai/codebuddy-code" 2>$null
            if ($out -match "codebuddy") {
                $details += "      pkg  ${mgr}: @tencent-ai/codebuddy-code"
                $found = $true
            }
        }
    }

    $paths = @("$env:APPDATA\WorkBuddy", "$env:LOCALAPPDATA\WorkBuddy", "$env:LOCALAPPDATA\Programs\WorkBuddy")
    if ($env:ProgramFiles) { $paths += "$env:ProgramFiles\Tencent\WorkBuddy" }
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $sz = Get-DirSizeHuman $p
            $details += "      dir  $p ($sz)"
            $found = $true
        }
    }

    return @{ Found=$found; Details=$details }
}

function Detect-ZeroClaw {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.zeroclaw") {
        $sz = Get-DirSizeHuman "$home\.zeroclaw"
        $details += "      dir  ~\.zeroclaw ($sz)"
        $found = $true
    }

    if (Test-CmdExists "zeroclaw") {
        $bin = (Get-Command zeroclaw).Source
        $details += "      bin  $bin"
        $found = $true
    }

    $procs = Get-Process -Name "*zeroclaw*" -ErrorAction SilentlyContinue
    if ($procs) {
        $details += "      proc zeroclaw process running"
        $found = $true
    }

    return @{ Found=$found; Details=$details }
}

function Detect-PicoClaw {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.picoclaw") {
        $sz = Get-DirSizeHuman "$home\.picoclaw"
        $details += "      dir  ~\.picoclaw ($sz)"
        $found = $true
    }

    if (Test-CmdExists "picoclaw") {
        $bin = (Get-Command picoclaw).Source
        $details += "      bin  $bin"
        $found = $true
    }

    $procs = Get-Process -Name "*picoclaw*" -ErrorAction SilentlyContinue
    if ($procs) {
        $details += "      proc picoclaw process running"
        $found = $true
    }

    return @{ Found=$found; Details=$details }
}

function Detect-KimiCLI {
    $found = $false
    $details = @()
    $home = $env:USERPROFILE

    if (Test-Path "$home\.kimi") {
        $sz = Get-DirSizeHuman "$home\.kimi"
        $details += "      dir  ~\.kimi ($sz)"
        $found = $true
    }

    foreach ($pip in @("pip3", "pip")) {
        if (Test-CmdExists $pip) {
            $out = & $pip show kimi-cli 2>$null
            if ($LASTEXITCODE -eq 0 -and $out) {
                $details += "      pkg  ${pip}: kimi-cli"
                $found = $true
                break
            }
        }
    }

    if (Test-CmdExists "kimi") {
        $bin = (Get-Command kimi).Source
        $details += "      bin  $bin"
        $found = $true
    }

    return @{ Found=$found; Details=$details }
}

# ── Removal ─────────────────────────────────────────────────────────

function Remove-OpenClaw {
    Write-Host "`n  Removing OpenClaw..." -ForegroundColor White
    Stop-ProcessByName "openclaw" | Out-Null

    # Scheduled tasks
    foreach ($taskName in @("OpenClaw Gateway", "openclaw-gateway")) {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($task) {
            if ($DryRun) {
                Write-Ok "[dry-run] Would remove scheduled task: $taskName"
            } else {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
                Write-Ok "Removed scheduled task: $taskName"
            }
        }
    }

    # npm packages
    foreach ($mgr in @("npm", "pnpm", "bun")) {
        if (Test-CmdExists $mgr) {
            $out = & $mgr list -g openclaw 2>$null
            if ($out -match "openclaw") {
                if ($DryRun) {
                    Write-Ok "[dry-run] Would uninstall: $mgr rm -g openclaw"
                } else {
                    & $mgr rm -g openclaw 2>$null
                    Write-Ok "Uninstalled $mgr package: openclaw"
                }
            }
        }
    }

    # Directories
    $home = $env:USERPROFILE
    foreach ($d in @("$home\.openclaw", "$home\clawd", "$home\.clawdbot", "$home\.molthub")) {
        Remove-PathSafe $d
    }
    foreach ($d in @("$env:APPDATA\OpenClaw", "$env:LOCALAPPDATA\OpenClaw", "$env:LOCALAPPDATA\Programs\OpenClaw")) {
        Remove-PathSafe $d
    }
}

function Remove-QClaw {
    Write-Host "`n  Removing QClaw..." -ForegroundColor White
    Stop-ProcessByName "qclaw" | Out-Null
    $home = $env:USERPROFILE
    Remove-PathSafe "$home\.qclaw"
    foreach ($d in @("$env:APPDATA\QClaw", "$env:LOCALAPPDATA\QClaw", "$env:LOCALAPPDATA\Programs\QClaw")) {
        Remove-PathSafe $d
    }
}

function Remove-WorkBuddy {
    Write-Host "`n  Removing WorkBuddy..." -ForegroundColor White
    Stop-ProcessByName "workbuddy" | Out-Null

    foreach ($mgr in @("npm", "pnpm", "bun")) {
        if (Test-CmdExists $mgr) {
            $out = & $mgr list -g "@tencent-ai/codebuddy-code" 2>$null
            if ($out -match "codebuddy") {
                if ($DryRun) {
                    Write-Ok "[dry-run] Would uninstall: $mgr rm -g @tencent-ai/codebuddy-code"
                } else {
                    & $mgr rm -g "@tencent-ai/codebuddy-code" 2>$null
                    Write-Ok "Uninstalled $mgr package: @tencent-ai/codebuddy-code"
                }
            }
        }
    }

    $home = $env:USERPROFILE
    Remove-PathSafe "$home\.workbuddy"
    foreach ($d in @("$env:APPDATA\WorkBuddy", "$env:LOCALAPPDATA\WorkBuddy", "$env:LOCALAPPDATA\Programs\WorkBuddy")) {
        Remove-PathSafe $d
    }
    if ($env:ProgramFiles) { Remove-PathSafe "$env:ProgramFiles\Tencent\WorkBuddy" }
}

function Remove-ZeroClaw {
    Write-Host "`n  Removing ZeroClaw..." -ForegroundColor White
    Stop-ProcessByName "zeroclaw" | Out-Null
    Remove-PathSafe "$env:USERPROFILE\.zeroclaw"
    if (Test-CmdExists "zeroclaw") {
        $bin = (Get-Command zeroclaw).Source
        if ($DryRun) {
            Write-Ok "[dry-run] Would remove binary: $bin"
        } else {
            Remove-Item $bin -Force -ErrorAction SilentlyContinue
            Write-Ok "Removed binary: $bin"
        }
    }
}

function Remove-PicoClaw {
    Write-Host "`n  Removing PicoClaw..." -ForegroundColor White
    Stop-ProcessByName "picoclaw" | Out-Null
    Remove-PathSafe "$env:USERPROFILE\.picoclaw"
    if (Test-CmdExists "picoclaw") {
        $bin = (Get-Command picoclaw).Source
        if ($DryRun) {
            Write-Ok "[dry-run] Would remove binary: $bin"
        } else {
            Remove-Item $bin -Force -ErrorAction SilentlyContinue
            Write-Ok "Removed binary: $bin"
        }
    }
}

function Remove-KimiCLI {
    Write-Host "`n  Removing KimiCLI..." -ForegroundColor White
    foreach ($pip in @("pip3", "pip")) {
        if (Test-CmdExists $pip) {
            $out = & $pip show kimi-cli 2>$null
            if ($LASTEXITCODE -eq 0 -and $out) {
                if ($DryRun) {
                    Write-Ok "[dry-run] Would uninstall: $pip uninstall -y kimi-cli"
                } else {
                    & $pip uninstall -y kimi-cli 2>$null
                    Write-Ok "Uninstalled $pip package: kimi-cli"
                }
                break
            }
        }
    }
    Remove-PathSafe "$env:USERPROFILE\.kimi"
    if (Test-CmdExists "kimi") {
        $bin = (Get-Command kimi).Source
        if ($DryRun) {
            Write-Ok "[dry-run] Would remove binary: $bin"
        } else {
            Remove-Item $bin -Force -ErrorAction SilentlyContinue
            Write-Ok "Removed binary: $bin"
        }
    }
}

# ── Main ────────────────────────────────────────────────────────────

if ($Help) {
    Write-Host @"
KillClaws v$KCVersion - Remove all Claw AI products (Windows)

Usage:
  powershell -ExecutionPolicy Bypass -File killclaws.ps1 [options]

Options:
  -Scan       Scan only, don't remove anything
  -Yes        Skip confirmation prompt (remove all detected)
  -DryRun     Preview what would be removed
  -Help       Show this help

Examples:
  .\killclaws.ps1              # Interactive: scan -> select -> remove
  .\killclaws.ps1 -Scan        # Just scan
  .\killclaws.ps1 -Yes         # Remove all without asking
  .\killclaws.ps1 -DryRun      # Preview removal actions
  irm https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.ps1 | iex
"@
    exit 0
}

if ($Version) {
    Write-Host "KillClaws v$KCVersion"
    exit 0
}

Write-Host "KillClaws v$KCVersion — Windows" -ForegroundColor White
Write-Host ""
Write-Host "Scanning for Claw products..."

# Scan all products
$products = @(
    @{ Name="OpenClaw";  Detect={ Detect-OpenClaw };  Remove={ Remove-OpenClaw } },
    @{ Name="QClaw";     Detect={ Detect-QClaw };     Remove={ Remove-QClaw } },
    @{ Name="WorkBuddy"; Detect={ Detect-WorkBuddy }; Remove={ Remove-WorkBuddy } },
    @{ Name="ZeroClaw";  Detect={ Detect-ZeroClaw };  Remove={ Remove-ZeroClaw } },
    @{ Name="PicoClaw";  Detect={ Detect-PicoClaw };  Remove={ Remove-PicoClaw } },
    @{ Name="KimiCLI";   Detect={ Detect-KimiCLI };   Remove={ Remove-KimiCLI } }
)

$detected = @()
foreach ($prod in $products) {
    $result = & $prod.Detect
    if ($result.Found) {
        $detected += @{ Name=$prod.Name; Details=$result.Details; Remove=$prod.Remove }
    }
}

if ($detected.Count -eq 0) {
    Write-Host ""
    Write-Host "No Claw products detected. System is clean!" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Found $($detected.Count) Claw product(s):" -ForegroundColor White
Write-Host ""

for ($i = 0; $i -lt $detected.Count; $i++) {
    Write-Host "  [$($i+1)] " -NoNewline
    Write-Host $detected[$i].Name -ForegroundColor Cyan
    foreach ($line in $detected[$i].Details) {
        Write-Host $line
    }
    Write-Host ""
}

if ($Scan) { exit 0 }

if ($DryRun) {
    Write-Host "Dry-run mode: showing what would be removed" -ForegroundColor Yellow
    Write-Host ""
}

# Selection
$selection = ""
if ($Yes) {
    $selection = "all"
} else {
    $selection = Read-Host "Select products to remove (comma-separated numbers, 'all', or 'q' to quit)"
    if ([string]::IsNullOrEmpty($selection) -or $selection -eq "q") {
        Write-Host "Aborted."
        exit 0
    }
}

# Build list
$toRemove = @()
if ($selection -eq "all" -or $selection -eq "a") {
    $toRemove = 0..($detected.Count - 1)
} else {
    foreach ($s in ($selection -split ",")) {
        $idx = [int]$s.Trim() - 1
        if ($idx -ge 0 -and $idx -lt $detected.Count) {
            $toRemove += $idx
        }
    }
}

# Confirm
if (-not $Yes -and -not $DryRun) {
    $names = ($toRemove | ForEach-Object { $detected[$_].Name }) -join ", "
    $confirm = Read-Host "Remove $names ? [y/N]"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Aborted."
        exit 0
    }
}

# Execute
$removed = 0
foreach ($idx in $toRemove) {
    & $detected[$idx].Remove
    $removed++
}

Write-Host ""
if ($DryRun) {
    Write-Host "Dry-run complete. No changes were made." -ForegroundColor Yellow
} else {
    Write-Host "Done! Removed $removed product(s)." -ForegroundColor Green
    Write-Host ""
    Write-Host "Reminders:" -ForegroundColor Yellow
    Write-Host "  - Revoke API keys (OpenAI, Anthropic, Moonshot, etc.)"
    Write-Host "  - Remove browser extensions"
    Write-Host "  - Disconnect chat bot integrations"
}
