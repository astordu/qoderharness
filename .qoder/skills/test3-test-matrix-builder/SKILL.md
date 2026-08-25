---
name: test3-test-matrix-builder
description: 基于 PRD、需求意图表和验收条件生成一个功能级测试矩阵 CSV。适用于 test2-acceptance-criteria-builder 之后；当用户要求“生成测试矩阵 CSV”“测试地图”“一个需求一个 CSV”“从 PRD 生成测试清单”时使用。
---

# 测试矩阵 CSV 生成

生成该功能唯一的测试矩阵 CSV。这个 CSV 是全量测试地图和后续验证清单的基础。

## 输入

需要以下上下文：

- PRD 原文
- 需求意图表
- 验收条件表

如果缺少需求意图表，先调用 `test1-prd-intent-extractor`。如果缺少验收条件表，先调用 `test2-acceptance-criteria-builder`。

## 输出文件

只写一个 CSV：

```text
.qoder/test-matrix/<feature-id>.csv
```

`feature-id` 优先使用 PRD 文件名去掉扩展名，例如：

```text
.qoder/prd/blood-pressure-manual-entry.md
-> .qoder/test-matrix/blood-pressure-manual-entry.csv
```

如果 `.qoder/test-matrix/` 不存在，创建它。

使用 `/test-matrix-rules` 读取测试矩阵规则表头说明.

## 规则

- 测试矩阵要全面，但不要把所有项都标记为本轮验证。
- 不要直接生成测试代码。
- 不要生成多个 CSV、JSON 或 Markdown 辅助文件。
- 范围外事项可以保留为 `risk_type=范围控制`、`test_layer=Manual`、`priority=P0`，用于提醒不要误测。
- 同一个 PRD 反复执行时，更新同一个 CSV，不创建副本。

## 下一步

完成后提示：

```text
下一步建议调用 test4-validation-scope-selector：
基于测试矩阵 CSV，选择本轮最小可信验证集，并更新 selected_for_validation。
```
