---
workshop_id: "66E9222820080A19"
workshop_url: https://reforger.armaplatform.com/workshop/66E9222820080A19
version: "1.0.19"
author: "CMinano98 2.0"
load_order_layer: L6
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
reverse_deps: []
related_memories: []
folder: "DarkGruFactions_66E9222820080A19"
---

# DarkGruFactions

> **One-line role**: faction pack adding NATO, CSAT, and VEPR factions plus the DarkGru-branded unit families (Tactical Turtlenecks, Сerафимы, Spectre Bravo PMC, WMD Elite Forces) that the DarkGru-MPP-Camos overlay reskins.

## 1. Overview

Ships three top-level factions (NATO, CSAT, VEPR) along with the unit prefab families consumed by DarkGru's Milsim Partnership Program — these are the prefabs that `DarkGruMPPCamos-GRS` adds camos to. The Workshop description is sparse ("Adds NATO, CSAT, and VEPR Factions"). On this server the faction pack is one of two L6 faction sources used by COE2's runtime string-key faction picker.

## 2. Functionality / Features

- **Top-level factions added** (per Workshop): NATO, CSAT, VEPR
- **Unit families** (per DarkGruMPPCamos-GRS Workshop description, which reskins these): Tactical Turtlenecks (Tier 3), Сerафимы (Tier 2), Spectre Bravo PMC (Tier 2), WMD Elite Forces (Tier 2)
- Pulled at runtime by COE2 when the operator picks one of these factions as the enemy in the COE2 scenario menu
- No standalone scenario / mission; pure content pack

## 3. Configuration

**Server-side config files**: none in `profile_new/profile/`. Faction selection happens at COE2 scenario boot via the in-game picker, not via a JSON config.

## 4. Operator usage

- **In-game (COE2)**: at scenario start, open the COE2 params menu and select a DarkGru faction as the enemy (or as a player faction if the COE2 mission supports it).
- **In-game (Game Master)**: spawn DarkGru units from Entity Browser → search "DarkGru" or one of the unit-family names.

## 5. Compatibility & load order

- **Load order layer**: **L6** (faction packs) per `MASTER_OBJECTIVE.md`. Sibling in L6: `Arma2Factions`. CLAUDE.md verbatim: "**L6** Faction packs (DarkGruFactions, Arma2Factions only — PMC chain and Misfits blocked 2026-05-14)".
- **Must load after**: nothing in this stack — gproj declares only the base game as a hard dep, so registration is order-tolerant. Layer placement is for symbol-override tiebreaker discipline.
- **Must load before**: L7 apparel/camo overlays that reskin DarkGru units — specifically `DarkGruMPPCamos-GRS` (which gproj-deps `GRS-Apparel` and ZeliksCharacter, NOT DarkGruFactions directly — so registration won't fail, but the camo overlay is meaningless without the underlying DarkGru unit prefabs).
- **Conflicts with**: no known conflicts.
- **Synergies with**: `DarkGruMPPCamos-GRS` (reskins these unit families), COE2 scenario controller (consumes the factions at runtime).

## 6. Performance impact

Negligible. Content-only mod; cost is asset-load at scenario init, not per-tick.

## 7. Known issues / landmines

- **Sparse Workshop description** — the canonical inventory of unit prefabs is *implicit* in the DarkGruMPPCamos-GRS Workshop page (which enumerates what it reskins). If a future Workshop update changes the unit-family roster, the camo overlay may misalign and the operator should re-verify the GM Entity Browser inventory.
- The `LOGLOGLOG` script messages mentioned in CLAUDE.md "Cosmetic noise" don't originate here — DarkGruFactions is silent at boot.

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: 1.0.19
- **Folder**: `DarkGruFactions_66E9222820080A19`
- **Game compat declared**: 1.6.0.119 (matches server)
- **Workshop last updated**: 2026-05-11
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/66E9222820080A19)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/66E9222820080A19/changelog)
- License: Arma Public License Share Alike (APL-SA)
- Sibling L6 mod: `[[Arma2Factions]]`
- Reskin overlay: `[[DarkGruMPPCamos-GRS]]`
- CLAUDE.md "Mod stack architecture (load order layers)" — L6 placement
- CLAUDE.md "Active scenario behavior — COE2 Eden" — how COE2 consumes factions at runtime
