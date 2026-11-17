#!/usr/bin/env bash
# Seam: processing/test-releases-structure.sh run against a synthetic repository root.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SCRIPT=test-releases-structure.sh

begin "complete releases pass and non-release folders are ignored"
root="$(new_tmp)"
add_release "$root" 7.5.0
add_release "$root" 7.4.0
mkdir -p "$root/site/assets" "$root/site/doc"
run_script "$SCRIPT" "$root"
assert_exit 0 && assert_contains "2 release directories" && pass

begin "a release without artifacts.jar fails and names release and file"
root="$(new_tmp)"
add_release "$root" 7.5.0
add_release "$root" 7.4.0
rm "$root/site/7.4.0/artifacts.jar"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "site/7.4.0/artifacts.jar" && pass

begin "a release without index.html fails and names it"
root="$(new_tmp)"
add_release "$root" 7.5.0
rm "$root/site/7.5.0/index.html"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "site/7.5.0/index.html" && pass

begin "a release without plugins folder fails and names it"
root="$(new_tmp)"
add_release "$root" 7.5.0
rmdir "$root/site/7.5.0/plugins"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "site/7.5.0/plugins" && pass

begin "a content.xml that is not well-formed fails and names it"
root="$(new_tmp)"
add_release "$root" 7.5.0
printf '<repository><units>' > "$root/site/7.5.0/content.xml"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "site/7.5.0/content.xml" && pass

begin "a jar that is not a zip fails and names it"
root="$(new_tmp)"
add_release "$root" 7.5.0
printf 'not a zip' > "$root/site/7.5.0/content.jar"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "site/7.5.0/content.jar" && pass

begin "a site without any release fails"
root="$(new_tmp)"
mkdir -p "$root/site"
run_script "$SCRIPT" "$root"
assert_exit 1 && assert_contains "no release directories" && pass

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
