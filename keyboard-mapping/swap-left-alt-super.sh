#!/bin/bash
# Toggle: Swap left Alt and Super keys using xmodmap
# Usage: ./swap-left-alt-super.sh [on|off]

set -e

STATE_FILE="$HOME/.config/keyboard-mapping-swap-left-alt-super"

apply_swap() {
    xmodmap -e "remove mod1 = Alt_L"
    xmodmap -e "remove mod4 = Super_L"
    xmodmap -e "keycode 64 = Super_L"
    xmodmap -e "keycode 133 = Alt_L"
    xmodmap -e "add mod1 = Alt_L"
    xmodmap -e "add mod4 = Super_L"
    touch "$STATE_FILE"
    echo "✓ Left Alt and Super keys are SWAPPED"
}

remove_swap() {
    xmodmap -e "remove mod1 = Alt_L"
    xmodmap -e "remove mod4 = Super_L"
    xmodmap -e "keycode 64 = Alt_L"
    xmodmap -e "keycode 133 = Super_L"
    xmodmap -e "add mod1 = Alt_L"
    xmodmap -e "add mod4 = Super_L"
    rm -f "$STATE_FILE"
    echo "✓ Left Alt and Super keys are NORMAL"
}

is_swapped() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|swap)
        apply_swap
        ;;
    off|normal)
        remove_swap
        ;;
    toggle)
        if is_swapped; then
            remove_swap
        else
            apply_swap
        fi
        ;;
    status)
        if is_swapped; then
            echo "SWAPPED"
        else
            echo "NORMAL"
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|toggle|status}"
        echo "  on/swap   - Swap left Alt and Super keys"
        echo "  off/normal - Restore normal key mapping"
        echo "  toggle    - Toggle between swapped and normal (default)"
        echo "  status    - Show current state"
        exit 1
        ;;
esac
