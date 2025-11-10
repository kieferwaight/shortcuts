#!/bin/bash
# Toggle: Enable Super+Tab and Super+` for application/window switching
# Usage: ./super-tab-switching.sh [on|off]

set -e

STATE_FILE="$HOME/.config/gnome-super-tab-enabled"

enable_super_tab() {
    # Super+Tab to switch between applications
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"

    # Super+` to switch between windows of the same application
    gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>grave']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>grave']"

    touch "$STATE_FILE"
    echo "✓ Super+Tab switching is ENABLED"
    echo "  Super+Tab       - Switch between applications"
    echo "  Super+Shift+Tab - Switch applications backwards"
    echo "  Super+\`         - Switch between windows of same application"
    echo "  Super+Shift+\`   - Switch windows backwards"
}

disable_super_tab() {
    # Clear the shortcuts
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-group "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "[]"

    rm -f "$STATE_FILE"
    echo "✓ Super+Tab switching is DISABLED"
}

is_enabled() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|enable)
        enable_super_tab
        ;;
    off|disable)
        disable_super_tab
        ;;
    toggle)
        if is_enabled; then
            disable_super_tab
        else
            enable_super_tab
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
        echo "  on/enable  - Enable Super+Tab switching"
        echo "  off/disable - Disable Super+Tab switching"
        echo "  toggle     - Toggle between enabled and disabled (default)"
        echo "  status     - Show current state"
        exit 1
        ;;
esac
