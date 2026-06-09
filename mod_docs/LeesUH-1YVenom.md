---
workshop_id: "66726C1CF64BDCDC"
workshop_url: https://reforger.armaplatform.com/workshop/66726C1CF64BDCDC
version: "1.0.47"
author: "YellowCobra7546"
load_order_layer: L8
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "58D0FB3206B6F859 # base game"
  - "668B5E64DD9E9041 # LeesWeaponFramework"
  - "64EE818E08AFCF94 # MFDFramework"
reverse_deps: []
related_memories: []
folder: "LeesUH-1YVenom_66726C1CF64BDCDC"
license: "APL-ND (Arma Public License No Derivatives)"
---

# LeesUH-1YVenom

> **One-line role**: Modernized UH-1Y Venom (twin-engine Huey successor) — utility/transport with door gunners, useful for medium-lift insertions and door-gun support runs.

## 1. Overview

The UH-1Y Venom is the **modernized Huey** — twin turboshaft engines, rigid four-blade rotor, retains the iconic silhouette but with substantially better speed and maneuverability than the original UH-1H. Authored by YellowCobra7546 (the "Lees" family of mods); ships as part of the Lees Weapon Framework ecosystem. APL-ND license (no-derivatives — important constraint for any custom shim work; see §8).

## 2. Functionality / Features

- **Variants shipped**: Workshop page does not enumerate specific variants. Lees mod-family convention is usually a small set of variants (e.g., armed/unarmed/transport) — verify via GM Entity Browser search "UH-1Y" / "Venom".
- **Weapon loadout**: door-gunner-mounted weapons expected (M240/M134 minigun is the real-world standard for UH-1Y). Per Workshop, specific weapon configuration is not enumerated; will need in-game verification.
- **Crew compartments**: 2-seat cockpit (pilot + copilot) + 2 door gunner stations + troop bay (real-world UH-1Y: 8 troops; in-mod capacity not specified).
- **Special features**: enhanced speed + maneuverability over vanilla Huey per author description.

## 3. Configuration

**Config files**: none in `profile_new/profile/LeesUH-1YVenom/` — content-only mod.

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)**:
1. GM Entity Browser → search "UH-1Y" / "Venom"
2. Crew: 2 pilots + 2 door gunners + 8 troop seats
3. Good for medium-lift insertion + door-gun overwatch

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `LeesWeaponFramework` (`668B5E64DD9E9041`), `MFDFramework`. **Note**: LeesWeaponFramework is currently a transitive dep — frontmatter says "not in any config" — meaning it's on-disk-but-undeclared. Per CLAUDE.md *"folder-presence triggers script compilation regardless of declaration"*, scripts compile fine, but if Steam re-evicts the framework, registration breaks. Consider declaring `LeesWeaponFramework` explicitly in `serverConfig.json` to harden.
- **Must load before**: any future UH-1Y DarcChopper compat shim.
- **Conflicts with**: none documented.
- **Synergies with**: `LeesWeaponFramework` (parent framework), `MFDFramework`.

## 6. Performance impact

213 MB on disk. Standard per-active-heli cost. No observed log spam.

## 7. Known issues / landmines

_no documented incidents on this stack._ The **APL-ND license** is a workflow constraint, not a server-runtime issue — see §8.

## 8. Extending / modding — DarcChopper integration

**Status**: ❌ **NO published DarcChopper compat shim exists for UH-1Y.** Custom Workbench shim required (procedure in `mod_docs/DarcChopper.md` §8 Option B + `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2).

**⚠️ License caveat**: this mod uses **APL-ND (No Derivatives)**. A standard DarcChopper compat shim (which inherit-and-overrides the upstream prefab to attach `SDRC_ChopperComp`) could be argued as a derivative work. Two safer paths:
1. **Server-local shim** — build the shim, keep it on the local server only, do NOT publish to Workshop. APL-ND restricts redistribution, not local modification.
2. **Author permission** — contact YellowCobra7546 (via Workshop Discord link or comments) and get explicit permission to publish a DarcChopper bridge derivative. WCS series has a similar restrictive clause; KA-52 shim (`684F3C94BD457F85`) is precedent that this is achievable.

**Per-airframe parameter recommendations** (verbatim from extension plan):

| Param | Value |
|---|---|
| RotorForce0 / 1 | medium lift, agile |
| Speed Min/Max | 30 / 75 m/s |
| Fly Height Low/High | 60 / 150 m |
| Rocket Prefab | _none_ (door gunner only) |
| Rocket Count | 0 |
| Enemy Search Type | `ANY_CHAR` (anti-infantry support via door guns) |
| Faction | `US` |

**Build priority**: ranked **#5** by ROI in the extension plan — *"utility/transport; benefits less from DarcChopper since transport role is less SAD-driven, but still useful for AI-piloted insertion missions."*

**Estimated build time**: 1-2h.

## 9. Changelog / verified state

- **Installed version**: 1.0.47
- **Folder**: `profile_new/addons/LeesUH-1YVenom_66726C1CF64BDCDC`
- **Last clean boot**: continuously loaded in golden state 2026-05-16 v5

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/66726C1CF64BDCDC)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/66726C1CF64BDCDC/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
