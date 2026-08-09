#!/bin/bash
set -eo pipefail

usage() {
  echo "Usage: $0 <qodercli|claude|codex>" >&2
}

ADAPTER=${1:-}

case "$ADAPTER" in
  qodercli|claude|codex)
    ;;
  *)
    usage
    exit 1
    ;;
esac

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

# 获取单个 issue 的完整详情（含评论）
fetch_issue_detail() {
  local iid=$1
  glab issue view "$iid" -F json -c 2>/dev/null
}

# 获取带指定标签的 issues 完整详情（含评论）
fetch_issues_with_label() {
  local label=$1
  local iids
  iids=$(glab issue list --label "$label" -O json --jq '.[].iid' 2>/dev/null || true)
  if [ -z "$iids" ]; then
    echo "[]"
    return
  fi
  local first=true
  echo "["
  for iid in $iids; do
    if [ "$first" = true ]; then first=false; else echo ","; fi
    fetch_issue_detail "$iid" | jq -c '.'
  done
  echo "]"
}

# 获取所有 open issues 的摘要
fetch_open_issue_summaries() {
  glab issue list -O json --jq '[.[] | {iid, title, labels}]' 2>/dev/null || echo "[]"
}

echo "=== Ralph (单次运行，$ADAPTER) ==="

# 获取最近 commits 作为上下文
commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

# 优先拉取 ready-for-agent 标签的 issues（含正文和评论）
issues=$(fetch_issues_with_label "ready-for-agent")

# 同时拉取其他 open issues（用于了解阻塞关系和全局状态）
all_issues=$(fetch_open_issue_summaries)

# 加载 prompt
prompt=$(cat ralph/prompt.md)

# 运行 agent
run_agent "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt"
