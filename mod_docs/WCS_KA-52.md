---
workshop_id: "64CB35D07BAEE60F"
workshop_url: https://reforger.armaplatform.com/workshop/64CB35D07BAEE60F
version: "6.0.12"
author: "Worst Case Scenario (Ronno, MrTylerjet, Keller vs Traffic, AkiraSeki, and others)"
load_order_layer: L8
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps:
  - "629B2BA37EFFD577 # WCS_Armaments"
  - "62CCD69DD17E4F2F # AKI_Core"
reverse_deps:
  - "684F3C94BD457F85 # KA52forDarcChopper (installed deployed-only — Phase 1 of extension plan)"
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# WCS_KA-52

> **One-line role**: WCS Ka-52 Alligator — Russian advanced attack helicopter, side-by-side 2-seat cockpit, coaxial rotors, primary deployed-server OPFOR heavy CAS asset. Deployed-only.

## 1. Overview

The Ka-52 "Alligator" is the **Russian modern heavy gunship** — distinctive coaxial main rotor (no tail rotor), side-by-side 2-seat cockpit (the only such layout in the stack), and modern fly-by-wire avionics. Added to the deployed stack only during iter3 (2026-05-15/16) as part of the WCS vehicle catalog gap-fill. 84% rating, 1.34M downloads. **Has an existing DarcChopper compat shim** — see §8 — which is **installed on deployed only**.

## 2. Functionality / Features

- **Variants shipped**: Workshop page does not enumerate specific variants by name. WCS authoring convention + the existence of `KA52forDarcChopper` referencing a `KA52_UPK_X2_Patrol` prefab confirms **at minimum a Patrol variant with UPK gunpod + X2 ATGM loadout**. Verify via GM Entity Browser search "KA-52" / "Ka52" / "Hokum" / "Alligator".
- **Weapon loadout** (Ka-52 real-world standard, expected in this mod):
  - 2A42 30mm cannon (side-mounted, slewable)
  - B-8V20 / B-13L rocket pods (S-8 or S-13 rockets — Warsaw Pact convention → `Ammo_Rocket_S5.et` family + S-8 if shipped)
  - 9M127 Vikhr ATGMs (laser beam-riding) on wing stubs
  - UPK-23-250 gunpods on certain variants (per the compat-shim's `KA52_UPK_X2_Patrol` naming)
- **Crew compartments**: **side-by-side 2-seat cockpit** (unique in this stack — every other 2-seat heli here is tandem). Pure attack platform.
- **Special features**: WCS_Armaments-managed reloads; coaxial-rotor flight model.

## 3. Configuration

**Config files**: none in `profile_new/profile/WCS_KA-52/` — content-only mod (no local profile folder; deployed-only).

**Tunable keys**: _N/A_

## 4. Operator usage

**In-game (Game Master)** — deployed server only:
1. GM Entity Browser → search "KA-52" / "Ka52" / "Alligator"
2. With KA52forDarcChopper shim installed, the **`KA52_UPK_X2_Patrol` variant** is also AI-flyable via SDRC_ChopperComp
3. Crew: 2 (side-by-side)
4. Primary OPFOR CAS asset; pairs naturally with USSR-faction ground ops

**Keybinds**: standard vanilla heli flight.

## 5. Compatibility & load order

- **Load order layer**: **L8** (vehicle/weapon content packs).
- **Must load after**: `WCS_Armaments`, `AKI_Core` (hard deps).
- **Must load before**: `KA52forDarcChopper` at L9 (consumer mod — see §8). Per `MASTER_OBJECTIVE.md` order convention, L8 content always loads before L9 overlays.
- **Conflicts with**: none documented.
- **Synergies with**: `KA52forDarcChopper` (DarcChopper compat — installed on deployed); `WCS_Armaments` (reloads).
- **Deployment scope**: **deployed-only** — added in iter3 alongside WCS_AH-1S and MRZR. ~37% of the 299 missing-prefab errors attributed to gap-fills like this one per [[golden_state_2026_05_16_v5]] memory.

## 6. Performance impact

198 MB on disk on deployed. No observed log spam.

## 7. Known issues / landmines

_no documented incidents on this stack._ Was specifically added as part of the iter3 missing-prefab fix; net-positive for error reduction.

## 8. Extending / modding — DarcChopper integration

**Status**: ✅ **PUBLISHED compat shim EXISTS and is INSTALLED on the deployed server** (Phase 1 of the extension plan applied 2026-05-16 15:59 UTC).

**Installed shim**: `KA52forDarcChopper` (`684F3C94BD457F85`) — declared in `serverconfig-deployed.json mods[]` at L9 position 77 (right after DarcChopper). Adds the `KA52_UPK_X2_Patrol` prefab variant with `SDRC_ChopperComp` pre-attached. No Workbench work required for KA-52.

**Per-airframe parameter recommendations** (KA-52 not enumerated in the extension plan table by name because the shim already exists — its parameters were authored by the shim author). For reference, comparable USSR gunship parameters that the shim likely uses:

| Param | Value (shim-authored — verify in-game) |
|---|---|
| RotorForce0 / 1 | high lift (heavy modern gunship) |
| Speed Min/Max | ~30 / ~95 m/s (real-world Vne ~310 km/h) |
| Fly Height Low/High | 80 / 200 m |
| Rocket Prefab | Warsaw Pact: `Ammo_Rocket_S5_FRAG_S5MO` (`{EF17BED6DCEE4DE4}`) or `S5_HEDP_S5KO` (`{EE65544BA845C458}`) |
| Rocket Count | -1 |
| Enemy Search Type | `VEHICLE_ARMORED` |
| Faction | `USSR` |

**Operator action**: from §`Phase 1 implementation` of `_asks/2026-05-16_darcchopper-heli-extension.md`:
- [ ] Push `serverconfig-deployed.json` via Pterodactyl panel; restart container; GM-spawn `KA52_UPK_X2_Patrol` → verify it accepts SAD waypoint and auto-flies.

**Build priority**: **N/A** — already covered by published shim. No Phase 2 Workbench work needed for this airframe.

## 9. Changelog / verified state

- **Installed version**: 6.0.12 (per Workshop page)
- **Folder**: present only on deployed server (Linux container)
- **Last clean boot**: deployed golden state 2026-05-16 v5 (iter3 fix); DarcChopper shim awaiting verification on next deployed restart

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/64CB35D07BAEE60F)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/64CB35D07BAEE60F/changelog)
- Related extension plan: `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` (Phase 1 — KA52 shim install applied)
- Compat shim doc: `mod_docs/KA52forDarcChopper.md`
- Framework consumer: `mod_docs/DarcChopper.md` §8
- Related memory: `[[golden_state_2026_05_16_v5]]` (iter3 addition rationale)
