#!/usr/bin/env bash
# Verifies that every Eclipse Installer link on site/index.md points at a setup
# file that exists in this repository.

set -uo pipefail

ROOT_DIR="${P2_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT_DIR"

failures=0
links=0

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

if [[ ! -f site/index.md ]]; then
  echo "FAIL: site/index.md is missing"
  exit 1
fi

# Reference definitions such as: [50r]: eclipse+installer:{{ site.raw_github_url }}/master/setup/bnd/config_bnd_50r.setup
while IFS= read -r line; do
  label="${line%%]:*}]"
  path="${line##*/master/}"
  links=$((links + 1))
  if [[ ! -f "$path" ]]; then
    fail "install link $label points at $path, which does not exist"
  fi
done < <(grep -E '^\[[^]]+\]: *eclipse\+installer:.*/master/' site/index.md | tr -d '\r')

if (( links == 0 )); then
  echo "FAIL: no install links found in site/index.md"
  exit 1
fi

if (( failures > 0 )); then
  echo "Install link checks failed with $failures issue(s)."
  exit 1
fi

echo "PASS: $links install links point at existing setup files"
echo "Install link checks passed."
