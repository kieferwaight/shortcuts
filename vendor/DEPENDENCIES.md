# Dependencies
This project uses a small set of cross-platform and Linux-specific tools.

## macOS (Homebrew)
Install via Brewfile:
```bash
brew bundle --file=vendor/Brewfile
```

Contents:
- yq (YAML processor)
- jq (JSON processor)
- karabiner-elements (GUI remapper)

## Linux (Ubuntu/Debian)
Install via Makefile (apt):
```bash
sudo make install-linux
```

Installs:
- yq, jq: for binding generation
- x11-xserver-utils: X11 utilities (xmodmap/xrandr, etc.)
- dconf-cli: GNOME settings
- wmctrl: window move/resize (tiling layer)
- xdotool: X automation helper (optional; some environments need it)

Manual:
- xremap: hotkey daemon used for universal bindings and tiling layer
  - Install via cargo:
    - curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    - cargo install xremap --features x11,gnome
  - Configure uinput permission (see xremap docs)

Notes:
- wmctrl and xremap require X11/XWayland. On pure Wayland, consider Wayland-native alternatives.