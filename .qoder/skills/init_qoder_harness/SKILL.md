---
name: init_qoder_harness
description: 为本仓库配置工程技能——设置 issue tracker 和分诊（triage）标签词汇。在首次使用其他工程技能之前运行一次。
disable-model-invocation: true
---

# 初始化 Qoder Harness

搭建工程技能所假定的、按仓库划分的配置：

- **Issue tracker**——issue 存放在哪里（默认 GitHub；本地 markdown 也开箱即用地受支持）
- **分诊标签（Triage labels）**——用于五个规范分诊角色的字符串

这是一个由提示词驱动的技能，而非一个确定性脚本。探索、呈现你的发现、与用户确认，然后再写入。

## 流程

### 1. 探索

查看当前仓库以理解它的初始状态。阅读已存在的东西；不要假设：

- `git remote -v` 和 `.git/config`——这是一个 GitHub 仓库吗？哪一个？
- 仓库根目录的 `AGENTS.md` 和 `CLAUDE.md`——有哪个存在吗？其中是否已有一个 `## Agent skills` 小节？
- `docs/agents/`——这个技能之前的输出是否已经存在？
- `.scratch/`——本地 markdown issue tracker 约定已在使用中的迹象
- `triage` 技能安装了吗？（与本技能并列的一个 `triage` 技能文件夹，或你可用技能中的 `triage`。）这决定 B 节是否会运行。

### 2. 呈现发现并询问

概述有什么、缺什么。然后按顺序处理各小节——一节，一个回答，再到下一节。

每一节都以推荐的答案开头，好让用户一个字就能接受它。只在选择确实产生分支时给一句解释；当探索已经把它敲定时就整节跳过（`triage` 未安装时跳过 B 节）。

**A 节——Issue tracker。**

> 解释：所谓 "issue tracker" 是本仓库 issue 存放的地方。像 `to-tickets`、`triage`、`to-spec` 和 `qa` 这样的技能会从中读取、也向其写入——它们需要知道到底该调用 `gh issue create`、在 `.scratch/` 下写一个 markdown 文件，还是遵循你描述的某种其他工作流。选你实际为本仓库跟踪工作的地方。

默认姿态：这些技能是为 GitHub 设计的。如果某个 `git remote` 指向 GitHub，就提议它。如果某个 `git remote` 指向 GitLab（`gitlab.com` 或自托管主机），就提议 GitLab。否则（或如果用户更倾向），提供：

- **GitHub**——issue 存放在仓库的 GitHub Issues 中（使用 `gh` CLI）
- **GitLab**——issue 存放在仓库的 GitLab Issues 中（使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **本地 markdown**——issue 作为本仓库 `.scratch/<feature>/` 下的文件存放（适合单人项目或没有远端的仓库）
- **其他**（Jira、Linear 等）——请用户用一段话描述工作流；技能会把它记录为自由格式的散文

把选择记录在 `docs/agents/issue-tracker.md` 中。GitHub 和 GitLab 模板带有一个 "PRs as a request surface（把 PR 作为请求来源）" 标志，默认 **关闭**——保持关闭、不要主动提起；想把外部 PR 纳入分诊队列的用户日后可以在文件里翻开这个标志。

**B 节——分诊标签词汇。** 如果 `triage` 技能未安装（探索已经告诉你了），就整节跳过——一个未安装的技能不需要标签。

如果它确实安装了，只问一个问题：

> 你想保留默认的分诊标签吗？（推荐：**是**）

默认值是五个规范角色，每个标签字符串都等于其名称：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`。选 **是**，就原样写入。只有当用户说不时——通常是因为他们的 tracker 已经用了其他名称（例如用 `bug:triage` 表示 `needs-triage`）——才收集这些覆盖项，好让 `triage` 应用现有标签而不是创建重复的。

### 3. 确认并编辑

向用户展示一份草稿：

- 要加进 `CLAUDE.md` / `AGENTS.md`（哪一个被编辑见第 4 步的选择规则）的 `## Agent skills` 块
- `docs/agents/issue-tracker.md` 和 `docs/agents/triage-labels.md`（最后一个只在 `triage` 已安装时）的内容

让他们在写入前先编辑。

### 4. 写入

**选择要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则如果 `AGENTS.md` 存在，编辑它。
- 如果两者都不存在，询问用户要创建哪一个——不要替他们选。

当 `CLAUDE.md` 已存在时绝不创建 `AGENTS.md`（反之亦然）——始终编辑那个已经在的。

如果所选文件中已存在一个 `## Agent skills` 块，就就地更新它的内容，而不是追加一个重复的。不要覆盖用户对周围小节的编辑。

这个块：

```markdown
## Agent skills

### Issue tracker

[一行摘要，说明 issue 在哪里跟踪]。See `docs/agents/issue-tracker.md`.

### Triage labels

[一行摘要，说明标签词汇]。See `docs/agents/triage-labels.md`.
```

只在 `triage` 已安装且 B 节运行过时，才包含 `### Triage labels` 子块并写 `docs/agents/triage-labels.md`。当它没有时，两者都省略。

然后用本技能文件夹中的种子模板作为起点来写各文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md)——GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md)——GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md)——本地 markdown issue tracker
- [triage-labels.md](./triage-labels.md)——标签映射（仅当 `triage` 已安装时）

对于"其他"类 issue tracker，用用户的描述从头编写 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户设置已完成，以及哪些工程技能现在将从这些文件读取。提一句他们日后可以直接编辑 `docs/agents/*.md`——只有当他们想切换 issue tracker 或从头重来时，才需要重新运行这个技能。
