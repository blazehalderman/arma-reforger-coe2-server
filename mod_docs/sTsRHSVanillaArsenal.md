---
workshop_id: "69075EC0BD287A6E"
workshop_url: https://reforger.armaplatform.com/workshop/69075EC0BD287A6E
version: "1.0.4"
author: "sTs"
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "606B100247F5C709 # BaconLoadoutEditor"
  - "1337C0DE5DABBEEF # RHS_Content_01"
  - "BADC0DEDABBEDA5E # RHS_Content_02"
  - "595F2BF2F44836FB # RHS_Status_Quo"
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "690EE89CA417ECD8 # sTsWCSVanillaArsenal"
related_memories:
  - golden_state_2026_05_16_v5.md
folder: "sTsRHSVanillaArsenal_69075EC0BD287A6E"
---

# sTsRHSVanillaArsenal

> **One-line role**: bridge mod that injects RHS weapons / vehicles / loadouts into the vanilla US/USSR arsenal + Bacon Loadout Editor pickers.

## 1. Overview

The "Bacon-side" half of the sTs arsenal-bridge pair (the WCS-side half is `[[sTsWCSVanillaArsenal]]`). This mod populates the vanilla arsenal catalogs and **Bacon Loadout Editor** templates with RHS Status Quo content so players can build RHS-flavored loadouts via the standard UI rather than only via WCS Loadout Editor.

## 2. Functionality / Features

- Adds RHS_USAF / RHS_AFRF / RHS_GREF / RHS_SAF weapon families to vanilla arsenal catalogs.
- Pre-builds RHS loadout templates for Bacon Loadout Editor.
- Hard-deps on Bacon Loadout Editor (BLE) — this is **why BLE has to stay declared first-class** in `serverConfig.json mods[]` even though it is otherwise discouraged (see CLAUDE.md "BaconLoadoutEditor" landmine and § "Known landmines"). Removing BLE breaks this mod's load chain.
- Paired-required-with `sTsWCSVanillaArsenal` (its reverse-dep).

## 3. Configuration

_No config file._ Content-merge mod only.

## 4. Operator usage

- Open **Bacon Loadout Editor** in-game → RHS faction templates available alongside vanilla.
- Open WCS Loadout Editor / GM-spawned arsenal → RHS items in their category tabs.

## 5. Compatibility & load order

- **Load order layer**: **L10** (arsenal/UI overlay).
- **Must load after**: BaconLoadoutEditor (L7 apparel/loadouts), RHS Content 01 / 02 / Status Quo (L1 cores).
- **Must load before**: `sTsWCSVanillaArsenal` (which reverse-deps it).
- **Hard depper on BaconLoadoutEditor**: per CLAUDE.md "Known landmines" → "BaconLoadoutEditor", this is one of the two mods that **forced BLE to be re-declared first-class** in 2026-05-13 (the other is `GRS-Apparel`). You cannot remove BLE without first removing this mod.
- **Cross-faction arsenal regression suspect** (CLAUDE.md "State summary as of 2026-05-16"): see § 7. Lower confidence than its WCS sibling — RHS bridges have a longer good-track-record — but stays on the watchlist.

## 6. Performance impact

One-shot catalog merge at scenario init. Negligible per-tick.

## 7. Known issues / landmines

**Hard-dep on BLE = removing BLE cascades** (CLAUDE.md): one of two reverse-deppers (with `GRS-Apparel`) that prevent BLE removal. Folder-presence triggers BLE's script compile regardless of `mods[]` declaration, so the only path to a BLE-less server is removing this mod *and* `GRS-Apparel` simultaneously *and* deleting BLE's folder *and* purging BLE's stale loadout-blob files in `profile_new/profile/BaconLoadoutEditor_Loadouts/`.

**BLE corrupt-loadout-blob risk** (CLAUDE.md "Known landmines" → "BaconLoadoutEditor"): the storage files `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` and `1.6.0/admin_loadouts` reference 22 PCM-era prefabs that no longer exist on disk. BLE's loader has no skip-and-continue, so opening the editor null-derefs and crashes the client. Workaround = delete the storage files; this mod will repopulate the templates on the next scenario init.

**Cross-faction arsenal regression** (V5 history): along with `sTsWCSVanillaArsenal` + `ArsenalItemsallranks` + `All-In-OneArsenals`, named as a contributor to the 121-mod regression that triggered the 103-mod revert. Currently active but flagged. Snapshot `state_snapshots/2026-05-14_21-35-46_pre-deployment-cleanup-2026-05-14` is the safe rollback. See `[[golden_state_2026_05_16_v5]]`.

## 8. Extending / modding

_N/A_ — content mod.

## 9. Changelog / verified state

- **Installed version**: 1.0.4
- **Folder**: `profile_new/addons/sTsRHSVanillaArsenal_69075EC0BD287A6E`
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/69075EC0BD287A6E)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/69075EC0BD287A6E/changelog)
- `CLAUDE.md` § "Known landmines" → "BaconLoadoutEditor" — reverse-dep chain reasoning
- `CLAUDE.md` § "State summary as of 2026-05-16" — regression history
- `[[golden_state_2026_05_16_v5]]` memory — arsenal-trio regression notes
- Paired mod: `[[sTsWCSVanillaArsenal]]`
- Reverse-depped: `[[BaconLoadoutEditor]]`
