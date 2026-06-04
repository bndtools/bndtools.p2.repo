#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

if [[ ! -f site/latest ]]; then
  fail "site/latest file is missing"
  echo "Repo consistency checks failed early."
  exit 1
fi

latest="$(tr -d '\r\n' < site/latest)"

if [[ -z "$latest" ]]; then
  fail "site/latest is empty"
else
  pass "site/latest declares version $latest"
fi

if [[ -d "site/$latest" ]]; then
  pass "release directory site/$latest exists"
else
  fail "release directory site/$latest is missing"
fi

for rel_file in content.xml index.html; do
  if [[ -f "site/$latest/$rel_file" ]]; then
    pass "site/$latest/$rel_file exists"
  else
    fail "site/$latest/$rel_file is missing"
  fi
done

if grep -Eq "href=[\"']?$latest([\"'/> ])" site/p2.html; then
  pass "site/p2.html contains latest release link"
else
  fail "site/p2.html does not contain a link for $latest"
fi

readme_release="$(grep -Eo 'https://bndtools.org/bndtools.p2.repo/[0-9]+\.[0-9]+\.[0-9]+/?' README.md | head -n 1 | sed -E 's#/$##; s#.*/##')"
if [[ -n "$readme_release" && "$readme_release" == "$latest" ]]; then
  pass "README.md direct p2 example matches latest release"
else
  fail "README.md direct p2 example does not match site/latest"
fi

if grep -Fq "Changes-in-$latest" site/index.md; then
  pass "site/index.md release wiki links match latest release"
else
  fail "site/index.md does not reference Changes-in-$latest"
fi

if (( failures > 0 )); then
  echo "Repo consistency checks failed with $failures issue(s)."
  exit 1
fi

echo "Repo consistency checks passed."
