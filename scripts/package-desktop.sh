#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
CONTROL_DIR="$ROOT_DIR/app/control-desktop"
TARGET_DIR="$CONTROL_DIR/src-tauri/target/package-desktop/$STAMP"
OUTPUT_DIR="$ROOT_DIR/release/desktop/$STAMP"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

cleanup() {
  rm -rf "$TARGET_DIR"
}

trap cleanup EXIT

require_command npm
require_command cargo
require_command cmake
require_command ninja
require_command hdiutil
require_command shasum
require_command codesign

if [[ ! -d "$CONTROL_DIR/node_modules" ]]; then
  echo "==> Installing desktop dependencies"
  npm --prefix "$CONTROL_DIR" ci
fi

if [[ -z "${VITE_NEKO_API_BASE_URL:-}" ]]; then
  echo "VITE_NEKO_API_BASE_URL is required to package account login" >&2
  exit 1
fi

if [[ ! "$VITE_NEKO_API_BASE_URL" =~ ^https?://[^/?#[:space:]]+/?$ ]]; then
  echo "VITE_NEKO_API_BASE_URL must be an HTTP(S) origin without a path" >&2
  exit 1
fi

export VITE_NEKO_API_BASE_URL="${VITE_NEKO_API_BASE_URL%/}"
export CARGO_TARGET_DIR="$TARGET_DIR"

echo "==> Building NekoPapa DMG"
npm --prefix "$CONTROL_DIR" run tauri -- build --bundles app,dmg

shopt -s nullglob
dmg_files=("$TARGET_DIR"/release/bundle/dmg/*.dmg)
app_bundles=("$TARGET_DIR"/release/bundle/macos/*.app)
shopt -u nullglob

if [[ "${#dmg_files[@]}" -ne 1 ]]; then
  echo "Expected exactly one DMG, found ${#dmg_files[@]}" >&2
  exit 1
fi

if [[ "${#app_bundles[@]}" -ne 1 ]]; then
  echo "Expected exactly one application bundle, found ${#app_bundles[@]}" >&2
  exit 1
fi

echo "==> Verifying bundled application signature"
codesign --verify --deep --strict --verbose=2 "${app_bundles[0]}"

mkdir -p "$OUTPUT_DIR"
cp "${dmg_files[0]}" "$OUTPUT_DIR/"
final_dmg="$OUTPUT_DIR/$(basename "${dmg_files[0]}")"

echo "==> Verifying DMG"
hdiutil verify "$final_dmg"

echo "==> Package output"
echo "$final_dmg"
shasum -a 256 "$final_dmg"
