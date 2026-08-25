---
name: test4-validation-scope-selector
description: 从功能级测试矩阵 CSV 中选择本轮最小可信验证集，更新 selected_for_validation、ci_stage 和 action。适用于 test3-test-matrix-builder 之后；当用户要求“筛选要测哪些”“挑 P0/P1”“哪些进 CI”“最小可信测试集”时使用。
---

# 验证范围选择

从全量测试矩阵中选择本轮真正要验证的测试点。目标是保留全景图，同时避免一次性生成和运行过多测试。

## 输入

读取：

```text
.qoder/test-matrix/<feature-id>.csv
```

如果没有 CSV，先调用 `test3-test-matrix-builder`。

## 输出

更新同一个 CSV，不创建新文件。

主要更新字段：

- `selected_for_validation`
- `ci_stage`
- `action`
- `notes`

## 选择策略

默认选择“最小可信验证集”：

1. 优先选择 P0。
2. 优先选择主路径、数据完整性、边界值、数据一致性。
3. 优先选择稳定、可在 CI 中运行的层级：`Service`、`API`。
4. 只保留少量 E2E 主路径，不把所有边界都放进 E2E。
5. P2 或低风险 UI 交互默认延后。
6. 范围外项不进入验证，保留 `selected_for_validation=N`。

## ci_stage 建议

- `commit`：快、稳定、适合每次提交跑。通常是 Service 或少量 API。
- `pre_merge`：合并前必须跑。通常是 API 集成和关键路径。
- `release`：发布前跑。通常是少量 E2E、关键回归。
- `manual`：只能人工确认或不值得自动化。
- `later`：后续模块或后续迭代再做。

## action 建议

- `generate_test`：本轮要生成测试。
- `manual_review`：需要人判断。
- `defer`：延后。
- `ignore`：范围外，不纳入本功能验证。

## 规则

- 不要删除矩阵行，只更新标记列。
- 不要因为测试多就删掉 PRD 要求；通过 `selected_for_validation=N` 控制本轮范围。
- 如果用户指定测试层级优先级，例如“只做 Service 和 API”，按用户要求筛选。
- 如果测试点已明显适合 E2E 但成本高，保留但标记为 `later` 或 `release`。

## 下一步

完成后提示：

```text
下一步建议调用 test5-implementation-coverage-reviewer：
在代码生成后，用同一个 CSV 对照当前代码和已有测试，标记实现状态、测试状态、证据和后续动作。
```
