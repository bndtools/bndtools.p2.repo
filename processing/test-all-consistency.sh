#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/test-repo-consistency.sh"
"$SCRIPT_DIR/test-oomph-consistency.sh"
"$SCRIPT_DIR/test-deployed-pages-consistency.sh"

echo "All consistency checks passed."
