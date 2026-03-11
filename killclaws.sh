#!/usr/bin/env bash
set -euo pipefail

# killclaws.sh - detect and remove Claw AI assistant products
# bash 3.2 compatible (no associative arrays/readarray)

YES=0
SCAN_ONLY=0
DRY_RUN=0

OS="$(uname -s 2>/dev/null || printf 'Unknown')"
IS_DARWIN=0
IS_LINUX=0
if [ "$OS" = "Darwin" ]; then
  IS_DARWIN=1
elif [ "$OS" = "Linux" ]; then
  IS_LINUX=1
fi

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  CYAN=''
  BOLD=''
  NC=''
fi

print_help() {
  cat <<'EOF'
Usage: killclaws.sh [OPTIONS]

Detect and uninstall Claw AI assistant products on Linux/macOS.

Options:
  --yes       Skip confirmation prompts
  --scan      Scan only; do not remove anything
  --dry-run   Preview actions without making changes
  --help      Show this help
EOF
}

log_info() { printf "%b\n" "${BLUE}$*${NC}"; }
log_warn() { printf "%b\n" "${YELLOW}$*${NC}"; }
log_ok() { printf "%b\n" "${GREEN}$*${NC}"; }
log_err() { printf "%b\n" "${RED}$*${NC}"; }

