# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Commands

### Core Operations
```bash
# List all toggles and their current status
./shortcuts.sh list

# Apply recommended macOS-like configuration (all toggles ON)
./shortcuts.sh apply

# Control individual toggles
./shortcuts.sh on <toggle-name>     # Enable a toggle
./shortcuts.sh off <toggle-name>    # Disable a toggle
./shortcuts.sh toggle <toggle-name> # Toggle between states
./shortcuts.sh status <toggle-name> # Check current state
```

### Available Toggles
- `swap-alt-super` - Swap left Alt and Super keys (xmodmap)
- `disable-super` - Disable default GNOME Super key shortcuts (gsettings)
- `super-tab` - Enable Super+Tab for application/window switching (gsettings)

### Testing Configuration Changes
```bash
# Always check status before and after changes
./shortcuts.sh list

# Verify xmodmap changes
xmodmap -pm

# Verify gsettings changes
gsettings get org.gnome.mutter overlay-key
gsettings get org.gnome.desktop.wm.keybindings switch-applications
```

## Architecture

### Project Structure
This is a **toggle-based configuration system** for keyboard shortcuts on Ubuntu/GNOME. Each toggle represents an independent, reversible configuration that can be combined to create a cohesive keyboard experience.

### Two-Layer Architecture

**Layer 1: Toggle Scripts** (`keyboard-mapping/` and `gnome-shortcuts/`)
- Individual bash scripts that implement on/off/toggle/status operations
- Each script is self-contained and manages its own state
- State tracked via marker files in `~/.config/`
- Must support 4 operations: `on`, `off`, `toggle`, `status`

**Layer 2: Master Controller** (`shortcuts.sh`)
- Unified interface for all toggles
- Delegates to individual toggle scripts
- Provides `list` command to show all toggle states
- Provides `apply` command for recommended configuration preset

### State Management Pattern
All toggle scripts follow this pattern:
1. **State file**: Marker file in `~/.config/` (e.g., `~/.config/gnome-super-shortcuts-disabled`)
2. **State check**: `is_<state>() { [ -f "$STATE_FILE" ] }`
3. **Operations**: 
   - `on/enable`: Apply configuration + `touch "$STATE_FILE"`
   - `off/disable`: Undo configuration + `rm -f "$STATE_FILE"`
   - `toggle`: Check state, call opposite operation
   - `status`: Echo current state (e.g., ENABLED/DISABLED)

### Configuration Domains

**xmodmap (Physical Key Remapping)**
- Session-only: Lost on logout/reboot
- Used in: `keyboard-mapping/swap-left-alt-super.sh`
- Requires X Window System
- Pattern: Remove modifiers → Change keycodes → Re-add modifiers

**gsettings (GNOME Desktop Settings)**
- Permanent: Stored in dconf database
- Used in: `gnome-shortcuts/*.sh`
- Schemas: `org.gnome.mutter`, `org.gnome.desktop.wm.keybindings`, `org.gnome.shell.keybindings`
- Pattern: Set arrays `[]` to disable, specific values to enable

### Master Controller Registration
To add a new toggle to the system:
1. Create toggle script in `keyboard-mapping/` or `gnome-shortcuts/`
2. Add to `TOGGLES` associative array in `shortcuts.sh`:
   ```bash
   declare -A TOGGLES=(
       ["toggle-name"]="path/to/script.sh"
   )
   ```
3. Update README.md with toggle documentation

### Runbook Documentation System
This project uses **executable runbooks** (RunMe-compatible markdown):
- Location: `docs/runbooks/*.md`
- Code blocks contain `name`, `description`, `action` metadata
- Each runbook documents a single toggle comprehensively
- Format: Overview → Prerequisites → Current Status → Apply → Undo → Understanding → Troubleshooting

When modifying toggle behavior, always update the corresponding runbook.

## Key Considerations

### When Modifying Toggle Scripts
- Test all 4 operations: on, off, toggle, status
- Ensure state file is correctly managed (created/deleted)
- Verify operations are truly reversible
- Check for proper error handling (`set -e`)

### xmodmap vs gsettings
- **xmodmap**: Changes physical key mappings (hardware layer)
  - Not persistent across sessions
  - Requires `xmodmap -pm` to verify modifier mappings
  - Use `setxkbmap -layout us` to fully reset
- **gsettings**: Changes GNOME keybindings (software layer)
  - Persistent in dconf database
  - Use `gsettings reset` to restore defaults
  - Can backup/restore with `dconf dump/load`

### State File Naming Convention
Format: `<domain>-<descriptive-name>`
- Examples: `keyboard-mapping-swap-left-alt-super`, `gnome-super-shortcuts-disabled`
- Location: Always `~/.config/`
- Purpose: Single source of truth for toggle state

### Startup Persistence for xmodmap
xmodmap changes are session-only. For persistence, create `.desktop` file in `~/.config/autostart/`:
```desktop
[Desktop Entry]
Type=Application
Name=Swap Alt-Super Keys
Exec=/path/to/script.sh on
X-GNOME-Autostart-enabled=true
```

## Repository Context
This project is part of a larger system configuration workspace located at `/home/sysadmin/Projects/system/`. It specifically handles keyboard shortcuts and key mappings for Ubuntu/GNOME environments, creating a macOS-like keyboard experience through reversible, toggle-based configurations.
