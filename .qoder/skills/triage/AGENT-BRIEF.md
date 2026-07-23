# 撰写 Agent 简报

一份 agent 简报（agent brief）是一条结构化的评论，在一个 GitHub issue 或 PR 移到 `ready-for-agent` 时发布在它上面。它是一个离线（AFK）agent 将据以工作的权威规格说明。原始正文和讨论是上下文——agent 简报才是合约。

简报陈述 **agent 应该做什么**，这延伸到两种界面：对一个 issue，那是从零开始构建改动；对一个 PR，那是 *对现有 diff* 还剩什么要做——把它完成、补上缺口、处理评审意见。两种情况原则相同；下面的 PR 示例展示了差异。

## 原则

### 耐用性优先于精确性

issue 可能会在 `ready-for-agent` 里待上数天或数周。其间代码库会变。把简报写得即便文件被重命名、移动或重构，它仍然有用。

- **要** 描述接口、类型和行为合约
- **要** 点名 agent 应查找或修改的具体类型、函数签名或配置形状
- **不要** 引用文件路径——它们会过时
- **不要** 引用行号
- **不要** 假设当前的实现结构会保持不变

### 面向行为，而非面向过程

描述系统 **应该做什么**，而不是 **如何** 实现它。agent 会重新探索代码库，并做出自己的实现决策。

- **好：** "`SkillConfig` 类型应接受一个可选的 `schedule` 字段，类型为 `CronExpression`"
- **差：** "打开 src/types/skill.ts，在第 42 行加一个 schedule 字段"
- **好：** "当用户不带参数运行 `/triage` 时，他们应看到一份需要关注的 issue 摘要"
- **差：** "在主处理函数里加一个 switch 语句"

### 完整的验收标准

agent 需要知道什么时候算完成。每一份 agent 简报都必须有具体的、可测试的验收标准。每一条标准都应可独立验证。

- **好：** "运行 `gh issue list --label needs-triage` 会返回那些经过初步分类的 issue"
- **差：** "分诊应正常工作"

### 明确的范围边界

陈述什么在范围之外。这能防止 agent 镀金（gold-plating）或对相邻功能做出假设。

## 模板

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one-line description of what needs to happen

**Current behavior:**
Describe what happens now. For bugs, this is the broken behavior.
For enhancements, this is the status quo the feature builds on.

**Desired behavior:**
Describe what should happen after the agent's work is complete.
Be specific about edge cases and error conditions.

**Key interfaces:**
- `TypeName` — what needs to change and why
- `functionName()` return type — what it currently returns vs what it should return
- Config shape — any new configuration options needed

**Acceptance criteria:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

**Out of scope:**
- Thing that should NOT be changed or addressed in this issue
- Adjacent feature that might seem related but is separate
```
