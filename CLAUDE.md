# Project Dashboard

Open-source meta-project that documents, connects, and visualizes all your active projects as a single-page HTML dashboard.

Communication language: English.

## Architecture

- **index.html** (~2.6k lines): Complete dashboard in a single file (HTML + CSS + JS, no build step)
- **favicon.svg**: Dashboard icon (gray square, "PD")
- **README.md**: Public documentation
- **LICENSE**: MIT

## Structure of index.html

The HTML follows a strict section order:

1. **Theme Tokens** (lines ~1-50) — CSS Custom Properties for Dark/Light Mode via `data-theme="dark"|"light"` on `<html>`
2. **Component Styles** (lines ~50-1000) — All CSS: layout, table, cards, agents, docs-tables, synergies, responsive
3. **About Section** (lines ~1017-1181) — Collapsible `<details class="about-section">` with project description and agent cards
4. **Overview Table** (lines ~1183-1510) — Sortable, filterable table with all projects and metrics
5. **Project Cards** (lines ~1514-2185) — Collapsible detail cards per project with grid layout + docs table
6. **Project Ideas** (lines ~2186-2297) — Collapsible idea cards for early-stage concepts
7. **Synergies** (lines ~2298-2450) — Connection cards between projects
8. **JavaScript** (lines ~2450-2633) — Table sorting, search/filter, theme toggle, back-to-top, clipboard, last-viewed

## Bootstrap: Setting Up Your Dashboard

This project is designed to be self-configuring via Claude Code. After cloning, run `claude` in the project directory and say: "Set up this dashboard for my projects. My code lives in ~/my-code-directory".

### What Claude Code generates for you

When a user asks to set up the dashboard, follow these steps:

**Step 1 — Discover projects:**
Scan the user's code directory for project folders. Identify projects by looking for `package.json`, `CLAUDE.md`, `.git/`, `README.md`, `src/` directories.

**Step 2 — Update index.html:**
Replace the example projects with the user's real projects:
- Update the overview table rows (name, type, org, tech badges, metrics, phase)
- Create project cards with details from each project's README/CLAUDE.md
- Build docs tables by scanning each project for relevant files
- Scan file sizes via `stat -f '%z' file` and format as "x.x KB"
- Scan timestamps via `stat -f '%Sm' -t '%Y-%m-%d %H:%M' file`
- Assign unique accent colors as CSS custom properties in `:root`
- Generate inline SVG icons per project (see Icon Pattern below)

**Step 3 — Configure paths:**
The dashboard uses two JavaScript functions that need the user's base path:
- `openClaude(project)` — generates a `cd ~/path/project && claude` command, copies to clipboard
- `copyDocPath(btn, dir, file)` — copies `~/path/dir/file` to clipboard
- Find these functions in the `<script>` section and update the base path

**Step 4 — Generate launch scripts** (optional, macOS):
Create a `launch/` directory with `.command` files for each project:
```bash
#!/bin/bash
cd ~/path/to/project && claude
```
Make executable: `chmod +x launch/*.command`

**Step 5 — Set up synergies:**
Analyze projects for shared technologies, patterns, or knowledge transfer opportunities. Create synergy cards in the synergies section.

**Step 6 — Create agents** (optional):
Ask the user if they want slash commands. If yes, create skill and agent definitions (see Skills & Agents section below).

### Ongoing maintenance

After initial setup, the user can keep the dashboard updated:
- "Scan my projects and update the dashboard" — full Radar scan
- "Scan project X" — single project update
- "Find synergies between my projects" — Bridge analysis
- "Add project X to the dashboard" — new project to table + card

## Skills & Agents

Three specialized helpers available as slash commands AND orchestrated subagents.

### Cockpit — Coordinator & Dashboard Developer

Control center of the dashboard. Evolves the `index.html`, coordinates Radar and Bridge, maintains memory files, prioritizes features.

**Invocation:**
- `/cockpit` — Skill mode (manual, in conversation)
- `/cockpit status` — Overview of all agents and dashboard state
- `claude --agent cockpit` — Agent mode (orchestrated, autonomous)

**Capabilities:**
- Spawns Radar and Bridge as subagents and runs them in parallel
- Processes their results and updates the dashboard HTML
- Maintains project memory files

### Radar — Update Scanner

