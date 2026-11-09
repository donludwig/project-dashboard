#!/usr/bin/env python3
"""make-social-images.py: optional helper that renders a 1200x630 share image per project.

Data comes from index.html: overview row (name, organization, type, phase) and project card
(subtitle, color of the card stripe). The image uses the design system that is embedded in
index.html (the <style data-kern-system> blocks, dark mode) and a Lucide icon from the embedded
icon set, so it matches the dashboard without any download. The right half shows the card
preview from assets/previews/<anchor>.(svg|png|jpg), or a color tile with the project initials.
Rendering uses Headless Chrome.

Output: assets/social/<anchor>.png, plus the anchor -> image map in the #social-images JSON
block of index.html (the info "i" behind each project name shows the image).

Usage: python3 tools/make-social-images.py [--dry] [--dashboard PATH] [anchor ...]
       (no anchor = all projects; --dry lists what would be rendered)
Standard library only. Set CHROME if Chrome is not found automatically.
"""
import html, json, os, re, shutil, subprocess, sys, tempfile, urllib.parse, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Lucide icon per project type (first match wins), fallback "folder"
ICONS = [('design system', 'blocks'), ('component', 'component'), ('tool', 'wrench'), ('audit', 'clipboard-check'),
         ('platform', 'layers'), ('landing', 'layout-template'), ('app', 'app-window'), ('learning', 'graduation-cap'),
         ('method', 'workflow'), ('color', 'palette')]


def chrome():
    for c in (os.environ.get('CHROME'), '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
              shutil.which('google-chrome'), shutil.which('chromium'), shutil.which('chromium-browser')):
        if c and os.path.exists(c):
            return c
    sys.exit('ERROR: Chrome not found, set CHROME=/path/to/chrome')


def text(s):
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', '', s))).strip()


def projects(H):
    a = H.index('<tbody', H.index('id="overview-table"'))
    b = H.index('</tbody>', a)
    org, seen = '', set()
    for tr in re.findall(r'<tr\b[^>]*>.*?</tr>', H[a:b], re.S):
        if 'org-header' in tr:
            if 'tool-header' not in tr and 'tool-code' not in tr:
                m = re.search(r'km-table__group-label">(.*?)</span>', tr, re.S)
                org = text(m.group(1)) if m else ''
            continue
        m = re.search(r'<a class="table-name[^"]*" href="#([^"]+)">(.*?)</a>', tr, re.S)
        if not m or m.group(1) in seen:
            continue
        anchor, name = m.group(1), text(m.group(2))
        seen.add(anchor)
        tds = re.findall(r'<td\b[^>]*>(.*?)</td>', tr, re.S)
        kind = text(tds[1]) if len(tds) > 1 else ''
        ph = re.search(r'phase-badge km-pill km-pill--([a-z]+)">(.*?)</span>', tr, re.S)
        mono = re.search(r'%3E([^%<]{1,3})%3C/text', m.group(2)) or re.search(r'>([^<>]{1,3})</text>', urllib.parse.unquote(m.group(2)))
        card = re.search(r'<article class="project[^"]*" id="%s"[^>]*>(.*?)</article>' % re.escape(anchor), H, re.S)
        sub, color = '', '#4f5b6b'
        if card:
            c = card.group(1)
            s = re.search(r'km-card__subtitle">(.*?)</div>', c, re.S) or re.search(r'project-description">(.*?)</p>', c, re.S)
            sub = text(s.group(1)) if s else ''
            k = re.search(r'project-indicator" style="background:\s*([^;"]+)', c)
            color = k.group(1).strip() if k else color
        abbr = mono.group(1) if mono else (''.join(w[0] for w in re.findall(r'[A-Za-z0-9]+', name)[:2]) or name[:2]).capitalize()
        yield dict(anchor=anchor, name=name, color=color, abbr=abbr, org=org, kind=kind,
                   phase=text(ph.group(2)) if ph else '', phase_cls=ph.group(1) if ph else 'neutral', sub=sub)


def preview(root, anchor):
    for ext in ('svg', 'png', 'jpg'):
        f = os.path.join(root, 'assets', 'previews', f'{anchor}.{ext}')
        if os.path.exists(f):
            return 'file://' + urllib.request.pathname2url(f)
    return None


