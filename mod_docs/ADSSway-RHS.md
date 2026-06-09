---
workshop_id: "656B3A0955474CB7"
workshop_url: https://reforger.armaplatform.com/workshop/656B3A0955474CB7
version: "1.0.9"
author: "Rayzi_63"
load_order_layer: L5
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "BADC0DEDABBEDA5E # RHS_Content_02"
  - "1337C0DE5DABBEEF # RHS_Content_01"
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "58D0FB3206B6F859 # base game"
  - "648D682E7038491E # ADSSway-Core"
reverse_deps:
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat (referenced via dep chain; not direct dep)"
related_memories: []
folder: "ADSSway-RHS_656B3A0955474CB7"
---

# ADSSway-RHS

> **One-line role**: the RHS compatibility patch for the ADSSway sway/recoil overlay — applies ADSSway-Core's handling behavior to every weapon shipped by RHS Status Quo. Pure compat shim, no standalone content.

## 1. Overview

Bridges the Rayzi_63 ADSSway system to the RHS weapon catalog. Without this, RHS rifles fall back to vanilla engine handling and the player gets no sway/recoil overlay on M16/AK/SVD/etc. With it, RHS weapons inherit the same animation curves ADSSway-Core applies to base-game weapons. Workshop description: "Compatibility mod" for RHS.

## 2. Functionality / Features

- Applies ADSSway-Core sway and recoil curves to RHS weapons
- No standalone weapons, attachments, or configs — purely a compat layer
- Required for the BWI-ADSsway-RHS-TAOcompat bridge to function on RHS guns

## 3. Configuration

**Server-side config files**: none. Behavior is per-weapon, baked into the mod's prefab overrides.

## 4. Operator usage

_N/A_

## 5. Compatibility & load order

- **Load order layer**: **L5** (sway/aiming chain) per `MASTER_OBJECTIVE.md`.
- **Must load before**: `BWI-ADSsway-RHS-TAOcompat` — the BWI bridge sits at the top of the L5 chain.
- **Must load after** (per `addon.gproj` Dependencies, all verified on disk):
  - `RHS_Content_01` (`1337C0DE5DABBEEF`) — placeholder GUID; the actual RHS content packs are declared in `mods[]`
  - `RHS_Content_02` (`BADC0DEDABBEDA5E`) — placeholder GUID
  - `RHS_Status_Quo` (`595F2BF2F44836FB`)
  - `ADSSway-Core` (`648D682E7038491E`)
- **CLAUDE.md DAG chain (verbatim)**: "ADSSway-Core → ADSSway-RHS → BWI-ADSsway-RHS-TAOcompat (bridge chain)".
- **Conflicts with**: no known conflicts on this stack.

## 6. Performance impact

Negligible. Per-weapon prefab override; no runtime tick cost.

## 7. Known issues / landmines

- Workshop page lists `ADSSway - PIP DOF - TEST` and `Rayzi Utils` and `Aiming Deadzone` as dependencies but the mod's `addon.gproj` only declares the 5 hard-deps above. The PIPDOF / RayziUtils / AimingDeadzone deps resolve via the transitive chain through `ADSSway-Core`'s gproj.
- 2026-05-12 RHS attachment fix (CLAUDE.md) added this mod and its sister mods to `serverConfig.json mods[]` because the bridge had been downloaded on disk but never declared. Symptom was "RHS weapons spawn but attachments are useless" — see CLAUDE.md "RHS attachment fix applied 2026-05-12" verbatim for the full causal chain.

## 8. Extending / modding

_N/A_ — to extend ADSsway coverage to another weapon pack (e.g. WCS_NATO), a new `ADSSway - <pack>` compat mod must be authored. Operators don't config this.

## 9. Changelog / verified state

- **Installed version**: 1.0.9
- **Folder**: `ADSSway-RHS_656B3A0955474CB7`
- **Game compat**: 1.6.0.119
- **Workshop last updated**: 2026-03-01
- **Last clean boot**: continuously loaded since 2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/656B3A0955474CB7)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/656B3A0955474CB7/changelog)
- License: Arma Public License (APL)
- Required dep: `[[ADSSway-Core]]`
- Downstream consumer: `[[BWI-ADSsway-RHS-TAOcompat]]`
- Related: CLAUDE.md "RHS attachment fix applied 2026-05-12"
