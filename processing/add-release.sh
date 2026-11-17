#!/usr/bin/env bash
# Performs the mechanical steps of adding a bnd/bndtools release to this
# repository (see .github/skills/update-bnd-version/SKILL.md):
#   - downloads and extracts the p2 jar into site/<version>/ and generates index.html
#   - points site/latest at the new release and lists it in site/p2.html
#   - adds the 'rel <version>' choice after 'rel latest' in every setup file
#   - updates the release links in README.md and site/index.md
#
# Usage: add-release.sh <version> [--artifact-url <url>]
#
# Safe to run twice: an existing release directory is kept, every other step
# only changes what is not yet up to date. A failure before the release
# directory is in place leaves the working tree unchanged.
# Environment: P2_REPO_ROOT (repository root), XSLTPROC (xsltproc executable).

set -euo pipefail

usage() {
  echo "usage: $0 <version> [--artifact-url <url>]" >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
version="$1"
shift
artifact_url=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --artifact-url) [[ $# -ge 2 ]] || usage; artifact_url="$2"; shift 2 ;;
    *) usage ;;
  esac
done

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "invalid version '$version', expected <major>.<minor>.<micro>" >&2
  exit 2
fi

ROOT_DIR="${P2_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=processing/lib-latest.sh
source "$SCRIPT_DIR/lib-latest.sh"
cd "$ROOT_DIR"

artifact_url="${artifact_url:-https://bndtools.jfrog.io/artifactory/update-latest/org/bndtools/org.bndtools.p2/$version/org.bndtools.p2-$version.jar}"
xsltproc_cmd="${XSLTPROC:-xsltproc}"

has_latest "$ROOT_DIR" || { echo "site/latest is missing" >&2; exit 1; }
old_version="$(read_latest "$ROOT_DIR")"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

extract() { # extract <zip> <destination> [member]
  python3 - "$@" <<'PY'
import sys, zipfile
archive, dest = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(archive) as z:
    z.extractall(dest, members=[sys.argv[3]] if len(sys.argv) > 3 else None)
PY
}

if [[ -e "site/$version" ]]; then
  echo "release directory site/$version exists, keeping it"
else
  echo "downloading $artifact_url"
  curl -fsSL "$artifact_url" -o "$work/artifact.jar"
  mkdir "$work/release"
  extract "$work/artifact.jar" "$work/release"
  if [[ ! -f "$work/release/content.xml" && -f "$work/release/content.jar" ]]; then
    extract "$work/release/content.jar" "$work/release" content.xml
  fi
  [[ -f "$work/release/content.xml" ]] || { echo "artifact contains no content.xml" >&2; exit 1; }
  command -v "$xsltproc_cmd" > /dev/null || { echo "$xsltproc_cmd is required to generate index.html" >&2; exit 1; }
  "$xsltproc_cmd" "$SCRIPT_DIR/content2html.xsl" "$work/release/content.xml" -o "$work/release/index.html"
  [[ -f "$work/release/index.html" ]] || { echo "index.html was not generated" >&2; exit 1; }
  cp "$work/artifact.jar" "$work/release/org.bndtools.p2-$version.jar"
  mv "$work/release" "site/$version"
  echo "created site/$version"
fi

# site/latest keeps the form it has in this checkout (symbolic link or text file)
if [[ -L site/latest ]]; then
  ln -sfn "$version" site/latest
else
  printf '%s\n' "$version" > site/latest
fi

if ! grep -q "href=$version>" site/p2.html; then
  size_mb=$(( ($(du -sk "site/$version" | cut -f1) + 512) / 1024 ))
  entry="<li><a href=$version>$version</a> -  ${size_mb}M</li>"
  python3 - site/p2.html "$entry" <<'PY'
import sys
path, entry = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8", newline="") as f:
    text = f.read()
eol = "\r\n" if "\r\n" in text else "\n"
if "</ul>" not in text:
    sys.exit("site/p2.html has no </ul>; cannot add the release entry")
text = text.replace("</ul>", entry + eol + "</ul>", 1)
with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(text)
PY
fi

python3 - "$old_version" "$version" <<'PY'
import os
import re
import sys

old, new = sys.argv[1], sys.argv[2]


def rewrite(path, transform):
    with open(path, encoding="utf-8", newline="") as f:
        text = f.read()
    changed = transform(text)
    if changed != text:
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(changed)


def setup(text):
    if 'id="bndtools-release"' not in text or ('bndtools.p2.repo/%s"' % new) in text:
        return text
    eol = "\r\n" if "\r\n" in text else "\n"
    pattern = re.compile(
        r'^([ \t]*)(<choice\s+value="https://bndtools\.org/bndtools\.p2\.repo/latest"\s+label="rel latest"\s*/>)',
        re.M)

    def add(match):
        copy = match.group(2).replace("/latest", "/" + new).replace("rel latest", "rel " + new)
        return match.group(0) + eol + match.group(1) + copy

    return pattern.sub(add, text, count=1)


for folder, _, files in os.walk("setup"):
    for name in files:
        if name.endswith(".setup"):
            rewrite(os.path.join(folder, name), setup)

if old != new:
    rewrite("README.md", lambda t: t.replace("bndtools.p2.repo/%s/" % old, "bndtools.p2.repo/%s/" % new)
            .replace("[bndtools %s]" % old, "[bndtools %s]" % new))
    rewrite("site/index.md", lambda t: t.replace("Changes-in-%s" % old, "Changes-in-%s" % new))
PY

echo "Release $version added (previous latest: $old_version). Run processing/test-all-consistency.sh to verify."
