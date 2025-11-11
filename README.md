# Keyboard Shortcuts Manager

A unified system for managing keyboard shortcuts and key mappings on Ubuntu/GNOME, documented as executable runbooks.

## Quick Start

## Installation

### macOS

```bash
brew bundle --file=vendor/Brewfile
```

### Linux (Ubuntu/Debian)

```bash
sudo ./scripts/install-deps-linux.sh
```

See [vendor/DEPENDENCIES.md](vendor/DEPENDENCIES.md) for detailed installation instructions.

Apply the recommended macOS-like configuration:

```sh {"description":"Apply recommended keyboard configuration","name":"quick-apply"}
cd /home/sysadmin/Projects/system/shortcuts
./scripts/shortcuts.sh apply
```

Check current status:

```sh {"description":"Check status of all keyboard settings","name":"quick-status"}
cd /home/sysadmin/Projects/system/shortcuts
./scripts/shortcuts.sh list
```

## 📚 Runbook Documentation

**[View Complete Runbook Index →](docs/INDEX.md)**

Detailed, executable runbooks for each configuration:

### [Swap Left Alt and Super Keys](docs/runbooks/swap-left-alt-super.md)

Physically swap the left Alt and Super keys to create a macOS-like keyboard layout.

- **Action**: Key remapping via xmodmap
- **Persistence**: Session-only (requires startup script)
- **Reversible**: Yes

### [Disable GNOME Super Key Shortcuts](docs/runbooks/disable-super-shortcuts.md)

Disable all default GNOME shortcuts that use the Super key to prevent conflicts.

- **Action**: Clear gsettings keybindings
- **Persistence**: Permanent (stored in dconf)
- **Reversible**: Yes

### [Enable Super+Tab Switching](docs/runbooks/super-tab-switching.md)
### [Map Caps Lock to Control](docs/runbooks/caps-to-control.md)

Convert Caps Lock into an additional Control key for macOS-like navigation (Caps+A/E for line begin/end, Caps+HJKL with helpers).

- **Action**: Key remapping via xmodmap
- **Persistence**: Session-only (requires startup script)
- **Reversible**: Yes

### [Map Super+Q to Close Window](docs/runbooks/super-cmd-q-quit.md)

Add Super+Q (Cmd+Q) as a close-window shortcut in GNOME.

- **Action**: gsettings keybinding (`org.gnome.desktop.wm.keybindings close`)
- **Persistence**: Permanent (stored in dconf)
- **Reversible**: Yes

### [macOS-like Universal Bindings (xremap)](docs/runbooks/macos-bindings.md)

Make common shortcuts universal: Cmd+C/V/X/Z/S/A and Caps+H/J/K/L for arrow movement, via xremap.

- **Action**: Run-time remapper (`xremap`) using `keyboard-mapping/xremap-macos.yml`
- **Persistence**: Background process (user service/autostart)
- **Reversible**: Yes

Configure Super+Tab for application switching and Super+` for window switching.

- **Action**: Set gsettings keybindings
- **Persistence**: Permanent (stored in dconf)
- **Reversible**: Yes

## Structure

```sh
shortcuts/
├── README.md                             # This file
├── WARP.md                               # AI integration notes
├── Makefile                              # Common tasks (install, bindings, test, clean)
├── docs/
│   ├── INDEX.md                          # Runbook index
│   └── runbooks/                         # Detailed runbook documentation
│       ├── swap-left-alt-super.md
│       ├── disable-super-shortcuts.md
│       ├── super-tab-switching.md
│       ├── caps-to-control.md
│       └── super-cmd-q-quit.md
├── src/
│   ├── data/
│   │   └── cross-platform-bindings.yml   # Abstract binding spec (source of truth)
│   ├── interface/
│   │   ├── xmodmap/                      # Physical key remapping (session-only)
│   │   │   ├── swap-left-alt-super.sh
│   │   │   └── caps-to-control.sh
│   │   ├── gsettings/                    # GNOME shortcuts (persistent)
│   │   │   ├── disable-super-shortcuts.sh
│   │   │   ├── super-tab-switching.sh
│   │   │   └── super-cmd-q-quit.sh
│   │   └── xremap/                       # Universal remapper (daemon)
│   │       └── universal-macos-bindings.sh
│   └── methods/
│       └── generate-bindings.sh          # Generate platform configs from spec
├── scripts/
│   ├── shortcuts.sh                      # Master control script
│   └── install-deps-linux.sh             # Linux dependency installer
├── vendor/
│   ├── Brewfile                          # macOS dependencies (Homebrew)
│   └── DEPENDENCIES.md                   # Dependency installation guide
└── dist/                                 # Generated configs (not in repo)
    ├── xremap-macos.yml                  # Generated xremap config (Linux)
    └── karabiner-macos.json              # Generated Karabiner config (macOS)
