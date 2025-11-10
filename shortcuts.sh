#!/bin/bash
# Master control script for keyboard shortcuts
# Usage: ./shortcuts.sh [command] [toggle-name] [on|off]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available toggles
declare -A TOGGLES=(
    ["swap-alt-super"]="keyboard-mapping/swap-left-alt-super.sh"
    ["disable-super"]="gnome-shortcuts/disable-super-shortcuts.sh"
    ["super-tab"]="gnome-shortcuts/super-tab-switching.sh"
    ["caps-to-control"]="keyboard-mapping/caps-to-control.sh"
    ["super-cmd-q"]="gnome-shortcuts/super-cmd-q-quit.sh"
    ["macos-bindings"]="keyboard-mapping/universal-macos-bindings.sh"
)

show_help() {
    cat << EOF
Keyboard Shortcuts Manager

Usage: $0 <command> [toggle-name] [on|off|status]

Commands:
    list            List all available toggles and their status
    apply           Apply the recommended configuration
    toggle <name>   Toggle a specific setting
    on <name>       Turn on a specific setting
    off <name>      Turn off a specific setting
    status <name>   Show status of a specific setting
    help            Show this help message

Available toggles:
    swap-alt-super   - Swap left Alt and Super keys
    disable-super    - Disable default Super key shortcuts
    super-tab        - Enable Super+Tab for app/window switching
    caps-to-control   - Map Caps Lock to Control
    super-cmd-q       - Map Super+Q to close window (like Cmd+Q)
    macos-bindings    - macOS-like universal bindings via xremap (Cmd+C/V/X/Z/S/A, Caps+HJKL)

Examples:
    $0 list
    $0 apply
    $0 toggle swap-alt-super
    $0 on super-tab
    $0 status disable-super
    $0 on caps-to-control
    $0 on super-cmd-q

EOF
}

list_toggles() {
    echo "Available keyboard shortcuts toggles:"
    echo ""
    for name in "${!TOGGLES[@]}"; do
        script="${TOGGLES[$name]}"
        if [ -x "$SCRIPT_DIR/$script" ]; then
            status=$("$SCRIPT_DIR/$script" status 2>/dev/null || echo "UNKNOWN")
            printf "  %-20s %s\n" "$name" "$status"
        else
            printf "  %-20s %s\n" "$name" "SCRIPT NOT FOUND"
        fi
    done | sort
}

apply_recommended() {
    echo "Applying recommended keyboard shortcuts configuration..."
    echo ""
    
    # Swap Alt and Super on the left
    echo "1. Swapping left Alt and Super keys..."
    "$SCRIPT_DIR/${TOGGLES[swap-alt-super]}" on
    echo ""
    
    # Disable default Super shortcuts
    echo "2. Disabling default Super key shortcuts..."
    "$SCRIPT_DIR/${TOGGLES[disable-super]}" on
    echo ""
    
    # Enable Super+Tab switching
    echo "3. Enabling Super+Tab switching..."
    "$SCRIPT_DIR/${TOGGLES[super-tab]}" on
    echo ""
    
    echo "✓ Recommended configuration applied successfully!"
    echo ""
    echo "Summary:"
    echo "  - Left physical Alt key now acts as Super (Command/Windows key)"
    echo "  - Left physical Super key now acts as Alt"
    echo "  - Default GNOME Super shortcuts disabled"
    echo "  - Super+Tab switches between applications"
    echo "  - Super+\` switches between windows of same app"
}

run_toggle() {
    local name="$1"
    local action="$2"
    
    if [ -z "${TOGGLES[$name]}" ]; then
        echo "Error: Unknown toggle '$name'"
        echo ""
        echo "Available toggles:"
        for key in "${!TOGGLES[@]}"; do
            echo "  - $key"
        done | sort
        exit 1
    fi
    
    local script="${TOGGLES[$name]}"
    if [ ! -x "$SCRIPT_DIR/$script" ]; then
        echo "Error: Script not found or not executable: $script"
        exit 1
    fi
    
    "$SCRIPT_DIR/$script" "$action"
}

# Main command handling
case "${1:-help}" in
    list)
        list_toggles
        ;;
    apply)
        apply_recommended
        ;;
    toggle|on|off|status)
        if [ -z "$2" ]; then
            echo "Error: Toggle name required"
            echo "Usage: $0 $1 <toggle-name>"
            exit 1
        fi
        run_toggle "$2" "$1"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
