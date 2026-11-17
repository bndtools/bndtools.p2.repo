#!/usr/bin/env bash
# Turns a copy of the fixture bnd workspace into a Git repository with one commit.
# Usage: make-fixture-repo.sh <destination-directory>
# The destination must not exist. Prints the destination path.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <destination-directory>" >&2
  exit 2
fi

dest="$1"
fixture="$(cd "$(dirname "${BASH_SOURCE[0]}")/../testbed/fixtures/bnd-workspace" && pwd)"

if [[ -e "$dest" ]]; then
  echo "destination already exists: $dest" >&2
  exit 1
fi

mkdir -p "$dest"
cp -R "$fixture/." "$dest/"

# The helper repository is throwaway: no signing, fixed identity, no global hooks.
git -C "$dest" init -q
git -C "$dest" add -A
git -C "$dest" -c user.name=fixture -c user.email=fixture@localhost -c commit.gpgsign=false \
  commit -q -m "fixture workspace"

echo "$dest"
