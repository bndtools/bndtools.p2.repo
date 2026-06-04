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

if [[ ! -f site/latest || ! -f site/p2.html ]]; then
  echo "FAIL: expected site/latest and site/p2.html to exist"
  exit 1
fi

mapfile -t setup_files < <(grep -RIl 'id="bndtools-release"' setup)

if (( ${#setup_files[@]} == 0 )); then
  echo "FAIL: no setup files with id=\"bndtools-release\" were found"
  exit 1
fi

latest="$(tr -d '\r\n' < site/latest)"
canonical_file="setup/bnd/config_bnd_10r.setup"
if [[ ! -f "$canonical_file" ]]; then
  canonical_file="${setup_files[0]}"
fi

mapfile -t canonical_release_urls < <(grep -Eo 'https://bndtools.org/bndtools.p2.repo/[0-9]+\.[0-9]+\.[0-9]+' "$canonical_file" | sort -Vu)

if (( ${#canonical_release_urls[@]} == 0 )); then
  echo "FAIL: could not derive canonical release URLs from $canonical_file"
  exit 1
fi

if ! printf '%s\n' "${canonical_release_urls[@]}" | grep -Fqx "https://bndtools.org/bndtools.p2.repo/$latest"; then
  fail "site/latest ($latest) is not listed in canonical setup choices ($canonical_file)"
else
  pass "site/latest is included in canonical setup choices"
fi

for file in "${setup_files[@]}"; do
  for expected_url in "${canonical_release_urls[@]}"; do
    if ! grep -Fq "$expected_url" "$file"; then
      fail "$file is missing release choice $expected_url"
    fi
  done

  if ! grep -Fq 'https://bndtools.jfrog.io/bndtools/update-latest' "$file"; then
    fail "$file is missing release (JFrog) choice"
  fi

  if ! grep -Fq 'https://bndtools.jfrog.io/bndtools/update-snapshot' "$file"; then
    fail "$file is missing snapshot (JFrog) choice"
  fi
done

mapfile -t malformed_pr < <(grep -RIn 'artifactory/p2/pr/' setup --include='*.setup' | grep -v '\${pullrequest}' || true)
if (( ${#malformed_pr[@]} > 0 )); then
  fail "malformed PR placeholder found in setup files"
  printf '%s\n' "${malformed_pr[@]}"
else
  pass 'all PR override URLs keep the ${pullrequest} placeholder'
fi

if command -v xmllint >/dev/null 2>&1; then
  while IFS= read -r setup_xml; do
    if xmllint --noout "$setup_xml" >/dev/null 2>&1; then
      :
    else
      fail "XML validation failed: $setup_xml"
    fi
  done < <(find setup -name '*.setup' -type f)
  pass "xmllint XML validation completed"
else
  echo "INFO: xmllint not found, skipping XML well-formedness checks"
fi

if (( failures > 0 )); then
  echo "Oomph consistency checks failed with $failures issue(s)."
  exit 1
fi

echo "Oomph consistency checks passed."
