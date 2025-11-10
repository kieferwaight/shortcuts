# Runbook Index

Quick reference guide for all keyboard shortcut configuration runbooks.

## Available Runbooks

### 1. [Swap Left Alt and Super Keys](runbooks/swap-left-alt-super.md)

**Category**: Keyboard Mapping | **Tool**: xmodmap

Physically swaps the left Alt and Super keys to create a macOS-like keyboard layout where the "command" key is in the Alt position.

**Key Actions**:

- Swap keys: Changes keycode mappings via xmodmap
- Restore: Reverts to normal key positions
- Persistence: Add to startup applications

**State**: SWAPPED or NORMAL

---

### 2. [Disable GNOME Super Key Shortcuts](runbooks/disable-super-shortcuts.md)

**Category**: GNOME Shortcuts | **Tool**: gsettings

Disables all default GNOME desktop shortcuts that use the Super key to prevent conflicts when remapping or customizing keyboard behavior.

**Key Actions**:

- Disable: Clears Activities overlay, Super+1-9, Super+P, etc.
- Restore: Resets to GNOME defaults
- Backup/restore: Export and import settings with dconf

**Shortcuts Disabled**:

- Super (alone): Activities overview
- Super+Space: Input source switching
- Super+1-9: Application launcher
- Super+P: Display switching
- Super+Alt+↑/↓: Workspace navigation
- And more...

**State**: DISABLED or ENABLED

---

### 3. [Enable Super+Tab Switching](runbooks/super-tab-switching.md)

**Category**: GNOME Shortcuts | **Tool**: gsettings

Configures Super+Tab for application switching and Super+` for window switching, creating a macOS-like experience.

**Key Actions**:

- Enable: Configure Super+Tab and Super+`
- Disable: Clear Super+Tab shortcuts
- Multiple configs: macOS-like, Windows-like, dual-key

**Shortcuts Configured**:

- Super+Tab: Switch between applications
- Super+Shift+Tab: Switch applications backward
- Super+`: Switch between windows of same app
- Super+Shift+`: Switch windows backward

**State**: ENABLED or DISABLED

---

### 4. [Map Caps Lock to Control](runbooks/caps-to-control.md)
**Category**: Keyboard Mapping | **Tool**: xmodmap

Convert Caps Lock into Control for easier shortcuts and navigation.

**State**: ENABLED or DISABLED

---

### 5. [Map Super+Q to Close Window (Cmd+Q)](runbooks/super-cmd-q-quit.md)
**Category**: GNOME Shortcuts | **Tool**: gsettings

Adds `<Super>q` to window close bindings while keeping Alt+F4.

**State**: ENABLED or DISABLED

---

### 6. [macOS-like Universal Bindings (xremap)](runbooks/macos-bindings.md)
**Category**: Keyboard Remapping | **Tool**: xremap

Universal Cmd+C/V/X/Z/S/A and Caps+H/J/K/L navigation across apps via xremap.

**State**: ENABLED or DISABLED

---

## Quick Reference

### Apply All (Recommended)

For a complete macOS-like keyboard experience:

```sh {"description":"Apply all recommended configurations","name":"apply-all-runbooks"}
cd /home/sysadmin/Projects/system/shortcuts
./shortcuts.sh apply
```

This applies:

1. ✓ Swap left Alt and Super keys
2. ✓ Disable default Super shortcuts
3. ✓ Enable Super+Tab switching

Optional (apply individually):
- Caps→Control
- Cmd+Q close window
- macOS-like universal bindings (xremap)

### Check Status

```sh {"description":"Check status of all configurations","name":"check-all-status"}
cd /home/sysadmin/Projects/system/shortcuts
./shortcuts.sh list
```

### Individual Control

```sh {"description":"Control individual settings","name":"control-individual"}
# Toggle a setting
./shortcuts.sh toggle swap-alt-super

# Turn something on
./shortcuts.sh on super-tab

# Turn something off
./shortcuts.sh off disable-super

# Check status
./shortcuts.sh status swap-alt-super
```

---

## Runbook Structure

Each runbook follows this format:

1. **Overview**: What it does and why you'd use it
2. **Prerequisites**: Required tools and environment
3. **Current Status**: Commands to check current state
4. **Apply**: Step-by-step instructions to enable
5. **Undo**: How to reverse the changes
6. **Understanding**: Educational content explaining how it works
7. **Troubleshooting**: Common issues and solutions
8. **Technical Details**: Deep dive into implementation

---

## Tools Reference

### xmodmap

**Purpose**: Remap physical keys in X Window System

**Common commands**:

