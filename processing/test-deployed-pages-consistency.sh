#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_URL="https://bndtools.org/bndtools.p2.repo"
failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

if [[ ! -f site/latest ]]; then
  echo "FAIL: site/latest is missing"
  exit 1
fi

latest_local="$(tr -d '\r\n' < site/latest)"

latest_remote_raw="$(curl -fsSL "$BASE_URL/latest" || true)"
latest_remote="$(printf '%s' "$latest_remote_raw" | tr -d '\r\n')"
if [[ "$latest_remote" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  if [[ "$latest_remote" == "$latest_local" ]]; then
    pass "deployed latest pointer matches local latest ($latest_local)"
  else
    fail "deployed latest pointer ($latest_remote) differs from repo latest ($latest_local)"
  fi
else
  echo "INFO: $BASE_URL/latest does not expose a plain-text version pointer; validating latest alias path instead"
  if curl -fsSL "$BASE_URL/latest/" >/dev/null; then
    pass "deployed latest alias path is reachable"
  else
    fail "deployed latest alias path is not reachable"
  fi
fi

if curl -fsSL "$BASE_URL/p2.html" | grep -Fq "$latest_local"; then
  pass "deployed p2.html contains latest release"
else
  fail "deployed p2.html does not contain $latest_local"
fi

if curl -fsSL "$BASE_URL/$latest_local/" >/dev/null; then
  pass "deployed release directory is reachable"
else
  fail "deployed release directory is not reachable"
fi

if curl -fsSL "$BASE_URL/$latest_local/content.xml" >/dev/null; then
  pass "deployed content.xml is reachable"
else
  fail "deployed content.xml is not reachable"
fi

if curl -fsSL "$BASE_URL/$latest_local/index.html" >/dev/null; then
  pass "deployed human-readable index is reachable"
else
  fail "deployed human-readable index is not reachable"
fi

if (( failures > 0 )); then
  echo "Deployed pages consistency checks failed with $failures issue(s)."
  exit 1
fi

echo "Deployed pages consistency checks passed."
