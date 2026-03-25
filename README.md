# Project Dashboard

A single-file HTML dashboard that documents, connects, and visualizes all your active projects. Built for designers and developers who work across multiple codebases and want a central overview — powered by [Claude Code](https://claude.ai/claude-code).

## What is this?

Project Dashboard is a **meta-project** — a project that tracks all your other projects. It provides:

- **Overview Table** — Sortable, filterable table with project metrics (files, lines of code, last update, phase)
- **Project Cards** — Detailed cards per project with features, challenges, architecture notes
- **Document Tables** — Per-project file inventory with type badges, file sizes, dates, and copy-to-clipboard paths
- **Synergy Map** — Connections and knowledge transfer opportunities between projects
- **AI Agents** — Three specialized agents (Cockpit, Radar, Bridge) for automated scanning and cross-project analysis
- **Dark/Light Mode** — System preference detection with manual toggle

![Dashboard Screenshot](https://img.shields.io/badge/demo-open%20index.html-blue)

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

## Features

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

### Overview Table

Sortable by any column. Click column headers to sort. Includes:
- Project name with color-coded icon
- Type, organization, tech stack badges
- Code metrics (lines, files)
- Last update with timestamp
- Phase badge (Active, Stable, Migration, Prototype, Idea)
- Direct links to local files and live sites

## Structure

```
index.html      — The complete dashboard (HTML + CSS + JS)
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