Scans project directories on three levels:
1. **Code data**: file count, lines of code, prototypes, last modified
2. **Claude context**: CLAUDE.md presence, memory files, session count, MCP settings
3. **Health check**: stale memories, missing CLAUDE.md, outdated docs

**Invocation:**
- `/radar` — Scan all projects
- `/radar project-a project-b` — Scan specific projects only
- As subagent of Cockpit (automatic)

**Output per project:** Code metrics diff table, Claude context checklist, warnings for issues.

### Bridge — Synergy Finder

Compares projects by content: token architectures, configurations, component patterns. Identifies transfer opportunities with specific code references.

**Invocation:**
- `/bridge project-a project-b` — Compare two projects
- `/bridge transfer project-a→project-b` — Knowledge transfer direction
- As subagent of Cockpit (automatic)

**Output:** Comparison table + code references + recommendations + risks.

### Architecture: Skills vs. Agents

| | Skills (`/slash`) | Agents (`claude --agent`) |
|---|---|---|
| **Invocation** | `/cockpit`, `/radar`, `/bridge` | `claude --agent cockpit` |
| **Autocomplete on /** | Yes | No |
| **Cross-invocation** | No — sequential by user | Yes — Cockpit spawns Radar & Bridge |
| **Parallel execution** | No | Yes — Radar + Bridge simultaneously |
| **Tool restrictions** | No — full access | Yes — `tools:` field in frontmatter |
| **File location** | `~/.claude/skills/*/SKILL.md` | `~/.claude/agents/*.md` |

**Why both?**
- **Skills** for daily use: `/radar` → numbers updated. Fast, direct.
- **Agents** for orchestrated workflows: `claude --agent cockpit` starts a session where Cockpit autonomously decides when to spawn Radar or Bridge.

**Limitation:** Subagents cannot spawn further subagents. Only the main agent (Cockpit) can delegate. Radar and Bridge are pure workers.

**Typical workflows:**
- Quick: `/radar` → metrics updated
- Targeted: `/bridge project-a project-b` → comparison
- Orchestrated: `claude --agent cockpit` → "Update the dashboard and check if project A has patterns that project B could use" → Cockpit spawns Radar + Bridge, processes results, updates HTML

### Setting up Skills and Agents

To create the skill/agent files for your dashboard, ask Claude Code:

**For Skills:**
```
Create /radar, /bridge, and /cockpit skills for this dashboard
```
Claude will create files in `~/.claude/skills/radar/SKILL.md` etc.

**For Agents:**
```
Create a cockpit agent that can orchestrate radar and bridge
```
Claude will create files in `~/.claude/agents/cockpit.md` etc.

### Radar Scan Logic (detailed)

When scanning a project directory, collect:

**Metrics:**
- **File count**: All files excluding node_modules, .git, dist, build, coverage
- **Lines of code**: Count via `find ... -exec wc -l {} +` for source files (.ts, .tsx, .js, .jsx, .css, .scss, .html, .kt, .java)
- **Last modified**: Most recent file change timestamp

**Phase detection:**
- Active: changed within last 7 days
- Stable: no changes in 30+ days, has releases/tags
- Migration: major version bumps or framework changes in progress
- Prototype: has prototype/ or poc/ directories
- Idea: only has README or CLAUDE.md, minimal code

**Docs inventory — categorize files into 4 types:**
- Research (orange badge): UX research, audits, walkthroughs, analysis documents
- Project (blue badge): READMEs, changelogs, licenses, roadmaps
- Code (green badge): package.json, tsconfig, vite.config, token files, build configs
- Claude (purple badge): CLAUDE.md, memory files, agent configs, .claude/ contents

**Updating the HTML:**
- Update table row: scope (lines), files, last update, phase badge
- Update docs table: add/remove file rows, update sizes and timestamps
- Use `stat -f '%z' file` for byte size → format as "x.x KB"
- Use `stat -f '%Sm' -t '%Y-%m-%d %H:%M' file` for timestamp

## HTML Conventions

### Overview Table Row Pattern

```html
<tr>
  <td>
    <a class="table-name" href="#project-id">
      <img class="project-icon" src="data:image/svg+xml,..." alt="">
      Project Name
    </a>
  </td>
  <td>Type</td>
  <td>Organization</td>
  <td><div class="table-badges"><span class="table-badge">Tech</span></div></td>
  <td class="table-scope" data-sort="1234">~1.2k lines</td>
  <td data-sort="42">42</td>
  <td class="table-date" data-sort="2026-03-25T10:30">25.03.2026, 10:30</td>
  <td><span class="phase-badge phase-active">Active</span></td>
  <td><div class="table-links"><a class="table-link" href="file:///...">Local</a></div></td>
  <td><button class="btn-claude" onclick="openClaude('project-dir')">claude</button></td>
</tr>
```

Sub-rows (child projects) use `class="sub-row"` and always stay grouped under their parent.

### Icon Pattern

Inline SVG as data-URI in the table. 32x32 ViewBox, rx=6 rounded corners, white 2-letter abbreviation:

```
data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='6' fill='%23e8432a'/%3E%3Ctext x='16' y='22' font-family='system-ui' font-size='18' font-weight='700' fill='%23fff' text-anchor='middle'%3ENf%3C/text%3E%3C/svg%3E
```

Replace `%23e8432a` with the project's hex color (URL-encoded #) and `Nf` with the 2-letter abbreviation.

### Project Card Pattern

```html
<article class="project collapsed" id="project-id">
  <div class="project-header" style="border-left: 3px solid var(--accent-color);">
    <div class="project-badges"><span class="table-badge">Tech</span></div>
    <div class="project-name project-toggle"
         onclick="this.closest('.project').classList.toggle('collapsed')">
      Project Name
    </div>
    <div class="project-subtitle">One-line description</div>
  </div>
  <div class="project-body">
    <!-- Grid with project-section divs for Features, Challenges, etc. -->
    <details open>
      <summary>Show Documents & Configuration</summary>
      <table class="docs-table">...</table>
    </details>
    <div class="project-paths">
      <span class="path-tag">~/path/to/project</span>
    </div>
  </div>
</article>
```

Collapsible: `.collapsed` class toggles `.project-body` visibility via CSS `display: none`.

### Docs Table Pattern

```html
<table class="docs-table">
  <thead>
    <tr>
      <th data-sort="text">Type</th>
      <th>Actions</th>
      <th data-sort="text">File</th>
      <th>Description</th>
      <th data-sort="size">Size</th>
      <th data-sort="date">Updated</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="doc-type"><span class="doc-badge research">Research</span></td>
      <td class="doc-actions">
        <a class="doc-link" href="file:///path/to/file">open</a>
        <button class="copy-btn" onclick="copyDocPath(this,'project-dir','file.md')">copy</button>
      </td>
      <td>file.md</td>
      <td>Description of file</td>
      <td class="doc-size">2.4 KB</td>
      <td class="doc-date">2026-03-25 10:30</td>
    </tr>
  </tbody>
</table>
```

4 doc types in fixed display order: Research (orange), Project (blue), Code (green), Claude (purple).
Badge classes: `doc-badge research`, `doc-badge project`, `doc-badge code`, `doc-badge claude`.

### Idea Card Pattern

Same as project card but with `class="idea"` instead of `class="project"`, no docs table required.

### Synergy Card Pattern

```html
<div class="synergy-card">
  <h3>Synergy Title</h3>
  <p>Description of the connection between projects.</p>
  <p><strong>Potential:</strong> What could be gained from this synergy.</p>
</div>
```

### Phase Badges

Available phases: `phase-active`, `phase-stable`, `phase-migration`, `phase-prototype`, `phase-idea`

### Theme System

CSS Custom Properties in `:root[data-theme="dark"]` and `:root[data-theme="light"]`:
- `--bg`, `--surface`, `--surface-2`, `--surface-3`: Background layers
- `--border`, `--border-hover`: Borders
- `--text`, `--text-muted`, `--text-dim`: Text colors
- `--table-header-bg`, `--table-stripe`: Table colors
- `--shadow`: Box shadow color

Project accent colors in `:root` (theme-independent): `--accent-projectname: #hexcolor`

Theme toggle button in header switches `data-theme` attribute. System preference detected via `prefers-color-scheme`.

## Constraints

- No external dependencies — no npm, no CDN, no build tools
- All project data is maintained via Claude Code scans or manual updates
- File paths use file:// protocol for local access
- Works offline (except external links)
