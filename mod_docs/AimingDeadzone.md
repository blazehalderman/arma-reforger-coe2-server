---
workshop_id: "684608DD7C7E0DFB"
workshop_url: https://reforger.armaplatform.com/workshop/684608DD7C7E0DFB
version: "1.0.21"
author: "Rayzi_63 (contributor: Tonic)"
load_order_layer: L5
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "648D682E7038491E # ADSSway-Core"
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat"
related_memories: []
folder: "AimingDeadzone_684608DD7C7E0DFB"
---

# AimingDeadzone

> **One-line role**: primitive that lets the weapon move independently of the camera within a configurable deadzone — Arma 3-style aim point separation. Bedrock dep for the entire ADSSway chain.

## 1. Overview

Adds a customizable aiming deadzone so the weapon's aim point can drift inside a configurable cone before the camera follows. The system is **disabled by default** for the player — operators don't need to do anything client-side; the mod's value to this server is being the bottom of the ADSSway chain (every higher mod in L5 hard-deps it). Adapted from Tonic's REST settings system used in the Advanced Zeroing System.

## 2. Functionality / Features

- Configurable deadzone parameters: enable/disable, shape, horizontal/vertical limits, catch-up speed
- Per-client settings persisted between sessions (auto-save)
- No multiplayer balance impact (purely a visual/handling option for the player)
- Foundation for downstream ADSSway-Core sway animations

## 3. Configuration

**Server-side config files**: none. AimingDeadzone is per-client; settings are stored client-side and persisted automatically. Operators do not configure it server-side.

**Player-side**: in-game settings menu (no Workshop documentation of the exact path; the mod's REST system saves automatically).

## 4. Operator usage

_N/A_ — no operator-facing controls. The mod's role here is structural: satisfying the gproj dep chain so ADSSway-Core and BWI-ADSsway-RHS-TAOcompat will register.

## 5. Compatibility & load order

- **Load order layer**: **L5** (sway/aiming chain) per `MASTER_OBJECTIVE.md`.
- **Must load before**: `ADSSway-Core` — declared dep in `ADSSway-Core/addon.gproj` Dependencies (verified). Also a declared dep of `BWI-ADSsway-RHS-TAOcompat/addon.gproj`.
- **Must load after**: base game only.
- **CLAUDE.md DAG fix (verbatim)**: "AimingDeadzone MUST precede ADSSway-Core (gproj-verified 2026-05-14)".
- **Also referenced by CLAUDE.md DAG fix**: "RayziUtils MUST precede ADSSway-Core (gproj-verified 2026-05-14)" — RayziUtils is a sibling primitive in the same author's stack (Rayzi_63).
- **Conflicts with**: no known conflicts on this stack.

## 6. Performance impact

Negligible. Pure client-side handling math; no server tick cost, no RPC churn.

## 7. Known issues / landmines

- None on this stack. The mod has been continuously loaded since 2026-05-12 (added together with the WCS_RHS_Weapons bridge — see CLAUDE.md "RHS attachment fix applied 2026-05-12").

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.21
- **Folder**: `AimingDeadzone_684608DD7C7E0DFB`
- **Workshop last updated**: 2026-04-03
- **Game compat**: 1.6.0.119 (matches server)
- **Last clean boot**: continuously loaded since 2026-05-12

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/684608DD7C7E0DFB)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/684608DD7C7E0DFB/changelog)
- License: Arma Public License No Derivatives (APL-ND)
- Sibling mod: `[[RayziUtils]]` (same author primitive, also gproj-required by ADSSway-Core)
