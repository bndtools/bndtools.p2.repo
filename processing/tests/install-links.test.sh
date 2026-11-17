#!/usr/bin/env bash
# Seam: processing/test-install-links.sh run against a synthetic repository root.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT=test-install-links.sh

begin "install links that point at existing setup files pass"
root="$(make_repo 9.9.9 file)"
touch "$root/setup/bnd/config_bnd_50r.setup"
cat > "$root/site/index.md" <<'EOF'
| a | [{{ site.install_button }}][50r] |

[50r]: eclipse+installer:{{ site.raw_github_url }}/master/setup/bnd/config_bnd_50r.setup
EOF
run_script "$SCRIPT" "$root"
assert_exit 0 && assert_contains "1 install links" && pass

begin "an install link to a missing setup file fails and names label and path"
root="$(make_repo 9.9.9 file)"
cat > "$root/site/index.md" <<'EOF'
[52s]: eclipse+installer:{{ site.raw_github_url }}/master/setup/bnd/config_bnd_52s.setup
EOF
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "[52s]" && assert_contains "setup/bnd/config_bnd_52s.setup" && pass

begin "a page without any install link fails"
root="$(make_repo 9.9.9 file)"
echo "nothing here" > "$root/site/index.md"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "no install links" && pass

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
