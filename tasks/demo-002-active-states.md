---
id: DEMO-2
title: "Audit active states in ten components"
status: blocked
status_note: "waiting for the design review of the tab component"
priority: medium
project: helix-typography
due: "waiting"
created: 2026-10-28
summary: "Ten components need token-based active states with WCAG AA contrast."
next: "Wait for the design review of the tab component."
---

# Audit active states in ten components

Active and selected states are hard-coded in ten components and differ in color and weight.

## Steps

- [ ] List the active and selected states per component
- [ ] Map each state to a token
- [ ] Check contrast against WCAG AA (3:1 for UI, 4.5:1 for text)
- [ ] Update the components after the design review

## Notes

The tab component sets the pattern for the others, so it goes first.
