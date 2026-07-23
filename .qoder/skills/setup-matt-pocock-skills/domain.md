# 领域文档（Domain Docs）

在探索代码库时，这套工程技能应当如何消费本仓库的领域文档。

## 探索之前，先读这些

- 根目录的 **`CONTEXT.md`**，或
- 根目录的 **`CONTEXT-MAP.md`**（如果存在）——它指向每个上下文各自的一个 `CONTEXT.md`。阅读与话题相关的每一个。
- **`docs/adr/`**——阅读那些触及你即将工作的区域的 ADR。在多上下文仓库中，还要查看 `src/<context>/docs/adr/` 以获取上下文范围内的决策。

如果这些文件中有任何一个不存在，**默默继续**。不要标注它们的缺失；不要预先建议创建它们。`/domain-modeling` 技能（经由 `/grill-with-docs` 和 `/improve-codebase-architecture` 触及）会在术语或决策实际被确定下来时延迟创建它们。

## 文件结构

单上下文仓库（大多数仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文仓库（根目录存在 `CONTEXT-MAP.md`）：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← 系统级决策
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← 上下文专属决策
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 使用词汇表的词汇

当你的输出命名一个领域概念时（在 issue 标题、重构提案、假设、测试名中），使用 `CONTEXT.md` 中定义的术语。不要漂移到词汇表明确避免的同义词上。

如果你需要的概念还不在词汇表里，那是一个信号——要么你在发明项目并不使用的语言（重新考虑），要么存在一个真实的缺口（记下来交给 `/domain-modeling`）。

## 标注 ADR 冲突

如果你的输出与现有 ADR 相抵触，就明确地把它抛出来，而不是默默地覆盖：

> _与 ADK-0007（event-sourced orders）相抵触——但值得重开，因为……_
