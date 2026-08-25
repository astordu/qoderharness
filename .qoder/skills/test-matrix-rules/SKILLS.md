
## 测试矩阵的 CSV 字段说明

必须使用以下表头，顺序保持一致：

```csv
feature_id,prd_source,intent_id,ac_id,test_id,test_title,risk_type,test_layer,priority,test_data,expected_result,selected_for_validation,implementation_status,test_status,action,evidence,notes
```

字段含义：

- `feature_id`：功能标识，与 PRD 文件对应，用于追溯需求来源。
- `prd_source`：PRD 文件路径或名称，标明该测试用例源自哪份需求文档。
- `intent_id`：需求意图编号，关联需求意图表中的具体条目。
- `ac_id`：验收条件编号，关联验收条件表中的 Given/When/Then 条目。
- `test_id`：测试用例唯一编号，按测试层级分段编号以便检索。
- `test_title`：测试用例标题，用一句话描述该用例验证的行为。
- `risk_type`：风险类型，标明该用例主要防范哪类质量风险。
- `test_layer`：测试层级，指明用例属于哪一层（Service / API / UI / E2E / Manual）。
- `priority`：优先级，`P0` 为阻塞级、`P1` 为重要、`P2` 为锦上添花。
- `test_data`：测试数据描述，说明用例执行时需要的输入数据或前置条件。
- `expected_result`：预期结果，描述用例通过后应观察到的正确行为。
- `selected_for_validation`：是否被选入本轮验证集，初始填 `N`，后续由筛选技能更新。
- `implementation_status`：代码实现状态，标记对应功能代码是否已实现。
- `test_status`：测试代码状态，标记该用例的测试代码是否已生成或通过。
- `action`：后续动作，指示该用例下一步需要做什么（如 review、implement、skip）。
- `evidence`：证据链接，存放测试运行截图、日志路径等可验证的通过凭证。
- `notes`：备注，记录任何补充说明、特殊约束或与其他用例的关联关系。

字段取值建议：

- `test_id`：按层级编号，例如 `TC-API-001`、`TC-SVC-001`、`TC-E2E-001`。
- `risk_type`：功能主路径、数据完整性、边界值、异常处理、数据一致性、交互控制、范围控制等。
- `test_layer`：`Service`、`API`、`UI`、`E2E`、`Manual`。
- `priority`：`P0`、`P1`、`P2`。
- `selected_for_validation`：初始填 `N`，后续由 `test4-validation-scope-selector` 更新。
- `implementation_status`：初始填 `not_checked`。
- `test_status`：初始填 `not_generated`。
- `action`：初始填 `review`。
- `evidence`：初始留空。

`selected_for_validation` 为 `Y` 的需要被实现验证.