#!/usr/bin/env bash
# Seam: processing/test-repo-consistency.sh run against a synthetic repository root.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

begin "repo check reads the version from a synthetic root with a text file latest"
root="$(make_repo 9.9.9 file)"
run_script test-repo-consistency.sh "$root"
assert_exit 0 && assert_contains "site/latest declares version 9.9.9" && pass

begin "repo check gives the same result when latest is a symlink to the release directory"
if can_symlink; then
  root="$(make_repo 9.9.9 symlink)"
  run_script test-repo-consistency.sh "$root"
  assert_exit 0 && assert_contains "site/latest declares version 9.9.9" && pass
else
  skip "symlinks not supported here"
fi

begin "repo check fails and names the release when its directory is missing"
root="$(make_repo 9.9.9 file)"
rm -rf "$root/site/9.9.9"
run_script test-repo-consistency.sh "$root"
assert_exit 1 && assert_contains "release directory site/9.9.9 is missing" && pass

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
