---
workshop_id: "6632F94B46173164"
workshop_url: https://reforger.armaplatform.com/workshop/6632F94B46173164
version: "1.0.12"
author: "Rayzi_63 (contributor: Tonic)"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "6608FD6F58F3B90A # <undeclared>"
  - "663A654A6BB0AEA4 # BWI-ADSsway-RHS-TAOcompat"
related_memories: []
folder: "RayziUtils_6632F94B46173164"
---

# RayziUtils

> **One-line role**: shared utility library by Rayzi_63 (with Tonic), pulled in by the ADSSway / BWI weapon-handling chain.

## 1. Overview

RayziUtils is a small utility framework. The Workshop description is sparse — literally just "Utils" — but its high adoption (94% rating, 752K+ downloads at fetch time) implies it provides commonly-needed primitives reused across multiple weapons-handling and overlay mods. In this stack it is a hard-dep of `BWI-ADSsway-RHS-TAOcompat` (and another undeclared mod), making it an obligatory load for the ADS-sway weapon-immersion chain.

## 2. Functionality / Features

- Generic helper scripts (specifics not documented on Workshop page)
- License: Arma Public License — No Derivatives (APL-ND)
- Acts as common dependency for weapon-handling overlays (BWI / ADSSway chain)

## 3. Configuration

_N/A_ — no `profile_new/profile/RayziUtils/` directory exists.

## 4. Operator usage

Not directly consumed. Its value enters the stack transitively through the BWI 2.8 + ADSSway-RHS bridge chain that controls weapon sway/aim handling.

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `RayziUtils`).
- **Must load before**: ADSSway-Core (CLAUDE.md DAG fix #5: "RayziUtils MUST precede ADSSway-Core (gproj-verified 2026-05-14)"), and transitively BWI-ADSsway-RHS-TAOcompat (L5/L10 weapon-sway chain).
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure library.

## 7. Known issues / landmines

- **DAG ordering constraint** (cited verbatim from CLAUDE.md "DAG fixes" list): *"5. RayziUtils MUST precede ADSSway-Core (gproj-verified 2026-05-14)"* — already satisfied by L0 placement of RayziUtils vs L5 placement of ADSSway-Core. Do not move RayziUtils later in `mods[]`.

## 8. Extending / modding

_N/A_ — silent library; no public API documented on Workshop page.

## 9. Changelog / verified state

- **Installed version**: 1.0.12
- **Folder**: `RayziUtils_6632F94B46173164`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6632F94B46173164)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6632F94B46173164/changelog)
- Author: Rayzi_63 (contributor: Tonic)
