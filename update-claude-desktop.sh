#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
NIX_FILE="pkgs/claude-desktop.nix"

read -r NEW_VER NEW_SHA_HEX < <(
  curl -fsSL "https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages" \
    | awk '/^Version:/{v=$2} /^SHA256:/{s=$2} END{print v, s}'
)

NEW_HASH="sha256-$(python3 -c "import base64,sys; print(base64.b64encode(bytes.fromhex(sys.argv[1])).decode())" "$NEW_SHA_HEX")"
CUR_VER=$(sed -n 's/.*version = "\(.*\)";/\1/p' "$NIX_FILE" | head -1)

if [[ "$CUR_VER" == "$NEW_VER" ]]; then
  echo "claude-desktop $CUR_VER is up to date"
  exit 0
fi

echo "$CUR_VER → $NEW_VER"
sed -i "s/version = \"$CUR_VER\"/version = \"$NEW_VER\"/" "$NIX_FILE"
sed -i 's|hash = "sha256-[^"]*"|hash = "'"$NEW_HASH"'"|' "$NIX_FILE"
echo "updated. run: nh home switch ."
