---
workshop_id: "693323B2E7B456F4"
workshop_url: https://reforger.armaplatform.com/workshop/693323B2E7B456F4
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

# HushedWoodlands

> **One-line role**: dampens **2D forest ambient audio** (wind, leaf rustle, generic woodland chatter) so that the iter3 stack's distant-war ambience (`BattlefieldAmbienceMod`) and weapon-suppression audio (`GCSuppression`) can be heard clearly through trees.

## 1. Overview

Per [[golden_state_2026_05_16_v5]] iter3 table: "Forest 2D ambient dampening — orthogonal to existing sound stack". The COE2 stack already has a heavy realism-sound layer (`RealismOverhaulSounds` + the iter3 atmospheric additions); the vanilla wooded-area ambient loops were drowning out the more interesting layered audio. This mod tamps down those loops so the rest of the stack can be heard.

## 2. Functionality / Features

- Reduces 2D ambient audio loudness inside forested areas (does not affect 3D positional audio like weapon fire or footsteps)
- Likely targets specific vanilla audio events tagged "forest" / "woodland"
- Orthogonal to the rest of the audio stack — no overrides, no replacements

## 3. Configuration

**Config files**: likely under `$profile:/HushedWoodlands/` if exposed; unverified pending first boot.

**Tunable keys** (expected — verify after first boot):

| Key | Path | Default | Effect (expected) |
|---|---|---|---|
| `dampeningDb` | `$profile:/HushedWoodlands/<config>.json` | unknown | how many dB the forest 2D loops are attenuated |
| `enabledBiomes` | same | all forest | which biome triggers the dampening |

## 4. Operator usage

**In-game**: passive — automatic dampening in wooded areas. No keybinds.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio/visual overlays) per [[golden_state_2026_05_16_v5]] iter3 table.
- **Must load AFTER**: any mod that defines the woodland ambient loops it targets — i.e. base game audio + `RealismOverhaulSounds`.
- **Must load BEFORE**: nothing.
- **Conflicts with**: nothing known. The mod's description (per the iter3 rationale "orthogonal to existing sound stack") was the gate for its inclusion.
- **Synergies with**: `BattlefieldAmbienceMod`, `GCSuppression` — without HushedWoodlands, the distant-war ambient and suppression flinch audio FX get masked by woodland 2D loops in forested maps (Eden, Kunar). Together the three deliver the audio layering the operator wanted.

## 6. Performance impact

Negligible — audio attenuation is a single-coefficient operation per source.

## 7. Known issues / landmines

- **Possible over-dampening in non-forest biomes** if the trigger logic is map-tag-based rather than per-trigger-zone. Verify by walking into open fields post-boot and checking ambient audio is unaffected.
- **Maps without forest tagging** (urban-only) won't see any effect — mod is a no-op there.

## 8. Extending / modding

_N/A_.

## 9. Changelog / verified state

- **Installed version**: `version: ""`.
- **Declared in `serverconfig-deployed.json`**: yes (iter3 2026-05-15/16).
- **Declared in `serverConfig.json` (local)**: no.
- **Last clean boot**: pre-verification.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/693323B2E7B456F4)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/693323B2E7B456F4/changelog)
- **Companion docs**:
  - `mod_docs/BattlefieldAmbienceMod.md`, `mod_docs/GCSuppression.md`, `mod_docs/AtmosphericWeatherMod.md` — iter3 atmospheric immersion siblings
  - `mod_docs/RealismOverhaulSounds.md` — base audio layer this mod modulates atop
- **Memory references**:
  - `[[golden_state_2026_05_16_v5]]` — iter3 rationale
