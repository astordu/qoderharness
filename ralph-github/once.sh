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

echo "=== Ralph (单次运行，$ADAPTER) ==="

# 获取最近 commits 作为上下文
commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

# 优先拉取 ready-for-agent 标签的 issues
issues=$(gh issue list --state open --label "ready-for-agent" --json number,title,body,labels,comments --limit 50 2>/dev/null || echo "[]")

# 同时拉取其他 open issues（用于了解阻塞关系和全局状态）
all_issues=$(gh issue list --state open --json number,title,labels --limit 50 2>/dev/null || echo "[]")

# 加载 prompt
prompt=$(cat ralph/prompt.md)

# 运行 agent
run_agent "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt"
