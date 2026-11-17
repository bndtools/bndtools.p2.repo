#!/usr/bin/env bash
# Shared helpers for the consistency checks.

# has_latest <root>: succeeds when <root>/site/latest exists as file or symbolic link.
has_latest() {
  [[ -L "$1/site/latest" || -f "$1/site/latest" ]]
}

# read_latest <root>: prints the version named by <root>/site/latest.
# In Git the entry is a symbolic link to a release directory; on checkouts
# without symbolic-link support it is a text file holding the version.
read_latest() {
  local entry="$1/site/latest" target
  if [[ -L "$entry" ]]; then
    target="$(readlink "$entry")"
    basename "${target%/}"
  elif [[ -f "$entry" ]]; then
    tr -d '\r\n' < "$entry"
  else
    return 1
  fi
}