```sh {"description":"Common xmodmap commands","name":"xmodmap-reference"}
# View all key mappings
xmodmap -pke

# View modifier mappings
xmodmap -pm

# Apply a mapping
xmodmap -e "keycode 64 = Super_L"

# Reset to defaults
setxkbmap -layout us
```

### gsettings

**Purpose**: Configure GNOME desktop settings

**Common commands**:

```sh {"description":"Common gsettings commands","name":"gsettings-reference"}
# Get a setting
gsettings get org.gnome.mutter overlay-key

# Set a setting
gsettings set org.gnome.mutter overlay-key ''

# Reset to default
gsettings reset org.gnome.mutter overlay-key

# Describe a setting
gsettings describe org.gnome.mutter overlay-key

# List all keys in a schema
gsettings list-keys org.gnome.desktop.wm.keybindings
```

### dconf

**Purpose**: Low-level GNOME configuration database

**Common commands**:

```sh {"description":"Common dconf commands","name":"dconf-reference"}
# Export settings
dconf dump /org/gnome/desktop/wm/keybindings/ > backup.conf

# Import settings
dconf load /org/gnome/desktop/wm/keybindings/ < backup.conf

# Watch for changes
dconf watch /
```

---

## Configuration Files

### State Files

Location: `~/.config/`

- `keyboard-mapping-swap-left-alt-super`: Tracks Alt/Super swap state
- `gnome-super-shortcuts-disabled`: Tracks Super shortcuts state
- `gnome-super-tab-enabled`: Tracks Super+Tab state

### Startup Files

Location: `~/.config/autostart/`

- `swap-alt-super.desktop`: Auto-apply key swap on login

### Configuration Database

Location: `~/.config/dconf/user`

Binary database containing all gsettings values. Use `dconf` tool to interact.

---

## Schemas Reference

### org.gnome.mutter

Window manager settings

- `overlay-key`: Key to open Activities (default: Super_L)
- `dynamic-workspaces`: Auto-create workspaces
- `edge-tiling`: Window tiling behavior

### org.gnome.desktop.wm.keybindings

Window management shortcuts

- `switch-applications`: Application switcher (default: Alt+Tab)
- `switch-group`: Window group switcher (default: Alt+`)
- `switch-input-source`: Language/input switching

### org.gnome.shell.keybindings

GNOME Shell shortcuts

- `switch-to-application-[1-9]`: Quick launch (Super+1-9)
- `open-new-window-application-[1-9]`: New window (Super+Ctrl+1-9)
- `shift-overview-up/down`: Workspace navigation

### org.gnome.mutter.keybindings

System-level shortcuts

- `switch-monitor`: Display switching (Super+P)
- `cancel-input-capture`: Cancel capture (Super+Shift+Esc)

### org.gnome.settings-daemon.plugins.media-keys

Media and special keys

- `rotate-video-lock-static`: Rotation lock
- `touchpad-toggle-static`: Touchpad enable/disable

---

## Common Workflows

### First Time Setup

```sh {"description":"Complete first-time keyboard setup","name":"first-time-setup"}
cd /home/sysadmin/Projects/system/shortcuts

# Check current state
./shortcuts.sh list

# Apply recommended configuration
./shortcuts.sh apply

# Make key swap persistent
docs/runbooks/swap-left-alt-super.md
# (Run the "add-to-startup" code block)
```

### Troubleshooting

```sh {"description":"Debug keyboard configuration issues","name":"troubleshooting-workflow"}
# Check current state
./shortcuts.sh list

# Check specific toggle status
./shortcuts.sh status swap-alt-super

# View state files
ls -la ~/.config/ | grep -E "(keyboard|gnome|super)"

# Test xmodmap
xmodmap -pm

# Test gsettings
gsettings get org.gnome.mutter overlay-key
```

### Reset Everything

```sh {"description":"Reset all keyboard configurations to default","name":"reset-everything"}
cd /home/sysadmin/Projects/system/shortcuts

# Turn off all toggles
./shortcuts.sh off swap-alt-super
./shortcuts.sh off disable-super
./shortcuts.sh off super-tab

# Clean up state files
rm -f ~/.config/keyboard-mapping-swap-left-alt-super
rm -f ~/.config/gnome-super-shortcuts-disabled
rm -f ~/.config/gnome-super-tab-enabled

# Remove startup script
rm -f ~/.config/autostart/swap-alt-super.desktop
```

---

## Related Documentation

- [Main README](../README.md): Project overview and quick start
- [GNOME Keybinding Documentation](https://help.gnome.org/users/gnome-help/stable/keyboard-shortcuts-set.html)
- [xmodmap Manual](https://linux.die.net/man/1/xmodmap)
- [gsettings Manual](https://man.archlinux.org/man/gsettings.1)
