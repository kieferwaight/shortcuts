# Super+Tab Application Switching

## Overview
This runbook configures GNOME to use Super+Tab for application and window switching, similar to how Alt+Tab works by default. This creates a more macOS-like experience where the "command" key (Super) is used for switching between apps.

**Use Case**: Enable intuitive application switching using the Super key, especially useful after swapping Alt and Super keys physically.

**Scope**: Configures two keyboard shortcuts:
- Super+Tab: Switch between applications
- Super+`: Switch between windows of the same application

**Persistence**: Changes are stored in gsettings/dconf and persist across reboots and sessions.

## Prerequisites
- GNOME desktop environment
- gsettings command line tool

## Current Status

Check current application switching shortcuts:

```sh {"name":"check-current-shortcuts","description":"Check current app switching key bindings"}
echo "=== Application Switching ==="
echo "switch-applications: $(gsettings get org.gnome.desktop.wm.keybindings switch-applications)"
echo "switch-applications-backward: $(gsettings get org.gnome.desktop.wm.keybindings switch-applications-backward)"

echo -e "\n=== Window Group Switching ==="
echo "switch-group: $(gsettings get org.gnome.desktop.wm.keybindings switch-group)"
echo "switch-group-backward: $(gsettings get org.gnome.desktop.wm.keybindings switch-group-backward)"
```

Check if enabled:

```sh {"name":"check-enabled-status","description":"Check if Super+Tab switching is enabled"}
if [ -f "$HOME/.config/gnome-super-tab-enabled" ]; then
    echo "Status: ENABLED"
else
    echo "Status: DISABLED"
fi
```

## Enable Super+Tab Switching (Apply)

### Configure Application Switching

Enable Super+Tab to switch between applications:

```sh {"name":"enable-app-switching","description":"Enable Super+Tab for application switching","action":"apply"}
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
echo "✓ Super+Tab: Switch between applications"
echo "✓ Super+Shift+Tab: Switch applications backwards"
```

**What this does**:
- **Super+Tab**: Opens the application switcher and cycles forward through running applications
- **Super+Shift+Tab**: Cycles backward through running applications

### Configure Window Group Switching

Enable Super+` to switch between windows of the same app:

```sh {"name":"enable-window-switching","description":"Enable Super+grave for window switching","action":"apply"}
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>grave']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>grave']"
echo "✓ Super+\`: Switch between windows of same application"
echo "✓ Super+Shift+\`: Switch windows backwards"
```

**What this does**:
- **Super+`**: Cycles through windows of the currently active application
- **Super+Shift+`**: Cycles backward through windows of the current application

**Note**: The backtick/grave key (`) is typically located above Tab on US keyboards.

### Mark as Enabled

Create state tracking file:

```sh {"name":"mark-enabled","description":"Create state file to track enabled status","action":"apply"}
touch "$HOME/.config/gnome-super-tab-enabled"
echo "✓ State file created"
```

### All Steps Combined

Enable both shortcuts at once:

```sh {"name":"enable-all-switching","description":"Enable all Super+Tab switching shortcuts","action":"apply"}
# Application switching
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"

# Window group switching
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>grave']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>grave']"

# State file
touch "$HOME/.config/gnome-super-tab-enabled"

echo "✓ Super+Tab switching enabled"
echo ""
echo "Shortcuts configured:"
echo "  Super+Tab       - Switch between applications"
echo "  Super+Shift+Tab - Switch applications backwards"
echo "  Super+\`         - Switch windows of same application"
echo "  Super+Shift+\`   - Switch windows backwards"
```

## Disable Super+Tab Switching (Undo)

Clear the Super+Tab shortcuts:

```sh {"name":"disable-all-switching","description":"Disable Super+Tab switching shortcuts","action":"undo"}
# Clear application switching
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

# Clear window group switching
gsettings set org.gnome.desktop.wm.keybindings switch-group "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "[]"

# Remove state file
rm -f "$HOME/.config/gnome-super-tab-enabled"

echo "✓ Super+Tab switching disabled"
```

## Restore GNOME Defaults

Reset to GNOME's default Alt+Tab behavior:

```sh {"name":"restore-defaults","description":"Restore default Alt+Tab switching","action":"undo"}
gsettings reset org.gnome.desktop.wm.keybindings switch-applications
gsettings reset org.gnome.desktop.wm.keybindings switch-applications-backward
gsettings reset org.gnome.desktop.wm.keybindings switch-group
gsettings reset org.gnome.desktop.wm.keybindings switch-group-backward

