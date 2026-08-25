---
name: test2-acceptance-criteria-builder
description: 将 PRD 和需求意图表转换为 Given/When/Then 验收条件。适用于 test1-prd-intent-extractor 之后，准备生成测试矩阵之前；当用户要求“生成验收条件”“Gherkin”“把需求意图变成验收标准”时使用。
---

# 验收条件生成

将需求意图转成可测试、可验收的 Given/When/Then 条件。不要写测试代码，不要生成多个文件；本 Skill 的输出会进入后续测试矩阵 CSV。

## 输入

需要以下上下文：

- PRD 原文
- `test1-prd-intent-extractor` 输出的需求意图表

如果缺少需求意图表，先建议调用 `test1-prd-intent-extractor`。

## 输出格式

输出 Markdown 表格：

| ac_id | intent_id | prd_source | given | when | then | testability_note |
|---|---|---|---|---|---|---|

字段说明：

- `ac_id`：`AC-001` 起递增。
- `intent_id`：对应需求意图编号。
- `prd_source`：对应 PRD 来源。
- `given`：前置条件。
- `when`：触发动作。
- `then`：可观察结果。
- `testability_note`：可测试性备注，例如适合 API、UI、E2E、人工验收，或需要代码事实确认。

## 规则

- 每条验收条件必须能追溯到一个需求意图。
- `then` 必须可观察、可断言，不写“体验良好”“正常工作”这类模糊表达。
- 不引入 PRD 范围外能力。
- 如果一个意图包含多个风险，可以拆成多条验收条件。
- 标记可测试性问题，但不要在这一步解决实现问题。

## 下一步

完成后提示：

```text
下一步建议调用 test3-test-matrix-builder：
基于 PRD、需求意图表和验收条件，生成或更新该功能唯一的测试矩阵 CSV。
```
