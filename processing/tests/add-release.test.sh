#!/usr/bin/env bash
# Seam: processing/add-release.sh run against a synthetic repository root with a local artifact.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# make_artifact <path>: a stand-in for org.bndtools.p2-<version>.jar
make_artifact() {
  python3 - "$1" <<'PY'
import io, sys, zipfile

def inner_zip():
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as z:
        z.writestr("x.xml", "<repository/>")
    return buffer.getvalue()

with zipfile.ZipFile(sys.argv[1], "w") as z:
    z.writestr("content.xml", '<?xml version="1.0"?><repository><units size="0"/></repository>')
    z.writestr("artifacts.jar", inner_zip())
    z.writestr("content.jar", inner_zip())
    z.writestr("features/a.jar", "x")
    z.writestr("plugins/b.jar", "x")
PY
}

make_stubs() {
  STUB_DIR="$(new_tmp)"
  printf '#!/usr/bin/env bash\nout=""\nwhile [[ $# -gt 0 ]]; do [[ "$1" == "-o" ]] && out="$2"; shift; done\necho "<html>stub</html>" > "$out"\n' > "$STUB_DIR/xsltproc"
  chmod +x "$STUB_DIR/xsltproc"
  make_artifact "$STUB_DIR/org.bndtools.p2-9.9.9.jar"
}

# release <root> <version> [extra args]  -> sets RUN_OUT and RUN_EXIT
release() {
  local root="$1" version="$2"
  shift 2
  RUN_EXIT=0
  RUN_OUT="$(P2_REPO_ROOT="$root" XSLTPROC="$STUB_DIR/xsltproc" bash "$PROCESSING_DIR/add-release.sh" "$version" --artifact-url "file://$STUB_DIR/org.bndtools.p2-9.9.9.jar" "$@" 2>&1)" || RUN_EXIT=$?
}

snapshot() {
  local copy
  copy="$(new_tmp)"
  cp -R "$1/." "$copy/"
  echo "$copy"
}

make_stubs

begin "a new release passes every local check afterwards"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
release "$root" 9.9.9
run_script test-repo-consistency.sh "$root"; repo_exit=$RUN_EXIT
run_script test-oomph-consistency.sh "$root"; oomph_exit=$RUN_EXIT
run_script test-releases-structure.sh "$root"; structure_exit=$RUN_EXIT
run_script test-install-links.sh "$root"; links_exit=$RUN_EXIT
if [[ "$repo_exit$oomph_exit$structure_exit" == 000 && -f "$root/site/9.9.9/index.html" ]]; then pass; else fail "repo=$repo_exit oomph=$oomph_exit structure=$structure_exit"; fi

begin "the new choice follows 'rel latest' in every setup file"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
release "$root" 9.9.9
order="$(grep -o 'label="rel [^"]*"' "$root/setup/bnd/config_bnd_10r.setup" | head -n 3 | tr '\n' ' ')"
if [[ "$order" == 'label="rel latest" label="rel 9.9.9" label="rel 9.9.8" ' ]]; then pass; else fail "order was: $order"; fi

begin "release page, README and wiki links name the new release"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
release "$root" 9.9.9
if grep -q 'href=9.9.9>9.9.9</a>' "$root/site/p2.html" \
   && grep -q 'bndtools.p2.repo/9.9.9/' "$root/README.md" \
   && grep -q 'Changes-in-9.9.9' "$root/site/index.md" \
   && [[ "$(tr -d '\r\n' < "$root/site/latest")" == 9.9.9 ]]; then pass; else fail "references not updated"; fi

begin "latest stays a symlink and moves to the new release"
if can_symlink; then
  root="$(make_repo 9.9.8 symlink)"
  add_release "$root" 9.9.8
  release "$root" 9.9.9
  if [[ -L "$root/site/latest" && "$(readlink "$root/site/latest")" == 9.9.9 ]]; then pass; else fail "latest is '$(readlink "$root/site/latest")'"; fi
else
  skip "symlinks not supported here"
fi

begin "running it twice changes nothing the second time"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
release "$root" 9.9.9
before="$(snapshot "$root")"
release "$root" 9.9.9
if [[ "$RUN_EXIT" -eq 0 ]] && diff -r "$before" "$root" > /dev/null; then pass; else fail "exit $RUN_EXIT or tree changed"; fi

begin "an unreachable artifact fails and leaves the tree unchanged"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
before="$(snapshot "$root")"
RUN_EXIT=0
RUN_OUT="$(P2_REPO_ROOT="$root" XSLTPROC="$STUB_DIR/xsltproc" bash "$PROCESSING_DIR/add-release.sh" 9.9.9 --artifact-url "file://$STUB_DIR/missing.jar" 2>&1)" || RUN_EXIT=$?
if [[ "$RUN_EXIT" -ne 0 ]] && diff -r "$before" "$root" > /dev/null; then pass; else fail "exit $RUN_EXIT or tree changed"; fi

begin "an existing release directory is kept, not overwritten"
root="$(make_repo 9.9.8 file)"
add_release "$root" 9.9.8
add_release "$root" 9.9.9
echo keep > "$root/site/9.9.9/marker.txt"
release "$root" 9.9.9
if [[ -f "$root/site/9.9.9/marker.txt" ]] && assert_contains "keeping"; then pass; fi

begin "an invalid version is rejected"
root="$(make_repo 9.9.8 file)"
release "$root" "not-a-version"
assert_exit 2 && pass

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
