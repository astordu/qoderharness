---
name: create-pr
description: 当用户明确要求从当前已推送分支创建 GitHub Pull Request 或 GitLab Merge Request 时使用。检查完整分支范围，调用 /pr 生成描述，并在创建前让用户确认；不得由 CI 或 Agent 自行触发。
disable-model-invocation: true
---

# 目标

由用户主动发起一个供人类审查的 PR/MR。完整变更范围是目标分支与远端源分支的 merge-base 到远端源分支头；不要复用某一次 push 的 `before SHA`。

本技能负责：

1. 检查平台、分支、远端同步状态和既有 PR/MR。
2. 计算完整 PR 范围并收集 commits、issues 和验证证据。
3. 调用 `/pr` 生成简洁的 PR/MR Body。
4. 展示标题、范围和 Body，获得用户确认后创建 PR/MR。

本技能不负责实现需求、修复 Code Review、自动 push 或合并。

# 流程

## 1. 确定平台与参数

根据 `origin` URL 判断平台：

- GitHub 使用 `gh`。
- GitLab 使用 `glab`。
- 无法可靠判断时询问用户，不要猜测。

读取用户提供的目标分支、Draft 状态、Reviewer 等参数。用户未指定目标分支时，优先使用 `origin/HEAD` 指向的默认分支；仍无法确定时再询问。

确认平台 CLI 已安装且认证有效。认证失败时停止，不要尝试修改凭据。

## 2. 检查本地与远端状态

执行 `git fetch origin`，然后确定：

```bash
CURRENT_BRANCH=$(git branch --show-current)
REMOTE_HEAD="origin/$CURRENT_BRANCH"
REMOTE_BASE="origin/$TARGET_BRANCH"
```

必须满足：

- 当前处于普通本地分支，而不是 detached HEAD。
- 当前分支不是目标分支。
- 工作区和暂存区没有未提交修改。
- `REMOTE_BASE` 和 `REMOTE_HEAD` 都存在。
- 本地 `HEAD` 与 `REMOTE_HEAD` 指向同一个 commit。

如果本地领先、落后或与远端分叉，停止并说明差异。不要自行执行 `git push`、`git pull`、rebase、merge 或强制同步。PR/MR 描述必须以服务器实际收到的远端源分支为准。

## 3. 防止重复创建

检查当前源分支是否已经存在 open PR/MR：

- GitHub：使用 `gh pr list --head "$CURRENT_BRANCH" --state open`。
- GitLab：使用 `glab mr list --source-branch "$CURRENT_BRANCH"`。

如果已经存在，停止创建并返回现有链接。只有用户明确要求更新描述时，才重新调用 `/pr` 并更新已有 PR/MR；不要创建重复项。

## 4. 计算完整 PR 范围

使用远端目标分支和远端源分支：

```bash
PR_BASE=$(git merge-base "$REMOTE_BASE" "$REMOTE_HEAD")
git diff "$PR_BASE"..."$REMOTE_HEAD"
git log "$PR_BASE".."$REMOTE_HEAD" --oneline
```

验证 `PR_BASE` 是有效 commit 且 diff 非空。这个范围代表整个分支相对目标分支的变化，不是最后一次 push 的变化。

从完整 commit message 中提取所有 issue 引用。根据平台使用 `gh issue view` 或 `glab issue view` 读取需求；已经关闭的 issue 仍然属于 PR 的需求来源。

## 5. 收集真实证据

读取仓库已有的测试、lint、typecheck、覆盖率和 CI 配置。使用已有输出或实际执行适合当前项目的验证命令。

- 不把占位 `echo` 当作测试证据。
- 不声称未执行的检查已经通过。
- UI 变化且可以获取截图时，优先提供 Before/After 截图。
- 无法获得某项证据时，在 Body 中明确说明，不要伪造。

## 6. 调用 `/pr`

把以下上下文交给 `/pr`：

- 目标分支、源分支、`PR_BASE` 和远端源分支头。
- `git diff "$PR_BASE"..."$REMOTE_HEAD"` 的完整改动范围。
- `git log "$PR_BASE".."$REMOTE_HEAD"` 的 commits。
- 所有关联 issues 的规格说明。
- 实际验证结果和已知风险。

使用 `/pr` 的 `Summary`、`Evidence`、`Merge Danger` 结构生成 Body。标题应简洁概括整个 PR，而不是只描述最后一个 commit。

## 7. 展示并确认

创建之前必须向用户展示：

- 平台与仓库。
- 源分支、目标分支。
- `PR_BASE...REMOTE_HEAD` 范围和 commit 数量。
- PR/MR 标题。
- 完整 Body。
- 是否为 Draft，以及将请求的 Reviewer/标签。

用户确认前不得创建。如果用户修改标题、Body、目标分支或 Draft 状态，重新验证受影响的范围并再次展示最终结果。

## 8. 创建 PR/MR

将最终 Body 写入临时文件；不要把临时文件提交到仓库。

GitHub：

```bash
gh pr create \
  --base "$TARGET_BRANCH" \
  --head "$CURRENT_BRANCH" \
  --title "$TITLE" \
  --body-file "$BODY_FILE"
```

GitLab：

```bash
glab mr create \
  --target-branch "$TARGET_BRANCH" \
  --source-branch "$CURRENT_BRANCH" \
  --title "$TITLE" \
  --description-file "$BODY_FILE" \
  --yes
```

仅当用户要求时添加 `--draft`、Reviewer、标签或其他平台选项。不要使用会隐式 push 分支的 `--fill` 或 `--push`。

创建成功后返回 PR/MR URL、完整审查范围和平台返回的编号。创建失败时报告原始错误并保留已经生成的标题和 Body；不要自动重试会产生重复外部对象的命令。

# 最终限制

- 只能由用户明确调用，不能加入 CI 或 Ralph 自动循环。
- 不创建空 PR/MR。
- 不从默认分支向自身创建 PR/MR。
- 不自动 push、pull、merge、rebase 或改写历史。
- 不自动合并，不启用自动合并。
- 不创建重复 PR/MR。
- `/pr` 只负责描述格式；本技能负责范围、确认和平台创建操作。
