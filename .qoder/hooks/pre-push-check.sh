#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
echo "$cmd" | grep -qE 'git\s+push' || exit 0

cd "${QODER_CWD:-.}"
PROJECT_DIR=$(git rev-parse --show-toplevel)
exec "$PROJECT_DIR/scripts/check-coverage.sh"
