---
workshop_id: "65AD7D0D9941A380"
workshop_url: https://reforger.armaplatform.com/workshop/65AD7D0D9941A380
version: "1.5.19"
author: "acemod"
load_order_layer: L2
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
reverse_deps:
  - "5ED61DC0AFE17E8E # Kex Scenario Core"
  - "65AD7C249E4ECDFB # ACE Captives Dev"
related_memories: []
folder: "ACECoreDev_65AD7D0D9941A380"
---

# ACE Core Dev

> **One-line role**: Dev-branch fork of the ACE (Advanced Combat Environment) Core framework for Reforger — minimal Anvil-platform realism scaffolding (turret radial menu, extended gestures, interaction system) plus the shared classes that `ACE Captives Dev` and `Kex Scenario Core` consume.

## 1. Overview

`ACE Core Dev` is the **acemod team's experimental development branch** of ACE Core for Reforger 1.6.0.119, published as a separate Workshop entry from the mainline `ACE Core` (`60C4CE4888FF4621`) so the team can ship breaking changes without disrupting the production tag. Per the Workshop page, "Details for this mod can be found in our documentations: <https://anvil.acemod.org/dev/components/core/>" — there is **no inline description** beyond pointing to the Anvil docs.

In our stack, the Dev pair (Core Dev + Captives Dev) is **hard-depped by `Kex Scenario Core` (`5ED61DC0AFE17E8E`)** — `Kex_Scenario_Core/addon.gproj` declares both Dev GUIDs in its Dependencies list. This is **the only reason ACE Dev is in this server**: COE2 builds on Kex, Kex requires ACE Dev. Per CLAUDE.md, the COE2 pivot (2026-05-13) replaced the full stable ACE Core + 4 feature mods (Trenches, Tactical Ladder, Tactical Periscope, Facepaint) with the minimal ACE Dev pair (Core Dev + Captives Dev). Operator's CLAUDE.md note: *"Kex hard-deps both Dev mods — stable ACE removed in COE2 pivot"*.

The `addon.gproj` declares **no hard deps beyond the base game** (verified — `dev.gproj` line 6) and ships 13-language localization (`ACE_localization.st`).

## 2. Functionality / Features

