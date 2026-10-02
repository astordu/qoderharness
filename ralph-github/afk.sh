#!/usr/bin/env bash
set -eo pipefail

usage() {
  echo "Usage: $0 <qodercli|claude|codex> [max_iterations]" >&2
}

RALPH_DIR=$(cd "$(dirname "$0")" && pwd -P)
PROJECT_DIR=$(dirname "$RALPH_DIR")
ADAPTER=${1:-}
MAX_ITERATIONS=${2:-10}
ASSIGNEE=${RALPH_ASSIGNEE:-@me}

cd "$PROJECT_DIR"

case "$ADAPTER" in
  qodercli|claude|codex) ;;
  *) usage; exit 1 ;;
esac

if ! [[ "$MAX_ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "max_iterations 必须是正整数。" >&2
  usage
  exit 1
fi

run_agent() {
  local agent_prompt=$1
  case "$ADAPTER" in
    qodercli) qodercli --model Qwen3.8-Max --permission-mode bypassPermissions -p "$agent_prompt" ;;
    claude) claude --dangerously-skip-permissions -p "$agent_prompt" ;;
    codex) codex exec --dangerously-bypass-approvals-and-sandbox "$agent_prompt" ;;
  esac
}

refresh_ready_issues() {
  READY_ISSUES=$(gh issue list \
    --state open \
    --assignee "$ASSIGNEE" \
    --label ready-for-agent \
    --json number,title,body,labels,comments \
    --limit 100 \
    --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]' \
    2>/dev/null || echo '[]')
}

list_open_issues() {
  gh issue list \
    --state open \
    --json number,title,labels \
    --limit 100 \
    --jq '[.[] | {number, title, labels: [.labels[].name]}]' \
    2>/dev/null || echo '[]'
}

run_push_agent() {
  local push_prompt
  push_prompt=$(cat "$RALPH_DIR/push-prompt.md")
  run_agent "GitHub ready-for-agent issue 列表为空。现在执行最终统一 push。

$push_prompt"
}

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "=== Ralph GitHub iteration $i/$MAX_ITERATIONS ($ADAPTER) ==="

  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
  refresh_ready_issues
  issues=$READY_ISSUES

  if [[ "$issues" == "[]" ]]; then
    echo "Ralph issues complete after $((i - 1)) iterations. Starting final push agent."
    run_push_agent
    exit 0
  fi

  all_issues=$(list_open_issues)
  prompt=$(cat "$RALPH_DIR/implements_prompt.md")

  result=$(run_agent "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt")

  echo "$result"
done

refresh_ready_issues
if [[ "$READY_ISSUES" == "[]" ]]; then
  echo "Ralph issues complete after $MAX_ITERATIONS iterations. Starting final push agent."
  run_push_agent
  exit 0
fi

echo "Ralph 停止，已完成 $MAX_ITERATIONS 次迭代（达到上限）。"
