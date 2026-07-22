# Issue tracker: GitHub

Issues and PRs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**:  gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] |{number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]' with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` â€” `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)]

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare #42` may be either â€” resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint). Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of <map>` at the top of the child body. Labels: `wayfinder:<type>` (`Research`/prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies** â€” the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#¹Õµ‰•É€½È¹½‘•}¥‘€¤¸¥Ñ!ÕˆÉ•Á½ÉÑÌ¥ÍÍÕ•}‘•Á•¹‘•¹¥•Í}ÍÕµµ…Éä¹‰±½­•‘}‰å€€¡½Á•¸‰±½­•ÉÌ½¹±äƒŠPÑ¡”±¥Ù”…Ñ”¤¸]¡•É”‘•Á•¹‘•¹¥•Ì…É•¸Ğ…Ù…¥±…‰±”°™…±°‰…¬Ñ¼„	±½­•‰äè€Œñ¸ø°€ñ¸ù€±¥¹”…ĞÑ¡”Ñ½À½˜Ñ¡”¡¥±‰½‘ä¸Ñ¥­•Ğ¥ÌÕ¹‰±½­•İ¡•¸•Ù•Éä‰±½­•È¥Ì±½Í•¸(´€¨©É½¹Ñ¥•ÈÅÕ•Éä¨¨è±¥ÍĞÑ¡”µ…ÀÌ½Á•¸¡¥±‘É•¸€¡ ¥ÍÍÕ”±¥ÍĞ€´µÍÑ…Ñ”½Á•¹€°Í½Á•Ñ¼Ñ¡”µ…ÀÌÍÕˆµ¥ÍÍÕ•Ì€¼Ñ…Í¬±¥ÍĞ¤°‘É½À…¹äİ¥Ñ …¸½Á•¸‰±½­•È€¡¥ÍÍÕ•}‘•Á•¹‘•¹¥•Í}ÍÕµµ…Éä¹‰±½­•‘}‰ä€ø€Á€°½È…¸½Á•¸¥ÍÍÕ”¥¸Ñ¡”	±½­•‰å€±¥¹”¤½È…¸…ÍÍ¥¹•”ì™¥ÉÍĞ¥¸µ…À½É‘•Èİ¥¹Ì¸(´€¨©±…¥´¨¨è ¥ÍÍÕ”•‘¥Ğ€ñ¸ø€´µ…‘µ…ÍÍ¥¹•”µ•€ƒŠPÑ¡”Í•ÍÍ¥½¸Ì™¥ÉÍĞİÉ¥Ñ”¸(´€¨©I•Í½±Ù”¨¨è ¥ÍÍÕ”½µµ•¹Ğ€ñ¸ø€´µ‰½‘ä€ˆñ…¹Íİ•Èø‰€°Ñ¡•¸ ¥ÍÍÕ”±½Í”€ñ¸ù€°Ñ¡•¸…ÁÁ•¹„½¹Ñ•áĞÁ½¥¹Ñ•È€¡¥ÍĞ€¬±¥¹¬¤Ñ¼Ñ¡”µ…ÀÌ•¥Í¥½¹ÌµÍ¼µ™…È¸