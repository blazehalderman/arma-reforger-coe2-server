---
workshop_id: "631C3C1AEE9C90BC"
workshop_url: https://reforger.armaplatform.com/workshop/631C3C1AEE9C90BC
version: "6.0.6"
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
  - "615806DC6C57AF02 # WCS_NATO"
  - "615818DA7C0343FD # WCS_RU"
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_Sounds_631C3C1AEE9C90BC"
---

# WCS_Sounds

> **One-line role**: custom weapon-fire audio + immersive sound effects for WCS faction weapons and the broader WCS soundscape.

## 1. Overview

`WCS_Sounds` is the **audio asset bundle** for the WCS weapons stack. It ships gunshot/fire sounds, mechanical sounds (bolt, magazine), and ambient WCS soundscape elements. Bound to WCS weapon prefabs via the `WCS_Weapon_Scripts` framework (transitive — this mod's gproj declares only the base game). 165 MB on disk.

Conflicts with `RealismOverhaul-Sounds`: per [[CLAUDE.md]] §"State summary as of 2026-05-16" deployed-only iter3 additive fix — see `Fix_RealismSounds_WCS-Earplugs` for the **purpose-built bridge mod** that resolves the RO-Sounds + WCS_Earplugs mixer conflict (1-sec earplug fail). On local this isn't installed; deployed has it.

## 2. Functionality / Features

- WCS-faction weapon-fire SFX (small arms, MGs, sniper rifles)
- Mechanical SFX (bolt cycling, mag insert/remove, dry fire)
- Optional WCS soundscape elements
- Zero non-base dependencies (lightweight on the dep DAG)

## 3. Configuration

**Config files**: none.

_N/A_ — no tunable keys.

## 4. Operator usage

**In-game**: audio plays automatically when WCS weapons fire. Volume mixing controlled by vanilla audio settings + [[WCS_Earplugs]] toggle.

**Keybinds / admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L3** (WCS content).
- **Must load before**: [[WCS_NATO]], [[WCS_RU]], [[WCS_Arsenal]] (reverse-deps).
- **Must load after**: base game only — no other WCS-side deps in gproj.
- **Conflicts with**: `RealismOverhaul-Sounds` (deployed-only) — RO-Sounds re-mixes the audio busses such that WCS_Earplugs' attenuation envelope only lasts ~1 second instead of indefinite. Fix is the deployed-only `Fix_RealismSounds_WCS-Earplugs` (`670E8DD9DA6ADF59`) — see [[Fix_RealismSounds_WCS-Earplugs]] doc + [[CLAUDE.md]] §"State summary as of 2026-05-16" iter3 fix list.
- **Synergies with**: [[WCS_Earplugs]] (volume-reduction toggle that depends on this mixer).

## 6. Performance impact

Negligible. Audio streamed as needed; 165 MB asset bundle.

## 7. Known issues / landmines

- **RO-Sounds conflict** (above) — only fires on deployed if `RealismOverhaul-Sounds` is loaded without the fix bridge.
- No version-pin landmines known for this mod specifically — use `version: ""` like all WCS mods.

## 8. Extending / modding

_N/A_ — audio asset bundle.

## 9. Changelog / verified state

- **Installed version**: 6.0.6
- **Folder**: `WCS_Sounds_631C3C1AEE9C90BC`
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/631C3C1AEE9C90BC) — 1.45M downloads
- [Workshop changelog](https://reforger.armaplatform.com/workshop/631C3C1AEE9C90BC/changelog)
- [[Fix_RealismSounds_WCS-Earplugs]] — the RO-Sounds compat bridge
- [[CLAUDE.md]] §"State summary as of 2026-05-16" — iter3 deployed-only fix context
- Companion: [[WCS_Earplugs]]
