# 输入

GitHub issues 在上下文开头提供，包含所有 open issues 的正文和评论。

同时传入了最近几次 git commits，请查看以了解已完成的工作。

# 任务选择

从 open issues 中，按以下优先级顺序选择下一个任务：

1. **关键 Bug 修复** — 影响最大的修复，必须优先处理
2. **开发基础设施** — 升级类型、测试、工具链，为后续开发打好基础
3. **Tracer Bullets（新功能）** — 垂直切片，贯穿所有层（Schema、API、UI、测试）。完成的切片可以独立演示或验证。
4. **打磨与快速优化** — 小改进、小功能
5. **重构** — 不改变行为的代码结构调整

**重要规则：**

- 只处理带有 `ready-for-agent` 标签的 issues（规格完整、可由 Agent 离线处理的任务）。
- 不要处理带有 `ready-for-human`（需要人工实现）或 `needs-triage` / `needs-info`（未完成评估/信息不足）标签的 issues。
- 遵守**阻塞关系**：如果某个 issue 标注了 "Blocked by #X" 且 #X 仍然 open，则跳过它。
- 如果有多个未阻塞的 `ready-for-agent` issues，选优先级最高的。

如果没有更多 `ready-for-agent` 任务需要完成，输出 <promise>NO MORE TASKS</promise>。

# 探索

探索代码仓库，了解当前代码状态。

# 实现

**只做被挑选出来的这一个任务**

你使用 /implement 这个skills来做任务。

# 反馈循环

提交之前，运行以下反馈循环：

- `cd back && uv run pytest` 运行后端测试
- `cd back && uv run ruff check .` 检查后端代码规范
- `cd front && npx tsc -b` 运行前端类型检查
- `cd front && npm run lint` 检查前端代码规范

修复所有失败后再提交。

# 提交

做一个 git commit。commit message 必须包含：

1. 做出的关键决策
2. 修改的文件
3. 关联的 issue 编号（例如 "Closes #N" 或 "Refs #N"）
4. 阻塞项或给下一轮迭代的备注

# 提交后

- 如果任务**完全完成**：使用 `gh issue close <number>` 关闭该 GitHub issue
- 如果任务**部分完成**：使用 `gh issue comment <number> --body "..."` 在 issue 上留评论，说明已完成的工作和剩余部分

push所有代码到远程仓库

# 最终规则

- **只做当前一个任务**。
- 如果所有 `ready-for-agent` 任务都已完成，输出 <promise>NO MORE TASKS</promise>。
