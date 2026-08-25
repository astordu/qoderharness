---
name: test5-implementation-coverage-reviewer
description: 用已确认的测试矩阵 CSV 对照当前代码和已有测试，审查实现缺口、测试覆盖、偏差和后续动作。适用于代码生成后、验收前；当用户要求“用矩阵验代码”“审查实现是否满足测试矩阵”“标记实现状态/测试状态/覆盖情况”时使用。
---

# 实现与覆盖审查

用已确认的测试矩阵 CSV 审查当前代码和已有测试。不要把代码当成需求来源；矩阵是标准，代码是被审查对象。

## 输入

读取：

```text
.qoder/test-matrix/<feature-id>.csv
```

同时读取必要的代码事实：

- DTO / Schema / 类型定义
- API Route / Controller
- Service 或核心业务模块
- 前端关键组件
- 已有测试文件

只读取与矩阵行相关的文件，不做无边界全仓库分析。

## 输出

更新同一个 CSV，不创建新文件。

主要更新字段：

- `implementation_status`
- `test_status`
- `action`
- `evidence`
- `notes`

## 状态取值

`implementation_status`：

- `not_checked`：尚未审查。
- `implemented`：代码已满足矩阵要求。
- `missing`：矩阵要求存在，但代码未实现。
- `partial`：实现不完整或行为不确定。
- `out_of_scope`：矩阵范围控制项或 PRD 范围外项。

`test_status`：

- `not_generated`：还没有对应测试。
- `generated`：已有测试代码，但未确认运行结果。
- `passing`：测试存在且通过。
- `failing`：测试存在但失败。
- `manual_only`：仅人工验收。

`action`：

- `generate_test`：代码已实现但测试缺失，下一步生成测试。
- `fix_code`：矩阵要求存在但代码缺失或偏差，下一步补实现。
- `manual_review`：需要人判断是改需求、改代码还是改测试。
- `defer`：延后。
- `ignore`：范围外，不处理。

## 审查原则

- PRD 和矩阵决定“该不该测”；代码只帮助判断“实现了没有、怎么测”。
- 代码里有但矩阵没有的功能，不自动加入本需求测试。
- 矩阵有但代码没有的功能，标记为实现缺口，不删除矩阵行。
- Service 覆盖不等于 API 覆盖，API 覆盖不等于 UI/E2E 覆盖。
- 证据必须写具体文件路径、测试文件路径或命令结果摘要。

## 分流逻辑

| 发现 | CSV 标记 | 后续 |
|---|---|---|
| 代码已实现，测试也覆盖 | `implemented` + `passing` | 保持 |
| 代码已实现，但没有测试 | `implemented` + `not_generated` + `generate_test` | 调用 `tdd` 或测试生成流程 |
| 代码没实现，但矩阵要求 | `missing` + `fix_code` | 回开发 Agent 补代码 |
| 代码和矩阵不一致 | `partial` + `manual_review` | 人判断 |
| PRD 范围外 | `out_of_scope` + `ignore` | 不纳入本功能验证 |

## 下一步

完成后提示：

```text
如果 CSV 中存在 action=generate_test，下一步建议调用 tdd：
从 selected_for_validation=Y 且 action=generate_test 的行中挑一个测试点，按红-绿-重构生成可执行测试。

如果 CSV 中存在 action=fix_code，先回开发 Agent 补齐实现，再重新调用 test5-implementation-coverage-reviewer。
```
