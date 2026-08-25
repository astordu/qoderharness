---
name: test1-prd-intent-extractor
description: 从 PRD 中提取需求意图、用户故事来源、业务风险和可验证结果。适用于已有 .qoder/prd/*.md，准备生成验收条件或测试矩阵之前；当用户提到“需求意图”“从 PRD 拆测试”“PRD 生成测试矩阵第一步”时使用。
---

# PRD 需求意图提取

从 PRD 中提取可测试的需求意图。不要写测试代码，不要生成 CSV；本 Skill 只产出结构化意图表，供下一步验收条件生成使用。

## 输入

读取用户指定的 PRD。若未指定，优先在 `.qoder/prd/` 下选择与当前功能最匹配的 Markdown 文件。

重点读取：

- 问题陈述
- 解决方案
- 用户故事
- 实现决策
- 测试决策
- 范围外

## 输出格式

输出 Markdown 表格：

| intent_id | prd_source | user_intent | business_risk | verifiable_result | notes |
|---|---|---|---|---|---|

字段说明：

- `intent_id`：`INT-001` 起递增。
- `prd_source`：写明来源，例如 `用户故事 6`、`测试决策`、`范围外`。
- `user_intent`：用户真正想完成什么。
- `business_risk`：如果这个意图没被满足，会产生什么风险。
- `verifiable_result`：系统达到什么表现才算满足意图。
- `notes`：信息不足、需代码事实校准、范围外等备注。

## 规则

- 以 PRD 为准，不根据代码补需求。
- 不要把“范围外”变成待测需求；只标记为范围控制项。
- 每条意图必须能追溯到 PRD 中的具体来源。
- 不要产出过多重复意图；相同用户价值可以合并。
- 如果 PRD 里已有测试决策，将其转化为意图或风险，不要直接写成测试代码。

## 下一步

完成后提示：

```text
下一步建议调用 test2-acceptance-criteria-builder：
基于这份需求意图表，将每条意图转成 Given/When/Then 验收条件，为测试矩阵做准备。
```
