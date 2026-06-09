---
workshop_id: "65F929DF622BAD50"
workshop_url: https://reforger.armaplatform.com/workshop/65F929DF622BAD50
version: "6.0.13"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, Tonimontana, YouAreBamboozled, FailNot)"
load_order_layer: L4
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # ArmaReforger (base game)"
  - "65CF7AE8574E06D2 # WCS_Weapons"
  - "595F2BF2F44836FB # RHS_Status_Quo"
reverse_deps:
  - "615CC2D870A39838 # WCS_Arsenal"
related_memories: []
folder: "WCS_RHS_Weapons_65F929DF622BAD50"
---

# WCS_RHS_Weapons

> **One-line role**: **CRITICAL BRIDGE MOD** — re-publishes RHS weapon prefabs with WCS attachment slots wired in, so RHS rifles (M4, M16, AK, etc.) actually accept WCS scopes / grips / suppressors / sounds. Without this mod loaded, RHS weapons render in-game as bare metal.

## 1. Overview

`WCS_RHS_Weapons` is the **single canonical bridge** between the L1 RHS asset pipeline and the L3 WCS attachment ecosystem. Workshop description (verbatim): **"RHS weapon prefabs for WCS servers."** Per the `addon.gproj`, it hard-deps the base game, `WCS_Weapons` (`65CF7AE8574E06D2`), and `RHS_Status_Quo` (`595F2BF2F44836FB`) — all three must load first. The mod's contribution is **inherited-prefab overrides** for the RHS firearm catalog that add WCS attachment-slot components (the proxy-node entries that `WCS_Attachments` + `WCS_Scopes` + `WCS_Sounds` bind to).

Per `MASTER_OBJECTIVE.md`: **"WCS_RHS_Weapons is the ONLY canonical bridge between WCS attachment slots and RHS weapons — without it, RHS weapons silently drop attachment slots even when WCS_Attachments is loaded. Do not stack alternate attachment systems."**

This mod is the **load-bearing L4 layer** of the realism stack — the entire `MASTER_OBJECTIVE.md` 12-layer scheme positions L4 specifically for this bridge.

## 2. Functionality / Features

- Bridges RHS firearms into the WCS attachment ecosystem (scope rails, grip slots, suppressor threads, light/laser mounts, IR-LAM, etc.).
- Bridges RHS firearms into WCS sound replacements (via WCS_Sounds bindings on the inherited prefabs).
- Ships 13-language localization (`wcs_rhs_weapons_localization.st` — same locale set as WCS_Core).
- Per Workshop: "Special thanks to RHS for their Status Quo mod" — i.e., this is a third-party companion, not RHS-published; it consumes RHS's CC BY-NC-ND assets via inherit-and-override (legal pattern).
- Specific weapons covered: Workshop doesn't enumerate, but the operationally important set per CLAUDE.md is M4 / M4A1 / M16A4 / AK-74M / AKM (verified in-game post-fix 2026-05-12 — see §7).

## 3. Configuration

**Config files**: none in `$profile:/`. Behavior is per-prefab and baked.

**Tunable keys**: none operator-side.

## 4. Operator usage

**In-game**:
- Open arsenal (WCS_LoadoutEditor or GM-spawned arsenal entity).
- Select an RHS weapon (e.g. RHS M4A1).
- Attachment slots should populate (red dot, grip, suppressor, etc.) — **if they don't, see §7 landmine "RHS attachment fix 2026-05-12"**.

**Keybinds**: none.

**Admin commands**: none.

## 5. Compatibility & load order

- **Load order layer**: **L4** (RHS↔WCS attachment bridge) per `MASTER_OBJECTIVE.md`. Single-mod layer — this is the only mod at L4.
- **Must load before**: `WCS_Arsenal` (gproj-verified — Arsenal declares this bridge as a hard dep).
- **Must load after**:
  - **All of L1**: `WCS_Core`, `WCS_Weapon_Scripts`, `RHS_Content_01`, `RHS_Content_02`, `RHS_Status_Quo` (the latter is the gproj-verified hard dep).
  - **L3 WCS content layer**: `WCS_NATO`, `WCS_RU`, `WCS_Weapons` (gproj-verified hard dep), `WCS_Attachments`, `WCS_Scopes`, `WCS_Sounds` (transitive — WCS_Weapons hard-deps Attachments + Scopes + Sounds).
- **Conflicts with**: any alternate RHS↔WCS attachment bridge (none should be stacked — `MASTER_OBJECTIVE.md` explicit warning under "Proxy Node Preservation": "Strictly enforce a single, unified rail framework.").
- **Synergies with**: `BetterWeaponImmersion 2.8` + `BWI-ADSsway-RHS-TAOcompat` (L10) — these consume the attachment-slot data this bridge establishes, adding RHS-specific sway curves on top.

## 6. Performance impact

- Boot cost: minimal — pure inherit-and-override prefab tree.
- Runtime: zero additional script work; attachment-slot lookups happen at weapon-spawn time using vanilla `WCS_Weapon_Scripts` paths. No measurable cost.

## 7. Known issues / landmines

### **The 2026-05-12 "RHS attachment fix" incident — primary landmine on this server**

