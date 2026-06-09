---
workshop_id: "6528C95796EBEDE0"
workshop_url: https://reforger.armaplatform.com/workshop/6528C95796EBEDE0
version: "1.0.12"
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
folder: "EnvironmentalAmbienceMod_6528C95796EBEDE0"
---

# EnvironmentalAmbienceMod

> **One-line role**: adds biome-specific ambient sound layers (birds, wind, distant artillery, rustling leaves) for richer environmental audio.

## 1. Overview

Atmospheric audio overlay — drops biome-aware ambient samples (forest birds, urban traffic, desert wind, distant artillery thumps) on top of the engine's default ambience. Independent of the RealismOverhaul suite — they layer rather than conflict.

## 2. Functionality / Features

- Biome-detected ambient sound packs.
- Time-of-day modulation (dawn chorus, dusk insects, night silence).
- Distant-artillery occasional rumble.

## 3. Configuration

_No documented config file._

## 4. Operator usage

Passive.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio overlay).
- **Synergies with**: `[[RealismOverhaulSounds]]` (mixer layers separately), `[[BattlefieldAmbienceMod]]` and `[[HushedWoodlands]]` (deployed-only, V5 iter3) — together form the audio-atmosphere stack.
- **No known conflicts**.

## 6. Performance impact

Audio sample memory; negligible CPU.

## 7. Known issues / landmines

None known. Watch for mixer overlap if you stack many ambient mods + RO-Sounds; the V5 iter3 didn't report new conflicts after adding the deployed-only audio mods.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.0.12
- **Last clean boot**: 2026-05-16

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6528C95796EBEDE0)
- Related audio mods: `[[RealismOverhaulSounds]]`, `[[BattlefieldAmbienceMod]]`, `[[HushedWoodlands]]`, `[[GCSuppression]]`
