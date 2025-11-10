#!/bin/bash
# Toggle: macOS-like universal bindings (Super=Cmd, Ctrl-based navigation)
# Requires: xremap (https://github.com/k0kubun/xremap) with uinput permissions
# Usage: ./universal-macos-bindings.sh {on|off|toggle|status}

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/xremap-macos.yml"
PID_FILE="$HOME/.config/xremap-macos.pid"
STATE_FILE="$HOME/.config/keyboard-mapping-universal-macos-bindings"
LOG_FILE="$HOME/.config/xremap-macos.log"

start_xremap() {
    if ! command -v xremap >/dev/null 2>&1; then
        echo "Error: xremap is not installed."
        echo "Install: https://github.com/k0kubun/xremap#installation"
        echo "Then re-run: $0 on"
        exit 1
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config not found at $CONFIG_FILE"
        exit 1
    fi

    # If already running, stop first
    stop_xremap || true

    nohup xremap "$CONFIG_FILE" >"$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    sleep 0.2
    if ps -p "$(cat "$PID_FILE" 2>/dev/null || echo 0)" >/dev/null 2>&1; then
        touch "$STATE_FILE"
        echo "✓ macOS-like universal bindings ENABLED (xremap running)"
    else
        echo "Error: Failed to start xremap. See log: $LOG_FILE"
        exit 1
    fi
}

stop_xremap() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null || echo 0)
        if [ -n "$PID" ] && ps -p "$PID" >/dev/null 2>&1; then
            kill "$PID" || true
        fi
        rm -f "$PID_FILE"
    fi
    rm -f "$STATE_FILE"
    echo "✓ macOS-like universal bindings DISABLED"
}

is_enabled() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|enable)
        start_xremap
        ;;
    off|disable)
        stop_xremap
        ;;
    toggle)
        if is_enabled; then
            stop_xremap
        else
            start_xremap
        fi
        ;;
    status)
        if is_enabled; then
            echo "ENABLED"
        else
            echo "DISABLED"
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|toggle|status}"
        echo "  on/enable   - Start xremap with macOS-like bindings"
        echo "  off/disable - Stop xremap and disable bindings"
        echo "  toggle      - Toggle bindings (default)"
        echo "  status      - Show current state"
        exit 1
        ;;
esac
