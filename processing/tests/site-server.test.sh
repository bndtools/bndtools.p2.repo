#!/usr/bin/env bash
# Seam: processing/serve-site.py as an HTTP server over a synthetic site directory.

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SERVER_PID=""
stop_server() {
  [[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null
  SERVER_PID=""
}
trap 'stop_server; cleanup_tmp' EXIT

# start_server <site-dir>  -> sets SERVER_URL; the server reports its address on its first output line
start_server() {
  local log i
  log="$(new_tmp)/server.log"
  python3 "$PROCESSING_DIR/serve-site.py" --site "$1" --port 0 > "$log" 2>&1 &
  SERVER_PID=$!
  SERVER_URL=""
  for i in $(seq 1 50); do
    SERVER_URL="$(grep -Eo 'http://127\.0\.0\.1:[0-9]+/' "$log" | head -n 1)"
    [[ -n "$SERVER_URL" ]] && return 0
    sleep 0.1
  done
  RUN_OUT="$(cat "$log")"
  return 1
}

# fetch <path> -> sets HTTP_CODE and HTTP_BODY
fetch() {
  local out
  out="$(new_tmp)/body"
  HTTP_CODE="$(curl -s --max-time 5 --noproxy '*' -o "$out" -w '%{http_code}' "$SERVER_URL$1")"
  HTTP_BODY="$(cat "$out")"
}

p2_index_content=$'version=1\nmetadata.repository.factory.order=content.xml,\\!\n'

begin "latest/p2.index returns the same content as the release it names (text file latest)"
root="$(make_repo 9.9.9 file)"
printf '%s' "$p2_index_content" > "$root/site/9.9.9/p2.index"
if start_server "$root/site"; then
  fetch "latest/p2.index"
  if [[ "$HTTP_CODE" == 200 && "$HTTP_BODY" == "$(cat "$root/site/9.9.9/p2.index")" ]]; then pass; else fail "status $HTTP_CODE, body '$HTTP_BODY'"; fi
else
  fail "server did not report an address"
fi
stop_server

begin "latest/p2.index works when latest is a symlink"
if can_symlink; then
  root="$(make_repo 9.9.9 symlink)"
  printf '%s' "$p2_index_content" > "$root/site/9.9.9/p2.index"
  if start_server "$root/site"; then
    fetch "latest/p2.index"
    if [[ "$HTTP_CODE" == 200 && "$HTTP_BODY" == "$(cat "$root/site/9.9.9/p2.index")" ]]; then pass; else fail "status $HTTP_CODE"; fi
  else
    fail "server did not report an address"
  fi
  stop_server
else
  skip "symlinks not supported here"
fi

begin "a release is reachable under its own name and unknown paths give 404"
root="$(make_repo 9.9.9 file)"
printf 'x' > "$root/site/9.9.9/content.xml"
start_server "$root/site" || fail "server did not report an address"
fetch "9.9.9/content.xml"; first="$HTTP_CODE"
fetch "9.9.9/nothing.xml"; second="$HTTP_CODE"
if [[ "$first" == 200 && "$second" == 404 ]]; then pass; else fail "got $first and $second"; fi
stop_server

begin "paths cannot escape the site directory"
root="$(make_repo 9.9.9 file)"
echo secret > "$root/secret.txt"
start_server "$root/site" || fail "server did not report an address"
fetch "9.9.9/content.xml"; reachable="$HTTP_CODE"
escaped="$(curl -s --max-time 5 --noproxy '*' --path-as-is -o /dev/null -w '%{http_code}' "${SERVER_URL}../secret.txt")"
if [[ "$reachable" == 200 && ( "$escaped" == 400 || "$escaped" == 403 || "$escaped" == 404 ) ]]; then pass; else fail "reachable=$reachable escaped=$escaped"; fi
stop_server

echo "-- $TEST_COUNT tests, $TEST_FAILURES failed, $SKIPPED skipped"
(( TEST_FAILURES == 0 ))
