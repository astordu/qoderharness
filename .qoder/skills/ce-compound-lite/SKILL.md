---
name: ce-compound-lite
description: 轻量级复利工程，在完成任务后将工作成果蒸馏为可复用的方案文档。当任务发现了非显而易见的修复、工作流或决策时使用，或当用户提到"复利工程"、"沉淀"、"lessons learned"、"write this up"、"compound engineering"时触发。可通过 subagent 并行完成上下文分析、方案提取和相关文档发现，最终在 docs/solutions/ 下生成一个方案文件。
---

# CE Compound Lite

在任务完成后使用此技能，将已完成的工作蒸馏为可复用的方案文档。

## 目标

创建一份持久、可搜索的方案笔记，供未来的 agent 复用。

仅在 `docs/solutions/` 下写入一个最终文件。Subagent 不得写文件。

## 何时使用

- 任务揭示了非显而易见的修复、工作流或决策
- 任务涉及调试、调查或权衡取舍
- 用户要求"复利工程"、"沉淀"、"lessons learned"或"write this up"

如果任务很琐碎且没有产生可复用的洞察，跳过此技能。

## 输入

收集最少必要的上下文：

- 最近的用户请求
- 变更的文件或产生的产物
- 关键命令、错误或约束
- `docs/solutions/` 下可能与新内容重叠的已有文档

## 轨道

选择一个主轨道：

- `bug`：诊断并修复了一个异常行为
- `knowledge`：建立了一个可复用的实现模式、决策或工作流

## 工作流

1. 从当前对话和工作区收集任务上下文。
2. 一定要通过 Agent 工具启动最多三个 subagent（位于 `.qoder/agents/`）：
   - `context-analyzer`：分析上下文
   - `solution-extractor`：提取可复用方案
   - `related-docs-finder`：发现相关已有文档
3. 检查 `docs/solutions/` 中是否已有可能重叠的文档。
4. 决定是创建新笔记还是更新已有笔记。
5. 在 `docs/solutions/` 下写入恰好一个 Markdown 文件。

## Subagent 规则

如果启动 subagent：

- 给每个 subagent 一个狭窄的只读任务
- 让它们以纯文本返回发现
- 不允许 subagent 编辑文件
- 编排器拥有所有最终编辑权

## 输出格式

使用此结构：

```md
---
title: 简短标题
slug: short-kebab-name
track: bug|knowledge
updated_at: YYYY-MM-DD
keywords:
  - keyword
  - keyword
---

# 简短标题

## 问题

发生了什么或需要弄清楚什么。

## 上下文

约束、症状、根因或相关环境细节。

## 方案

最终采用的方法。有用时引用具体文件、命令或检查。

## 复用

未来 agent 遇到类似情况时应首先做什么。

## 参考

- 相对路径或命令
```

## 质量标准

- 偏好一个具体笔记而非宽泛摘要
- 移除填充内容，只保留下次有用的信息
- 包含足够的细节使笔记可执行
- 保持文件名稳定且可搜索

## 文件命名

使用 `docs/solutions/<slug>.md`。

推荐简短描述性的 slug，例如：

- `fix-dev-server-port-conflict.md`
- `document-postgres-migration-workflow.md`

## 可发现性

未来 agent 在重新解决类似问题前应搜索 `docs/solutions/`。

如果 `AGENTS.md` 未提及此目录，更新它。
