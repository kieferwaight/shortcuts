# Disable GNOME Super Key Shortcuts

## Overview

This runbook disables all default GNOME desktop keyboard shortcuts that use the Super (Windows/Command) key. This is useful when you want to repurpose the Super key for custom shortcuts or when using it in a way that conflicts with GNOME's defaults.

**Use Case**: Clear default Super key bindings to prevent conflicts when remapping keys or creating custom shortcuts.

**Scope**: Affects all default GNOME shortcuts including Activities overview, workspace switching, and application launchers.

**Persistence**: Changes are stored in dconf/gsettings and persist across reboots and sessions.

## Prerequisites

- GNOME desktop environment
- gsettings command line tool

## Current Status

Check current overlay key setting:

```sh {"description":"Check if Super key opens Activities overview","name":"check-overlay-key"}
gsettings get org.gnome.mutter overlay-key
```

List all Super key shortcuts currently configured:

```sh {"description":"List all active Super key shortcuts","name":"list-super-shortcuts"}
echo "=== Window Manager Shortcuts ==="
gsettings get org.gnome.desktop.wm.keybindings switch-input-source
gsettings get org.gnome.desktop.wm.keybindings switch-input-source-backward

echo -e "\n=== Shell Shortcuts (Super+1-9) ==="
for i in {1..9}; do
    echo "Super+$i: $(gsettings get org.gnome.shell.keybindings switch-to-application-$i)"
done

echo -e "\n=== Mutter Shortcuts ==="
gsettings get org.gnome.mutter.keybindings switch-monitor
```

## Disable All Super Shortcuts (Apply)

### Step 1: Disable Activities Overlay

The overlay key (usually Super) opens the Activities overview:

```sh {"action":"apply","description":"Disable Super key from opening Activities","name":"disable-overlay-key"}
gsettings set org.gnome.mutter overlay-key ''
echo "✓ Activities overlay disabled"
```

**What this does**: Prevents pressing Super alone from opening the Activities overview (the window/app launcher screen).

### Step 2: Clear Window Manager Shortcuts

Disable input source switching shortcuts:

```sh {"action":"apply","description":"Disable window manager Super shortcuts","name":"disable-wm-shortcuts"}
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"
echo "✓ Window manager Super shortcuts disabled"
```

**What this does**: Clears Super+Space (input source/language switching) and Super+Shift+Space.

### Step 3: Clear Application Switcher Shortcuts

Disable Super+1 through Super+9 for application switching:

```sh {"action":"apply","description":"Disable Super+number application shortcuts","name":"disable-app-shortcuts"}
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
    gsettings set org.gnome.shell.keybindings open-new-window-application-$i "[]"
done
echo "✓ Application switcher shortcuts (Super+1-9) disabled"
```

**What this does**:

- **Super+1 to Super+9**: Switch to application in dash (disabled)
- **Super+Ctrl+1 to Super+Ctrl+9**: Open new window of application (disabled)

### Step 4: Clear Overview Navigation

Disable workspace/overview navigation shortcuts:

```sh {"action":"apply","description":"Disable overview navigation shortcuts","name":"disable-overview-shortcuts"}
gsettings set org.gnome.shell.keybindings shift-overview-up "[]"
gsettings set org.gnome.shell.keybindings shift-overview-down "[]"
echo "✓ Overview navigation shortcuts disabled"
```

**What this does**: Clears Super+Alt+Up and Super+Alt+Down (overview workspace switching).

### Step 5: Clear Mutter Shortcuts

Disable display and input capture shortcuts:

```sh {"action":"apply","description":"Disable mutter Super key shortcuts","name":"disable-mutter-shortcuts"}
gsettings set org.gnome.mutter.keybindings cancel-input-capture "[]"
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"
echo "✓ Mutter shortcuts updated (Super removed, hardware keys preserved)"
```

**What this does**:

- Removes Super+Shift+Escape (cancel input capture)
- Removes Super+P from monitor switching, keeps XF86Display hardware key

### Step 6: Clear Media Key Shortcuts

Remove Super key from media shortcuts:

```sh {"action":"apply","description":"Disable Super key media shortcuts","name":"disable-media-shortcuts"}
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
gsettings set org.gnome.settings-daemon.plugins.media-keys touchpad-toggle-static "['XF86TouchpadToggle']"
echo "✓ Media key shortcuts updated (Super removed, hardware keys preserved)"
```

**What this does**:

- Removes Super+O from video lock rotation
- Removes Super+Ctrl from touchpad toggle
- Preserves hardware function keys

### Step 7: Mark as Disabled

Create state tracking file:

```sh {"action":"apply","description":"Create state file to track disabled status","name":"mark-disabled"}
touch "$HOME/.config/gnome-super-shortcuts-disabled"
echo "✓ State file created"
```

### All Steps Combined

Run all disable steps at once:

