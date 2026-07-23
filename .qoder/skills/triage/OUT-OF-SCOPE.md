# 范围之外（Out-of-Scope）知识库

仓库中的 `.out-of-scope/` 目录持久保存被否决的功能请求的记录。它有两个用途：

1. **组织记忆**——为什么某个功能被否决，好让理由不会在 issue 关闭时丢失
2. **去重**——当一个与先前否决相匹配的新 issue 进来时，技能可以浮现之前的决策，而不是重新翻案

## 目录结构

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

一个 **概念** 一个文件，而不是一个 issue 一个文件。请求同一件事的多个 issue 归到同一个文件下。

## 文件格式

文件应以一种轻松、可读的风格来写——更像一份简短的设计文档，而非一条数据库记录。用段落、代码示例和例子把理由说清楚，让第一次看到它的人觉得有用。

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
```

### 给文件命名

给概念取一个简短、描述性的 kebab-case 名称：`dark-mode.md`、`plugin-system.md`、`graphql-api.md`。名称应足够可辨识，让浏览该目录的人不用打开文件就明白什么被否决了。

### 撰写理由

理由应当有实质内容——不是"我们不想要这个"，而是为什么。好的理由会引用：

- 项目范围或理念（"本项目专注于 X；主题是下游的关注点"）
- 技术约束（"支持这个需要 Y，而 Y 与我们的 Z 架构冲突"）
- 战略决策（"我们选择用 A 而不是 B，因为……"）

理由应当经久耐用。避免引用临时性情形（"我们现在太忙了"）——那些不是真正的否决，而是推迟。

## 何时检查 `.out-of-scope/`

在分诊期间（第 1 步：收集上下文），阅读 `.out-of-scope/` 中的所有文件。在评估一个新 issue 时：

- 检查这个请求是否匹配某个已有的范围之外概念
- 匹配靠概念相似度，而非关键词——"night theme" 匹配 `dark-mode.md`
- 如果有匹配，就把它浮现给维护者："这与 `.out-of-scope/dark-mode.md` 相似——我们之前因为 [理由] 否决过它。你现在还是这么想吗？"

维护者可能会：

- **确认**——新 issue 被添加到已有文件的 "Prior requests" 列表中，然后关闭
- **重新考虑**——范围之外文件被删除或更新，issue 走正常分诊流程
- **不认同**——这些 issue 相关但有别，走正常分诊流程

## 何时写入 `.out-of-scope/`

只有当一个 **enhancement**（而非 bug）被 *否决* 为 `wontfix` 时。这对 enhancement PR 的适用方式与对 issue 完全相同——一个被否决的 PR 被记录在此，好让同一个请求不会又作为新代码回来。

当某个东西因为 **已实现** 而被关闭为 `wontfix` 时，**不要** 写在这里。那是一个已构建的功能，而非被否决的；把它记下来会用假否决污染去重检查。相反，关闭评论应指向该功能已存在的位置。

流程：

1. 维护者判定某个功能请求在范围之外
2. 检查是否已存在一个匹配的 `.out-of-scope/` 文件
3. 如果有：把新 issue 追加到 "Prior requests" 列表
4. 如果没有：新建一个文件，写上概念名称、决策、理由以及第一个先前请求
5. 在 issue 上发布一条评论，解释该决策并提及那个 `.out-of-scope/` 文件
6. 用 `wontfix` 标签关闭该 issue

## 更新或移除范围之外文件

如果维护者对一个先前被否决的概念改变了主意：

- 删除那个 `.out-of-scope/` 文件
- 技能无需重开旧 issue——它们是历史记录
- 触发这次重新考虑的新 issue 走正常分诊流程
