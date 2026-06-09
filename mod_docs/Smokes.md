---
workshop_id: "65D050C86106E5BC"
workshop_url: https://reforger.armaplatform.com/workshop/65D050C86106E5BC
version: "2.1.4"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "5D0551624969C92E # ZeliksCharacter"
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "SmokeableSmokes_65D050C86106E5BC"
---

# Smokes

> **One-line role**: adds smokeable cigarette / cigar items with light-up animation and visible exhale plume.

## 1. Overview

Cosmetic / immersion mod — adds inventory items for cigarettes and cigars with a light-up animation, idle smoke trail, and exhale particle. Hard-deps `ZeliksCharacter` for the animation rig hook.

## 2. Functionality / Features

- Smokeable inventory items (multiple variants).
- Light-up + idle smoke animation.
- Visible exhale plume (other players see it too).

## 3. Configuration

_No config file._

## 4. Operator usage

Player-facing — equip the item from inventory, use the action.

## 5. Compatibility & load order

- **Load order layer**: **L10** (cosmetic overlay).
- **Hard-deps**: `[[ZeliksCharacter]]` (L0 framework).
- **No known conflicts**.

## 6. Performance impact

Per-active-smoker particle cost; negligible.

## 7. Known issues / landmines

None known.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 2.1.4
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/65D050C86106E5BC)
- Hard-depped: `[[ZeliksCharacter]]`
