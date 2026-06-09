---
workshop_id: "59A30ACC02650E71"
workshop_url: https://reforger.armaplatform.com/workshop/59A30ACC02650E71
version: "1.1.28"
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
folder: "NightVisionSystem_59A30ACC02650E71"
---

# NIGHTVISION

> **One-line role**: implements toggleable NVG / thermal optics with Gen-tiered fidelity for player and AI use.

## 1. Overview

The de facto NVG mod for the Reforger modding scene. Adds toggleable night-vision goggles with multiple generation tiers (Gen 1-3, ANVPS-14, ENVG-B with overlay HUD elements), white-phosphor vs green-phosphor variants, and supports AI use as well. Pairs with `[[DarkerNights]]` and `[[RealismOverhaulLighting]]` for the full night-fighting experience.

## 2. Functionality / Features

- NVG prefabs with multiple generation/quality tiers.
- White / green phosphor toggle.
- Thermal optics variants.
- AI can use NVGs at night (faction-equipment-dependent).
- Player toggle via NVG keybind (engine default `N`).

## 3. Configuration

_No documented config file._

## 4. Operator usage

Players need an NVG item in inventory; toggle via `N` (default). Arsenal-add via WCS Loadout Editor or BLE.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **Co-equips with**: `[[DarkerNights]]` (the canonical pairing), `[[RealismOverhaulLighting]]`.
- **No known conflicts** with current stack.

## 6. Performance impact

Per-equipped-NVG post-process pass. GPU-side only.

## 7. Known issues / landmines

None observed in V5. Older revisions had some AI-NVG-vision-distance bugs; current 1.1.28 is the stable version.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.1.28
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/59A30ACC02650E71)
- Co-equips: `[[DarkerNights]]`, `[[RealismOverhaulLighting]]`
