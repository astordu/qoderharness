# 输入

上下文开头提供两份 GitHub issue 数据：分配给当前执行者的 `ready-for-agent` issues 包含正文和评论；所有 open issues 的摘要用于判断阻塞关系。

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

如果当前没有未阻塞的 `ready-for-agent` 任务，明确说明阻塞状态；是否结束循环由外层脚本根据 GitHub Issues 的实时状态决定。

# 探索

探索代码仓库，了解当前代码状态。

# 实现

**只做被挑选出来的这一个任务**

使用 /implement skill 完成任务。遵循 TDD，并运行与本任务相关的测试。

# 提交

实现完成后，只暂存本 Issue 直接相关的文件并做一个 git commit。不要使用 `git add -A` 把无关修改或未跟踪文件带入提交。commit 会触发 pre-commit hook 中的 lint 和 type check；禁止使用 `--no-verify` 绕过验证。

commit message 使用中文，并且必须包含：

1. 做出的关键决策
2. 修改的文件
3. 关联的 issue 编号（使用 `Refs #N`）
4. 阻塞项或给下一轮迭代的备注

# 提交后

- 只有 commit 成功后才能关闭 issue。
- 如果任务**完全完成**：先运行 `gh issue comment <number> --body "..."` 写上完成说明、commit SHA 和测试结果，再运行 `gh issue close <number>` 关闭 issue。
- 如果任务**部分完成**：不要关闭 issue；运行 `gh issue comment <number> --body "..."` 说明已完成内容、剩余内容和测试结果。
- 不执行 Code Review；统一 Code Review 在最终 push 后由 CI 完成。
- 不执行 `git push`；所有 issue 完成后由外层脚本启动 Push Agent 统一 push。

# 最终规则

- **只做当前一个任务**。
- 不要自行判断或声明整个 Ralph 循环已经完成；GitHub Issues 是任务状态的事实来源。
