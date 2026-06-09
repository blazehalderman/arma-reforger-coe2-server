---
workshop_id: "655B341B90518659"
workshop_url: https://reforger.armaplatform.com/workshop/655B341B90518659
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

# BattlefieldAmbienceMod

> **One-line role**: location-triggered ambient battlefield audio — distant artillery, distant gunfire, vehicle rumble — that replaces vanilla scenario ambient music with immersive war sounds.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Distant war sounds at locations — replaces vanilla ambient music". One of three iter3 atmospheric immersion mods (alongside `HushedWoodlands` and `GCSuppression`) added to give COE2 the production-grade "world feels at war" audio backdrop that the vanilla scenario lacks.

## 2. Functionality / Features

- Plays distant battlefield audio loops (artillery thuds, far gunfire, distant explosions, vehicle engine rumble) that fade in when players enter specific map locations
- Replaces or supplements vanilla scenario ambient music with these loops
- Likely runtime-configurable trigger volumes and per-location loop selection
- No effect on gameplay damage/AI — pure audio overlay

## 3. Configuration

**Config files**: likely under `$profile:/BattlefieldAmbienceMod/` once the mod boots on deployed. Path unverified pending first boot.

**Tunable keys** (expected based on category-typical ambient overlays — verify after first boot):

| Key | Path | Default | Effect (expected) |
|---|---|---|---|
| `masterVolume` | `$profile:/BattlefieldAmbienceMod/<config>.json` | unknown | top-level loudness |
| `enabledLocations` | same | all | per-map opt-in/opt-out |
| `replaceVanillaMusic` | same | true | whether to silence vanilla music while ambient plays |

Read post-boot to confirm actual schema.

## 4. Operator usage

**In-game**: passive — audio plays automatically when players enter trigger zones. No keybinds.

**Volume/disable**: via the config file once a player or operator complains; otherwise leave default.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio/visual overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: nothing required.
- **Must load BEFORE**: nothing required.
- **Conflicts with**: any other "battlefield ambience" overlay (only run one). The existing `EnvironmentalAmbienceMod` may overlap — verify on first boot whether both fire simultaneously and de-duplicate if so.
- **Synergies with**: `HushedWoodlands` (forest 2D dampening), `GCSuppression` (suppression flinch/audio FX), `AtmosphericWeatherMod` (weather audio sync) — full iter3 atmospheric immersion stack.

## 6. Performance impact

Audio overlays are typically cheap (one looping audio source per active trigger zone). Negligible server-side. Client GPU/CPU impact also negligible.

## 7. Known issues / landmines

- **Possible overlap with `EnvironmentalAmbienceMod`** — if both play simultaneously, audio mix becomes muddy. Test post-boot and disable one if so.
- **Vanilla music replacement** can be jarring if the operator preferred the vanilla soundtrack. Per the config (if exposed), set `replaceVanillaMusic` to false to additive-mix instead.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification — gate #5 in [[golden_state_2026_05_16_v5]] is "New atmospheric mod activity: BattlefieldAmbience location triggers + GCSuppression flinch events".

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/655B341B90518659)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/655B341B90518659/changelog)
- **Companion docs**:
  - `mod_docs/HushedWoodlands.md`, `mod_docs/GCSuppression.md`, `mod_docs/AtmosphericWeatherMod.md` — iter3 atmospheric immersion siblings
  - `mod_docs/EnvironmentalAmbienceMod.md` — potential overlap
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale + verification gate #5
