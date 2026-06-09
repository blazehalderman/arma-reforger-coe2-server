---
workshop_id: "64FC36E952FD8E58"
workshop_url: https://reforger.armaplatform.com/workshop/64FC36E952FD8E58
version: "1.0.1"
author: ""
load_order_layer: L10
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: "ArsenalItemsallranks_64FC36E952FD8E58"
---

# ArsenalItemsallranks

> **One-line role**: removes per-rank gating from arsenal items so all players see all items regardless of rank/role.

## 1. Overview

Small overlay mod that strips the `m_AvailableForSupplyUsers` / minimum-rank checks from vanilla arsenal entries. Pairs with `NoRankRequirements` to flatten the supply/rank-gating layer entirely. Useful on sandbox / casual servers where the rank progression isn't part of the gameplay loop.

## 2. Functionality / Features

- All arsenal items visible to every player, regardless of their faction rank or supply level.
- Complements (does not replace) `NoRankRequirements` — that mod handles the player-rank check, this one handles the item-rank check.

## 3. Configuration

_No config file._ Pure prefab override.

## 4. Operator usage

Passive — players just see everything in the arsenal UI without rank-locked items being hidden.

## 5. Compatibility & load order

- **Load order layer**: **L10** (arsenal/UI overlay).
- **Synergies with**: `[[NoRankRequirements]]` — typically co-deployed (per CLAUDE.md, NoRankRequirements is in L9 and `CRX_EAI Rank_Type=1 (Vanilla)` defers to it).
- **Cross-faction arsenal regression suspect** (CLAUDE.md "State summary as of 2026-05-16"): named alongside `sTsWCSVanillaArsenal` + `All-In-OneArsenals` as contributor to the 121-mod → 103-mod revert. Lowest-suspicion of the three (a "remove gating" mod is structurally simpler than catalog-merger mods), but stays on the watchlist.

## 6. Performance impact

Zero per-tick cost. One-shot prefab override at boot.

## 7. Known issues / landmines

**Arsenal regression participant** (CLAUDE.md V5): see § 5. Lower-priority for bisection than `All-In-OneArsenals` and `sTsWCSVanillaArsenal`, but still in the suspect set. If the arsenal regression recurs after disabling the other two suspects, this is the third bisection target.

**Doesn't bypass scenario gating** — COE2 / Kex framework can layer additional class/role restrictions on top of arsenal that this mod doesn't touch. Combine with `NoRankRequirements` for full bypass.

## 8. Extending / modding

_N/A_ — content/override mod.

## 9. Changelog / verified state

- **Installed version**: 1.0.1
- **Folder**: `profile_new/addons/ArsenalItemsallranks_64FC36E952FD8E58`
- **Last clean boot**: 2026-05-16 (golden state V5)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/64FC36E952FD8E58)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64FC36E952FD8E58/changelog)
- `CLAUDE.md` § "State summary as of 2026-05-16" — regression contributor list
- `[[golden_state_2026_05_16_v5]]` memory — arsenal-trio regression notes
- Companion: `[[NoRankRequirements]]`
- Related arsenal mergers: `[[sTsWCSVanillaArsenal]]`, `[[sTsRHSVanillaArsenal]]`, `[[All-In-OneArsenals]]`