```

## Available Toggles

### swap-alt-super

**Swap left Alt and Super (Windows/Command) keys**

States:

- **SWAPPED**: Left physical Alt sends Super, left physical Super sends Alt
- **NORMAL**: Keys work as labeled

Usage:

```sh {"description":"Toggle Alt/Super key swap","name":"toggle-swap-keys"}
./scripts/shortcuts.sh toggle swap-alt-super
```

### disable-super

**Disable default GNOME Super key shortcuts**

States:

- **DISABLED**: Super key shortcuts cleared (Activities, Super+1-9, Super+P, etc.)
- **ENABLED**: Default GNOME shortcuts active

Usage:

```sh {"description":"Toggle Super key shortcuts","name":"toggle-disable-super"}
./scripts/shortcuts.sh toggle disable-super
```

### super-tab

**Enable Super+Tab application/window switching**

States:

- **ENABLED**: Super+Tab switches apps, Super+` switches windows
- **DISABLED**: Super+Tab shortcuts not configured

Usage:

```sh {"description":"Toggle Super+Tab switching","name":"toggle-super-tab"}
./scripts/shortcuts.sh toggle super-tab

### caps-to-control

**Map Caps Lock to Control**

States:

- **ENABLED**: Caps acts as Control (Cmd-like navigation with Caps+A/E)
- **DISABLED**: Caps acts as Caps Lock

Usage:

```sh
./scripts/shortcuts.sh toggle caps-to-control
```

### super-cmd-q

**Map Super+Q to close window (Cmd+Q)**

States:

- **ENABLED**: Super+Q closes the active window
- **DISABLED**: Default GNOME behavior (Alt+F4 only)

Usage:

```sh
./scripts/shortcuts.sh toggle super-cmd-q
```

### macOS-bindings (xremap)

**Universal macOS-like shortcuts (requires xremap)**

Provides:

- Cmd+C/V/X/Z/S/A → Ctrl+C/V/X/Z/S/A
- Caps+H/J/K/L → ←/↓/↑/→
- Caps+A/E → Home/End

Usage:

```sh
./scripts/shortcuts.sh on macos-bindings   # start xremap with provided config
./scripts/shortcuts.sh off macos-bindings  # stop xremap
```
Note: Install xremap first. See runbook for instructions.
```

## Master Control Script

The `shortcuts.sh` script provides a unified interface:

### Commands

List all toggles with current status:

```sh {"description":"List all available toggles and their status","name":"list-toggles"}
./scripts/shortcuts.sh list
```

Apply recommended configuration (all three toggles ON):

```sh {"description":"Apply recommended macOS-like configuration","name":"apply-recommended"}
./scripts/shortcuts.sh apply
```

Control individual toggles:

```sh {"description":"Turn on a specific toggle","name":"control-toggle-on"}
./scripts/shortcuts.sh on swap-alt-super
```

```sh {"description":"Turn off a specific toggle","name":"control-toggle-off"}
./scripts/shortcuts.sh off disable-super
```

```sh {"description":"Toggle a specific setting","name":"control-toggle-toggle"}
./scripts/shortcuts.sh toggle super-tab
```

```sh {"description":"Check status of a toggle","name":"control-toggle-status"}
./scripts/shortcuts.sh status swap-alt-super
```

## Recommended Configuration

The recommended setup creates a macOS-like keyboard experience:

**What it does:**

