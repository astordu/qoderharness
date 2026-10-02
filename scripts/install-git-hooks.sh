#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=$(git rev-parse --show-toplevel)
git -C "$PROJECT_DIR" config core.hooksPath .githooks
echo "Git hooks enabled from $PROJECT_DIR/.githooks"
