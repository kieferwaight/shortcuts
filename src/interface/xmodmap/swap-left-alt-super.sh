#!/bin/bash
# Toggle: Swap left Alt and Super keys using xmodmap
# Usage: ./swap-left-alt-super.sh [on|off]

set -e

STATE_FILE="$HOME/.config/keyboard-mapping-swap-left-alt-super"

apply_swap() {
    # Prefer XKB option (more reliable than xmodmap)
    if command -v setxkbmap >/dev/null 2>&1; then
        setxkbmap -option altwin:swap_lalt_lwin
    else
        echo "Error: setxkbmap not found; cannot apply swap reliably" >&2
        exit 1
    fi
    touch "$STATE_FILE"
    echo "✓ Left Alt and Super keys are SWAPPED (via XKB altwin:swap_lalt_lwin)"
}

remove_swap() {
    if command -v setxkbmap >/dev/null 2>&1; then
        # Clear all options; if you have other options, reapply them afterwards
        setxkbmap -option
    else
        echo "Error: setxkbmap not found; cannot remove swap reliably" >&2
        exit 1
    fi
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
