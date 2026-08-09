#!/bin/bash

RALPH_DIR=$(cd "$(dirname "$0")" && pwd -P)
PROJECT_DIR=$(dirname "$RALPH_DIR")

while true; do
  cd "$PROJECT_DIR" && "$RALPH_DIR/afk.sh" claude 20
  sleep 1800
done