**Source**: CLAUDE.md section "RHS attachment fix applied 2026-05-12" (verbatim cited).

**Symptom**: *"RHS weapons spawn but attachments are useless"* — scopes / grips / suppressors did not render or equip on RHS guns.

**Root cause**: `WCS_RHS_Weapons` (`65F929DF622BAD50`) **was downloaded on disk** (in `profile_new/addons/WCS_RHS_Weapons_65F929DF622BAD50/`) **but never declared in `serverConfig.json` `mods[]`**. Per the folder-presence landmine (CLAUDE.md "Folder-presence triggers script execution, not just dep resolution"), the engine *will* compile scripts of an undeclared folder — but a bridge mod's *value* is its inherited prefab tree, which only registers when the mod is in the active `mods[]` graph (Steam download + CRC validation gate). Without that declaration, RHS weapon prefabs reverted to their non-bridged form: no WCS attachment slots advertised, so `WCS_Attachments` + `WCS_Scopes` had nothing to bind to.

The fix (CLAUDE.md verbatim):

> Mods added to `serverConfig.json` 2026-05-12 (backup at `serverConfig.pre-rhs-attachment-fix-2026-05-12.json`):
> - `WCS_Weapons` `65CF7AE8574E06D2` — base WCS weapon prefabs (dep of bridge).
> - `WCS_RHS_Weapons` `65F929DF622BAD50` — the bridge mod itself.
> - `RayziUtils` `6632F94B46173164` — common util dep.
> - `AimingDeadzone` `684608DD7C7E0DFB` — sway/deadzone primitive.
> - `ADSSway-Core` `648D682E7038491E` — current ADSsway core (1.6.0.119 supported).
> - `ADSSway-RHS` `656B3A0955474CB7` — RHS weapon sway tuning.
> - `BWI-ADSsway-RHS-TAOcompat` `663A654A6BB0AEA4` — Better Weapon Immersion + ADSsway + RHS bridge.

**Validation step (CLAUDE.md verbatim)**:

> Validate by spawning an RHS M4/AK in arsenal and checking the attachment slots populate; if they do but 3rd-person rendering is broken, that's a WCS_RHS_Weapons-side issue (file in Hushmodee Discord, no local fix).

**Lesson encoded into operator practice** (CLAUDE.md): *"ALWAYS verify the bridge is in `serverConfig.json` mods array, not just downloaded."*

### Other landmines

- **Don't stack alternate attachment bridges**: per `MASTER_OBJECTIVE.md` Manifesto rule "Proxy Node Preservation". Multiple attachment systems on the same prefab destroy the inheritance tree → client desync.
- **3rd-person rendering** (CLAUDE.md): if attachments equip and function but render incorrectly in third-person view, that's a bridge-side bug with no local fix — file with Hushmodee Discord (WCS team's support channel).
- **CC BY-NC-ND license interaction**: this mod consumes RHS assets via inherit-and-override (legal under ND because no asset is modified — only extended with new components). Confirms the legal extension pattern for the operator's future Workbench bridge plans (see `WORKBENCH_BRIDGE_MOD_PLAN.md`).

## 8. Extending / modding

- **To bridge a NEW non-RHS weapon pack into WCS attachments**: build a separate Workshop mod following this mod's pattern — gproj deps = base game + WCS_Weapons + your-target-weapon-pack, then inherit-and-override the target's firearm prefabs adding WCS attachment-slot components. Same pattern as DarcChopper compat shims (see `[[DarcChopper]]` §8 Option B).
- **Don't fork this mod** — non-commercial WCS license + ND on RHS side both forbid derivatives. The legal path is an additional companion mod.

## 9. Changelog / verified state

- **Installed version**: 6.0.13 (per Workshop page + folder name)
- **Folder**: `WCS_RHS_Weapons_65F929DF622BAD50`
- **Last clean boot**: continuously loaded since 2026-05-12 RHS attachment fix. Verified in both local `serverConfig.json` and deployed `serverconfig-deployed.json`.
- **Critical**: **declared in both configs** — verified 2026-05-16 via grep of `serverConfig.json` (matches "WCS_RHS_Weapons" at line 1 of the WCS bridge cluster).

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/65F929DF622BAD50)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/65F929DF622BAD50/changelog)
- License: WCS proprietary (non-commercial; no redistribution / modification without permission)
- **CLAUDE.md "RHS attachment fix applied 2026-05-12"** — full incident chronology and remediation pattern; mandatory read before touching this mod
- `MASTER_OBJECTIVE.md` Manifesto → "Proxy Node Preservation" → single attachment-bridge rule
- `MASTER_OBJECTIVE.md` Layer 4 — single-mod layer reserved for this bridge
- Backup config at server root: `serverConfig.pre-rhs-attachment-fix-2026-05-12.json` (pre-fix snapshot)
- Related memories: `[[golden_state_2026_05_12_v2]]`, `[[golden_state_2026_05_16_v5]]`
- Related docs: `[[RHS_Status_Quo]]` (the asset side), `[[WCS_Weapons]]` (the consuming side), `[[BWI-ADSsway-RHS-TAOcompat]]` (the sway overlay that builds on this bridge)
