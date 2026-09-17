#!/usr/bin/env python3
"""sync-tasks.py — optional helper: builds the dashboard task cards from ticket files.

The dashboard works without this script (task cards can be written by hand). Use it
when your tasks live in Markdown files: the ticket file stays the source of truth,
the dashboard is a view. Only the block between
<!-- AUTO-TASKS:BEGIN --> and <!-- AUTO-TASKS:END --> in index.html is rewritten.

Ticket = Markdown file with YAML frontmatter (same fields scan.sh reads from todo_*.md):

    ---
    id: APP-12
    title: "Short task title"
    status: open            # open | active | blocked  -> shown · anything else -> skipped
    priority: high          # high | medium | low
    project: my-app         # anchor id of the project row in the overview table
    deadline: 2026-10-01    # optional
    summary: "One line for the card"   # optional
    dashboard: false        # optional: keep the ticket off the dashboard
    ---
    Free-form notes (shown in the detail dialog).

Two ways to work with tickets:
  * without Obsidian — the card links to the file (file://), edit it in any editor
  * with Obsidian    — keep tickets inside your vault and set OBSIDIAN in index.html;
                       the same link then opens the ticket in Obsidian

Usage: python3 sync-tasks.py        (standard library only)
"""
import base64, glob, html, os, re, sys, urllib.parse, urllib.request

BASE = os.path.dirname(os.path.abspath(__file__))
DASH = os.path.join(BASE, 'index.html')

# Where your tickets live. Relative globs are resolved against the dashboard folder.
# 'project' is the fallback anchor id when a ticket has no `project:` field.
SOURCES = [
    {'glob': 'tasks/*.md'},
    # {'glob': '~/projects/my-app/tasks/*.md', 'project': 'my-app'},
    # {'glob': '~/.claude/projects/-Users-jane-projects-my-app/memory/todo_*.md', 'project': 'my-app'},
]

SHOWN = {'open': ('offen', 'Open'), 'active': ('aktiv', 'Active'), 'blocked': ('offen', 'Blocked')}
PRIO_ORDER = {'high': 0, 'medium': 1, 'low': 2}
FRONTMATTER = re.compile(r'---\n(.*?)\n---\n?', re.S)


def parse(path):
    text = open(path, encoding='utf-8').read()
    m = FRONTMATTER.match(text)
    if not m:
        return None, ''
    fm = {}
    for line in m.group(1).splitlines():
        km = re.match(r'^([a-z_]+):\s*(.*)$', line)
        if km:
            v = km.group(2).strip()
            quoted = re.match(r'^(["\'])(.*?)\1', v)
            fm[km.group(1)] = quoted.group(2) if quoted else re.sub(r'\s+#.*$', '', v)  # unquoted: drop trailing comment
    return fm, text[m.end():].strip()


def projects(page):
    """anchor id -> (name, color), read from the overview table so nothing is configured twice."""
    out = {}
    for m in re.finditer(r'<a class="table-name" href="#([^"]+)">(.*?)</a>', page, re.S):
        color = re.search(r"fill='%23([0-9a-fA-F]{3,6})'", m.group(2))
        name = re.sub(r'<[^>]+>', '', m.group(2)).strip()
        out[m.group(1)] = (html.unescape(name), '#' + color.group(1) if color else 'var(--accent)')
    return out


def file_href(path):
    rel = os.path.relpath(path, BASE)
    if not rel.startswith('..'):  # inside the dashboard folder: relative link, no absolute path in the HTML
        return urllib.parse.quote(rel.replace(os.sep, '/'))
    return 'file://' + urllib.request.pathname2url(path)


def card(fm, body, path, known):
    e = html.escape
    cls, label = SHOWN[fm['status']]
    if fm.get('deadline'):
        cls, label = 'aktiv', 'Due ' + fm['deadline']
    pid = fm.get('project', '')
    name, color = known.get(pid, (pid, 'var(--accent)'))
    project = f'<a href="#{e(pid)}" style="color:{color};text-decoration:none;font-weight:500;">{e(name)}</a> &middot; ' if pid else ''
    summary = fm.get('summary') or f"Priority {fm.get('priority', '–')}"
    attrs = ''.join(f' data-{k}="{e(fm[k])}"' for k in ('priority', 'deadline', 'created') if fm.get(k))
    b64 = base64.b64encode(body.encode('utf-8')).decode('ascii')
    return f'''      <div class="task-item" data-generated="1" data-file="{e(file_href(path))}"{attrs} data-body="{b64}">
        <input type="checkbox" class="task-checkbox" aria-label="Done: {e(fm.get('title', ''))}">
        <div class="task-content">
          <div class="task-title">
            <span>{e(fm.get('title', os.path.basename(path)))}</span>
            <span class="task-id">{e(fm.get('id', ''))}</span>
            <span class="task-status {cls}">{e(label)}</span>
          </div>
          <div class="task-meta">
            {project}{e(summary)}
          </div>
        </div>
      </div>'''


def main():
    page = open(DASH, encoding='utf-8').read()
    pat = re.compile(r'<!-- AUTO-TASKS:BEGIN.*?<!-- AUTO-TASKS:END -->', re.S)
    if not pat.search(page):
        sys.exit('ERROR: AUTO-TASKS markers are missing in index.html')
    known, cards = projects(page), []
    for src in SOURCES:
        pattern = os.path.expanduser(src['glob'])
        for path in sorted(glob.glob(pattern if os.path.isabs(pattern) else os.path.join(BASE, pattern))):
            if os.path.basename(path).startswith(('README', '_')):
                continue
            fm, body = parse(path)
            if not fm or fm.get('status') not in SHOWN or fm.get('dashboard', '').lower() == 'false':
                continue
            fm.setdefault('project', src.get('project', ''))
            order = (fm.get('deadline') or '9999', PRIO_ORDER.get(fm.get('priority'), 1), fm.get('id', ''))
            cards.append((order, card(fm, body, path, known)))
    cards.sort(key=lambda c: c[0])
    block = ('<!-- AUTO-TASKS:BEGIN — generated from ticket files by sync-tasks.py; do not edit by hand -->\n'
             + '\n'.join(c[1] for c in cards) + '\n      <!-- AUTO-TASKS:END -->')
    open(DASH, 'w', encoding='utf-8').write(pat.sub(lambda _: block, page))
    print(f'{len(cards)} task cards generated.')


if __name__ == '__main__':
    main()
