---
workshop_id: "5F340B3613F49010"
workshop_url: https://reforger.armaplatform.com/workshop/5F340B3613F49010
version: "1.0.5"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "DarkerNights_5F340B3613F49010"
---

# DarkerNights

> **One-line role**: deepens night brightness curves so dark = actually dark.

## 1. Overview

Single-purpose lighting override that pushes night-time exposure / ambient floor lower than vanilla, so NVGs become genuinely necessary and unaided navigation is hard. Co-equips well with `[[NIGHTVISION]]` for the canonical "real darkness + functional NVGs" pairing.

## 2. Functionality / Features

- Night ambient floor + moonlight contribution reduced.
- Indoor / cave dimming amplified.

## 3. Configuration

_No config file._

## 4. Operator usage

Passive.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **Co-equips with**: `[[NIGHTVISION]]` (NVGs become essential), `[[RealismOverhaulLighting]]` (stacks with deeper shadow curves).
- **No known conflicts**.

## 6. Performance impact

Zero — exposure curve tweak only.

## 7. Known issues / landmines

Without NVGs, night gameplay can be unplayable for players who haven't equipped them; consider in-game MOTD reminder.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.0.5
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/5F340B3613F49010)
- Co-equips: `[[NIGHTVISION]]`, `[[RealismOverhaulLighting]]`
