---
workshop_id: "64ED6553B8AF6B62"
workshop_url: https://reforger.armaplatform.com/workshop/64ED6553B8AF6B62
version: ""
author: ""
load_order_layer: L10
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps: []
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# AtmosphericWeatherMod

> **One-line role**: adds **dynamic weather cycling** (clear → overcast → rain → fog → clear, etc.) — chosen for iter3 because `RealismOverhaul-Weather` only tunes static weather and doesn't cycle.

## 1. Overview

Per CLAUDE.md § "State summary 2026-05-16 V5" iter3 table verbatim: "AtmosphericWeatherMod: dynamic cycling (RealismOverhaul-Weather is static-tuning only)". Added to the deployed iter3 stack to introduce weather variety over a mission's duration (front-passing, rain windows, fog banks) rather than the static "one weather state per session" the RO-Weather tuning produces.

## 2. Functionality / Features

- **Dynamic weather transitions** during a session (sunny → cloudy → rain → clear, etc.)
- Likely configurable transition intervals + biome biases (typical of weather-overlay mods)
- Visual sync (clouds, precipitation, fog) + likely audio sync (rain ambient)
- Compatible with engine-level weather settings tab in scenario menu

## 3. Configuration

**Config files**: likely under `$profile:/AtmosphericWeatherMod/` once the mod boots once on deployed and writes its defaults. Path unverified pending first boot.

**Tunable keys** (expected based on category-typical weather mods — verify after first boot):

| Key | Path | Default | Effect (expected) |
|---|---|---|---|
| `transitionIntervalMin` | `$profile:/AtmosphericWeatherMod/<config>.json` | unknown | minutes between weather state changes |
| `enabledStates` | same | all | which weather states the cycle picks from |
| `precipitationProbability` | same | unknown | weight for rain vs clear |

Verify these by reading the config file after the first deployed boot.

## 4. Operator usage

**In-game**:
- Pass-through to engine weather: shows up in the scenario menu's Weather tab. Per [[golden_state_2026_05_16_v5]] verification gate #7: "Weather settings tab: dynamic transitions enabled".
- No GM keybinds — weather happens automatically.
- Game Master can still override the current state via the GM Time/Weather panel; the mod resumes cycling from whatever GM set.

**Keybinds / admin**: none mod-specific.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio/visual overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: `RealismOverhaulWeather` if both are present — AtmosphericWeather is the dynamic-cycling consumer; RO-Weather tunes the static parameter baseline. At L10 the order is the same layer; load-order array position resolves tiebreaker.
- **Must load BEFORE**: nothing currently known.
- **Conflicts with**: any OTHER dynamic-weather mod (only run one cycling overlay). RO-Weather is **static-tuning only** so no conflict.
- **Synergies with**: `RealismOverhaulLighting`, `RealismOverhaulEffects` — visual immersion stack; `BattlefieldAmbienceMod` + `HushedWoodlands` — atmospheric immersion bundle this is part of.

## 6. Performance impact

Weather overlays are typically cheap (interpolation work, no per-tick scripts on AI). No measured impact in this stack — verify against deployed monitor.

## 7. Known issues / landmines

- **Layer/order with RO-Weather not authoritatively verified** — if scenarios load with static weather and no cycling, RO-Weather may be overriding this mod's runtime cycle. Move AtmosphericWeatherMod **later** in the mods[] array than RO-Weather to win the tiebreaker (per CLAUDE.md § "Mod stack architecture" — "mods[] array order is the tiebreaker for symbol overrides").
- Rain particles can elevate GPU load on low-end clients but server-side impact is negligible.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification — gate #7 is "Weather settings tab: dynamic transitions enabled" per [[golden_state_2026_05_16_v5]].

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/64ED6553B8AF6B62)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64ED6553B8AF6B62/changelog)
- **Companion docs**:
  - `mod_docs/RealismOverhaulWeather.md` — static-tuning baseline this mod cycles over
  - `mod_docs/BattlefieldAmbienceMod.md`, `mod_docs/HushedWoodlands.md`, `mod_docs/GCSuppression.md` — iter3 atmospheric immersion siblings
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + verification gate #7
