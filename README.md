# Project Dashboard

I've been managing a few design system projects at the same time and kept losing track of what's where. I opened Claude Code and started building a dashboard. Just a single HTML file, nothing fancy.

First it was only a table with project names and some numbers. But then I wanted to sort it. Then I wanted search. Project cards came next, then docs tables, then task management.

Somewhere along the way I realized I was learning more about Claude Code than about dashboards. What works, what doesn't, how to structure things so the AI can actually help you. I ended up building three AI agents that now help me keep the dashboard up to date.

If you're a designer trying to get into Claude Code and looking to understand better code and developers, fork it, swap in your own projects, and go from there.

<img width="1733" height="1366" alt="Project Dashboard — Dark Mode" src="https://github.com/user-attachments/assets/e81e8298-f9fc-4692-ae3f-d5da91767909" />

## Features

- Sortable, filterable project table, collapsible sections
- Column visibility toggle — show/hide columns from the overview, persisted in localStorage
- Hours tracking via per-project `time-log.md` (manual entries + auto Claude sessions)
- Auto-generated color-coded favicons per project
- Expandable project cards
- Docs tables per project (research, project, code, Claude files)
- Task management with status tracking
- AI-generated task recommendations
- Full text search
- Three AI agents (scanner, bridge, coordinator)
- Shell script that scans all projects and updates dashboard
- Connections between projects
- Zero dependencies, no build step, single HTML file

https://github.com/user-attachments/assets/3f0ea605-f076-4a26-8b56-edaf8c06cc2f

## Quick Start

### 1. Clone and explore the demo

```bash
git clone https://github.com/donludwig/project-dashboard.git
cd project-dashboard
open index.html
```

The demo includes 12 fictional example projects showing all features.

### 2. Set up with Claude Code

This is where it gets interesting. The dashboard is designed to **configure itself** via Claude Code:

```bash
claude
```

Then say:

> Set up this dashboard for my projects. My code lives in ~/projects

Claude Code reads the `CLAUDE.md` instructions and will:

1. **Scan your project directories** — finds all projects, counts files, measures code
2. **Replace the example data** — swaps demo projects with your real ones
3. **Build project cards** — pulls descriptions from your READMEs and CLAUDE.md files
4. **Create docs tables** — inventories each project's files by type
5. **Configure paths** — sets up local file links and clipboard copy
6. **Find synergies** — analyzes connections between your projects
7. **Generate launch scripts** (optional) — one-click `.command` files to open any project in Claude Code

### 3. Keep it updated

Ask Claude Code anytime:

- `"Scan my projects and update the dashboard"` — refreshes all metrics
- `"Find synergies between my projects"` — discovers new connections
- `"Add project X to the dashboard"` — adds a new project

## Feature Details

### Single-File Architecture

Everything lives in one `index.html` — no build step, no framework, no dependencies. Just open it in a browser.

### Document Tables

Each project card includes a sortable table of relevant files, categorized by type:

| Type | Color | Examples |
|------|-------|----------|
| **Research** | Orange | UX research, audits, walkthroughs |
| **Project** | Blue | READMEs, changelogs, licenses |
| **Code** | Green | package.json, configs, token files |
| **Claude** | Purple | CLAUDE.md, memory files, agent configs |

Each row has **open** (file link) and **copy** (path to clipboard) buttons.

### AI Agent Architecture

Three agents work together as a hybrid Skill/Agent system:

- **Cockpit** — Coordinator that orchestrates the other two
- **Radar** — Scans project directories for file counts, code lines, docs, Claude context
- **Bridge** — Compares projects, finds synergies, recommends knowledge transfer

You don't need to set these up manually — just ask Claude Code to scan or analyze, and it follows the conventions documented in `CLAUDE.md`.

Want explicit slash commands? Ask Claude Code:
```
Create a /radar skill that scans my projects and updates the dashboard
```

### Task Management with AI Recommendations

A global task section sits above the overview table, combining manual tasks and AI-generated suggestions.

**Manual tasks** have a checkbox, ticket ID badge, and status (Open/Active/Done). They also appear in their project card for context.

**AI recommendations** are generated during a Radar scan — the AI analyzes all projects and suggests actionable next steps. Each suggestion has:
- An `AI` tag to distinguish it from manual tasks
- A **Promote** button — moves the suggestion into the manual task list
- A **✕ revert** (demote) button — reverts a promoted task back to a suggestion

