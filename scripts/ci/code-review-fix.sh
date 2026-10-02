#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <qodercli|claude|codex>" >&2
}

ADAPTER=${1:-${AI_AGENT_ADAPTER:-qodercli}}
case "$ADAPTER" in
  qodercli|claude|codex) ;;
  *) usage; exit 1 ;;
esac

PROJECT_DIR=$(git rev-parse --show-toplevel)
PROMPT_FILE="$PROJECT_DIR/scripts/ci/code-review-fix_prompt.md"
ZERO_SHA=0000000000000000000000000000000000000000

run_agent() {
  local agent_prompt=$1
  case "$ADAPTER" in
    qodercli) qodercli --model Qwen3.8-Max --permission-mode bypassPermissions -p "$agent_prompt" ;;
    claude) claude --dangerously-skip-permissions -p "$agent_prompt" ;;
    codex) codex exec --dangerously-bypass-approvals-and-sandbox "$agent_prompt" ;;
  esac
}

resolve_review_base() {
  local before_sha=${REVIEW_BASE_SHA:-${CI_COMMIT_BEFORE_SHA:-${GITHUB_EVENT_BEFORE:-}}}
  local default_branch=${CI_DEFAULT_BRANCH:-${GITHUB_DEFAULT_BRANCH:-main}}
  local default_ref="origin/$default_branch"

  if [ -n "$before_sha" ] && [ "$before_sha" != "$ZERO_SHA" ] && git cat-file -e "$before_sha^{commit}" 2>/dev/null; then
    echo "$before_sha"
    return
  fi

  if git remote get-url origin >/dev/null 2>&1; then
    git fetch origin "$default_branch:refs/remotes/origin/$default_branch" >&2
  fi

  if git rev-parse --verify "$default_ref^{commit}" >/dev/null 2>&1; then
    git merge-base "$default_ref" HEAD
    return
  fi

  if git rev-parse --verify "$default_branch^{commit}" >/dev/null 2>&1; then
    git merge-base "$default_branch" HEAD
    return
  fi

  git rev-list --max-parents=0 HEAD | tail -n 1
}

cd "$PROJECT_DIR"

REVIEW_BASE=$(resolve_review_base)
git rev-parse --verify "$REVIEW_BASE^{commit}" >/dev/null

if git diff --quiet "$REVIEW_BASE"...HEAD; then
  echo "No changes found in $REVIEW_BASE...HEAD; skipping AI Code Review."
  exit 0
fi

START_SHA=$(git rev-parse HEAD)
TARGET_BRANCH=${CI_COMMIT_REF_NAME:-${GITHUB_REF_NAME:-$(git branch --show-current)}}
PLATFORM=${CODE_HOST_PLATFORM:-}

if [ -z "$PLATFORM" ] && [ -n "${GITHUB_ACTIONS:-}" ]; then
  PLATFORM=github
elif [ -z "$PLATFORM" ] && [ -n "${GITLAB_CI:-}" ]; then
  PLATFORM=gitlab
elif [ -z "$PLATFORM" ]; then
  PLATFORM=unknown
fi

if [ -z "$TARGET_BRANCH" ]; then
  echo "Unable to determine the target branch for review fixes." >&2
  exit 1
fi

COMMIT_LOG=$(git log "$REVIEW_BASE"..HEAD --format='%H %s%n%b%n---')
ISSUE_REFS=$(git log "$REVIEW_BASE"..HEAD --format='%B' | grep -Eo '#[0-9]+' | sort -u | tr '\n' ' ' || true)
REVIEW_PROMPT=$(cat "$PROMPT_FILE")

git config user.name "${AI_REVIEW_GIT_NAME:-AI Review Bot}"
git config user.email "${AI_REVIEW_GIT_EMAIL:-ai-review-bot@example.com}"

run_agent "CI Code Review 上下文

代码托管平台：$PLATFORM
固定基点（整个 Review/修复任务中保持不变）：$REVIEW_BASE
任务开始时的 HEAD：$START_SHA
目标分支：$TARGET_BRANCH
提交中引用的 Issues：${ISSUE_REFS:-无}

提交列表：
$COMMIT_LOG

$REVIEW_PROMPT"

if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "The review agent left uncommitted changes. Each repair round must be committed before re-review." >&2
  git status --short >&2
  exit 1
fi

if [ "$(git rev-parse HEAD)" = "$START_SHA" ]; then
  echo "AI Code Review completed without repair commits."
  exit 0
fi

if ! git merge-base --is-ancestor "$START_SHA" HEAD; then
  echo "The review agent rewrote existing history; refusing to push." >&2
  exit 1
fi

git push origin "HEAD:$TARGET_BRANCH"