Per the Anvil docs (<https://anvil.acemod.org/dev/components/core/>):

- **"Common functions and systems used by other mods"** — shared framework for the ACE Anvil ecosystem.
- **Turret Radial Menu** — accessed via Inspect keybind (default: Hold `R`) in the Equipment category. Enables turret inspection workflows on supported vehicle prefabs.
- **Extended Gestures System** — Open gestures menu (default `F1`) → Character category. Adds animations like sitting on the floor.
- **Interaction system + settings infrastructure** — underlying class graph that ACE feature mods (Captives, Medical, etc.) bind into.
- Localization in 13 languages (`cs_cz / de_de / en_us / es_es / fr_fr / it_it / ja_jp / ko_kr / pl_pl / pt_br / ru_ru / uk_ua / zh_cn`).

## 3. Configuration

**Config files**: none observed in `$profile:/` (verified — no `profile_new/profile/ACE Core Dev/` or `profile_new/profile/ACE/` directory). ACE settings on the Dev branch are typically passed via **scenario mission header** (Anvil docs pattern) rather than separate JSON files.

**Tunable keys**: none operator-side at framework level. Feature-mod settings (Captives, etc.) are scenario-header gated.

## 4. Operator usage

**In-game (any player)**:
- **Hold `R`** in a turret seat → Turret Radial Menu opens.
- **`F1`** anywhere → Gestures radial menu opens. Browse Character category → sit / other animations.

**Keybinds** (default per Anvil docs):
- `R` (Hold) — Inspect / Turret Radial Menu
- `F1` — Open gestures menu

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L2** (ACE sub-modules) per `MASTER_OBJECTIVE.md` revision 2026-05-16. Note: the MASTER_OBJECTIVE.md table currently still shows the older "stable ACE Core + 4 feature mods" L2 entry — that table's L2 was **superseded by the 2026-05-14 evening revert back to Dev pair**. Live `serverConfig.json` declares `ACE Core Dev` + `ACE Captives Dev` (confirmed via grep).
- **Must load before**: `ACE Captives Dev` (its only declared dep), `Kex Scenario Core` (which deps the Dev pair → COE2 chain).
- **Must load after**: base game only.
- **Conflicts with**: **stable ACE Core (`60C4CE4888FF4621`)** — per CLAUDE.md "GOLDEN STATE 2026-05-16 V5", coexistence of stable + Dev creates script-symbol conflicts. **Do not stack both**. The 2026-05-14 121-mod state attempted stable ACE Core + 4 feature mods (Trenches, Tactical Ladder, Tactical Periscope, Facepaint) and was reverted late 2026-05-14 partly due to Kex's hard-dep on Dev (cross-faction arsenal regression was the other half).
- **Synergies with**: `ACE Captives Dev` (consumer), `Kex Scenario Core` → `COE2` (transitive consumers).

## 6. Performance impact

- Boot cost: 13.90 MB pak (small). 977k Workshop downloads — mature, stable.
- Runtime: pure framework — interaction system + gesture handler tick is bounded. No measurable load on this server's 100+ AI density envelope.

## 7. Known issues / landmines

- **Stable-vs-Dev coexistence breaks Kex**: per CLAUDE.md golden state V5 + `MASTER_OBJECTIVE.md` 2026-05-16 revision header, the 2026-05-14 121-mod state replaced ACE Dev with stable ACE → Kex Scenario Core failed its hard-dep check (Kex's gproj points at the Dev GUIDs specifically). Result: state was reverted to baseline 103 mods with ACE Dev pair restored. **Always verify Kex's `addon.gproj` dep GUIDs before swapping ACE branches.**
- **Dev branch is breaking-change-active**: by definition the Dev branch ships untagged-stability changes. Pin `version: ""` (current convention) and verify boot after every Steam pull.
- **The `addons_disabled/ folder-presence` landmine** (CLAUDE.md, IPCHigherAISkill incident 2026-05-13) applies: removing ACE Core Dev from `serverConfig.json mods[]` without deleting the folder still leaves scripts compiling. To truly disable, **delete** the folder.

## 8. Extending / modding

- The ACE Anvil project is open-source under GPLv2 — extension is via building a sibling ACE component (the Captives Dev sister-mod is the canonical example).
- Upstream development at <https://github.com/acemod/ACE3-Reforger> (Anvil) — Anvil is acemod's Reforger-targeted code line.
- Custom mission headers can set ACE Captives flags (see [[ACE_Captives_Dev]] §3) — that's the operator-side surface.

## 9. Changelog / verified state

- **Installed version**: 1.5.19 (per `dev.gproj` ID + `ServerData.json` revision; folder `ACECoreDev_65AD7D0D9941A380`)
- **Folder**: `ACECoreDev_65AD7D0D9941A380` (note: pak file is named `data.pak`; project file is `dev.gproj` not `addon.gproj` — Workbench Dev-build artifact)
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot. Re-restored 2026-05-14 evening when 121-mod state was reverted.

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/65AD7D0D9941A380)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65AD7D0D9941A380/changelog)
- [Anvil docs — ACE Core (Dev)](https://anvil.acemod.org/dev/components/core/) — primary feature reference
- [acemod GitHub org](https://github.com/acemod)
- License: GNU GPLv2 ("free software"; derivatives forbidden from using names suggesting official ACE status)
- CLAUDE.md "What this is" → "ACE Core Dev + ACE Captives Dev — minimal ACE Dev pair paired with COE2"
- CLAUDE.md "State summary as of 2026-05-16" → Kex hard-deps both Dev mods
- Related memories: `[[golden_state_2026_05_16_v5]]`, `[[golden_state_2026_05_14_v4]]` (the failed 121-mod swap)