```sh {"action":"apply","description":"Disable all Super key shortcuts in one command","name":"disable-all-shortcuts"}
# Overlay key
gsettings set org.gnome.mutter overlay-key ''

# Window manager
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

# Shell - application switching
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
    gsettings set org.gnome.shell.keybindings open-new-window-application-$i "[]"
done

# Shell - overview
gsettings set org.gnome.shell.keybindings shift-overview-up "[]"
gsettings set org.gnome.shell.keybindings shift-overview-down "[]"

# Mutter
gsettings set org.gnome.mutter.keybindings cancel-input-capture "[]"
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"

# Media keys
gsettings set org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static "['XF86RotationLockToggle']"
gsettings set org.gnome.settings-daemon.plugins.media-keys touchpad-toggle-static "['XF86TouchpadToggle']"

# State file
touch "$HOME/.config/gnome-super-shortcuts-disabled"

echo "✓ All Super key shortcuts disabled"
```

## Restore Default Shortcuts (Undo)

Reset all shortcuts to GNOME defaults:

```sh {"action":"undo","description":"Restore all default GNOME Super key shortcuts","name":"restore-all-shortcuts"}
# Overlay key
gsettings reset org.gnome.mutter overlay-key

# Window manager
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward

# Shell - application switching
for i in {1..9}; do
    gsettings reset org.gnome.shell.keybindings switch-to-application-$i
    gsettings reset org.gnome.shell.keybindings open-new-window-application-$i
done

# Shell - overview
gsettings reset org.gnome.shell.keybindings shift-overview-up
gsettings reset org.gnome.shell.keybindings shift-overview-down

# Mutter
gsettings reset org.gnome.mutter.keybindings cancel-input-capture
gsettings reset org.gnome.mutter.keybindings switch-monitor

# Media keys
gsettings reset org.gnome.settings-daemon.plugins.media-keys rotate-video-lock-static
gsettings reset org.gnome.settings-daemon.plugins.media-keys touchpad-toggle-static

# State file
rm -f "$HOME/.config/gnome-super-shortcuts-disabled"

echo "✓ All default Super key shortcuts restored"
```

## Understanding gsettings

### What is gsettings?

gsettings is the command-line interface to GNOME's configuration system (dconf). It stores desktop environment settings persistently.

View a setting's description:

```sh {"description":"Show description of a gsettings key","name":"describe-setting"}
gsettings describe org.gnome.mutter overlay-key
```

List all keys in a schema:

```sh {"description":"List all available keys in a schema","name":"list-schema-keys"}
gsettings list-keys org.gnome.desktop.wm.keybindings
```

### Schema Reference

Key schemas used in this runbook:

- **org.gnome.mutter**: Window manager settings (overlay-key)
- **org.gnome.desktop.wm.keybindings**: Window management shortcuts
- **org.gnome.shell.keybindings**: GNOME Shell shortcuts
- **org.gnome.mutter.keybindings**: Display and system shortcuts
- **org.gnome.settings-daemon.plugins.media-keys**: Media control shortcuts

## Default Shortcuts Reference

Shortcuts disabled by this runbook:

| Shortcut | Action | Schema |
|----------|--------|--------|
| Super | Open Activities | org.gnome.mutter overlay-key |
| Super+Space | Switch input source | org.gnome.desktop.wm.keybindings |
| Super+1-9 | Switch to app N in dash | org.gnome.shell.keybindings |
| Super+Ctrl+1-9 | Open new window of app N | org.gnome.shell.keybindings |
| Super+Alt+Up/Down | Navigate overview | org.gnome.shell.keybindings |
| Super+P | Switch monitor | org.gnome.mutter.keybindings |
| Super+O | Rotate video lock | media-keys |
| Super+Shift+Escape | Cancel input capture | org.gnome.mutter.keybindings |

## Troubleshooting

### Setting Won't Change

If a setting refuses to change, check if it's locked:

```sh {"description":"Check if settings are locked by policy","name":"check-locked"}
gsettings writable org.gnome.mutter overlay-key
```

### Restore a Single Setting

To restore just one setting without affecting others:

```sh {"description":"Example: restore just the overlay key","name":"restore-single"}
gsettings reset org.gnome.mutter overlay-key
```

### Export Current Settings

Backup settings before making changes:

```sh {"description":"Export current keybinding settings","name":"backup-settings"}
dconf dump /org/gnome/desktop/wm/keybindings/ > ~/gnome-keybindings-backup.conf
dconf dump /org/gnome/shell/keybindings/ >> ~/gnome-keybindings-backup.conf
echo "✓ Settings backed up to ~/gnome-keybindings-backup.conf"
```

Restore from backup:

```sh {"description":"Restore settings from backup file","name":"restore-backup"}
dconf load /org/gnome/desktop/wm/keybindings/ < ~/gnome-keybindings-backup.conf
echo "✓ Settings restored from backup"
```
