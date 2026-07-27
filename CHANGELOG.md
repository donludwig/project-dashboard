# Changelog

All notable changes to the Project Dashboard.

## 2.0.0 — 2026-07-27

A major release: new two-column layout with quicklinks, view modes, drag & drop everywhere, a full visual overhaul, and a much more capable Radar scanner.

### Layout & Interaction

- **Sticky header with quicklink pills** — pin favorite projects with **+** in their table row; pills show the project icon, copy the `cd … && claude` launch command on click, reorder via drag & drop, remove with ×
- **Two-column layout** — main column (overview, about, project details) plus a sticky sidebar (tasks, synergies) that scrolls independently
- **View modes** — Projects (flat), Organizations (grouped, default), Active (starred only), persisted in localStorage
- **Star & complete toggles per row** — ★ marks a project as "in progress" (bold, amber edge, auto-pins to quicklinks), ✓ marks it completed (dims the row, strikes through its tasks)
- **Drag & drop everywhere** — reorder sections (per column) and table rows (per organization, sub-rows travel with their parent), all persisted
- **Footer** — live stats (projects, organizations, in progress, completed, open tasks, ideas, hours), layout reset button, last-viewed/last-update dates
- **Keyboard shortcuts** — `/` search, `t` theme, `a` tasks, `1`/`2`/`3` view modes
- **Quality of life** — search hit counter, collapse/expand all project cards, full-header click targets on cards, hours summary as info icon

### Visual Overhaul

- Full-width layout (no max-width), square corners throughout (`--radius: 0`)
- New color scheme: cool dark/light themes with cyan UI accent (`--accent`/`--on-accent`)
- Shared SVG caret mask for all collapse indicators; squared project icons and UI icons
- Organization headers with colored left bar (`--org-color`), card shadows with hover states

### Radar Scanner (scan.sh)

- **Time-log generation** — computes active hours per Claude session from `.jsonl` timestamps (gaps > 30 min excluded, 2 min tail buffer) and rebuilds each project's `time-log.md`, preserving manual entries
- **Hours check** — per-project manual/claude/total table plus grand total
- **Tasks check** — collects `todo_*.md` files from Claude memory directories (status, priority, title)
- **Link check** — verifies every `file://` link in `index.html` and reports dead targets

### Removed

- Sticky floating tasks button (replaced by the header tasks toggle)
- Outdated demo video in the README

## 1.2.0 — 2026-06-26

- Organization sub-headings in the overview table with section-aware sorting — sorting by a column switches to a flat global ranking
- Sub-projects as indented sub-rows that stay attached to their parent
- Freshness bar minimum width so stale projects stay visible

## 1.1.0 — 2026-04-27

- Column visibility toggle with persisted state
- Hours tracking via per-project `time-log.md`, hours column and Σ total
- Time-log summary blocks in project cards, overview scroll wrapper

## 1.0.0 — 2026-03-29

- Initial public release: single-file dashboard (HTML + CSS + JS, zero dependencies), sortable/filterable overview table, project cards with docs tables, task management with AI recommendations, synergy cards, dark/light theme, three AI agents (Cockpit, Radar, Bridge), `scan.sh` metrics scanner, self-bootstrapping setup via `CLAUDE.md`
