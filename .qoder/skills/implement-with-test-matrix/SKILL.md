---
name: implement
description: "基于一份规格或一组工单来实现一部分工作。"
disable-model-invocation: true
---

实现用户在prd所描述的工作。 

对应的测试矩阵在 `.qoder/test-matrix` 目录下, 名字prd的名字相同.

使用 `/test-matrix-rules` 读取测试矩阵规则表头说明.

在预先约定好的接缝（seam）处，尽可能使用 /tdd。
一定要写测试用例, 如果项目中没有, 要进行构建补齐