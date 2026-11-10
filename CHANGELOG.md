# Changelog

All notable changes to the Project Dashboard.

## 3.1.0 "Traits" · 2026-11-10

Traits in the side navigation, a place to manage lists, and a focus box that matches the overview.

- Side navigation: new group Traits with Live, Open tasks, Untouched for a while and No preview image. Traits come from the data, one at a time, with All first; picking another filter sets them back to All.
- Counts in the side navigation show exactly what the click shows, under all other active filters.
- Lists: an All tab with every list, each with drag handle, up, down and delete on the right. Delete asks once, without a browser dialog. You can drag the list tabs too.
- Lists in the side navigation: clicking the group only opens or closes it; the gear icon next to it opens All and marks Lists.
- Clicking a list or trait in the side navigation scrolls to the top; switching list tabs brings the Lists section to the top.
- Focus box: same columns and column widths as the overview, with the tool label and a working info icon. Filters no longer hide pinned projects.
- Overview: empty groups disappear when filtering by phase; the info icon shows the card preview when a project has no share image.
- Reloading a page with a #anchor jumps to the card again instead of a random position.
- Tables: action buttons sit on the right, the column is only as wide as its buttons, and row number, icon and name share one line.
- Kernmix 0.16.11.

## 3.0.2 "Overview first" · 2026-11-10

The dashboard opens with the overview.

- First view: Project overview and Lists open, Project details collapsed, no focus box.
- README and social images show this first view.

## 3.0.1 · 2026-11-10

A calmer first view and the latest Kernmix.

- First view: no focus box, Project overview collapsed with “open only” on, Project details and Lists open, About further down. The side navigation follows the same order.
- Your own projects appear under Claude Code in Project details, not under Claude Desktop.
- Kernmix 0.16.3 with an image viewer: images in a section open large, arrow keys go through them, Esc closes.
- The design system tile links to the Kernmix repository.

## 3.0.0 "Common Ground" · 2026-11-09

A new foundation. The dashboard now runs on Kernmix, a design system built on the open standard KERN, ships in English with a fresh set of fictional demo projects, and adds lists, skills, shortcuts and a filter set that works across every section. The project is now licensed under the EUPL-1.2.

### Added

- **Kernmix design system**: all styles and components come from Kernmix, a remix of the open standard KERN, embedded in `index.html` between the `KERN-SYSTEM` markers. Theme "Kobalt" in dark and light, square corners, measured contrast (text at least 4.5:1, interface at least 3:1), Lucide icons throughout.
- **Header buttons**: "Capture idea", "Temp project" and "New project" copy a command that starts Claude Code in the dashboard folder with the matching request: an idea card, a small temporary work folder shown as a temporary card in Ideas, or a complete new project (folder, CLAUDE.md, memory, `scan.sh` entry, table row and card). `CLAUDE.md` describes each step.
- **Side navigation**: a collapsible sidebar on the left with every section, a collapse button and an icon-only rail; the selected section is marked as you scroll, jumps are instant, and the browser's back and forward buttons follow your jumps.
- **Filters for all sections**: a "Filter" group at the top of the sidebar: organization, type, phase, "Open only" and "Active", each with "All" and live counts. A filter applies to the overview, the project details, tasks, synergies, lists and focus at the same time; every filtered section shows the active filters as chips with × to remove them.
- **Seven phases**: Idea, Concept, Prototype, Active, Migration, Stable and Dormant, each with its own colored pill and a phase filter.
- **Lists**: your own project lists with an icon picker (search across all Lucide icons), a quick list filled with one click from each row, rename and delete, a "Deactivated" list for completed projects, and a list filter for the overview.
- **Skills overview with call graph**: a card per Claude Code skill with purpose, scope (global, shared, project) and the projects it belongs to, a filter box, and a graph that shows which skill calls which: entry points, brokers, helpers and building blocks, colored by category, dashed where a skill asks before it continues. Click a skill or a category to highlight its connections.
- **Shortcuts**: a section for prompt shortcuts (`+` and two letters): what each one does, which skill it starts, and a graphic of the fixed order in which several shortcuts run.
- **Ideas**: early ideas get their own card in a separate section before they become a project.
- **About section with animated graphics**: how the dashboard is made (sources, tools, one file, the browser) and how the three agents Cockpit, Radar and Bridge work together, each as a graphic with a text description; motion stops when the system asks for reduced motion.
- **Project facts and previews**: each card shows phase, type, scope, files, last update (with a freshness bar) and hours as fact tiles, plus a preview image; long descriptions fold with "Read more".
- **Card groups with counts**: the project details are grouped like the table; group counts follow the active filters and empty groups disappear.
- **Card actions**: the row buttons (quick list, lists, quicklink, focus, star, completed) also sit in the head of every project card.
- **Tool groups in the project cards**: a header before the first card of each tool band, foldable, with a card count; jumping to a card in a folded group opens it.
- **Share images**: `tools/make-social-images.py` renders a 1200×630 image per project in the Kernmix style; an info "i" behind the project name previews it.
- **Task details**: a dialog per task with status, priority, due date and the ticket text; tasks can be starred, reordered and checked off in the browser (view state only).
- **AI task suggestions**: a foldable list of suggestions below the tasks, each with project, reason and next step. Accept one to turn it into a task, or put it back. Claude Code writes them on request from your tickets, project status and synergies; the demo ships with four examples.
- **Search help**: the search field suggests fields (`person:`, `tag:`, `in:memory`, `in:task`, `in:synergy`, `in:document`, `in:status`, `in:cross-links`) and shows the syntax with examples; `org:` filters by organization.
- **Obsidian Bases view**: `tasks.base` with kanban views by status and priority, a ticket template in `templates/ticket.md`, and an optional color code in `obsidian-color-code.md`.
- **Column sets**: the column picker offers named sets (Overview, Organizations, Tech, All) besides single columns; table headers carry icons.
- **Embedded font**: Atkinson Hyperlegible Next ships in `assets/fonts/` (SIL Open Font License), no CDN.

### Changed

- **English throughout**: interface, demo data, tickets, documentation and helper scripts are in English.
- **New demo data**: twelve fictional projects in five organizations, five tasks, three synergies, three ideas, fifteen example skills and eight shortcuts.
- **Dates in ISO 8601**: the table, cards and documents show `2026-11-09 10:00`, relative times read "2d ago", decimals use a point.
- **Tickets**: one bare `status` value (open, active, blocked, waiting, done, dropped) plus `status_note`; new fields `due` (replaces `deadline`, which is still read), `next` and `created`. `sync-tasks.py` writes the new task markup.
- **`scan.sh`**: code root set with `PD_CODE_DIR` (default `~/projects`), new section with ready-to-paste table values, reads the dashboard's own `tasks/` folder; it never rewrites the dashboard's own `time-log.md` and skips `.venv*` and `.cache` folders.
- **Overview table**: numbered rows, sticky action column on the right, scope with bars, relative dates with freshness bars; a completed project dims right away.
- **Licence**: from MIT to the European Union Public Licence v. 1.2 (EUPL-1.2), matching the embedded Kernmix and KERN-Kit. Third-party parts are listed in `NOTICE.md`.
- **README images**: new header, screenshots in dark and light, section banners, an infographic of how the dashboard works, social preview and LinkedIn image in the Kobalt style.

### Removed

- **Claude Design and other cloud project bands**: the overview lists local projects only.
- **Old phase badges** and the hand-written CSS; everything visible is a Kernmix component now.
- **`file://` links in the demo**: document rows offer "copy path" instead.

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
