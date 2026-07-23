# Qoder Harness

一套面向 [Qoder](https://qoder.com) 的工程技能（Skills）集合，外加一个用于自动化编程的 **Ralph** 循环脚本。

## 思考来源

本项目的灵感与技能体系来源于 Matt Pocock 的开源项目：

> https://github.com/mattpocock/skills/tree/main

在此基础上，我做了以下工作：

- **中文化翻译**：将全部技能的说明与提示词翻译为中文；
- **Qoder 兼容**：调整技能格式与调用方式，使其可以在 Qoder 中作为 Skill 使用（存放于 `.qoder/skills/`）；
- **微小调整**：对个别流程、措辞与默认值做了贴合实际使用的改动；
- **自动化编程补齐**：新增 `ralph/` 目录，提供一套基于 issue 队列的无人值守（AFK）自动编程循环。

在此特别感谢 [Matt Pocock](https://github.com/mattpocock) 的原创工作。

## 目录结构

```
.
├── .qoder/skills/      # 工程技能集合（中文化 + Qoder 兼容）
└── ralph/              # 自动化编程循环（Ralph）
    ├── afk.sh          # 多轮无人值守循环
    ├── once.sh         # 单次运行
    └── prompt.md       # 驱动 Agent 的任务提示词
```

## 技能一览

技能位于 `.qoder/skills/`，在 Qoder 中可通过斜杠命令（如 `/implement`）调用。主要包括：

| 技能 | 说明 |
| --- | --- |
| `setup-matt-pocock-skills` | 为仓库配置这套技能：issue tracker、分诊标签、领域文档布局。**首次使用前先运行一次。** |
| `domain-modeling` | 构建并打磨项目的领域模型与统一语言，记录架构决策（ADR）。 |
| `codebase-design` | 设计深模块的共享术语体系，寻找"加深（deepening）"机会与接缝（seam）。 |
| `improve-codebase-architecture` | 扫描代码库寻找加深机会，产出可视化 HTML 报告并追问。 |
| `prototype` | 构建用完即弃的原型，快速验证状态模型、逻辑或 UI。 |
| `to-spec` | 把当前对话综合成一份规格（spec），并发布到 issue tracker。 |
| `to-tickets` | 把计划/规格/对话拆解成一组曳光弹式工单，声明阻塞边并发布。 |
| `triage` | 让 issue 与外部 PR 走过分诊状态机，并撰写可供 Agent 使用的简报。 |
| `implement` | 基于规格或工单实现一部分工作，尽量走 TDD，并在完成后自审。 |
| `tdd` | 测试驱动开发（红-绿-重构），支持集成测试与 mocking。 |
| `code-review` | 从"规范"与"需求"两个维度审查自某个固定基点以来的改动。 |
| `grilling` / `grill-me` / `grill-with-docs` | 对计划、设计或想法刨根问底地追问，以压力测试思路（可同时产出文档）。 |
| `handoff` | 将当前对话压缩成一份交接文档，供另一个 Agent 接手。 |

## Ralph 自动化编程循环

`ralph/` 目录提供一套无人值守的自动编程循环：从 GitHub issues 中按优先级挑选一个带 `ready-for-agent` 标签的任务，交给 Qoder CLI 实现、跑反馈循环、提交并推送，然后进入下一轮。

### 前置条件

- 已安装并登录 [`gh`](https://cli.github.com/)（GitHub CLI）
- 已安装 `qodercli`（Qoder 命令行）
- 仓库中的 issues 已通过 `triage` / `to-tickets` 打好标签（如 `ready-for-agent`）

### 使用方式

单次运行（处理一个任务）：

```bash
./ralph/once.sh
```

多轮循环（默认最多 10 轮，可传入上限）：

```bash
./ralph/afk.sh          # 最多 10 轮
./ralph/afk.sh 20       # 最多 20 轮
```

当没有更多 `ready-for-agent` 任务时，循环会在 Agent 输出 `NO MORE TASKS` 后自动结束。

任务选择、反馈循环与提交规范等行为均在 [`ralph/prompt.md`](ralph/prompt.md) 中定义，可按项目实际需要调整（例如替换测试/lint 命令）。

## 如何使用

想把 `.qoder` 和 `ralph` 两个文件夹快速复制进你正在开发的项目，只需 `cd` 到目标项目目录，运行下面这条命令：

```bash
git clone --depth=1 https://github.com/astordu/qoderharness /tmp/qh \
  && cp -R /tmp/qh/.qoder /tmp/qh/ralph . \
  && rm -rf /tmp/qh
```

它做了三件事：

1. 把本仓库浅克隆（只取最新一版）到临时目录 `/tmp/qh`；
2. 把 `.qoder` 和 `ralph` 复制到**当前目录**；
3. 删掉临时克隆，保持干净。

> ⚠️ 如果目标项目里已存在同名的 `.qoder` 或 `ralph`，`cp -R` 会覆盖其中的同名文件，请谨慎在空项目或已备份的项目中使用。

## 快速开始

1. 将本仓库的 `.qoder/skills/` 放入你的 Qoder 工作区（或直接在本仓库中使用）。
2. 首次运行 `/setup-matt-pocock-skills`，完成 issue tracker、分诊标签与领域文档配置。
3. 按工作流使用各技能：`/domain-modeling` → `/to-spec` → `/to-tickets` → `/triage` → `/implement`。
4. 需要自动化时，用 `ralph/` 中的脚本让 Agent 自动消化 `ready-for-agent` 队列。

## 致谢

- 原始技能体系：[mattpocock/skills](https://github.com/mattpocock/skills)
