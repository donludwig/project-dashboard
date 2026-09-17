# Changelog

All notable changes to the Project Dashboard.

## 2.1.0 — 2026-09-17

Focus, smart search and a more forgiving layout.

### Added

- **Focus section** — pin up to 3 projects above the overview table (arrow button per row). Pinned rows are cloned on top and hidden below, stay fully operable (quicklink, star, done) and can be reordered by drag; a 4th pin is declined with a short hint
- **Smart search** — weighted index over table rows, project cards, synergies and tasks. AND by default, `-word`, `"phrase"`, and the filters `tool:` `org:` `tag:` `in:`; filters become removable chips inside the search box, suggestions appear on focus, a results panel shows matched fields with highlighted snippets
- **Tool bands & cloud projects** — `tool-header` rows group projects by where they live (e.g. Claude Code / Claude Design) in the Projects view; `cloud-row` projects carry a link instead of the `claude` button, and their quicklink pill opens that link
- **Collapsible, movable organizations** — click an organization header to fold its rows (with project count), drag its grip to move the whole section
- **"Open only" toggle** — hides completed projects
- **Resizable sidebar** — drag the gap between the columns (380–860px), double-click resets, drag far right hides the sidebar; the header tasks button brings it back
- **Organization filter for tasks** — derived from the project each task links to (`data-org` on a task overrides); counters respect the filter
- **Remembered state** — open/closed sections, collapsed organizations and collapsed project cards survive reloads
- **Footer bars** — stacked ASCII bars with the project share per tool band and per organization; hidden projects are noted in the stats
- **Task cards** — details dialog (native `<dialog>` with the full ticket), star, hide with restore, drag to reorder; view state only, nothing is written from the browser
- **Tasks from files (optional)** — `sync-tasks.py` builds the task cards from Markdown tickets with frontmatter (same format as `todo_*.md`), project name and color are read from the overview table; works without Obsidian (file link) and with it (ticket opens in the vault). Demo tickets in `tasks/`
- **Card previews** — optional preview image per project card (`assets/previews/`), schematic SVG placeholders for the demo projects
- **Optional Obsidian integration** — `.md` links inside a configured vault open in Obsidian, `Cmd/Ctrl+Enter` searches the vault

### Changed

- **Self-healing row order** — a saved order is now only a ranking applied to the HTML structure: renamed anchors, new organizations or moved rows no longer strand sub-rows or require a storage key bump. Projects and Organizations views keep separate orders
- **Quicklinks are keyed by the row's anchor id** instead of the `openClaude` argument, so sub-projects sharing a folder with their parent can be pinned independently (existing quicklinks are migrated)
- Row buttons: bookmark = quicklink, arrow = focus, star = in progress, check box = completed; active buttons are filled. The completed icon is now square like the rest of the UI
- Accessibility & typography: visible keyboard focus on all controls, tabular figures with slashed zero, balanced headings, hyphenated body copy, links inherit the accent color; deactivated tasks are labelled "Project completed"

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