1. Swaps left Alt and Super keys physically
2. Disables default GNOME Super shortcuts
3. Enables Super+Tab for app/window switching

**Result:**

- Left physical Alt key → acts as Super (Command key)
- Left physical Super key → acts as Alt (Option key)
- Super+Tab → switch between applications
- Super+` → switch between windows of same app
- No conflicts with default GNOME shortcuts

Apply it:

```sh {"description":"Apply complete macOS-like keyboard configuration","name":"apply-full-config"}
./scripts/shortcuts.sh apply
```

## Runbook Format

All documentation uses RunMe-compatible markdown:

- **Code blocks have metadata**: `name`, `description`, `action` tags
- **Educational content**: "What this does" and "Understanding" sections
- **Single-outcome tasks**: Each code block performs one clear action
- **Status checks**: Verify configuration before and after changes
- **Troubleshooting**: Common issues and solutions
- **Technical details**: Background information and references

### Code Block Tags

- `name`: Unique identifier for the command
- `description`: What the command does
- `action`: Type of action (`apply`, `undo`, or omitted for read-only)

Example:

```sh {"action":"apply","description":"Example command that makes changes","name":"example-apply"}
echo "This command applies a configuration"
```

## Technical Details

### State Tracking

Toggle states are tracked using marker files in `~/.config/`:

- `keyboard-mapping-swap-left-alt-super`: Alt/Super swap is active
- `gnome-super-shortcuts-disabled`: Super shortcuts are disabled
- `gnome-super-tab-enabled`: Super+Tab switching is enabled

### Persistence

**xmodmap (key swapping)**:

- Session-only: Lost on logout/reboot
- Must be added to startup applications for persistence
- See runbook for autostart configuration

**gsettings (GNOME shortcuts)**:

- Permanent: Stored in dconf database
- Persists across sessions automatically
- Can be backed up/restored with dconf

### Requirements

- Ubuntu/GNOME desktop environment
- X Window System (for xmodmap)
- gsettings/dconf tools
- Bash 4.0+ (for associative arrays)
- Optional: xremap (for universal macOS-like bindings)

### Cross-Platform Bindings

This repository supports generating both Linux (xremap) and macOS (Karabiner-Elements) configs from a single abstract spec:

- Spec: `src/data/cross-platform-bindings.yml`
- Generator: `src/methods/generate-bindings.sh` (requires `yq` and `jq`)
- Outputs:
  - Linux: `dist/xremap-macos.yml`
  - macOS: `dist/karabiner-macos.json`

On macOS, import the generated `dist/karabiner-macos.json` in Karabiner-Elements → Complex Modifications.

## Contributing

### Adding New Toggles

1. **Create runbook documentation** in `docs/runbooks/[name].md`

   - Follow existing runbook format
   - Include overview, prerequisites, status checks
   - Tag all code blocks with name/description/action
   - Add educational content and troubleshooting

2. **Create toggle script** in appropriate directory

   - `src/interface/xmodmap/` for physical key changes
   - `src/interface/gsettings/` for shortcut configurations
   - `src/interface/xremap/` for universal remapping
   - Follow standard toggle pattern (on/off/toggle/status)
   - Use state files in `~/.config/`

3. **Update master script** (`scripts/shortcuts.sh`)

   - Add to `TOGGLES` associative array
   - Test with list/apply/toggle commands

4. **Update this README**

   - Add runbook link to documentation section
   - Add toggle to Available Toggles section
   - Update recommended configuration if applicable

### Toggle Script Pattern

All toggle scripts must support:

- `on` or primary action name: Enable the feature
- `off` or inverse action name: Disable the feature
- `toggle`: Switch between on and off
- `status`: Output current state (one word: ENABLED/DISABLED, ON/OFF, etc.)
- Exit code 0 on success, 1 on error
- State file in `~/.config/` for persistence checking

## Support

For detailed information on each configuration:

- Read the appropriate runbook in `docs/runbooks/`
- Each runbook contains troubleshooting sections
- Code blocks are executable and documented

For issues with the toggle scripts:

- Check state files in `~/.config/`
- Verify prerequisites (xmodmap, gsettings)
- Run status commands to debug
