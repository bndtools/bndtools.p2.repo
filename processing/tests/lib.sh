#!/usr/bin/env bash
# Test helpers: build synthetic repository trees and assert on script behavior.

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROCESSING_DIR="$(cd "$TESTS_DIR/.." && pwd)"

TEST_FAILURES=0
TEST_COUNT=0
SKIPPED=0
TMP_ROOTS=()

new_tmp() {
  local d
  d="$(mktemp -d)"
  TMP_ROOTS+=("$d")
  echo "$d"
}

cleanup_tmp() {
  local d
  for d in "${TMP_ROOTS[@]:-}"; do
    [[ -n "$d" && -d "$d" ]] && rm -rf "$d"
  done
}
trap cleanup_tmp EXIT

# make_repo <version> [latest-kind: file|symlink]
# Creates a minimal tree in which every local consistency check passes.
make_repo() {
  local version="$1" kind="${2:-file}" root
  root="$(new_tmp)"
  mkdir -p "$root/site/$version" "$root/setup/bnd"
  : > "$root/site/$version/content.xml"
  : > "$root/site/$version/index.html"
  if [[ "$kind" == symlink ]]; then
    ln -s "$version" "$root/site/latest"
  else
    printf '%s\n' "$version" > "$root/site/latest"
  fi
  printf '<html><body><h1>Release Directories</h1><ul>\n<li><a href=%s>%s</a> -  1M</li>\n</ul></body></html>\n' "$version" "$version" > "$root/site/p2.html"
  printf 'https://bndtools.org/bndtools.p2.repo/%s/\n' "$version" > "$root/README.md"
  printf '[w]: https://github.com/bndtools/bnd/wiki/Changes-in-%s\n' "$version" > "$root/site/index.md"
  cat > "$root/setup/bnd/config_bnd_10r.setup" <<EOF
<setupTask id="bndtools-release" value="https://bndtools.org/bndtools.p2.repo/latest" defaultValue="https://bndtools.org/bndtools.p2.repo/latest">
  <choice value="https://bndtools.org/bndtools.p2.repo/latest" label="rel latest"/>
  <choice value="https://bndtools.org/bndtools.p2.repo/$version" label="rel $version"/>
  <choice value="https://bndtools.jfrog.io/bndtools/update-latest" label="release (JFrog)"/>
  <choice value="https://bndtools.jfrog.io/bndtools/update-snapshot" label="snapshot (JFrog)"/>
  <choice value="https://bndtools.jfrog.io/artifactory/p2/pr/\${pullrequest}/" label="SelectPullRequest"/>
</setupTask>
EOF
  echo "$root"
}

# add_release <root> <version>: adds a complete synthetic p2 release directory.
add_release() {
  local root="$1" version="$2" dir
  dir="$root/site/$version"
  mkdir -p "$dir/features" "$dir/plugins" "$dir/META-INF"
  printf '<?xml version="1.0"?><repository><units size="0"/></repository>\n' > "$dir/content.xml"
  : > "$dir/index.html"
  python3 - "$dir" <<'PY'
import sys, zipfile
d = sys.argv[1]
for name, inner in (("artifacts.jar", "artifacts.xml"), ("content.jar", "content.xml")):
    with zipfile.ZipFile(d + "/" + name, "w") as z:
        z.writestr(inner, "<repository/>")
PY
}

# run_script <script> <root>  -> sets RUN_OUT and RUN_EXIT
run_script() {
  local script="$1" root="$2"
  RUN_EXIT=0
  RUN_OUT="$(P2_REPO_ROOT="$root" bash "$PROCESSING_DIR/$script" 2>&1)" || RUN_EXIT=$?
}

can_symlink() {
  local d
  d="$(new_tmp)"
  ln -s target "$d/l" 2>/dev/null && [[ -L "$d/l" ]]
}

begin() {
  TEST_COUNT=$((TEST_COUNT + 1))
  CURRENT="$1"
}

pass() { echo "ok   - $CURRENT"; }

fail() {
  echo "FAIL - $CURRENT: $1"
  [[ -n "${RUN_OUT:-}" ]] && printf '       output: %s\n' "$(printf '%s' "$RUN_OUT" | tail -n 5 | tr '\n' '|')"
  TEST_FAILURES=$((TEST_FAILURES + 1))
}

skip() {
  echo "skip - $CURRENT: $1"
  SKIPPED=$((SKIPPED + 1))
}

assert_exit() {
  local expected="$1"
  if [[ "$RUN_EXIT" -ne "$expected" ]]; then
    fail "expected exit $expected, got $RUN_EXIT"
    return 1
  fi
}

assert_contains() {
  if ! grep -Fq -- "$1" <<< "$RUN_OUT"; then
    fail "output does not contain '$1'"
    return 1
  fi
}