rm -f "$HOME/.config/gnome-super-tab-enabled"

echo "✓ Restored to default Alt+Tab behavior"
```

## Understanding Window Switching

### Application vs Window Switching

GNOME distinguishes between two types of switching:

**Application Switching** (`switch-applications`):
- Groups all windows of the same application together
- Shows application icons in the switcher
- Default: Alt+Tab
- One entry per application, regardless of window count

**Window Group Switching** (`switch-group`):
- Switches between windows of the currently focused application
- Shows individual window thumbnails
- Default: Alt+` (above Tab)
- Only shows windows from the same app

### Key Notation in gsettings

Keyboard shortcuts use special notation:
- `<Super>`: Super/Windows/Command key
- `<Shift>`: Shift key
- `<Control>` or `<Ctrl>`: Control key
- `<Alt>`: Alt key
- `grave`: Backtick/grave accent key (`)

Multiple modifiers are combined: `<Shift><Super>Tab`

### Why Arrays?

Shortcuts are stored as arrays (`['<Super>Tab']`) because gsettings allows multiple key combinations for the same action:

```sh {"name":"multiple-bindings-example","description":"Example: assign multiple keys to same action"}
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"
```

This would make both Super+Tab and Alt+Tab switch applications.

## Common Configurations

### macOS-like Configuration

Super for switching (recommended with swapped Alt/Super keys):

```sh {"name":"macos-like-config","description":"Configure macOS-style switching (Command+Tab)","action":"apply"}
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>grave']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>grave']"
echo "✓ macOS-like configuration applied"
```

### Keep Both Alt and Super

Use both Alt and Super for switching:

```sh {"name":"dual-switching-config","description":"Enable both Alt+Tab and Super+Tab"}
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
echo "✓ Both Alt+Tab and Super+Tab enabled"
```

### Windows-like Alt+Tab Only

Use only Alt+Tab (GNOME default):

```sh {"name":"windows-like-config","description":"Configure Windows-style switching (Alt+Tab only)"}
gsettings reset org.gnome.desktop.wm.keybindings switch-applications
gsettings reset org.gnome.desktop.wm.keybindings switch-applications-backward
gsettings reset org.gnome.desktop.wm.keybindings switch-group
gsettings reset org.gnome.desktop.wm.keybindings switch-group-backward
echo "✓ Windows-like configuration (Alt+Tab)"
```

## Troubleshooting

### Super+Tab Opens Activities Instead

If pressing Super+Tab opens the Activities overview instead of switching apps, the overlay key is still active:

```sh {"name":"fix-overlay-conflict","description":"Disable overlay key to fix Super+Tab conflict"}
gsettings set org.gnome.mutter overlay-key ''
echo "✓ Overlay key disabled - Super+Tab should now work"
```

### Nothing Happens When Pressing Super+Tab

Check if the shortcut is actually set:

```sh {"name":"verify-shortcuts","description":"Verify shortcuts are properly configured"}
echo "Checking configuration..."
SWITCH_APPS=$(gsettings get org.gnome.desktop.wm.keybindings switch-applications)
if [[ "$SWITCH_APPS" == *"Super"* ]]; then
    echo "✓ Super+Tab is configured"
else
    echo "✗ Super+Tab is NOT configured"
    echo "Current value: $SWITCH_APPS"
fi
```

### Test Keyboard Input

Verify your Super key is being detected:

```sh {"name":"test-super-key","description":"Test if Super key is detected by system"}
echo "Press Super key and another key, then Ctrl+C to exit..."
xev | grep -A2 --line-buffered '^KeyPress' | grep -i super
```

Press Ctrl+C to stop the test.

## Related Settings

View all window management shortcuts:

```sh {"name":"list-all-wm-shortcuts","description":"List all window manager keyboard shortcuts"}
gsettings list-recursively org.gnome.desktop.wm.keybindings | grep -v "@as \[\]" | sort
```

Export switching shortcuts for backup:

```sh {"name":"export-switching-config","description":"Export current switching configuration"}
echo "switch-applications: $(gsettings get org.gnome.desktop.wm.keybindings switch-applications)"
echo "switch-applications-backward: $(gsettings get org.gnome.desktop.wm.keybindings switch-applications-backward)"
echo "switch-group: $(gsettings get org.gnome.desktop.wm.keybindings switch-group)"
echo "switch-group-backward: $(gsettings get org.gnome.desktop.wm.keybindings switch-group-backward)"
```
