#!/bin/bash
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
echo "$cmd" | grep -qE 'git\s+push' || exit 0

cd "${QODER_CWD:-.}"
errors=""
echo "[pre-push] Running pre-push verification..." >&2

(cd back && uv run ruff check . 2>&1) || errors="${errors}Ruff check failed\n"

# Backend pytest (coverage >= 90%)
cov_output=$(cd back && uv run pytest --cov=app --cov-report=term-missing --cov-fail-under=90 2>&1)
cov_exit=$?
if [ $cov_exit -ne 0 ]; then
  echo "$cov_output"
  errors="${errors}Pytest/coverage check failed\n"
fi

(cd front && npm run lint 2>&1)   || errors="${errors}ESLint failed\n"
(cd front && npm run build 2>&1)  || errors="${errors}Frontend build failed\n"

if [ -n "$errors" ]; then
  printf "[pre-push] ❌ Checks failed:\n${errors}" >&2
  exit 2
fi
echo "[pre-push] ✅ All checks passed, allowing push." >&2
exit 0
