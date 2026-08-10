---
name: git-commit
description: 分析 git 暂存区变更，生成符合 Conventional Commits 规范的中文提交信息并执行提交。当用户要求提交代码、写 commit message、或提到 git commit 时使用。
---

# Git Commit

分析暂存区变更，生成 Conventional Commits 格式的中文提交信息并提交。

## 工作流程

### 1. 检查变更

```bash
git status
git diff --stat
git diff --cached --stat
git diff
git diff --cached
```

- 若有未暂存的变更，自动执行 `git add` 将所有变更文件加入暂存区
- 若暂存区和工作区均无变更，提示用户无可提交内容

### 2. 生成 commit message

根据变更内容推断 type 和 scope，用中文编写描述：

**type 枚举**（必须使用以下之一）：

| type | 含义 |
|------|------|
| feat | 新功能 |
| fix | 缺陷修复 |
| docs | 文档变更 |
| style | 格式调整（不影响逻辑） |
| refactor | 重构（非新功能、非修复） |
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具变更 |

**scope**：从变更涉及的模块推断，如 `auth`、`api`、`ui`、`db`。跨模块时省略 scope。

**格式**：
```
<type>(<scope>): <中文简述>

<body: 可选，补充说明>
```

**示例**：

```
feat(heart-rate): 添加心率手动录入功能

- 新增录入 Modal 组件
- 添加 POST /heart-rate 接口
- 编写 service 层 TDD 测试
```

```
fix(api): 修复仪表盘数据聚合查询超时

添加索引并优化 SQL 查询逻辑
```

```
refactor: 将 schemas 目录重命名为 dtos
```

### 3. 直接提交

1. 将生成的 commit message 展示给用户
2. 直接执行提交，无需等待用户确认
3. **必须分两步执行**：先单独执行 `git add`，再单独执行 `git commit`（不要用 `&&` 合并为一条命令），确保 PreToolUse hook 能正确检测暂存区内容
4. 执行提交命令：

```bash
# 第一步：暂存文件（单独执行）
git add <files>

# 第二步：提交（单独执行）
git commit -m "<commit message>"
```

- 若 message 含多行，使用 heredoc：
```bash
git commit -m "<首行>" -m "<body 内容>"
```

**⚠️ 重要**：`git add` 和 `git commit` 必须作为两次独立的 `run_in_terminal` 调用，因为 PreToolUse hook 在命令执行前触发，合并执行时暂存区仍为空，hook 无法检测到已暂存的文件。

### 4. 禁止事项

- 自动执行 `git add` 将变更加入暂存区，无需用户手动操作
- **不要** 使用 `--no-verify`
- **不要** 使用 `--force`
- **不要** 执行 `git push`，除非用户明确要求
- **不要** 修改 git config