**State persistence** — all user interactions are saved to `localStorage`:
- Checkbox states (which tasks are done)
- Promoted AI recommendations
- Open/close state of all collapsible sections

**Task file standard** — tasks are stored as Markdown files with YAML frontmatter in Claude memory directories (`todo_*.md`). The Radar scanner (`scan.sh`) picks them up automatically. Schema:

```yaml
---
id: TODO-DEMO-001
title: "Migrate typography tokens to fluid scale"
status: open         # open | active | done | blocked
priority: high       # low | medium | high | critical
project: nova-fluid-type
parent: DEMO-000     # optional parent ticket
deadline: 2026-04-15 # optional
tags: [typography, tokens]
created: 2026-03-29
updated: 2026-03-29
type: project
---
```

### Overview Table

Sortable by any column. Click column headers to sort. Includes:
- Project name with color-coded icon
- Type, organization, tech stack badges
- Code metrics (lines, files)
- Last update with timestamp
- Hours invested (sourced from per-project `time-log.md`)
- Phase badge (Active, Stable, Migration, Prototype, Idea)
- Direct links to local files and live sites

### Column Visibility Toggle

A **Display columns** dropdown next to the search input lets you hide columns you don't need. The button shows a `visible/total` counter when columns are hidden, and the state is saved to `localStorage` so it survives reloads. Useful when the table gets wider than your screen — hide what's not relevant for the moment.

### Hours Tracking (time-log.md)

Each project has a `time-log.md` in its root as a rough orientation (not exact tracking). Format:

```markdown
---
type: time-log
project: nova-fluid-type
---

# Time Log

## Manual

| Date | Hours | Note |
|---|---|---|
| 2026-03-21 | 3.0 | Setup, concept |

## Claude Sessions (auto, by scan.sh)

| Session | Date | Start | End | Hours |
|---|---|---|---|---|
| de81b351 | 2026-04-26 | 15:26 | 22:34 | 7.1 |

**Total:** 10.1h (manual: 3.0 + claude: 7.1)
```

- **Manual section** — you maintain it: work outside of Claude sessions (concept, notes, code without Claude). Decimal hours with a dot.
- **Claude Sessions section** — `scan.sh` writes it automatically from `.jsonl` session timestamps. Active time only — gaps over 30 minutes (lunch breaks, resuming the next day) are excluded so multi-day sessions don't count idle hours as work. Sub-agent sessions are also excluded.
- **Total** — auto-summed by `scan.sh`.

The dashboard shows the total per project in the **Hours** column and a Σ across all projects above the table. There's also an optional `<details>` time-log block in each project card with the full breakdown.

### Radar Scanner (scan.sh)

The dashboard includes a bash script that collects all project metrics in ~3 seconds — replacing what previously required multiple AI agents (~3 minutes).

```bash
./scan.sh              # Scan all projects
./scan.sh kern tipi    # Scan specific projects (fuzzy match)
```

Per project, the script collects: file count, lines of code, last modification date, Claude memory count, and session count. It also runs a health check (`CFM`) — uppercase means present, lowercase means missing:

- `C`/`c` — CLAUDE.md exists
- `F`/`f` — favicon.svg exists
- `M`/`m` — Claude memory index exists

The Radar agent calls this script first, then only uses AI for interpretation: what changed, which docs are missing in the dashboard, what needs updating.

Edit the `PROJECTS` array at the top of the script to match your projects.

## Structure

```
index.html      — The complete dashboard (HTML + CSS + JS)
scan.sh         — Radar scanner script (collects project metrics)
favicon.svg     — Dashboard icon
README.md       — This file
LICENSE         — MIT License
CLAUDE.md       — AI assistant instructions (the brain of the project)
```

The `CLAUDE.md` is the key file — it contains all the conventions, scan logic, and setup instructions that Claude Code uses to configure and maintain your dashboard.

## Design Principles

- **Zero Dependencies** — No npm, no CDN, no build tools
- **Single Source of Truth** — One file, always in sync
- **AI-Native** — Built with and for AI coding assistants
- **Self-Bootstrapping** — Claude Code sets everything up from `CLAUDE.md`
- **Offline-First** — Works without internet (except external links)

## Inspired By

- The [Spine Pattern](https://tsoporan.com/blog/spine-pattern-multi-repo-ai-development/) — using a meta-repo as AI context anchor
- Design System documentation patterns
- Personal knowledge management tools

## License

MIT — see [LICENSE](LICENSE)
