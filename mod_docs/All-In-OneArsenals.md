---
workshop_id: "6846EB65C0A446EE"
workshop_url: https://reforger.armaplatform.com/workshop/6846EB65C0A446EE
version: "0.0.0"
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
folder: "All-In-OneArsenals_6846EB65C0A446EE"
---

# All-In-OneArsenals

> **One-line role**: superset-arsenal mod that tries to surface every installed faction's weapons in a single unified arsenal UI.

## 1. Overview

Catch-all arsenal merger — scans installed faction packs and folds their inventory-item entity catalogs into a unified, faction-agnostic arsenal entity. Closest the ecosystem gets to the operator's stated goal "single arsenal with all weapons". Version `0.0.0` indicates a pre-1.0 work-in-progress mod with limited documentation.

## 2. Functionality / Features

- Single arsenal entity that lists weapons / scopes / magazines / clothing from every loaded faction pack regardless of player faction.
- Useful for sandbox / Game-Master sessions where the operator wants free choice across factions.

## 3. Configuration

_No documented config file._ Behavior is encoded in the mod's catalog merge logic.

## 4. Operator usage

In-game: Game Master can spawn the all-in-one arsenal entity (look for the "Arsenal — All In One" entry in the GM entity browser). Players walking up to it see the merged inventory.

## 5. Compatibility & load order

- **Load order layer**: **L10** (arsenal/UI overlay — must run after all faction-pack content layers).
- **Must load after**: L1/L3/L6/L8 (RHS cores, WCS content, faction packs, vehicle/weapon packs) — anything whose inventory it scans.
- **Cross-faction arsenal regression suspect** (CLAUDE.md "State summary as of 2026-05-16"): named alongside `sTsWCSVanillaArsenal` + `ArsenalItemsallranks` (+ ACE Dev/stable conflict) as a contributor to the **121-mod → 103-mod revert on 2026-05-14**. The merge-everything approach is precisely the kind of broad catalog overwrite that can override per-faction catalogs in unexpected ways, especially when multiple arsenal-merger mods (this + sTsWCS + ArsenalItemsallranks) are stacked.

## 6. Performance impact

Catalog scan + merge at scenario init. Per-tick cost negligible. Memory cost scales with installed faction count (currently ~14 declared factions across the stack).

## 7. Known issues / landmines

**Pre-release version (0.0.0)** — no Workshop changelog, no documented version progression. Updates may land without notice; pin via `version: ""` so engine accepts whatever Steam delivers, but be prepared for surprises on Workshop updates.

**Cross-faction arsenal regression contributor** (V5 history, CLAUDE.md): part of the suspect trio that triggered the 121→103 mod revert 2026-05-14. If after a Workshop update for this mod the arsenal starts mixing wrong-faction items, **disable this one first** (it's the lowest-confidence of the three arsenal mergers — sTsRHS has the best track record, sTsWCS is middle, this is most-suspect). Rollback snapshot: `state_snapshots/2026-05-14_21-35-46_pre-deployment-cleanup-2026-05-14`.

**Overlap with sTsWCSVanillaArsenal + sTsRHSVanillaArsenal + ArsenalItemsallranks**: all four target the same problem space (extending arsenal coverage). Running all four simultaneously is the current state but is not architecturally clean — the operator's V5 strategy is to keep them all declared but monitor for regressions, with a clear bisection order if symptoms reappear.

## 8. Extending / modding

_N/A_ — content/merger mod, no extension points.

## 9. Changelog / verified state

- **Installed version**: 0.0.0
- **Folder**: `profile_new/addons/All-In-OneArsenals_6846EB65C0A446EE`
- **Last clean boot**: 2026-05-16 (golden state V5; flagged as bisection-candidate #1 if arsenal regression recurs)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/6846EB65C0A446EE)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/6846EB65C0A446EE/changelog)
- `CLAUDE.md` § "State summary as of 2026-05-16 (golden state V5 — local + deployed split)" — regression contributor list
- `[[golden_state_2026_05_16_v5]]` memory — arsenal-trio regression notes
- Related arsenal mergers: `[[sTsWCSVanillaArsenal]]`, `[[sTsRHSVanillaArsenal]]`, `[[ArsenalItemsallranks]]`
