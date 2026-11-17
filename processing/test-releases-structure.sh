#!/usr/bin/env bash
# Verifies the structure of every published p2 release directory under site/:
# required files and folders exist, the metadata is well-formed XML and the
# jar files are readable zip archives. Does not install anything.

set -uo pipefail

ROOT_DIR="${P2_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT_DIR"

failures=0
releases=0

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

shopt -s nullglob
for dir in site/*/; do
  version="$(basename "$dir")"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || continue
  releases=$((releases + 1))
  base="site/$version"

  for file in artifacts.jar content.jar content.xml index.html; do
    [[ -f "$base/$file" ]] || fail "$base/$file is missing"
  done
  for folder in features plugins; do
    [[ -d "$base/$folder" ]] || fail "$base/$folder is missing"
  done

  while IFS= read -r problem; do
    [[ -n "$problem" ]] && fail "$problem"
  done < <(python3 - "$base" <<'PY'
import os
import sys
import xml.etree.ElementTree as ET
import zipfile

base = sys.argv[1]

xml_path = os.path.join(base, "content.xml")
if os.path.isfile(xml_path):
    try:
        ET.parse(xml_path)
    except ET.ParseError as error:
        print("%s is not well-formed XML (%s)" % (xml_path.replace(os.sep, "/"), error))

for name in ("artifacts.jar", "content.jar"):
    path = os.path.join(base, name)
    if os.path.isfile(path):
        try:
            with zipfile.ZipFile(path) as archive:
                if archive.testzip() is not None:
                    print("%s/%s has a damaged entry" % (base, name))
        except zipfile.BadZipFile:
            print("%s/%s is not a valid zip archive" % (base, name))
PY
  )
done

if (( releases == 0 )); then
  echo "FAIL: no release directories found under site/"
  exit 1
fi

if (( failures > 0 )); then
  echo "Release structure checks failed with $failures issue(s) in $releases release directories."
  exit 1
fi

echo "PASS: $releases release directories have a complete structure"
echo "Release structure checks passed."
