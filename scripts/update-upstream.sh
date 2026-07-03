#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"
TARBALL_URL="https://registry.npmjs.org/cavemem/-/cavemem-${VERSION}.tgz"

TARBALL=$(mktemp)
WORKDIR=$(mktemp -d)
trap 'rm -f "$TARBALL"; rm -rf "$WORKDIR"' EXIT

if ! curl -sfL "$TARBALL_URL" -o "$TARBALL"; then
  echo "Failed to download tarball from ${TARBALL_URL}" >&2
  exit 1
fi
SRC_HASH=$(nix hash file "$TARBALL")

tar xzf "$TARBALL" -C "$WORKDIR"
cp "$WORKDIR/package/package.json" package.json

npm install --package-lock-only --ignore-scripts

NPM_DEPS_HASH=$(nix shell nixpkgs#prefetch-npm-deps -c prefetch-npm-deps package-lock.json)

sed -i "s|version = \"[^\"]*\"|version = \"${VERSION}\"|" cavemem.nix
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"${SRC_HASH}\"|" cavemem.nix
sed -i "s|npmDepsHash = \"sha256-[^\"]*\"|npmDepsHash = \"${NPM_DEPS_HASH}\"|" cavemem.nix
