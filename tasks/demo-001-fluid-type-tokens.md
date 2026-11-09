---
id: DEMO-1
title: "Migrate type tokens to the fluid scale"
status: open
status_note: ""
priority: high
project: nova-fluid-type
due: "in 4 days"
created: 2026-11-02
summary: "Define clamp() values for all nine font-size steps and keep the old names as aliases."
next: "Generate the steps for 320 to 1200 px."
---

# Migrate type tokens to the fluid scale

The breakpoint jumps in the type scale go away; every step gets a `clamp()` value.

## Steps

- [ ] Agree on the two type scales (1.1 on mobile, 1.2 on desktop)
- [ ] Generate the nine steps for a 320 to 1200 px viewport
- [ ] Replace the font-size tokens, keep the old names as aliases for one release
- [ ] Check text zoom at 200 % (WCAG 1.4.4)

## Notes

Line heights stay unitless. The test page with the viewport slider is the review surface for the product teams.
