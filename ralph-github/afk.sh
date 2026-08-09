#!/bin/bash
set -eo pipefail

usage() {
  echo "Usage: $0 <qodercli|claude|codex> [max_iterations]" >&2
}

ADAPTER=${1:-}
MAX_ITERATIONS=${2:-10}

case "$ADAPTER" in
  qodercli|claude|codex)
    ;;
  *)
    usage
    exit 1
    ;;
esac

if ! [[ "$MAX_ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
  echo "max_iterations 必须是正整数。" >&2
  usage
  exit 1
fi

run_agent() {
  local agent_prompt=$1

  case "$ADAPTER" in
    qodercli)
      qodercli --model Qwen3.8-Max --permission-mode bypassPermissions -p "$agent_prompt"
      ;;
    claude)
      claude --dangerously-skip-permissions -p "$agent_prompt"
      ;;
    codex)
      codex exec --dangerously-bypass-approvals-and-sandbox "$agent_prompt"
      ;;
  esac
}

list_ready_issues() {
  gh issue list \
    --state open \
    --label "ready-for-agent" \
    --json number,title,body,labels,comments \
    --limit 50 \
    --jq '[.[] |{number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'
}

list_open_issue_summaries() {
  gh issue list \
    --state open \
    --json number,title,labels \
    --limit 50 \
    --jq '[.[] |{number, title, labels: [.labels[].name]}]'
}

refresh_ready_issues() {
  if ! READY_ISSUES=$(list_ready_issues); then
    echo "Ralph 无法读取 ready-for-agent issues，停止运行。" >&2
    return 1
  fi
}

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$MAX_ITERATIONS ($ADAPTER) ==="

  # 获取最近 commits 作为上下文
  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

  # 从 GitHub 拉取所有 open issues（含正文和评论）
  # 优先拉取 ready-for-agent 标签的 issues
  if ! refresh_ready_issues; then
    exit 1
  fi
  issues=$READY_ISSUES

  if [[ "$issues" == "[]" ]]; then
    echo "Ralph complete after $((i - 1)) iterations."
    exit 0
  fi

  # 同时拉取其他 open issues（用于了解阻塞关系和全局状态）
  if ! all_issues=$(list_open_issue_summaries); then
    echo "Ralph 无法读取 open issues，停止运行。" >&2
    exit 1
  fi

  # 加载 prompt
  prompt=$(cat ralph/prompt.md)

  # 运行 agent
  result=$(run_agent "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt")

  echo "$result"
done

if ! refresh_ready_issues; then
  exit 1
fi

if [[ "$READY_ISSUES" == "[]" ]]; then
  echo "Ralph complete after $MAX_ITERATIONS iterations."
  exit 0
fi

echo "Ralph 停止，已完成 $MAX_ITERATIONS 次迭代（达到上限）。"
