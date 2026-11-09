---
id: TASK-
title: "{{title}}"
status: open
status_note: ""
priority: medium
project: ""
due: ""
created: {{date:YYYY-MM-DD}}
summary: ""
next: ""
tags: []
---

# {{title}}

Context, acceptance criteria, links. Highlights follow the color code in `obsidian-color-code.md`: ==🔴blocker==, ==🟠waiting for an answer==, ==🟡check==, ==🟢decided==, ==🔵reference==, ==🟣idea==.

`status` takes one bare value (open | active | blocked | waiting | done | dropped), the details go into `status_note`. `project` is the anchor id of the project row in the overview table. `due` is a date (YYYY-MM-DD) or a short text such as "this week". `summary` and `next` appear on the dashboard card. After saving, run `python3 sync-tasks.py` to show the card in the dashboard.
