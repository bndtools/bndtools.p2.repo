#!/usr/bin/env bash
# Seam: the fixture bnd workspace stored in the repository and the helper that turns it into a Git repository.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

FIXTURE_DIR="$(cd "$PROCESSING_DIR/.." && pwd)/testbed/fixtures/bnd-workspace"
EXPECTED_LIST="$(cd "$PROCESSING_DIR/.." && pwd)/testbed/fixtures/expected-projects.txt"

begin "the projects found in the fixture equal the stored expected list"
found="$(
  { [[ -f "$FIXTURE_DIR/cnf/build.bnd" ]] && echo cnf
    for f in "$FIXTURE_DIR"/*/bnd.bnd; do [[ -f "$f" ]] && basename "$(dirname "$f")"; done
  } | sort
)"
expected="$(grep -v '^#' "$EXPECTED_LIST" 2>/dev/null | sed '/^$/d' | sort)"
if [[ -n "$found" && "$found" == "$expected" ]]; then pass; else fail "found '$(echo $found)' expected '$(echo $expected)'"; fi

begin "every project and cnf carry committed Eclipse project and classpath files"
missing=""
for name in $expected; do
  [[ -f "$FIXTURE_DIR/$name/.project" ]] || missing="$missing $name/.project"
  [[ "$name" == cnf || -f "$FIXTURE_DIR/$name/.classpath" ]] || missing="$missing $name/.classpath"
done
if [[ -n "$expected" && -z "$missing" ]]; then pass; else fail "missing:$missing"; fi

begin "each project file names its own folder"
wrong=""
for name in $expected; do
  grep -q "<name>$name</name>" "$FIXTURE_DIR/$name/.project" 2>/dev/null || wrong="$wrong $name"
done
if [[ -n "$expected" && -z "$wrong" ]]; then pass; else fail "wrong:$wrong"; fi

begin "the helper turns a copy of the fixture into a Git repository with one commit"
dest="$(new_tmp)/repo"
RUN_EXIT=0
RUN_OUT="$(bash "$PROCESSING_DIR/make-fixture-repo.sh" "$dest" 2>&1)" || RUN_EXIT=$?
count="$(git -C "$dest" rev-list --count HEAD 2>/dev/null)"
if [[ "$RUN_EXIT" -eq 0 && "$count" == 1 && -f "$dest/cnf/build.bnd" && -z "$(git -C "$dest" status --porcelain)" ]]; then pass; else fail "exit $RUN_EXIT, commits '$count'"; fi

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
