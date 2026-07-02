#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
TARBALL_URL="https://registry.npmjs.org/cavemem/-/cavemem-${VERSION}.tgz"

TARBALL=$(mktemp)
WORKDIR=$(mktemp -d)
trap 'rm -f "$TARBALL"; rm -rf "$WORKDIR"' EXIT

curl -sfL "$TARBALL_URL" -o "$TARBALL"
SRC_HASH=$(nix hash file "$TARBALL")

tar xzf "$TARBALL" -C "$WORKDIR"
cp "$WORKDIR/package/package.json" package.json

npm install --package-lock-only --ignore-scripts

NPM_DEPS_HASH=$(nix shell nixpkgs#prefetch-npm-deps -c prefetch-npm-deps package-lock.json)

sed -i "s|version = \"[^\"]*\"|version = \"${VERSION}\"|" cavemem.nix
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"${SRC_HASH}\"|" cavemem.nix
sed -i "s|npmDepsHash = \"sha256-[^\"]*\"|npmDepsHash = \"${NPM_DEPS_HASH}\"|" cavemem.nix
