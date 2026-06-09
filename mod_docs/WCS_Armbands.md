---
workshop_id: "61E42AE6714A3CC2"
workshop_url: https://reforger.armaplatform.com/workshop/61E42AE6714A3CC2
version: "6.0.1"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L3
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Armbands_61E42AE6714A3CC2"
---

# WCS_Armbands

> **One-line role**: adds a dedicated armband slot to the UI + color-coded armband inventory items for US/USSR/FIA faction PID (positive identification) during firefights.

## 1. Overview

`WCS_Armbands` is a **small QoL content mod** addressing a perennial Reforger problem: friendly-fire incidents from poor PID at distance. It adds a dedicated armband equipment slot (separate from gloves/clothing) and ships color-coded armband prefabs for the US, USSR, and FIA factions. Players equip an armband in the new slot via WCS_Arsenal; the armband renders on the upper arm of the wearing character at all ranges (cheap silhouette tell).

Zero non-base deps — completely standalone. 1.4M downloads, 84% rating; clearly a popular QoL.

## 2. Functionality / Features

- New dedicated **Armband equipment slot** in the inventory UI
- US-faction armband inventory item
- USSR-faction armband inventory item
- FIA-faction armband inventory item
- Color-coded for at-distance ID
- Localization in 12+ languages (per gproj)

## 3. Configuration

**Config files**: none in `$profile:/`.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**:
- Players open WCS arsenal → Armband category
- Select faction-appropriate armband (US / USSR / FIA)
- Equip in the dedicated Armband slot
- Visible on character upper arm at all ranges

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: [[WCS_Arsenal]] (gproj reverse-dep).
- **Must load after**: base game only.
- **Conflicts with**: nothing in current stack. Note: this is one of the WCS_Arsenal hard-deps — purging it breaks the arsenal.
- **Synergies with**: [[WCS_Clothing]] (parallel wearable system; armband renders on top of clothing).

## 6. Performance impact

Zero. Tiny content mod (armband meshes + 3 prefabs).

## 7. Known issues / landmines

- **Hard-depped by [[WCS_Arsenal]]** — do not purge without audit per [[CLAUDE.md]] §"Mod purge safety protocol".
- **Only 3 factions supported out-of-box** (US, USSR, FIA) — DarkGru/Arma2/PMC characters have no armband options. Modded-faction armbands would require a fork of this mod.
- No version-pin landmines known.

## 8. Extending / modding

To add armbands for a modded faction (e.g. DarkGru): fork this mod in Workbench, copy the US armband prefab, replace the texture with the target faction's color/insignia, register it in a new `InventoryItem` prefab. ~1 h per faction. Not currently done in this stack.

## 9. Changelog / verified state

- **Installed version**: 6.0.1 (Workshop current as of 2026-05-05)
- **Folder**: `WCS_Armbands_61E42AE6714A3CC2`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/61E42AE6714A3CC2) — 84% rating, 1.4M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/61E42AE6714A3CC2/changelog)
- [[CLAUDE.md]] §"Mod purge safety protocol" — required dep audit
- Companion: [[WCS_Arsenal]] (consumer), [[WCS_Clothing]] (parallel wearable)
