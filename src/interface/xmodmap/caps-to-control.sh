#!/bin/bash
# Toggle: Map Caps Lock to Control (Caps -> Control)
# Usage: ./caps-to-control.sh {on|off|toggle|status}

set -e

STATE_FILE="$HOME/.config/keyboard-mapping-caps-to-control"

apply_caps_to_control() {
    # Remove Caps_Lock from lock modifier and remap to Control_L
    xmodmap -e "remove lock = Caps_Lock"
    xmodmap -e "keycode 66 = Control_L"
    xmodmap -e "add control = Control_L"
    touch "$STATE_FILE"
    echo "✓ Caps Lock now acts as Control (Caps->Ctrl)"
}

remove_caps_to_control() {
    # Remove Control_L from control modifier and restore Caps_Lock
    xmodmap -e "remove control = Control_L"
    xmodmap -e "keycode 66 = Caps_Lock"
    xmodmap -e "add lock = Caps_Lock"
    rm -f "$STATE_FILE"
    echo "✓ Caps Lock restored to normal behavior"
}

is_enabled() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|enable)
        apply_caps_to_control
        ;;
    off|disable)
        remove_caps_to_control
        ;;
    toggle)
        if is_enabled; then
            remove_caps_to_control
        else
            apply_caps_to_control
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
        echo "  on/enable   - Map Caps Lock to Control"
        echo "  off/disable - Restore Caps Lock"
        echo "  toggle      - Toggle mapping (default)"
        echo "  status      - Show current state"
        exit 1
        ;;
esac
