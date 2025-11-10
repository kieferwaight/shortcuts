#!/bin/bash
# Toggle: Map Super+Q (Command+Q) to close the current window
# Usage: ./super-cmd-q-quit.sh {on|off|toggle|status}

set -e

STATE_FILE="$HOME/.config/gnome-super-cmd-q-enabled"

enable_cmd_q_quit() {
    # Preserve Alt+F4 and add Super+Q as a close-window shortcut
    gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>q']"
    touch "$STATE_FILE"
    echo "✓ Super+Q now closes the current window"
}

disable_cmd_q_quit() {
    # Restore to GNOME default
    gsettings reset org.gnome.desktop.wm.keybindings close
    rm -f "$STATE_FILE"
    echo "✓ Super+Q close-window mapping removed (defaults restored)"
}

is_enabled() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|enable)
        enable_cmd_q_quit
        ;;
    off|disable)
        disable_cmd_q_quit
        ;;
    toggle)
        if is_enabled; then
            disable_cmd_q_quit
        else
            enable_cmd_q_quit
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
        echo "  on/enable   - Map Super+Q to close-window"
        echo "  off/disable - Remove mapping and restore default"
        echo "  toggle      - Toggle mapping (default)"
        echo "  status      - Show current state"
        exit 1
        ;;
esac
