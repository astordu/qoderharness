# Issue tracker：本地 Markdown

本仓库的 issue 和规格（你可能把规格称作 PRD）以 markdown 文件的形式存放在 `.scratch/` 中。

## 约定

- 每个功能一个目录：`.scratch/<feature-slug>/`
- 规格是 `.scratch/<feature-slug>/spec.md`
- 实现 issue 每个工单一个文件，位于 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，从 `01` 起编号——绝不用一个合并的大工单文件
- 分诊状态记录为每个 issue 文件顶部附近的一行 `Status:`（角色字符串见 `triage-labels.md`）
- 评论和对话历史追加到文件底部的 `## Comments` 标题之下

## 当某个技能说"发布到 issue tracker"

在 `.scratch/<feature-slug>/` 下新建一个文件（如有需要就创建该目录）。

## 当某个技能说"获取相关工单"

读取所引用路径处的文件。用户通常会直接传入路径或 issue 编号。

## 寻路（Wayfinding）操作

由 `/wayfinder` 使用。**地图（map）** 是一个文件，每个工单对应一个 **子（child）** 文件。

- **Map**：`.scratch/<effort>/map.md`——包含 Notes / Decisions-so-far / Fog 正文。
- **Child ticket**：`.scratch/<effort>/issues/NN-<slug>.md`，从 `01` 起编号，正文里写问题。一行 `Type:` 记录工单类型（`research`/`prototype`/`grilling`/`task`）；一行 `Status:` 记录 `claimed`/`resolved`。
- **Blocking**：顶部附近的一行 `Blocked by: NN, NN`。当一个工单列出的每个文件都为 `resolved` 时，它即解除阻塞。
- **Frontier**：扫描 `.scratch/<effort>/issues/`，找出那些开放、未阻塞且未认领的文件；编号最小者优先。
- **Claim**：在任何工作之前设置 `Status: claimed` 并保存。
- **Resolve**：在 `## Answer` 标题下追加答案，设置 `Status: resolved`，然后把一个上下文指针（要点 + 链接）追加到 `map.md` 里地图的 Decisions-so-far。
