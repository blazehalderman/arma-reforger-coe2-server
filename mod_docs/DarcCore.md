---
workshop_id: "631EE12D448D7FCC"
workshop_url: https://reforger.armaplatform.com/workshop/631EE12D448D7FCC
version: "1.0.137"
author: "darc_"
load_order_layer: L0
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "689EDED542F881AF # DarcChopper"
related_memories: []
folder: "DarcCore_631EE12D448D7FCC"
---

# DarcCore

> **One-line role**: foundational library for the Darc mod family ("Core for mods by Darc") — consumed by DarcChopper and other Darc content.

## 1. Overview

DarcCore by darc_ is described on the Workshop page as a "Core for mods by Darc" — a shared library underpinning the Darc mod ecosystem. In this stack it is depended on by `DarcChopper` (`689EDED542F881AF`), which is the heli AI-flying framework. Licensed APL-ND. CLAUDE.md "Mod purge safety protocol" example dep chain explicitly notes: *"DarcCore ← DarcChopper. Darc mod family dep."*

## 2. Functionality / Features

- Shared scripts for Darc family mods (DarcChopper, and presumably DarcChopperExample / compat shims)
- No standalone gameplay surface
- License APL-ND — no derivatives

## 3. Configuration

_N/A_ — no `profile_new/profile/DarcCore/` directory exists. Note: Darc mods do write to `profile_new/profile/DarcMods/` (e.g., `dc_coreConfig.json`, `dc_enemyList.json`, `dc_vehicleList.json` per CLAUDE.md "SDRC framework" section), but that directory is owned by `SHSScenarioFramework`/SDRC, not DarcCore proper.

## 4. Operator usage

Not directly consumed. Its sole reverse-dep in this stack is `DarcChopper`, which the operator uses via Game Master (see `mod_docs/DarcChopper.md` §4).

## 5. Compatibility & load order

- **Load order layer**: **L0** per CLAUDE.md (L0 list explicitly names `DarcCore`).
- **Must load before**: `DarcChopper` (L9). DAG-resolved via DarcChopper's gproj.
- **Conflicts with**: none documented.

## 6. Performance impact

Negligible — pure library.

## 7. Known issues / landmines

- **Transitive-dep declaration caveat** cited from `mod_docs/DarcChopper.md` §7: *"DarcCore (`631EE12D448D7FCC`) is on disk but not in mods[]"* — this was the state earlier. **Currently DarcCore IS declared in serverConfig.json `mods[]`** per its `declared_in: [local, deployed]` frontmatter and CLAUDE.md L0 enumeration. If anyone refers to the old DarcChopper doc claim of transitive-only status, refresh against the live serverConfig.json.
- **Dep-chain protection**: CLAUDE.md "Mod purge safety protocol" example chain — *"DarcCore ← DarcChopper. Darc mod family dep."* — purging DarcCore breaks DarcChopper. **Do not purge.**

## 8. Extending / modding

_N/A_ — silent library; no public API documented. See `mod_docs/DarcChopper.md` §8 for Workbench compat-shim procedures that use DarcCore + DarcChopper together.

## 9. Changelog / verified state

- **Installed version**: 1.0.137
- **Folder**: `DarcCore_631EE12D448D7FCC`
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/631EE12D448D7FCC)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/631EE12D448D7FCC/changelog)
- Author: darc_
- See also: `mod_docs/DarcChopper.md` (primary depender), [github.com/mokdevel/DarcMods](https://github.com/mokdevel/DarcMods)