def page(p, kit, icons, shot):
    e = lambda s: html.escape(s or '')
    k = p['kind'].lower()
    ico = icons.get(next((n for key, n in ICONS if key in k), 'folder')) or icons.get('folder', '')
    right = (f'<div class="shot"><img src="{shot}" alt=""></div>' if shot
             else f'<div class="tile"><span>{e(p["abbr"])}</span></div>')
    meta = ' · '.join(x for x in (p['org'], p['kind']) if x)
    size = 64 if len(p['name']) <= 20 else 52 if len(p['name']) <= 30 else 44
    return f'''<!doctype html><html lang="en" data-theme="dark" data-kern-theme="dark"><meta charset="utf-8">{kit}<style>
*{{box-sizing:border-box;margin:0}}
html,body{{width:1200px;height:630px;overflow:hidden;scrollbar-gutter:auto}}
body{{font-family:var(--km-font);background:var(--km-color-page);color:var(--km-color-text);-webkit-font-smoothing:antialiased;
display:grid;grid-template-columns:600px 1fr;box-shadow:inset 16px 0 0 {p["color"]}}}
.l{{padding:64px 48px 56px 72px;display:flex;flex-direction:column}}
.top{{display:flex;align-items:center;gap:16px}}
.kz{{width:64px;height:64px;background:{p["color"]};color:#fff;font-weight:700;font-size:26px;display:grid;place-items:center}}
.ic{{width:40px;height:40px;color:var(--km-color-accent)}}
.ic svg{{width:40px;height:40px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:square;stroke-linejoin:miter}}
.meta{{margin-top:36px;font-size:19px;letter-spacing:.06em;text-transform:uppercase;color:var(--km-color-text-dim);font-weight:600}}
h1{{margin-top:14px;font-size:{size}px;line-height:1.06;letter-spacing:-.01em;font-weight:700;text-wrap:balance}}
p{{margin-top:22px;font-size:25px;line-height:1.4;color:var(--km-color-text-muted);text-wrap:pretty}}
.ph{{margin-top:auto;align-self:flex-start;font-size:19px;padding:6px 14px}}
.shot{{padding:56px 0;display:flex;align-items:center;overflow:hidden}}
.shot img{{width:640px;height:auto;max-height:518px;object-fit:cover;object-position:top left;display:block;
border:1px solid var(--km-color-border-section)}}
.tile{{background:var(--km-color-card);display:grid;place-items:center;box-shadow:inset 0 0 0 1px var(--km-color-border-section)}}
.tile span{{color:{p["color"]};font-size:220px;font-weight:700;letter-spacing:-.03em}}
</style><body><div class="l"><div class="top"><div class="kz">{e(p["abbr"])}</div><span class="ic"><svg viewBox="0 0 24 24" aria-hidden="true">{ico}</svg></span></div>
<div class="meta">{e(meta)}</div><h1>{e(p["name"])}</h1><p>{e(p["sub"])}</p>
{f'<span class="ph km-pill km-pill--{p["phase_cls"]}">{e(p["phase"])}</span>' if p["phase"] else ''}</div>{right}</body></html>'''


def main():
    argv = sys.argv[1:]
    dash = os.path.join(ROOT, 'index.html')
    if '--dashboard' in argv:
        i = argv.index('--dashboard'); dash = os.path.abspath(os.path.expanduser(argv[i + 1])); del argv[i:i + 2]
    root = os.path.dirname(dash)
    out_dir = os.path.join(root, 'assets', 'social')
    dry = '--dry' in argv
    args = [a for a in argv if not a.startswith('--')]
    H = open(dash, encoding='utf-8').read()
    kit = ''.join(re.findall(r'<style data-kern-system[^>]*>.*?</style>', H, re.S))
    m = re.search(r'<script type="application/json" id="lucide-icons">(.*?)</script>', H, re.S)
    icons = {k: (v[0] if isinstance(v, list) else v) for k, v in json.loads(m.group(1)).items()} if m else {}
    made, exe = [], None if dry else chrome()
    with tempfile.TemporaryDirectory() as tmp:
        for p in projects(H):
            if args and p['anchor'] not in args:
                continue
            made.append((p['anchor'], p['name'], p['sub'][:60]))
            if dry:
                continue
            out = os.path.join(out_dir, p['anchor'] + '.png')
            src = os.path.join(tmp, p['anchor'] + '.html')
            open(src, 'w', encoding='utf-8').write(page(p, kit, icons, preview(root, p['anchor'])))
            os.makedirs(out_dir, exist_ok=True)
            subprocess.run([exe, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--allow-file-access-from-files',
                            '--force-device-scale-factor=1', '--window-size=1200,630', '--virtual-time-budget=1500',
                            f'--screenshot={out}', 'file://' + urllib.request.pathname2url(src)],
                           check=True, capture_output=True, timeout=90)
            assert os.path.getsize(out) > 5000, out
    for row in made:
        print('IMG ', *row, sep='  ')
    if dry:
        return
    known = {p['anchor'] for p in projects(H)}
    images = {a: f'assets/social/{a}.png' for a in sorted(known) if os.path.exists(os.path.join(out_dir, a + '.png'))}
    a, b = '<script type="application/json" id="social-images">', '</script>'
    if a not in H:
        sys.exit('ERROR: #social-images block missing in index.html')
    i = H.index(a) + len(a)
    j = H.index(b, i)
    H2 = H[:i] + json.dumps(images, ensure_ascii=False, sort_keys=True) + H[j:]
    assert H2.count('<article') == H.count('<article')
    open(dash, 'w', encoding='utf-8').write(H2)
    print(f'{len(made)} images rendered, #social-images: {len(images)} projects')


if __name__ == '__main__':
    main()
