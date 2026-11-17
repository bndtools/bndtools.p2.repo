#!/usr/bin/env bash
# Seam: processing/test-oomph-consistency.sh run against a synthetic repository root.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

begin "oomph check passes on a consistent synthetic root with a text file latest"
root="$(make_repo 9.9.9 file)"
run_script test-oomph-consistency.sh "$root"
assert_exit 0 && assert_contains "Oomph consistency checks passed" && pass

begin "oomph check gives the same result when latest is a symlink"
if can_symlink; then
  root="$(make_repo 9.9.9 symlink)"
  run_script test-oomph-consistency.sh "$root"
  assert_exit 0 && assert_contains "Oomph consistency checks passed" && pass
else
  skip "symlinks not supported here"
fi

begin "oomph check fails and names the file when a setup misses a release choice"
root="$(make_repo 9.9.9 file)"
cp "$root/setup/bnd/config_bnd_10r.setup" "$root/setup/bnd/config_bnd_50r.setup"
sed -i '/p2.repo\/9.9.9/d' "$root/setup/bnd/config_bnd_50r.setup"
run_script test-oomph-consistency.sh "$root"
assert_exit 1 && assert_contains "config_bnd_50r.setup is missing release choice" && pass

begin "oomph check fails when a PR override URL lost its placeholder"
root="$(make_repo 9.9.9 file)"
sed -i 's#p2/pr/\${pullrequest}/#p2/pr//#' "$root/setup/bnd/config_bnd_10r.setup"
run_script test-oomph-consistency.sh "$root"
assert_exit 1 && assert_contains "malformed PR placeholder" && pass

begin "oomph check fails when the bndtools-release default is pinned to a version"
root="$(make_repo 9.9.9 file)"
sed -i 's#defaultValue="https://bndtools.org/bndtools.p2.repo/latest"#defaultValue="https://bndtools.org/bndtools.p2.repo/9.9.9"#' "$root/setup/bnd/config_bnd_10r.setup"
run_script test-oomph-consistency.sh "$root"
assert_exit 1 && assert_contains "config_bnd_10r.setup" && assert_contains "bndtools-release defaultValue" && pass

begin "oomph check fails when the first release choice is not 'rel latest'"
root="$(make_repo 9.9.9 file)"
sed -i 's#label="rel latest"#label="rel newest"#' "$root/setup/bnd/config_bnd_10r.setup"
run_script test-oomph-consistency.sh "$root"
assert_exit 1 && assert_contains "config_bnd_10r.setup" && assert_contains "first choice" && pass

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
