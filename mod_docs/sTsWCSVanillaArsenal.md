---
workshop_id: "690EE89CA417ECD8"
workshop_url: https://reforger.armaplatform.com/workshop/690EE89CA417ECD8
version: "1.0.6"
author: "sTs"
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
  - "62A668F513428630 # WCS_Scopes"
  - "69075EC0BD287A6E # sTsRHSVanillaArsenal"
  - "65CF7AE8574E06D2 # WCS_Weapons"
  - "6470FD91F0646126 # WCS_Attachments"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: "sTsWCSVanillaArsenal_690EE89CA417ECD8"
---

# sTsWCSVanillaArsenal

> **One-line role**: bridge mod that merges WCS weapon/scope/attachment entries into the vanilla arsenal/loadout-editor catalogs so WCS guns appear in the stock US/USSR arsenal UI.

## 1. Overview

Companion to `sTsRHSVanillaArsenal`. Where the RHS bridge surfaces RHS content in vanilla arsenal slots, this one does the same for the WCS weapon family (NATO + RU + Weapons + Scopes + Attachments). It edits the inventory-item entity catalogs that the vanilla `SCR_Faction` US/USSR factions consume, appending WCS entries alongside the stock items.

## 2. Functionality / Features

- Appends WCS rifles, optics, suppressors, magazines to the vanilla US and USSR arsenal catalogs.
- Surfaces WCS items in the **WCS Loadout Editor** + **vanilla GM-spawned arsenal entity** + any scenario-provided arsenal box (COE2 surfaces these).
- No tunable knobs — pure content merge mod.

## 3. Configuration

_No config file._ Behavior is entirely encoded in the mod's prefab/catalog assets. The only operator-visible knob is "declared in `serverConfig.json mods[]` or not".

## 4. Operator usage

In-game: open WCS Loadout Editor or any arsenal entity at a player base; WCS items appear in the relevant category tabs alongside vanilla.

## 5. Compatibility & load order

- **Load order layer**: **L10** (arsenal/UI overlay — must run after L1 RHS cores, L3 WCS content, L4 RHS-WCS bridge are loaded).
- **Hard deps (gproj-declared)**: WCS_Scopes, sTsRHSVanillaArsenal, WCS_Weapons, WCS_Attachments. **Note**: it hard-deps `sTsRHSVanillaArsenal` — they are a paired chain, not independent mods.
- **Must load after**: all of L1/L3/L4 (RHS Content, WCS_NATO/RU/Weapons/Scopes/Attachments, WCS_RHS_Weapons).
- **Known regression interaction** (CLAUDE.md "State summary as of 2026-05-16"): together with `All-In-OneArsenals` + `ArsenalItemsallranks` + ACE Dev/stable conflict, contributed to the **cross-faction arsenal regression that triggered the 121-mod → 103-mod revert on 2026-05-14**. The merged-catalog approach overlaps with arsenal entries provided by faction-pack content, and at high mod counts the catalog merger produced wrong-faction items in arsenal tabs. The rollback baseline is snapshot `state_snapshots/2026-05-14_21-35-46_pre-deployment-cleanup-2026-05-14`.

## 6. Performance impact

Catalog merge happens once at scenario init — no per-tick cost. Boot-time impact is a handful of extra prefab loads (already in WCS dep chain).

## 7. Known issues / landmines

**Cross-faction arsenal regression** (2026-05-14): see § 5 above. If after enabling this mod you see WCS items leaking into faction tabs that shouldn't have them (DarkGru/Arma2 factions getting US gear etc.), this is the smoking-gun mod. Mitigation in V5 was to revert the 121-mod state and pin to the 103-mod baseline. The mod remains *declared* in the current local + deployed config but is **suspect-flagged** — investigate first if arsenal weirdness recurs. Cross-ref `[[golden_state_2026_05_16_v5]]` memory.

**Tight dep chain**: removing this without also removing `sTsRHSVanillaArsenal` will break the RHS bridge's reverse-dep expectation; either keep the pair or remove the pair.

## 8. Extending / modding

_N/A_ — content mod, no extension points.

## 9. Changelog / verified state

- **Installed version**: 1.0.6
- **Folder**: `profile_new/addons/sTsWCSVanillaArsenal_690EE89CA417ECD8`
- **Last clean boot**: 2026-05-16 (golden state V5; suspect-flagged per regression history)
- **Snapshot before any change**: `state_snapshots/2026-05-14_21-35-46_pre-deployment-cleanup-2026-05-14` is the safe rollback point.

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/690EE89CA417ECD8)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/690EE89CA417ECD8/changelog)
- `CLAUDE.md` § "State summary as of 2026-05-16 (golden state V5 — local + deployed split)" — regression history
- `[[golden_state_2026_05_16_v5]]` memory — current baseline + arsenal-trio regression notes
- Paired mod: `[[sTsRHSVanillaArsenal]]`
