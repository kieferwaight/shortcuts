#!/usr/bin/env bash
# Move/resize the active window to screen halves using wmctrl
# Usage: tiling-move.sh {left|right|up|down|full}

set -euo pipefail

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: '$1' is required but not installed" >&2
    exit 1
  fi
}

require wmctrl
require xdpyinfo

action="${1:-}" 
if [[ -z "$action" ]]; then
  echo "Usage: $0 {left|right|up|down|full}" >&2
  exit 1
fi

# Get total screen dimensions (width x height)
read -r SCREEN_W SCREEN_H < <(xdpyinfo | awk '/dimensions:/ {print $2}' | awk -Fx '{print $1, $2}')

if [[ -z "${SCREEN_W:-}" || -z "${SCREEN_H:-}" ]]; then
  echo "Error: Unable to determine screen dimensions" >&2
  exit 1
fi

# Remove maximized state to allow resize
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz || true

# Optional padding (in pixels) to avoid overlapping panels
P=0

half_w=$(( SCREEN_W / 2 ))
half_h=$(( SCREEN_H / 2 ))

case "$action" in
  left)
    X=$P; Y=$P; W=$(( half_w - 2*P )); H=$(( SCREEN_H - 2*P ))
    ;;
  right)
    X=$(( half_w + P )); Y=$P; W=$(( half_w - 2*P )); H=$(( SCREEN_H - 2*P ))
    ;;
  up|top)
    X=$P; Y=$P; W=$(( SCREEN_W - 2*P )); H=$(( half_h - 2*P ))
    ;;
  down|bottom)
    X=$P; Y=$(( half_h + P )); W=$(( SCREEN_W - 2*P )); H=$(( half_h - 2*P ))
    ;;
  full|max)
    X=$P; Y=$P; W=$(( SCREEN_W - 2*P )); H=$(( SCREEN_H - 2*P ))
    ;;
  *)
    echo "Error: Unknown action '$action' (use left|right|up|down|full)" >&2
    exit 1
    ;;
esac

# Apply new geometry
# wmctrl -e format: gravity,X,Y,WIDTH,HEIGHT (gravity 0 = use default)
wmctrl -r :ACTIVE: -e 0,${X},${Y},${W},${H}

exit $?
