---
workshop_id: "65351DA1585DF3BF"
workshop_url: https://reforger.armaplatform.com/workshop/65351DA1585DF3BF
version: "6.0.83"
author: "HFS (Heli Flight School)"
load_order_layer: L10
status: removed
last_verified: 2026-05-17
declared_in: []
hard_deps:
  - "5E389BB9F58B79A6 # SpaceCore"
  - "61FB659D6529902D # NH-90"
  - "6273146ADFE8241D # WCS_AH-6M"
  - "6276E6E3CC97A22B # AUS_CORE"
  - "628933A0D3A0D700 # WCS_Mi-24V"
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "62CCD69DD17E4F2F # AKI_Core"
  - "64CB35D07BAEE60F # WCS_KA-52"
  - "64CB39E57377C861 # WCS_AH-1S"
  - "64EE818E08AFCF94 # MFDFramework"
reverse_deps: []
related_memories: []
folder: "(deleted 2026-05-17)"
---

# HFS_Configs — **REMOVED 2026-05-17**

> **One-line role** (when installed): prefab-config rewrites for assigning helicopters to factions, setting rank and supply costs, creating unarmed variants. Built for the Heli Flight School private server. **Removed from this stack after causing icon + spawn-routing regressions.**

## 1. Overview

Author's verbatim description: *"prefab edits for assigning helicopters to appropriate factions, setting rank and supply costs, and creating unarmed variants."* Covers Mi-24V, KA-52, AH-64D, AH-6M, AH-1S, MH-60 DAP, NH-90, KA-27, CH-47, SA342, Z9, KA-50, CH-46, Lynx, RAH-66, Puma, EVTOL.

Tested 2026-05-17 boot 7 as a fix for the WCS helis' missing faction binding (GM categorized panel → click heli → spawn Tigr fallback). Rolled back boot 8 after surfacing two regressions described in §7.

## 2. Functionality / Features (when installed)

- Helicopter prefab faction assignments.
- Rank-cost and supply-cost rewrites.
- Unarmed variant prefabs.

## 3. Configuration

_No external config file._ All behavior is baked into the prefab rewrites.

## 4. Operator usage

_N/A — removed._

## 5. Compatibility & load order

- **Load order layer**: L10 (audio-visual / config overlay) — was the install position.
- **Conflicts with**: the mixed RHS+WCS+COE2 prefab catalog. HFS's prefab rewrites win the "last loaded wins" race per CLAUDE.md silent-override-collision pattern and inject HFS-flavored config that doesn't resolve cleanly against the operator's other mods (icon paths + GM catalog ordering).

## 6. Performance impact

Not measured at runtime — removed before extended play.

## 7. Known issues / landmines — **the reason it's removed**

When installed in boot 7, surfaced two regressions visible in-game:

1. **Placeholder icons** for a broad swath of vehicles in the GM panel. HFS's modified prefabs reference icon paths/GUIDs that don't resolve against the other mods in this stack.
2. **Wrong-helicopter spawning** — clicking heli A in the GM categorized panel spawned heli B (or sometimes a still-wrong fallback). HFS's prefab rewrites reshuffle the GM/EntityCatalog ordering such that the click→spawn mapping is broken.

Root cause: HFS_Configs is built for the **Heli Flight School private server** stack, where its prefab conventions match the rest of that server's mod environment. On this mixed RHS+WCS+COE2 stack, the conventions don't line up, and the "fix" causes more visible regressions than the original problem (heli→Tigr fallback in the categorized GM panel).

**Lesson recorded in CLAUDE.md** — APL-ND private-server mods may have icon/catalog conventions that conflict with mixed public-stack environments. Don't recommend HFS_Configs for this stack without a Workbench-level audit of its prefab catalog deltas against the operator's RHS+WCS bindings.

## 8. Alternative path forward

For the WCS heli → faction binding gap that motivated this install:

- **Immediate workaround**: GM F1 entity browser → text-search `Mi-24` / `Ka52` / `AH-64` etc. Bypasses the broken categorized panel routing entirely.
- **Long-term fix**: build a Workbench bridge mod that extends RHS_AFRF and RHS_USAF EntityCatalogs with the WCS heli prefab GUIDs. Estimate 4-8 hours, follows the operator's `[[bridge_mod_v103_architecture]]` precedent. Per `BohemiaInteractive/Arma-Reforger-Samples/SampleMod_NewFaction` template + BI Faction Creation wiki.

## 9. Changelog / verified state

- **Installed**: 2026-05-17 boot 7 (config edit + Steam pull, ~0.8 MB)
- **Removed**: 2026-05-17 boot 8 prep (15:11:57 stop, folder deleted)
- **Snapshot pre-install**: `state_snapshots/2026-05-17_14-35-19_pre-ashyl-fx-iter-2026-05-17`

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/65351DA1585DF3BF)
- [HFS gaming community site](https://hfsgaming.com/) — author identity
- Related: `[[WCS_Mi-24V]]`, `[[WCS_KA-52]]` (helis it tried to faction-bind), `[[bridge_mod_v103_architecture]]` (Workbench precedent for the alternative path)
