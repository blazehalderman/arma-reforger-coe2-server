---
workshop_id: "59822DF3A86DA197"
workshop_url: https://reforger.armaplatform.com/workshop/59822DF3A86DA197
version: "1.0.2"
author: "Ashyl"
load_order_layer: L10
status: active
last_verified: 2026-05-17
declared_in:
  - local
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories: []
folder: "BetterCasings_59822DF3A86DA197"
---

# BetterCasings

> **One-line role**: replaces vanilla flat-sprite casing ejects with 3D physics-meshed shell casings that bounce + roll on the ground.

## 1. Overview

Ashyl's smallest and oldest mod (15 KB, 09.12.2022, 93% rating, 7.5k subscribers). Replaces the vanilla casing eject particle with a physics body — casings tumble, bounce off surfaces, roll on slopes. Immersion polish, no gameplay change.

Installed 2026-05-17 as the only Ashyl mod with zero surface conflict in the live stack.

## 2. Functionality / Features

- 3D physical casings (with mesh + collision) replace flat-sprite casings.
- Casings auto-despawn (timing not verified — typical implementations use ~10 sec).

## 3. Configuration

_No config file._ Casing eject behavior is global.

## 4. Operator usage

Passive — visible automatically when any weapon fires.

## 5. Compatibility & load order

- **Load order layer**: **L10** (audio-visual overlay).
- **No known conflicts** — no existing stack mod overrides casing eject visuals. `[[WCS_Sounds]]` handles eject *audio* but not visuals.
- **Caveat**: 3-year-old code (2022). May not cover casing eject points on weapons that didn't exist in 2022 (some `[[RHS_Status_Quo]]` and `[[WCS_Weapons]]` additions). If a weapon shows no casing eject post-install, that's a "covered weapon list" gap, not a runtime fault.

## 6. Performance impact

Per-shot physics body. On AI-dense MG fire (100+ AI under CRX `Formation_Scale=2.0`), casings can pile up. Mitigation: despawn timing (presumed ~10s). Boot test 2026-05-17 boot 8 showed no regression at idle.

## 7. Known issues / landmines

- **3-year staleness** (2022 build). The cheap-experiment recommendation from the eval gate: if a weapon's casings look broken or invisible, that's the staleness manifesting — easy rollback via snapshot.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.2
- **Folder**: `profile_new/addons/BetterCasings_59822DF3A86DA197`
- **Last clean boot**: 2026-05-17 boot 8 (GAME at 15:13:02, arsenal 6689)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/59822DF3A86DA197)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/59822DF3A86DA197/changelog)
- Related: `[[BHE_EXP]]`, `[[Shrapnel]]` (same author family)
