#!/usr/bin/env bash
# Generate platform-specific remap configs from cross-platform-bindings.yml
# - Outputs:
#   - keyboard-mapping/xremap-macos.yml (Linux)
#   - macos/karabiner-macos.json (macOS)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/keyboard-mapping/cross-platform-bindings.yml"
XREMAP_OUT="$ROOT_DIR/keyboard-mapping/xremap-macos.yml"
KARABINER_DIR="$ROOT_DIR/macos"
KARABINER_OUT="$KARABINER_DIR/karabiner-macos.json"

mkdir -p "$KARABINER_DIR"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' required"; exit 1; }
}

require yq
require jq

# Map abstract tokens to xremap
x_key() {
  case "$1" in
    SUPER) echo "Super";;
    CTRL) echo "Control";;
    CAPS) echo "CapsLock";;
    *) echo "$1";;
  esac
}

x_action() {
  case "$1" in
    COPY) echo "Ctrl-c";;
    PASTE) echo "Ctrl-v";;
    CUT) echo "Ctrl-x";;
    SAVE) echo "Ctrl-s";;
    UNDO) echo "Ctrl-z";;
    REDO) echo "Ctrl-Shift-z";;
    SELECT_ALL) echo "Ctrl-a";;
    CLOSE_WINDOW) echo "Alt-F4";;
    LINE_START) echo "Home";;
    LINE_END) echo "End";;
    DELETE_BACKWARD) echo "BackSpace";;
    ARROW_LEFT) echo "Left";;
    ARROW_RIGHT) echo "Right";;
    ARROW_UP) echo "Up";;
    ARROW_DOWN) echo "Down";;
    *) echo "$1";;
  esac
}

# Map abstract tokens to Karabiner-Elements JSON snippets
k_mod() {
  case "$1" in
    SUPER) echo "command";;
    CTRL) echo "control";;
    SHIFT) echo "shift";;
    *) echo "$1";;
  esac
}

k_key() {
  # Lowercase letters pass through; special names adjusted
  case "$1" in
    ARROW_LEFT) echo "left_arrow";;
    ARROW_RIGHT) echo "right_arrow";;
    ARROW_UP) echo "up_arrow";;
    ARROW_DOWN) echo "down_arrow";;
    DELETE_BACKWARD) echo "delete_or_backspace";;
    LINE_START) echo "home";;
    LINE_END) echo "end";;
    *) echo "$1" | tr 'A-Z' 'a-z';;
  esac
}

k_to() {
  case "$1" in
    COPY) echo '{"key_code":"c","modifiers":["command"]}' ;;
    PASTE) echo '{"key_code":"v","modifiers":["command"]}' ;;
    CUT) echo '{"key_code":"x","modifiers":["command"]}' ;;
    SAVE) echo '{"key_code":"s","modifiers":["command"]}' ;;
    UNDO) echo '{"key_code":"z","modifiers":["command"]}' ;;
    REDO) echo '{"key_code":"z","modifiers":["command","shift"]}' ;;
    SELECT_ALL) echo '{"key_code":"a","modifiers":["command"]}' ;;
    CLOSE_WINDOW) echo '{"key_code":"q","modifiers":["command"]}' ;;
    LINE_START) echo '{"key_code":"home"}' ;;
    LINE_END) echo '{"key_code":"end"}' ;;
    DELETE_BACKWARD) echo '{"key_code":"delete_or_backspace"}' ;;
    ARROW_LEFT) echo '{"key_code":"left_arrow"}' ;;
    ARROW_RIGHT) echo '{"key_code":"right_arrow"}' ;;
    ARROW_UP) echo '{"key_code":"up_arrow"}' ;;
    ARROW_DOWN) echo '{"key_code":"down_arrow"}' ;;
    *) echo '{"key_code":"'$1'"}' ;;
  esac
}

