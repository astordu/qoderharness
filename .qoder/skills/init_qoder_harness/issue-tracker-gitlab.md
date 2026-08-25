# Issue tracker：GitLab

本仓库的 issue 和 PRD 作为 GitLab issue 存放。所有操作使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI。

## 约定

- **创建 issue**：`glab issue create --title "..." --description "..."`。多行描述用 heredoc。传 `--description -` 可打开编辑器。
- **阅读 issue**：`glab issue view <number> --comments`。用 `-F json` 获取机器可读输出。
- **列出 issue**：`glab issue list -F json`，配合适当的 `--label` 过滤。
- **在 issue 上评论**：`glab issue note <number> --message "..."`。GitLab 把评论称为 "notes"。
- **应用 / 移除标签**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可用逗号分隔，或重复该 flag。
- **关闭**：`glab issue close <number>`。`glab issue close` 不接受关闭评论，所以先用 `glab issue note <number> --message "..."` 发布解释，再关闭。
- **Merge request**：GitLab 把 PR 称为 "merge request"。用 `glab mr create`、`glab mr view`、`glab mr note` 等——与 `gh pr ...` 形状相同，只是把 `pr` 换成 `mr`、把 `comment`/`--body` 换成 `note`/`--message`。

从 `git remote -v` 推断仓库——`glab` 在克隆内运行时会自动完成这一点。
