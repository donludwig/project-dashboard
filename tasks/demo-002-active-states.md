---
id: DEMO-002
title: "Component audit for consistent active states"
status: active
priority: medium
project: helix-typography
created: 2026-07-18
summary: "10 components need token-based active state styling with WCAG AA contrast"
---

# Component audit for consistent active states

Active states are styled per component today, with hard-coded colors in three places.

## Scope

- Tabs, segmented control, pagination, nav items, chips, toggle buttons
- One semantic token pair: `--state-active-bg` / `--state-active-text`
- Contrast: 4.5:1 for text, 3:1 for the state indicator against adjacent colors

## Open question

Does the active state need a non-color cue everywhere (underline, weight), or only where color is the single difference?
