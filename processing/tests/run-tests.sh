#!/usr/bin/env bash
# Runs every processing/tests/*.test.sh and reports the combined result.

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0

for t in "$TESTS_DIR"/*.test.sh; do
  echo "== $(basename "$t")"
  bash "$t" || status=1
done

if (( status != 0 )); then
  echo "Some tests failed."
  exit 1
fi
echo "All tests passed."
