#!/usr/bin/env bash
set -eo pipefail

RALPH_DIR=$(cd "$(dirname "$0")" && pwd -P)
exec "$RALPH_DIR/afk.sh" "${1:-}" 1
