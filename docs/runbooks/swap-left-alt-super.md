# Swap Left Alt and Super Keys

## Overview
This runbook configures xmodmap to swap the physical left Alt and Super (Windows/Command) keys on your keyboard. After swapping, pressing the physical Alt key will send Super key events, and pressing the physical Super key will send Alt key events.

**Use Case**: Makes Linux keyboard shortcuts feel more like macOS by moving the "command" key position to where the Alt key normally sits.

**Scope**: Only affects the left side keys. Right Alt and right Super (if present) remain unchanged.

**Persistence**: Changes only last for the current X session. You'll need to run this after each login or add it to your startup applications.

## Prerequisites
- X Window System (xmodmap)
- GNOME desktop environment (Ubuntu/Fedora/Debian with GNOME)

## Current Status

Check if keys are currently swapped:

```sh {"name":"check-swap-status","description":"Check if left Alt and Super keys are swapped"}
if [ -f "$HOME/.config/keyboard-mapping-swap-left-alt-super" ]; then
    echo "Status: SWAPPED"
else
    echo "Status: NORMAL"
fi
```

## Swap Keys (Apply)

Swap the left Alt and Super keys:

```sh {"name":"swap-keys-on","description":"Swap left Alt and Super keys","action":"apply"}
xmodmap -e "remove mod1 = Alt_L"
xmodmap -e "remove mod4 = Super_L"
xmodmap -e "keycode 64 = Super_L"
xmodmap -e "keycode 133 = Alt_L"
xmodmap -e "add mod1 = Alt_L"
xmodmap -e "add mod4 = Super_L"
touch "$HOME/.config/keyboard-mapping-swap-left-alt-super"
echo "✓ Left Alt and Super keys are SWAPPED"
```

**What this does:**
1. Removes Alt_L from modifier group mod1
2. Removes Super_L from modifier group mod4
3. Reassigns keycode 64 (physical Alt key) to generate Super_L
4. Reassigns keycode 133 (physical Super key) to generate Alt_L
5. Adds the keys back to their respective modifier groups
6. Creates a state file to track that swap is active

## Restore Normal (Undo)

Restore the original key mapping:

```sh {"name":"swap-keys-off","description":"Restore normal Alt and Super key mapping","action":"undo"}
xmodmap -e "remove mod1 = Alt_L"
xmodmap -e "remove mod4 = Super_L"
xmodmap -e "keycode 64 = Alt_L"
xmodmap -e "keycode 133 = Super_L"
xmodmap -e "add mod1 = Alt_L"
xmodmap -e "add mod4 = Super_L"
rm -f "$HOME/.config/keyboard-mapping-swap-left-alt-super"
echo "✓ Left Alt and Super keys are NORMAL"
```

## Understanding Key Codes

View current key mappings:

```sh {"name":"show-keycodes","description":"Display current keycode mappings for Alt and Super"}
xmodmap -pke | grep -E "keycode (64|133)"
```

View modifier mappings:

```sh {"name":"show-modifiers","description":"Display current modifier key mappings"}
xmodmap -pm
```

## Troubleshooting

### Keys Not Working After Swap

If keys stop responding after running the swap:

```sh {"name":"reset-xmodmap","description":"Reset xmodmap to system defaults"}
setxkbmap -layout us
rm -f "$HOME/.config/keyboard-mapping-swap-left-alt-super"
```

### Make Swap Persistent Across Reboots

Add to GNOME startup applications:

```sh {"name":"add-to-startup","description":"Add swap command to GNOME startup applications"}
cat > "$HOME/.config/autostart/swap-alt-super.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Swap Alt and Super Keys
Exec=sh -c 'sleep 2 && xmodmap -e "remove mod1 = Alt_L" && xmodmap -e "remove mod4 = Super_L" && xmodmap -e "keycode 64 = Super_L" && xmodmap -e "keycode 133 = Alt_L" && xmodmap -e "add mod1 = Alt_L" && xmodmap -e "add mod4 = Super_L"'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
echo "✓ Added to startup applications"
```

Remove from startup:

```sh {"name":"remove-from-startup","description":"Remove swap from startup applications"}
rm -f "$HOME/.config/autostart/swap-alt-super.desktop"
echo "✓ Removed from startup applications"
```

## Technical Details

### Key Codes
- **64**: Physical left Alt key
- **133**: Physical left Super/Windows key

### Modifier Groups
- **mod1**: Alt modifier (used for Alt+Tab, Alt+F4, etc.)
- **mod4**: Super modifier (used for Super+key shortcuts)

### Why This Works
The swap works by changing which keysym (key symbol) each physical key generates while keeping the modifier groups correctly assigned. Applications looking for "Alt" still work because mod1 is still Alt - it's just triggered by a different physical key now.
