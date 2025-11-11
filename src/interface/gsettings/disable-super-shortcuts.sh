#!/bin/bash
# Toggle: Disable all default Super key shortcuts in GNOME
# Usage: ./disable-super-shortcuts.sh [on|off]

set -e

STATE_FILE="$HOME/.config/gnome-super-shortcuts-disabled"

disable_shortcuts() {
    # Disable the overlay key (Super key to open Activities overview)
    gsettings set org.gnome.mutter overlay-key ''

    # Window Manager Keybindings
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

    # Shell Keybindings - Application switching (Super+1-9)
    for i in {1..9}; do
        gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
        gsettings set org.gnome.shell.keybindings open-new-window-application-$i "[]"
    done

    # Shell Keybindings - Overview navigation
    gsettings set org.gnome.shell.keybindings shift-overview-up "[]"
    gsettings set org.gnome.shell.keybindings shift-overview-down "[]"

    # Mutter Keybindings
    gsettings set org.gnome.mutter.keybindings cancel-input-capture "[]"
    gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"

    # Media Keys
    gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys touchpad-toggle-static "['XF86TouchpadToggle']"

    touch "$STATE_FILE"
    echo "✓ Super key shortcuts are DISABLED"
}

enable_shortcuts() {
    # Restore defaults
    gsettings reset org.gnome.mutter overlay-key

    # Window Manager Keybindings
    gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
    gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward

    # Shell Keybindings
    for i in {1..9}; do
        gsettings reset org.gnome.shell.keybindings switch-to-application-$i
        gsettings reset org.gnome.shell.keybindings open-new-window-application-$i
    done

    gsettings reset org.gnome.shell.keybindings shift-overview-up
    gsettings reset org.gnome.shell.keybindings shift-overview-down

    # Mutter Keybindings
    gsettings reset org.gnome.mutter.keybindings cancel-input-capture
    gsettings reset org.gnome.mutter.keybindings switch-monitor

    # Media Keys
    gsettings reset org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static
    gsettings reset org.gnome.settings-daemon.plugins.media-keys touchpad-toggle-static

    rm -f "$STATE_FILE"
    echo "✓ Super key shortcuts are ENABLED (default)"
}

is_disabled() {
    [ -f "$STATE_FILE" ]
}

case "${1:-toggle}" in
    on|disable)
        disable_shortcuts
        ;;
    off|enable)
        enable_shortcuts
        ;;
    toggle)
        if is_disabled; then
            enable_shortcuts
        else
            disable_shortcuts
        fi
        ;;
    status)
        if is_disabled; then
            echo "DISABLED"
        else
            echo "ENABLED"
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|toggle|status}"
        echo "  on/disable  - Disable Super key shortcuts"
        echo "  off/enable  - Enable Super key shortcuts (restore defaults)"
        echo "  toggle      - Toggle between disabled and enabled (default)"
        echo "  status      - Show current state"
        exit 1
        ;;
esac
