---
id: DEMO-001
title: "Migrate typography tokens to fluid scale"
status: open
priority: high
project: nova-fluid-type
created: 2026-07-10
summary: "Define clamp() values for all 9 font-size steps across breakpoints"
---

# Migrate typography tokens to fluid scale

The breakpoint jump (19px to 21px at 992px) goes away; every step gets a `clamp()` value.

## Steps

- [ ] Agree on the two type scales (mobile 1.1, desktop 1.2)
- [ ] Generate the 9 steps with Utopia (320px to 1200px viewport)
- [ ] Replace the font-size tokens, keep the old names as aliases for one release
- [ ] Check text zoom at 200% (WCAG 1.4.4)

## Notes

Line heights stay unitless. The demo page with the viewport viewer is the review surface for stakeholders.
