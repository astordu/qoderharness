# Qoder Harness

面向 [Qoder](https://qoder.com) 的工程技能集合 + **Ralph** 无人值守自动编程循环。

> 灵感与技能体系源自 [mattpocock/skills](https://github.com/mattpocock/skills)，在此做了中文化、Qoder 兼容适配与自动化编程扩展。

## 目录结构

```
.
├── .qoder/
│   ├── skills/         # 工程技能（斜杠命令调用）
│   ├── agents/         # 自定义 subagent（代码审查、方案提取等）
│   ├── prompts/        # CI Code Review / 修复提示词
│   └── hooks/          # Qoder 钩子兼容层
├── .githooks/          # Git pre-commit / pre-push hooks
├── .github/workflows/  # GitHub Actions
├── .gitlab-ci.yml      # GitLab CI
├── scripts/            # 平台适配、质量检查和 CI Shell
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
| `ascii-pattern` | ASCII 图案库（方框图、流程图、文件树、进度条、制表符等，全中文） |
| `test1-prd-intent-extractor` | 从 PRD 中提取需求意图、用户故事来源与业务风险 |
| `test2-acceptance-criteria-builder` | 将需求意图转换为 Given/When/Then 验收条件 |
| `test3-test-matrix-builder` | 基于 PRD 与验收条件生成功能级测试矩阵 CSV |
| `test4-validation-scope-selector` | 从测试矩阵中筛选最小可信验证集 |
| `test5-implementation-coverage-reviewer` | 对照测试矩阵审查实现缺口与覆盖情况 |

## Ralph 自动编程循环

从分配给当前执行者的 issue 队列中按优先级挑选 `ready-for-agent` 任务，交给 Agent 实现、测试、提交并关闭。每个 issue 只 commit、不 push；列表为空后启动第二个 Push Agent，统一执行 push。GitHub 入口直接使用 `gh`，GitLab 入口直接使用 `glab`。

```bash
# 单次运行
./ralph-github/once.sh qodercli
./ralph-gitlab/once.sh qodercli

# 多轮循环（默认最多 10 轮）
./ralph-github/afk.sh qodercli 20
./ralph-gitlab/afk.sh qodercli 20

# 定时循环
./ralph-github/cronjobloop.sh # cron 调度
```

支持 `qodercli`、`claude`、`codex` 三种适配器。默认查询分配给 `@me` 的任务，可通过 `RALPH_ASSIGNEE=<username>` 覆盖。

任务实现行为在 `ralph-*/implements_prompt.md` 中定义，最终 push 行为在 `ralph-*/push-prompt.md` 中定义。

## Git Hooks 与项目检查

安装仓库级 hooks：

```bash
./scripts/install-git-hooks.sh
```

- `pre-commit` 调用 `scripts/check-test.sh`，作为 lint 和 type check 的占位检查点。
- `pre-push` 调用 `scripts/check-coverage.sh`，作为单元测试与覆盖率的占位检查点。

由于 Qoder Harness 可用于不同技术栈，这两个脚本只保留检查点提示。复制到实际项目后，再按照项目技术栈替换为真实命令：

```text
scripts/check-test.sh       # lint + type check
scripts/check-coverage.sh   # unit tests + coverage gate
```

## CI Code Review

GitHub Actions 和 GitLab CI 都按以下流程运行：

```text
确定性检查
    ↓
以本次 push 之前的 SHA 为 fixed point
    ↓
审查 fixed-point...HEAD 的全部 commits
    ↓
读取这些 commits 引用的全部 issues（包括已关闭 issue）
    ↓
Prompt 内最多三轮 Review → 修复 → 验证 → commit
    ↓
Shell 将修复 commits push 回当前分支
```

- GitHub 入口：`.github/workflows/verify.yml`
- GitLab 入口：`.gitlab-ci.yml`
- 公共 Shell：`scripts/ci/code-review-fix.sh`
- 公共 Prompt：`scripts/ci/code-review-fix_prompt.md`

CI Runner 必须预装并认证选定的 Agent CLI，并具备读取 issues、向当前分支 push 的权限。通过 `AI_AGENT_ADAPTER` 选择 `qodercli`、`claude` 或 `codex`。

## 快速使用

将 `.qoder`、`.githooks`、`scripts` 和对应平台的 Ralph/CI 文件复制到目标项目：

```bash
# GitHub 版
git clone --depth=1 https://github.com/astordu/qoderharness /tmp/qh \
  && cp -R /tmp/qh/.qoder /tmp/qh/.githooks /tmp/qh/scripts . \
  && cp -R /tmp/qh/ralph-github ./ralph \
  && mkdir -p .github/workflows \
  && cp /tmp/qh/.github/workflows/verify.yml .github/workflows/verify.yml \
  && ./scripts/install-git-hooks.sh \
  && rm -rf /tmp/qh

# GitLab 版
git clone --depth=1 https://github.com/astordu/qoderharness /tmp/qh \
  && cp -R /tmp/qh/.qoder /tmp/qh/.githooks /tmp/qh/scripts . \
  && cp -R /tmp/qh/ralph-gitlab ./ralph \
  && cp /tmp/qh/.gitlab-ci.yml .gitlab-ci.yml \
  && ./scripts/install-git-hooks.sh \
  && rm -rf /tmp/qh
```

> ⚠️ 目标项目中若已存在同名目录或 CI 文件，复制前先合并配置，不要直接覆盖。

## 致谢

- [mattpocock/skills](https://github.com/mattpocock/skills) — 原始技能体系