warn_root_maybe_needed() {
  log_warn "⚠ Some package/binary removals may require elevated permissions depending on your install location."
  log_warn "  This script does not use sudo automatically."
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

human_kb() {
  local kb
  kb="${1:-0}"
  awk -v kb="$kb" '
    function fmt(x, u) { printf "%.1f %s", x, u }
    BEGIN {
      if (kb < 1024) { printf "%d KB", kb; exit }
      if (kb < 1024*1024) { fmt(kb/1024.0, "MB"); exit }
      fmt(kb/(1024.0*1024.0), "GB")
    }
  '
}

path_size_kb() {
  local p
  p="$1"
  if [ -e "$p" ]; then
    du -sk "$p" 2>/dev/null | awk '{print $1+0}'
  else
    printf "0"
  fi
}

path_size_human() {
  local p
  p="$1"
  if [ -e "$p" ]; then
    du -sh "$p" 2>/dev/null | awk '{print $1}'
  else
    printf "0"
  fi
}

run_or_preview() {
  local desc cmd
  desc="$1"
  cmd="$2"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf "  %b\n" "${CYAN}• [dry-run] $desc${NC}"
    return 0
  fi

  if bash -c "$cmd" >/dev/null 2>&1; then
    printf "  %b\n" "${GREEN}✓ $desc${NC}"
    return 0
  fi

  printf "  %b\n" "${YELLOW}⚠ Failed: $desc${NC}"
  return 1
}

remove_path() {
  local p label
  p="$1"
  label="$2"
  if [ -e "$p" ]; then
    run_or_preview "Removed $label" "rm -rf \"$p\"" || true
  fi
}

kill_pid_gracefully() {
  local pid name
  pid="$1"
  name="$2"

  if ! kill -0 "$pid" >/dev/null 2>&1; then
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf "  %b\n" "${CYAN}• [dry-run] Stop process $name (PID $pid)${NC}"
    return 0
  fi

  if kill -TERM "$pid" >/dev/null 2>&1; then
    sleep 2
    if kill -0 "$pid" >/dev/null 2>&1; then
      if kill -KILL "$pid" >/dev/null 2>&1; then
        printf "  %b\n" "${GREEN}✓ Stopped process $name (PID $pid)${NC}"
      else
        printf "  %b\n" "${YELLOW}⚠ Could not SIGKILL process $name (PID $pid)${NC}"
      fi
    else
      printf "  %b\n" "${GREEN}✓ Stopped process $name (PID $pid)${NC}"
    fi
  else
    printf "  %b\n" "${YELLOW}⚠ Could not SIGTERM process $name (PID $pid)${NC}"
  fi
}

collect_pids() {
  # input: space-separated patterns
  local patterns pat pids tmp
  patterns="$1"
  pids=""
  for pat in $patterns; do
    if command_exists pgrep; then
      tmp="$(pgrep -f "$pat" 2>/dev/null || true)"
      if [ -n "$tmp" ]; then
        pids="$pids $tmp"
      fi
    fi
  done
  printf "%s\n" "$pids" | tr ' ' '\n' | awk 'NF' | sort -u | tr '\n' ' '
}

append_detail() {
  # append_detail VAR "text"
  local var text current
  var="$1"
  text="$2"
  eval "current=\${$var}"
  if [ -z "$current" ]; then
    eval "$var=\"$text\""
  else
    eval "$var=\"\${$var}\n$text\""
  fi
}

add_kb() {
  # add_kb VAR NUMBER
  local var n cur
  var="$1"
  n="$2"
  eval "cur=\${$var}"
  cur=$((cur + n))
  eval "$var=$cur"
}

# Product state
FOUND_OPENCLAW=0; DETAILS_OPENCLAW=""; SIZEKB_OPENCLAW=0; PIDS_OPENCLAW=""
FOUND_QCLAW=0; DETAILS_QCLAW=""; SIZEKB_QCLAW=0; PIDS_QCLAW=""
FOUND_WORKBUDDY=0; DETAILS_WORKBUDDY=""; SIZEKB_WORKBUDDY=0; PIDS_WORKBUDDY=""
FOUND_ZEROCLAW=0; DETAILS_ZEROCLAW=""; SIZEKB_ZEROCLAW=0; PIDS_ZEROCLAW=""; BIN_ZEROCLAW=""
FOUND_PICOCLAW=0; DETAILS_PICOCLAW=""; SIZEKB_PICOCLAW=0; PIDS_PICOCLAW=""; BIN_PICOCLAW=""
FOUND_KIMICLI=0; DETAILS_KIMICLI=""; SIZEKB_KIMICLI=0; BIN_KIMI=""; HAS_PIP_KIMI=0; HAS_PIP3_KIMI=0

detect_openclaw() {
  local p s pids
  for p in "$HOME/.openclaw" "$HOME/clawd" "$HOME/.clawdbot" "$HOME/.molthub"; do
    if [ -d "$p" ]; then
      FOUND_OPENCLAW=1
      s="$(path_size_human "$p")"
      if [ "$p" = "$HOME/clawd" ]; then
        append_detail DETAILS_OPENCLAW "      📂 ~/clawd (legacy workspace)"
      elif [ "$p" = "$HOME/.clawdbot" ]; then
        append_detail DETAILS_OPENCLAW "      📂 ~/.clawdbot (legacy)"
      elif [ "$p" = "$HOME/.molthub" ]; then
        append_detail DETAILS_OPENCLAW "      📂 ~/.molthub (legacy)"
      else
        append_detail DETAILS_OPENCLAW "      📂 ~/.openclaw ($s)"
      fi
      add_kb SIZEKB_OPENCLAW "$(path_size_kb "$p")"
    fi
  done

  if command_exists npm && npm list -g openclaw --depth=0 >/dev/null 2>&1; then
    FOUND_OPENCLAW=1
    append_detail DETAILS_OPENCLAW "      📦 npm: openclaw"
  fi
  if command_exists pnpm && pnpm list -g openclaw >/dev/null 2>&1; then
    FOUND_OPENCLAW=1
    append_detail DETAILS_OPENCLAW "      📦 pnpm: openclaw"
  fi
  if command_exists bun && bun pm ls -g 2>/dev/null | awk '/openclaw/ { found=1 } END { exit(!found) }'; then
    FOUND_OPENCLAW=1
    append_detail DETAILS_OPENCLAW "      📦 bun: openclaw"
  fi

  pids="$(collect_pids "openclaw")"
  if [ -n "$pids" ]; then
    FOUND_OPENCLAW=1
    PIDS_OPENCLAW="$pids"
    for p in $pids; do
      append_detail DETAILS_OPENCLAW "      🔄 Process: openclaw (PID $p)"
    done
  fi

  if [ "$IS_DARWIN" -eq 1 ]; then
    if [ -d "/Applications/OpenClaw.app" ]; then
      FOUND_OPENCLAW=1
      append_detail DETAILS_OPENCLAW "      🧩 App: /Applications/OpenClaw.app"
      add_kb SIZEKB_OPENCLAW "$(path_size_kb "/Applications/OpenClaw.app")"
    fi
    if [ -e "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" ]; then
      FOUND_OPENCLAW=1
      append_detail DETAILS_OPENCLAW "      ⚙ LaunchAgent: ai.openclaw.gateway"
    fi
    if [ -e "$HOME/Library/LaunchAgents/com.openclaw.gateway.plist" ]; then
      FOUND_OPENCLAW=1
      append_detail DETAILS_OPENCLAW "      ⚙ LaunchAgent: com.openclaw.gateway"
    fi
    if [ -d "$HOME/Library/Application Support/OpenClaw" ]; then
      FOUND_OPENCLAW=1
      append_detail DETAILS_OPENCLAW "      📂 ~/Library/Application Support/OpenClaw ($(path_size_human "$HOME/Library/Application Support/OpenClaw"))"
      add_kb SIZEKB_OPENCLAW "$(path_size_kb "$HOME/Library/Application Support/OpenClaw")"
    fi
    if [ -d "$HOME/Library/Caches/OpenClaw" ]; then
      FOUND_OPENCLAW=1
      append_detail DETAILS_OPENCLAW "      📂 ~/Library/Caches/OpenClaw ($(path_size_human "$HOME/Library/Caches/OpenClaw"))"
      add_kb SIZEKB_OPENCLAW "$(path_size_kb "$HOME/Library/Caches/OpenClaw")"
    fi
  fi

  if [ "$IS_LINUX" -eq 1 ] && [ -e "$HOME/.config/systemd/user/openclaw-gateway.service" ]; then
    FOUND_OPENCLAW=1
    append_detail DETAILS_OPENCLAW "      ⚙ Service: ~/.config/systemd/user/openclaw-gateway.service"
  fi
}

detect_qclaw() {
  local pids p
  p="$HOME/.qclaw"
  if [ -d "$p" ]; then
    FOUND_QCLAW=1
    append_detail DETAILS_QCLAW "      📂 ~/.qclaw ($(path_size_human "$p"))"
    add_kb SIZEKB_QCLAW "$(path_size_kb "$p")"
  fi

  pids="$(collect_pids "QClaw qclaw")"
  if [ -n "$pids" ]; then
    FOUND_QCLAW=1
    PIDS_QCLAW="$pids"
    for p in $pids; do
      append_detail DETAILS_QCLAW "      🔄 Process: qclaw (PID $p)"
    done
  fi

  if [ "$IS_DARWIN" -eq 1 ]; then
    if [ -d "/Applications/QClaw.app" ]; then
      FOUND_QCLAW=1
      append_detail DETAILS_QCLAW "      🧩 App: /Applications/QClaw.app"
      add_kb SIZEKB_QCLAW "$(path_size_kb "/Applications/QClaw.app")"
    fi
    if [ -d "$HOME/Library/Application Support/QClaw" ]; then
      FOUND_QCLAW=1
      append_detail DETAILS_QCLAW "      📂 ~/Library/Application Support/QClaw ($(path_size_human "$HOME/Library/Application Support/QClaw"))"
      add_kb SIZEKB_QCLAW "$(path_size_kb "$HOME/Library/Application Support/QClaw")"
    fi
    if [ -d "$HOME/Library/Caches/QClaw" ]; then
      FOUND_QCLAW=1
      append_detail DETAILS_QCLAW "      📂 ~/Library/Caches/QClaw ($(path_size_human "$HOME/Library/Caches/QClaw"))"
      add_kb SIZEKB_QCLAW "$(path_size_kb "$HOME/Library/Caches/QClaw")"
    fi
  fi
}

detect_workbuddy() {
  local pids p
  p="$HOME/.workbuddy"
  if [ -d "$p" ]; then
    FOUND_WORKBUDDY=1
    append_detail DETAILS_WORKBUDDY "      📂 ~/.workbuddy ($(path_size_human "$p"))"
    add_kb SIZEKB_WORKBUDDY "$(path_size_kb "$p")"
  fi

  pids="$(collect_pids "WorkBuddy workbuddy")"
  if [ -n "$pids" ]; then
    FOUND_WORKBUDDY=1
    PIDS_WORKBUDDY="$pids"
    for p in $pids; do
      append_detail DETAILS_WORKBUDDY "      🔄 Process: workbuddy (PID $p)"
    done
  fi

  if [ "$IS_DARWIN" -eq 1 ]; then
    if [ -d "/Applications/WorkBuddy.app" ]; then
      FOUND_WORKBUDDY=1
      append_detail DETAILS_WORKBUDDY "      🧩 App: /Applications/WorkBuddy.app"
      add_kb SIZEKB_WORKBUDDY "$(path_size_kb "/Applications/WorkBuddy.app")"
    fi
    if [ -d "$HOME/Library/Application Support/WorkBuddy" ]; then
      FOUND_WORKBUDDY=1
      append_detail DETAILS_WORKBUDDY "      📂 ~/Library/Application Support/WorkBuddy ($(path_size_human "$HOME/Library/Application Support/WorkBuddy"))"
      add_kb SIZEKB_WORKBUDDY "$(path_size_kb "$HOME/Library/Application Support/WorkBuddy")"
    fi
    if [ -d "$HOME/Library/Caches/WorkBuddy" ]; then
      FOUND_WORKBUDDY=1
      append_detail DETAILS_WORKBUDDY "      📂 ~/Library/Caches/WorkBuddy ($(path_size_human "$HOME/Library/Caches/WorkBuddy"))"
      add_kb SIZEKB_WORKBUDDY "$(path_size_kb "$HOME/Library/Caches/WorkBuddy")"
    fi
  fi
}

detect_zeroclaw() {
  local pids p
  p="$HOME/.zeroclaw"
  if [ -d "$p" ]; then
    FOUND_ZEROCLAW=1
    append_detail DETAILS_ZEROCLAW "      📂 ~/.zeroclaw ($(path_size_human "$p"))"
    add_kb SIZEKB_ZEROCLAW "$(path_size_kb "$p")"
  fi
  if command_exists zeroclaw; then
    FOUND_ZEROCLAW=1
    BIN_ZEROCLAW="$(command -v zeroclaw 2>/dev/null || true)"
    append_detail DETAILS_ZEROCLAW "      🔧 Binary: $BIN_ZEROCLAW"
  fi
  pids="$(collect_pids "zeroclaw")"
  if [ -n "$pids" ]; then
    FOUND_ZEROCLAW=1
    PIDS_ZEROCLAW="$pids"
    for p in $pids; do
      append_detail DETAILS_ZEROCLAW "      🔄 Process: zeroclaw (PID $p)"
    done
  fi
}

detect_picoclaw() {
  local pids p
  p="$HOME/.picoclaw"
  if [ -d "$p" ]; then
    FOUND_PICOCLAW=1
    append_detail DETAILS_PICOCLAW "      📂 ~/.picoclaw ($(path_size_human "$p"))"
    add_kb SIZEKB_PICOCLAW "$(path_size_kb "$p")"
  fi
  if command_exists picoclaw; then
    FOUND_PICOCLAW=1
    BIN_PICOCLAW="$(command -v picoclaw 2>/dev/null || true)"
    append_detail DETAILS_PICOCLAW "      🔧 Binary: $BIN_PICOCLAW"
  fi
  pids="$(collect_pids "picoclaw")"
  if [ -n "$pids" ]; then
    FOUND_PICOCLAW=1
    PIDS_PICOCLAW="$pids"
    for p in $pids; do
      append_detail DETAILS_PICOCLAW "      🔄 Process: picoclaw (PID $p)"
    done
  fi
}

detect_kimicli() {
  local p
  p="$HOME/.kimi"
  if [ -d "$p" ]; then
    FOUND_KIMICLI=1
    append_detail DETAILS_KIMICLI "      📂 ~/.kimi ($(path_size_human "$p"))"
    add_kb SIZEKB_KIMICLI "$(path_size_kb "$p")"
  fi

  if command_exists pip && pip show kimi-cli >/dev/null 2>&1; then
    FOUND_KIMICLI=1
    HAS_PIP_KIMI=1
    append_detail DETAILS_KIMICLI "      📦 pip: kimi-cli"
  fi
  if command_exists pip3 && pip3 show kimi-cli >/dev/null 2>&1; then
    FOUND_KIMICLI=1
    HAS_PIP3_KIMI=1
    append_detail DETAILS_KIMICLI "      📦 pip3: kimi-cli"
  fi

  if command_exists kimi; then
    FOUND_KIMICLI=1
    BIN_KIMI="$(command -v kimi 2>/dev/null || true)"
    append_detail DETAILS_KIMICLI "      🔧 Binary: $BIN_KIMI"
  fi
}

remove_openclaw() {
  local pid
  printf "%b\n" "${BOLD}Removing OpenClaw...${NC}"
  for pid in $PIDS_OPENCLAW; do
    kill_pid_gracefully "$pid" "openclaw"
  done

  if [ "$IS_DARWIN" -eq 1 ]; then
    if [ -e "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" ]; then
      run_or_preview "Unloaded LaunchAgent ai.openclaw.gateway" "launchctl unload \"$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist\"" || true
      remove_path "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" "~/Library/LaunchAgents/ai.openclaw.gateway.plist"
    fi
    if [ -e "$HOME/Library/LaunchAgents/com.openclaw.gateway.plist" ]; then
      run_or_preview "Unloaded LaunchAgent com.openclaw.gateway" "launchctl unload \"$HOME/Library/LaunchAgents/com.openclaw.gateway.plist\"" || true
      remove_path "$HOME/Library/LaunchAgents/com.openclaw.gateway.plist" "~/Library/LaunchAgents/com.openclaw.gateway.plist"
    fi
  fi
  if [ "$IS_LINUX" -eq 1 ] && [ -e "$HOME/.config/systemd/user/openclaw-gateway.service" ]; then
    if command_exists systemctl; then
      run_or_preview "Stopped user service openclaw-gateway.service" "systemctl --user stop openclaw-gateway.service" || true
      run_or_preview "Disabled user service openclaw-gateway.service" "systemctl --user disable openclaw-gateway.service" || true
    fi
    remove_path "$HOME/.config/systemd/user/openclaw-gateway.service" "~/.config/systemd/user/openclaw-gateway.service"
  fi

  if command_exists npm; then
    run_or_preview "Uninstalled npm package: openclaw" "npm rm -g openclaw" || true
  fi
  if command_exists pnpm; then
    run_or_preview "Uninstalled pnpm package: openclaw" "pnpm rm -g openclaw" || true
  fi
  if command_exists bun; then
    run_or_preview "Uninstalled bun package: openclaw" "bun remove -g openclaw" || true
  fi

  remove_path "$HOME/.openclaw" "~/.openclaw"
  remove_path "$HOME/clawd" "~/clawd"
  remove_path "$HOME/.clawdbot" "~/.clawdbot"
  remove_path "$HOME/.molthub" "~/.molthub"
  if [ "$IS_DARWIN" -eq 1 ]; then
    remove_path "$HOME/Library/Application Support/OpenClaw" "~/Library/Application Support/OpenClaw"
    remove_path "$HOME/Library/Caches/OpenClaw" "~/Library/Caches/OpenClaw"
    remove_path "/Applications/OpenClaw.app" "/Applications/OpenClaw.app"
  fi
}

remove_qclaw() {
  local pid
  printf "%b\n" "${BOLD}Removing QClaw...${NC}"
  for pid in $PIDS_QCLAW; do
    kill_pid_gracefully "$pid" "qclaw"
  done
  remove_path "$HOME/.qclaw" "~/.qclaw"
  if [ "$IS_DARWIN" -eq 1 ]; then
    remove_path "$HOME/Library/Application Support/QClaw" "~/Library/Application Support/QClaw"
    remove_path "$HOME/Library/Caches/QClaw" "~/Library/Caches/QClaw"
    remove_path "/Applications/QClaw.app" "/Applications/QClaw.app"
  fi
}

remove_workbuddy() {
  local pid
  printf "%b\n" "${BOLD}Removing WorkBuddy...${NC}"
  for pid in $PIDS_WORKBUDDY; do
    kill_pid_gracefully "$pid" "workbuddy"
  done
  remove_path "$HOME/.workbuddy" "~/.workbuddy"
  if [ "$IS_DARWIN" -eq 1 ]; then
    remove_path "$HOME/Library/Application Support/WorkBuddy" "~/Library/Application Support/WorkBuddy"
    remove_path "$HOME/Library/Caches/WorkBuddy" "~/Library/Caches/WorkBuddy"
    remove_path "/Applications/WorkBuddy.app" "/Applications/WorkBuddy.app"
  fi
}

remove_zeroclaw() {
  local pid
  printf "%b\n" "${BOLD}Removing ZeroClaw...${NC}"
  for pid in $PIDS_ZEROCLAW; do
    kill_pid_gracefully "$pid" "zeroclaw"
  done
  remove_path "$HOME/.zeroclaw" "~/.zeroclaw"
  if [ -n "$BIN_ZEROCLAW" ] && [ -e "$BIN_ZEROCLAW" ]; then
    remove_path "$BIN_ZEROCLAW" "$BIN_ZEROCLAW"
  fi
}

remove_picoclaw() {
  local pid
  printf "%b\n" "${BOLD}Removing PicoClaw...${NC}"
  for pid in $PIDS_PICOCLAW; do
    kill_pid_gracefully "$pid" "picoclaw"
  done
  remove_path "$HOME/.picoclaw" "~/.picoclaw"
  if [ -n "$BIN_PICOCLAW" ] && [ -e "$BIN_PICOCLAW" ]; then
    remove_path "$BIN_PICOCLAW" "$BIN_PICOCLAW"
  fi
}

remove_kimicli() {
  printf "%b\n" "${BOLD}Removing KimiCLI...${NC}"
  if [ "$HAS_PIP_KIMI" -eq 1 ] && command_exists pip; then
    run_or_preview "Uninstalled pip package: kimi-cli" "pip uninstall -y kimi-cli" || true
  fi
  if [ "$HAS_PIP3_KIMI" -eq 1 ] && command_exists pip3; then
    run_or_preview "Uninstalled pip3 package: kimi-cli" "pip3 uninstall -y kimi-cli" || true
  fi
  remove_path "$HOME/.kimi" "~/.kimi"
  if [ -n "$BIN_KIMI" ] && [ -e "$BIN_KIMI" ]; then
    remove_path "$BIN_KIMI" "$BIN_KIMI"
  fi
}

print_found_products() {
  local count idx
  count=0
  FOUND_KEYS=""

  if [ "$FOUND_OPENCLAW" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=OPENCLAW"; FOUND_KEYS="$FOUND_KEYS OPENCLAW"
  fi
  if [ "$FOUND_QCLAW" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=QCLAW"; FOUND_KEYS="$FOUND_KEYS QCLAW"
  fi
  if [ "$FOUND_WORKBUDDY" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=WORKBUDDY"; FOUND_KEYS="$FOUND_KEYS WORKBUDDY"
  fi
  if [ "$FOUND_ZEROCLAW" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=ZEROCLAW"; FOUND_KEYS="$FOUND_KEYS ZEROCLAW"
  fi
  if [ "$FOUND_PICOCLAW" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=PICOCLAW"; FOUND_KEYS="$FOUND_KEYS PICOCLAW"
  fi
  if [ "$FOUND_KIMICLI" -eq 1 ]; then
    count=$((count + 1)); eval "IDX_$count=KIMICLI"; FOUND_KEYS="$FOUND_KEYS KIMICLI"
  fi

  FOUND_COUNT="$count"

  if [ "$count" -eq 0 ]; then
    log_ok "No Claw products detected."
    return
  fi

  printf "\n%b\n" "${BOLD}Found $count Claw products:${NC}"

  idx=1
  while [ "$idx" -le "$count" ]; do
    local key name details
    eval "key=\${IDX_$idx}"
    case "$key" in
      OPENCLAW) name="OpenClaw"; details="$DETAILS_OPENCLAW" ;;
      QCLAW) name="QClaw"; details="$DETAILS_QCLAW" ;;
      WORKBUDDY) name="WorkBuddy"; details="$DETAILS_WORKBUDDY" ;;
      ZEROCLAW) name="ZeroClaw"; details="$DETAILS_ZEROCLAW" ;;
      PICOCLAW) name="PicoClaw"; details="$DETAILS_PICOCLAW" ;;
      KIMICLI) name="KimiCLI"; details="$DETAILS_KIMICLI" ;;
      *) name="$key"; details="" ;;
    esac

    printf "  [%d] ✅ %s\n" "$idx" "$name"
    if [ -n "$details" ]; then
      printf "%b\n" "$details"
    fi
    printf "\n"

    idx=$((idx + 1))
  done
}

