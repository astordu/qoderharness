# Issue tracker：GitHub

本仓库的 issue 和 PR 以 GitHub issue 的形式存放。所有操作都使用 `gh` CLI。

## 约定

- **创建 issue**：`gh issue create --title "..." --body "..."`。多行正文用 heredoc。
- **读取 issue**：`gh issue view <number> --comments`，用 `jq` 过滤评论并一并获取标签。
- **列出 issue**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] |{number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，配合合适的 `--label` 和 `--state` 过滤条件。
- **在 issue 上评论**：`gh issue comment <number> --body "..."`
- **添加 / 移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

从 `git remote -v` 推断仓库——在一个 clone 内运行时 `gh` 会自动这么做。

## 把 pull request 作为分诊界面

**把 PR 作为请求界面：否。** _（如果本仓库把外部 PR 当作功能请求，就设为 `yes`；`/triage` 会读取这个标志。）_

当设为 `yes` 时，PR 走与 issue 相同的标签和状态，使用 `gh pr` 的对应命令：

- **读取 PR**：`gh pr view <number> --comments`，diff 用 `gh pr diff <number>`。
- **列出待分诊的外部 PR**：`gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，然后只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR` 或 `NONE` 的（剔除 `OWNER`/`MEMBER`/`COLLABORATOR`）。
- **评论 / 打标签 / 关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 在 issue 和 PR 之间共享同一个编号空间，所以裸写的 `#42` 可能是其中任一个——用 `gh pr view 42` 解析，失败时回退到 `gh issue view 42`。

## 当某个技能说"发布到 issue tracker"

创建一个 GitHub issue。

## 当某个技能说"获取相关工单"

运行 `gh issue view <number> --comments`。

## 寻路（Wayfinding）操作

由 `/wayfinder` 使用。**地图（map）** 是单个 issue，其 **子（child）** issue 作为工单。

- **Map**：一个打了 `wayfinder:map` 标签的单个 issue，承载 Notes / Decisions-so-far / Fog 正文。`gh issue create --label wayfinder:map`。
- **Child ticket**：一个作为 GitHub 子 issue 链接到地图的 issue（在 sub-issues 端点上用 `gh api`）。在未启用 sub-issues 的地方，把该子项加入地图正文里的任务列表，并在子项正文顶部写 `Part of <map>`。标签：`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。一旦被认领，工单就分派给推进它的开发者。
- **Blocking**：GitHub 的 **原生 issue 依赖**——规范的、UI 可见的表示。用 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` 添加一条边，其中 `<blocker-db-id>` 是阻塞方的数字 **数据库 id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`，_不是_ 那个 `#number`）。当一个工单所被阻塞的每个 issue 都已关闭时，它即解除阻塞。
- **Frontier**：扫描地图的子 issue，找出那些开放、未阻塞且未分派的；编号最小者优先。
- **Claim**：在任何工作之前，把该 issue 分派给推进它的开发者。
- **Resolve**：把答案作为评论发布，关闭该 issue，然后把一个上下文指针（要点 + 链接）追加到地图的 Decisions-so-far。
