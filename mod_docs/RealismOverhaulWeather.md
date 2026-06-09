---
workshop_id: "64AB5D83872CCF87"
workshop_url: https://reforger.armaplatform.com/workshop/64AB5D83872CCF87
version: "1.6.1"
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
folder: "RealismOverhaul-Weather_64AB5D83872CCF87"
---

# RealismOverhaulWeather

> **One-line role**: static weather/atmosphere tuning — overcast curves, fog density, precipitation visuals.

## 1. Overview

Weather quarter of the RealismOverhaul suite. **Static-tuning only** — adjusts the visual fidelity of weather states the engine produces but does NOT add a dynamic cycle. For dynamic weather cycling the V5 iter3 added the separate `[[AtmosphericWeatherMod]]` (deployed-only) per CLAUDE.md.

## 2. Functionality / Features

- Retuned overcast / cloud rendering.
- Heavier fog density curves.
- Improved rain particle look and surface wetness.
- Snow visuals (where the map supports it).

## 3. Configuration

_No config file._

## 4. Operator usage

Passive — weather still controlled by scenario / GM, but the visuals are richer when active.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **Synergies with**: `[[AtmosphericWeatherMod]]` (deployed-only) — that mod drives the dynamic *transitions*, this mod controls how the resulting weather looks/feels. Co-deploy.
- **Suite siblings**: `[[RealismOverhaulEffects]]`, `[[RealismOverhaulLighting]]`, `[[RealismOverhaulSounds]]`.
- **No known conflicts**.

## 6. Performance impact

Particle/shader tuning only — no measurable cost.

## 7. Known issues / landmines

**Static, not dynamic** — operators expecting a weather cycle out of this mod will be disappointed. The V5 iter3 deployed-only `AtmosphericWeatherMod` is what gives you cycling weather; this mod just makes whatever weather the engine picks look better.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: 1.6.1
- **Folder**: `profile_new/addons/RealismOverhaul-Weather_64AB5D83872CCF87`
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/64AB5D83872CCF87)
- Suite siblings: `[[RealismOverhaulEffects]]`, `[[RealismOverhaulLighting]]`, `[[RealismOverhaulSounds]]`
- Dynamic-weather companion: `[[AtmosphericWeatherMod]]`
- `CLAUDE.md` § "Iter3 additive fixes" — dynamic weather added separately
