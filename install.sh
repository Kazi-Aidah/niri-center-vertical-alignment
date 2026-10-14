#!/bin/sh
# Build niri with the center-single-window-vertically patch and install it.
#
# Usage:
#   ./install.sh                  # build + install binary (asks sudo password)
#   ./install.sh --enable-config  # also add the option to your niri config
#
# Env overrides:
#   NIRI_UPSTREAM_COMMIT  upstream commit to build (default: 8ed0da4 = niri 26.04,
#                         the commit this patch was written and tested against)
#   NIRI_SRC_DIR          where to clone/build (default: ~/Projects/niri-patched-build)
#   NIRI_JOBS             cargo build jobs (default: 2, release builds are RAM-hungry)
set -eu

UPSTREAM_COMMIT="${NIRI_UPSTREAM_COMMIT:-8ed0da4}"
SRC_DIR="${NIRI_SRC_DIR:-$HOME/Projects/niri-patched-build}"
JOBS="${NIRI_JOBS:-2}"
ENABLE_CONFIG=0
if [ "${1:-}" = "--enable-config" ]; then ENABLE_CONFIG=1; fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PATCH="$SCRIPT_DIR/center-single-window-vertically.patch"
CONFIG="$HOME/.config/niri/config.kdl"

for dep in git cargo pkg-config; do
    command -v "$dep" >/dev/null || { echo "missing: $dep"; exit 1; }
done
[ -f "$PATCH" ] || { echo "missing patch: $PATCH"; exit 1; }

if [ -d "$SRC_DIR/.git" ]; then
    echo "updating existing checkout in $SRC_DIR"
    git -C "$SRC_DIR" fetch --quiet origin
else
    echo "cloning niri into $SRC_DIR"
    git clone --quiet https://github.com/niri-wm/niri "$SRC_DIR"
fi
git -C "$SRC_DIR" reset --quiet --hard "$UPSTREAM_COMMIT"
if git -C "$SRC_DIR" apply --check "$PATCH"; then
    git -C "$SRC_DIR" apply "$PATCH"
    echo "patch applied"
else
    echo "patch does not apply cleanly (already applied or upstream drifted)"
    exit 1
fi

echo "building (this takes a while, ~15 min on 4 cores)..."
cargo build --quiet --release --jobs "$JOBS" --manifest-path "$SRC_DIR/Cargo.toml"
BUILT="$SRC_DIR/target/release/niri"
"$BUILT" --version

if [ ! -f /usr/sbin/niri.stock ]; then
    sudo cp /usr/sbin/niri /usr/sbin/niri.stock
    echo "backed up stock -> /usr/sbin/niri.stock"
fi
# --remove-destination: the running compositor locks its own binary,
# plain cp fails with "Text file busy". Unlink-then-create sidesteps it.
sudo cp --remove-destination "$BUILT" /usr/sbin/niri
md5sum /usr/sbin/niri "$BUILT"
/usr/sbin/niri --version   # patched build shows a -modified marker

if [ "$ENABLE_CONFIG" = 1 ]; then
    cp "$CONFIG" "$CONFIG.bak-$(date +%F)"
    python3 "$SCRIPT_DIR/enable_config.py" "$CONFIG"
    /usr/sbin/niri validate && echo "config valid against installed binary"
fi

echo "Done. Save your work, log out and back in (no reboot needed)."
echo "Revert anytime: sudo cp /usr/sbin/niri.stock /usr/sbin/niri (+ remove the config line on stock)."
