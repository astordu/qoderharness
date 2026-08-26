# Qoder Harness

面向 [Qoder](https://qoder.com) 的工程技能集合 + **Ralph** 无人值守自动编程循环。

> 灵感与技能体系源自 [mattpocock/skills](https://github.com/mattpocock/skills)，在此做了中文化、Qoder 兼容适配与自动化编程扩展。

## 目录结构

```
.
├── .qoder/
│   ├── skills/         # 工程技能（斜杠命令调用）
│   ├── agents/         # 自定义 subagent（代码审查、方案提取等）
│   └── hooks/          # Qoder 钩子（pre-push 检查）
├── .githooks/          # Git 钩子（pre-push）
├── .github/workflows/  # GitHub Actions（issue 自动处理）
├── ralph-github/       # Ralph 循环 — GitHub 版
└── ralph-gitlab/       # Ralph 循环 — GitLab 版
```

## 技能一览

技能位于 `.qoder/skills/`，在 Qoder 中通过斜杠命令调用：

| 技能 | 说明 |
| --- | --- |
| `init_qoder_harness` | 配置 issue tracker 和分诊标签词汇。**首次使用前运行。** |
| `domain-modeling` | 构建领域模型与统一语言 |
| `codebase-design` | 设计深模块术语体系与接缝 |
| `improve-codebase-architecture` | 扫描代码库寻找加深机会 |
| `prototype` | 构建用完即弃的原型 |
| `to-prd` | 将对话上下文转化为 PRD |
| `to-spec` | 综合对话为规格文档 |
| `to-spec-for-pm` | 将对话整理为面向 PM 的业务需求规格文档（不含技术细节） |
| `to-tickets` | 拆解计划为曳光弹式工单 |
| `triage` | issue / PR 分诊状态机 |
| `implement` | 基于规格或工单实现工作 |
| `implement-with-test-matrix` | 基于 PRD 实现工作，结合测试矩阵驱动验证 |
| `test-matrix-rules` | 测试矩阵 CSV 字段定义与取值规范（供其他技能引用） |
| `tdd` | 测试驱动开发 |
| `code-review` | 从规范与需求两维度审查改动 |
| `grilling` / `grill-me` / `grill-with-docs` | 对计划或设计刨根问底 |
| `grill-for-pm` | 面向不懂技术但熟悉业务的 PM 进行刨根问底访谈，收集需求后交给研发开发；页面内容用 ASCII 展现 |
| `ce-compound-lite` | 轻量级复利工程，将成果沉淀为方案文档 |
| `agents-md-refactor` / `agents-md-slim` | 重构或精简 AGENTS.md |
| `git-commit` | 分析暂存区变更，生成 Conventional Commits 规范提交 |
| `handoff` | 压缩对话为交接文档 |
| `ascii-pattern` | ASCII 图案库（框图、流程图、目录树、进度条等） |
| `test1-prd-intent-extractor` | 从 PRD 中提取需求意图、用户故事来源与业务风险 |
| `test2-acceptance-criteria-builder` | 将需求意图转换为 Given/When/Then 验收条件 |
| `test3-test-matrix-builder` | 基于 PRD 与验收条件生成功能级测试矩阵 CSV |
| `test4-validation-scope-selector` | 从测试矩阵中筛选最小可信验证集 |
| `test5-implementation-coverage-reviewer` | 对照测试矩阵审查实现缺口与覆盖情况 |

## Ralph 自动编程循环

从 issue 队列中按优先级挑选 `ready-for-agent` 任务，交给 Qoder CLI 实现、测试、提交，循环执行。提供 **GitHub** 和 **GitLab** 两个版本。

```bash
# 单次运行
./ralph-github/once.sh        # GitHub 版
./ralph-gitlab/once.sh        # GitLab 版

# 多轮循环（默认最多 10 轮）
./ralph-github/afk.sh 20      # 最多 20 轮

# 定时循环
./ralph-github/cronjobloop.sh # cron 调度
```

任务行为在 `ralph-*/prompt.md` 中定义，可按项目需要调整。

## 快速使用

将本仓库的 `.qoder` 和 `ralph` 复制到你的项目（根据你使用的平台选择 GitHub 或 GitLab 版本）：

```bash
# GitHub 版
git clone --depth=1 https://github.com/astordu/qoderharness /tmp/qh \
  && cp -R /tmp/qh/.qoder . && cp -R /tmp/qh/ralph-github ./ralph \
  && rm -rf /tmp/qh

# GitLab 版
git clone --depth=1 https://github.com/astordu/qoderharness /tmp/qh \
  && cp -R /tmp/qh/.qoder . && cp -R /tmp/qh/ralph-gitlab ./ralph \
  && rm -rf /tmp/qh
```

> ⚠️ 目标项目中若已存在同名目录，`cp -R` 会覆盖，请注意备份。

## 致谢

- [mattpocock/skills](https://github.com/mattpocock/skills) — 原始技能体系
