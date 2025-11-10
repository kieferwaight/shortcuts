#!/usr/bin/env bash
# Linux dependencies installer (apt-based distributions: Ubuntu, Debian)
# Run: sudo ./install-deps-linux.sh

set -e

echo "Installing Linux dependencies for keyboard shortcuts manager..."

# Core utilities for cross-platform binding generation
apt-get update
apt-get install -y \
  yq \
  jq \
  git

# Optional: xmodmap and X11 utilities (usually pre-installed)
apt-get install -y \
  x11-xserver-utils

# Optional: GNOME settings tools (usually pre-installed on GNOME)
apt-get install -y \
  dconf-cli

# xremap installation (requires Rust cargo)
echo ""
echo "Note: xremap requires manual installation via cargo:"
echo "  1. Install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo "  2. Install xremap: cargo install xremap --features x11,gnome"
echo "  3. Grant uinput permissions (see https://github.com/k0kubun/xremap#installation)"
echo ""

echo "✓ Core dependencies installed"
echo ""
echo "Optional setup:"
echo "  - Run ./shortcuts.sh apply to enable recommended keyboard config"
echo "  - Install xremap manually for universal macOS-like bindings"
