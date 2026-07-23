#!/bin/bash
set -eo pipefail

MAX_ITERATIONS=${1:-10}

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$MAX_ITERATIONS ==="

  # 获取最近 commits 作为上下文
  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")

  # 从 GitHub 拉取所有 open issues（含正文和评论）
  # 优先拉取 ready-for-agent 标签的 issues
  issues=$(gh issue list --state open --label "ready-for-agent" --json number,title,body,labels,comments --limit 50 2>/dev/null || echo "[]")

  # 同时拉取其他 open issues（用于了解阻塞关系和全局状态）
  all_issues=$(gh issue list --state open --json number,title,labels --limit 50 2>/dev/null || echo "[]")

  # 加载 prompt
  prompt=$(cat ralph/prompt.md)

  # 运行 agent
  result=$(qodercli --permission-mode bypassPermissions -p \
    "最近的 commits: $commits

可处理的 Issues (ready-for-agent): $issues

所有 open issues（用于查看阻塞关系）: $all_issues

$prompt")

  echo "$result"

  # 检查是否所有任务都已完成
  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    echo "Ralph complete after $i iterations."
    exit 0
  fi
done

echo "Ralph 停止，已完成 $MAX_ITERATIONS 次迭代（达到上限）。"