selection_contains() {
  # selection_contains "1 3" "3"
  local list needle x
  list="$1"
  needle="$2"
  for x in $list; do
    if [ "$x" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

ask_selection() {
  local input i n cleaned part

  if [ "$FOUND_COUNT" -eq 0 ]; then
    SELECTED_KEYS=""
    return
  fi

  if [ "$YES" -eq 1 ]; then
    SELECTED_KEYS="$FOUND_KEYS"
    return
  fi

  printf "Select products to remove (comma-separated, or 'all'): "
  IFS= read -r input
  input="$(printf "%s" "$input" | tr '[:upper:]' '[:lower:]')"

  if [ "$input" = "all" ]; then
    SELECTED_KEYS="$FOUND_KEYS"
    return
  fi

  cleaned="$(printf "%s" "$input" | tr ',' ' ')"
  SELECTED_KEYS=""

  for part in $cleaned; do
    if [ -n "$part" ]; then
      n="$part"
      if [ "$n" -ge 1 ] 2>/dev/null && [ "$n" -le "$FOUND_COUNT" ] 2>/dev/null; then
        if ! selection_contains "$SELECTED_NUMBERS" "$n"; then
          SELECTED_NUMBERS="$SELECTED_NUMBERS $n"
          eval "SELECTED_KEYS=\"$SELECTED_KEYS \${IDX_$n}\""
        fi
      fi
    fi
  done
}

confirm_removal() {
  local answer
  if [ "$YES" -eq 1 ]; then
    return 0
  fi
  printf "Proceed with removal? [y/N]: "
  IFS= read -r answer
  answer="$(printf "%s" "$answer" | tr '[:upper:]' '[:lower:]')"
  [ "$answer" = "y" ] || [ "$answer" = "yes" ]
}

remove_selected() {
  local key removed_count freed_kb
  removed_count=0
  freed_kb=0

  for key in $SELECTED_KEYS; do
    case "$key" in
      OPENCLAW)
        remove_openclaw
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_OPENCLAW))
        ;;
      QCLAW)
        remove_qclaw
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_QCLAW))
        ;;
      WORKBUDDY)
        remove_workbuddy
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_WORKBUDDY))
        ;;
      ZEROCLAW)
        remove_zeroclaw
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_ZEROCLAW))
        ;;
      PICOCLAW)
        remove_picoclaw
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_PICOCLAW))
        ;;
      KIMICLI)
        remove_kimicli
        removed_count=$((removed_count + 1))
        freed_kb=$((freed_kb + SIZEKB_KIMICLI))
        ;;
    esac
    printf "\n"
  done

  if [ "$DRY_RUN" -eq 1 ]; then
    log_ok "Done! [dry-run] Would remove $removed_count products, free approximately $(human_kb "$freed_kb")."
  else
    log_ok "Done! Removed $removed_count products, freed $(human_kb "$freed_kb")."
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --yes) YES=1 ;;
      --scan) SCAN_ONLY=1 ;;
      --dry-run) DRY_RUN=1 ;;
      --help|-h)
        print_help
        exit 0
        ;;
      *)
        log_err "Unknown argument: $1"
        print_help
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if [ "$IS_DARWIN" -ne 1 ] && [ "$IS_LINUX" -ne 1 ]; then
    log_warn "Unsupported OS: $OS. This script targets Linux/macOS."
  fi

  printf "%b\n\n" "${BOLD}🔍 Scanning for Claw products...${NC}"

  detect_openclaw
  detect_qclaw
  detect_workbuddy
  detect_zeroclaw
  detect_picoclaw
  detect_kimicli

  print_found_products

  if [ "${FOUND_COUNT:-0}" -eq 0 ]; then
    exit 0
  fi

  if [ "$SCAN_ONLY" -eq 1 ]; then
    log_info "--scan set, no removal performed."
    exit 0
  fi

  warn_root_maybe_needed

  SELECTED_KEYS=""
  SELECTED_NUMBERS=""
  ask_selection

  if [ -z "$SELECTED_KEYS" ]; then
    log_warn "No valid products selected. Nothing to do."
    exit 0
  fi

  if ! confirm_removal; then
    log_warn "Cancelled."
    exit 0
  fi

  printf "\n"
  remove_selected
}

main "$@"