# Build xremap YAML
build_xremap() {
  {
    echo "modmap:"
    # Modifiers
    if yq '.mappings[] | select(.group=="Modifier remap") | .entries[]' "$SRC" >/dev/null 2>&1; then
      echo "  - name: 'CapsLock to Control'"
      echo "    remap:"
      echo "      CapsLock: Control_L"
    fi
    echo
    echo "keymap:"
    # Standard shortcuts
    echo "  - name: 'macOS style shortcuts'"
    echo "    remap:"
    while IFS= read -r from && IFS= read -r to; do
      # parse from like SUPER+Shift+z into xremap form
      combo="$from"
      # Replace tokens with xremap prefixes
      combo=$(echo "$combo" | sed -E 's/\+/-/g; s/SUPER/Super/; s/CTRL/Ctrl/; s/SHIFT/Shift/')
      dest=$(x_action "$to")
      printf "      %s: %s\n" "$combo" "$dest"
    done < <(yq -r '.mappings[] | select(.group=="Standard shortcuts") | .entries[] | .from, .to' "$SRC")

    echo
    echo "  - name: 'Emacs/Vim navigation with Caps (Control)'"
    echo "    remap:"
    while IFS= read -r from && IFS= read -r to; do
      combo=$(echo "$from" | sed -E 's/\+/-/g; s/CTRL/Ctrl/;')
      dest=$(x_action "$to")
      printf "      %s: %s\n" "$combo" "$dest"
    done < <(yq -r '.mappings[] | select(.group=="Navigation (Emacs style)") | .entries[] | .from, .to' "$SRC")

    echo
    echo "  - name: 'Vim hjkl with Caps mapped to Control'"
    echo "    remap:"
    while IFS= read -r from && IFS= read -r to; do
      combo=$(echo "$from" | sed -E 's/\+/-/g; s/CTRL/Ctrl/')
      dest=$(x_action "$to")
      printf "      %s: %s\n" "$combo" "$dest"
    done < <(yq -r '.mappings[] | select(.group=="Vim arrows (uppercase HJKL with Control)") | .entries[] | .from, .to' "$SRC")
  } > "$XREMAP_OUT"
  echo "✓ Wrote $XREMAP_OUT"
}

# Build Karabiner JSON rules
build_karabiner() {
  # Complex manipulations array
  rules='[]'

  # Helper to append a rule
  add_rule() {
    local title="$1"; local from_combo="$2"; local to_action="$3"; local cond="$4"
    local key; key=$(echo "$from_combo" | awk -F'+' '{print tolower($NF)}')
    local mods; mods=$(echo "$from_combo" | awk -F"+" '{for(i=1;i<NF;i++) printf (i>1?",":"") tolower($i)}')
    local to_json; to_json=$(k_to "$to_action")
    local rule=$(jq -n --arg key "$key" --arg mods "$mods" --argjson to "$to_json" '{
      "description": $key,
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": $key,
            "modifiers": {"mandatory": ($mods|split(",")|map(select(length>0)))}
          },
          "to": [($to)]
        }
      ]
    }')
    rules=$(echo "$rules" | jq --argjson r "$rule" '. + [$r]')
  }

  # Populate from groups
  while IFS= read -r from && IFS= read -r to; do
    add_rule "Standard" "$from" "$to"
  done < <(yq -r '.mappings[] | select(.group=="Standard shortcuts") | .entries[] | .from, .to' "$SRC")

  while IFS= read -r from && IFS= read -r to; do
    add_rule "Navigation" "$from" "$to"
  done < <(yq -r '.mappings[] | select(.group=="Navigation (Emacs style)") | .entries[] | .from, .to' "$SRC")

  while IFS= read -r from && IFS= read -r to; do
    add_rule "Vim" "$from" "$to"
  done < <(yq -r '.mappings[] | select(.group=="Vim arrows (uppercase HJKL with Control)") | .entries[] | .from, .to' "$SRC")

  # Wrap into Karabiner profile JSON
  jq -n --arg title "Universal macOS-like bindings" --argjson rules "$rules" '{
    "title": $title,
    "rules": $rules
  }' > "$KARABINER_OUT"
  echo "✓ Wrote $KARABINER_OUT"
}

build_xremap
build_karabiner
