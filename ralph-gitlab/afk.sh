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
  local iids
  iids=$(glab issue list \
    --assignee "$ASSIGNEE" \
    --label ready-for-agent \
    -O json \
    --jq '.[].iid' \
    2>/dev/null || true)

  if [ -z "$iids" ]; then
    READY_ISSUES='[]'
    return
  fi

  READY_ISSUES=$(for iid in $iids; do
    glab issue view "$iid" -F json -c 2>/dev/null | jq -c '{
      number: (.iid // .id),
      title,
      body: (.description // ""),
      labels: (.labels // []),
      comments: [(.notes // [])[]? | (.body // "")]
    }'
  done | jq -s '.' || echo '[]')
}

list_open_issues() {
  glab issue list \
    -O json \
    --jq '[.[] | {number: .iid, title, labels}]' \
    2>/dev/null || echo '[]'
}

run_codereview_push_agent() {
  local issue_base=$1
  local review_prompt
  review_prompt=$(cat "$RALPH_DIR/codereview-push.md")
  run_agent "当前 Issue 实现前的固定基点 ISSUE_BASE：$issue_base

Implement Agent 已完成当前 Issue、创建 commit 并关闭 Issue。现在对本轮本地 commits 执行 Code Review、改进、commit 和 push。

$review_prompt"
}

verify_pushed_head() {
  local upstream
  local head_sha
  local upstream_sha

  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || {
    echo "Code Review Agent 完成后当前分支仍没有 upstream，无法确认 push 成功。" >&2
    return 1
  }
  head_sha=$(git rev-parse HEAD)
  upstream_sha=$(git rev-parse "$upstream")

  if [ "$head_sha" != "$upstream_sha" ]; then
    echo "Code Review Agent 完成后 HEAD 尚未同步到 $upstream。" >&2
    echo "HEAD: $head_sha" >&2
    echo "$upstream: $upstream_sha" >&2
    return 1
  fi
}

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "=== Ralph GitLab iteration $i/$MAX_ITERATIONS ($ADAPTER) ==="

  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
  refresh_ready_issues
  issues=$READY_ISSUES

  if [[ "$issues" == "[]" ]]; then
    echo "Ralph issues complete after $((i - 1)) iterations. Every completed issue has been reviewed and pushed."
    exit 0
  fi

  issue_base=$(git rev-parse HEAD)
  all_issues=$(list_open_issues)
  prompt=$(cat "$RALPH_DIR/implements_prompt.md")

  result=$(run_agent "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt")

  echo "$result"

  if [ "$(git rev-parse HEAD)" = "$issue_base" ]; then
    echo "Implement Agent 没有为当前 Issue 创建 commit，停止 Ralph。" >&2
    exit 1
  fi

  review_result=$(run_codereview_push_agent "$issue_base")
  echo "$review_result"
  verify_pushed_head
done

refresh_ready_issues
if [[ "$READY_ISSUES" == "[]" ]]; then
  echo "Ralph issues complete after $MAX_ITERATIONS iterations. Every completed issue has been reviewed and pushed."
  exit 0
fi

echo "Ralph 停止，已完成 $MAX_ITERATIONS 次迭代（达到上限）。"
