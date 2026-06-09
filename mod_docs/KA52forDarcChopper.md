---
workshop_id: "684F3C94BD457F85"
workshop_url: https://reforger.armaplatform.com/workshop/684F3C94BD457F85
version: ""
author: "mokdevel (DarcMods family)"
load_order_layer: L9
status: deployed-only
last_verified: 2026-05-16
declared_in:
  - deployed
hard_deps:
  - "63E63BC30F7F40D6 # WCS_Armaments"
  - "64A2CB52F65BBE16 # AKI_Core"
  - "631EE12D448D7FCC # DarcCore"
  - "64CB35D07BAEE60F # WCS_KA-52"
  - "689EDED542F881AF # DarcChopper"
reverse_deps: []
related_memories:
  - golden_state_2026_05_16_v5.md
folder: ""
---

# KA52forDarcChopper

> **One-line role**: Workbench compat shim that re-publishes the WCS KA-52 Hokum with `SDRC_ChopperComp` attached so it can AI-fly, accept Game Master waypoints, and engage targets under DarcChopper's framework.

## 1. Overview

`KA52forDarcChopper` is a **5-dep, content-shim mod**: it ships zero new vehicles, zero scripts, and zero textures. Its entire payload is **one inherited prefab** that takes the upstream WCS_KA-52 airframe and bolts on the DarcChopper component so the engine treats it as a DarcChopper-aware air asset. Without this shim, GM-spawning the vanilla `WCS_KA-52` prefab puts a player-flyable KA-52 on the map but **AI cannot pilot it and no waypoint commands work** — DarcChopper's whole value proposition only triggers when `SDRC_ChopperComp` is on the prefab, and that component must be attached at build time in Workbench (see `mod_docs/DarcChopper.md` §1, §8).

The shim is the third example in the wild of the "per-airframe compat mod" pattern that DarcChopper requires (alongside `Mi24and28forDarcChopper` and the example mods documented in the DarcChopper GitHub README). It exists because the operator's `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 1 path needed an existing, blacklist-free shim for at least one airframe — and the KA-52 was the only WCS heli with a published shim that did NOT pull a blacklisted dep (Mi-24's shim was BLOCKED — see §7 below).

## 2. Functionality / Features

- **Adds prefab**: `{490B9AAF7C1DDF1B}Prefabs/Vehicles/Helicopters/KA52/KA52_UPK_X2_Patrol.et` — child prefab of WCS_KA-52's base airframe with the following overrides:
  - `SDRC_ChopperComp` attached at the prefab root
  - Component configured for KA-52 flight envelope (Warsaw-Pact rotor lift, ~80 m/s top speed)
  - Crew faction defaulted to `USSR`
  - Rocket prefab list seeded with S-5 family (Warsaw-Pact munition convention)
  - Enemy search type tuned for gunship role (`VEHICLE_ARMORED` priority)
- **No new content beyond that one prefab**. No textures, no scripts, no models, no config files — the underlying KA-52 airframe, textures, weapon ports, and physics tuning come from WCS_KA-52; the AI/waypoint integration comes from DarcChopper. The shim is the bridge.
- **Inherits all DarcChopper behaviors automatically** (see `mod_docs/DarcChopper.md` §2 for the full list): auto-takeoff, waypoint-following, SAD/Suppress/Move/Defend/Artillery/GetOut commands, damage-evac, crew auto-spawn.

## 3. Configuration

**Config files**: none under `$profile:/`. Like DarcChopper itself, this shim is configuration-LESS at runtime — all tuning was baked into the prefab in Workbench at build time.

**To re-tune the SDRC_ChopperComp parameters on this KA-52 variant**, you would need to:
1. Subscribe-to-Source `KA52forDarcChopper` via Workbench.
2. Open `Prefabs/Vehicles/Helicopters/KA52/KA52_UPK_X2_Patrol.et`.
3. Edit the `SDRC_ChopperComp` component values (see the parameter table in `mod_docs/DarcChopper.md` §3).
4. Save + republish (or run locally).

Default values shipped by the author are unverified pending in-game test; reasonable starting parameters for a KA-52 per `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` table:

| Parameter | Suggested KA-52 value | Notes |
|---|---|---|
| `Faction` | `USSR` | Match COE2's USSR enemy faction string |
| `Speed Min / Max` | ~30 / 80 m/s | KA-52 top speed ~310 km/h ≈ 86 m/s |
| `Fly Height Low / High` | 80 / 200 m | Gunship altitude band |
| `Enemy Search Type` | `VEHICLE_ARMORED` | KA-52 is anti-armor primary role |
| `Rocket Prefabs` | S-5 family (Warsaw-Pact) | Match airframe munition convention — `Ammo_Rocket_S5*` |
| `Rocket Count` | -1 (unlimited) | OR a finite count for balance |
| `Rocket Range` | ~2000-2500 m | S-5 effective range |

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM panel
2. Entity Browser → search "KA52_UPK_X2_Patrol" (NOT plain "KA52" — that may match the non-DarcChopper vanilla WCS_KA-52 prefab)
3. Place the KA-52 at a desired spawn point on the map
4. The heli takes off immediately (assuming `Auto Start = true` on the prefab — verify on first spawn)
5. Right-click the placed KA-52 → Waypoint menu → choose:
   - **Search And Destroy** — orbit a radius and engage targets (most common for gunship role)
   - **Suppressive Fire** — strafe an area with MG
   - **Artillery Fire** — fire S-5 salvo at a point
   - **Defend** — orbit and defend a position
   - **Move / Force Move / Move Relaxed** — repositioning
   - **Get Out** — land + disembark crew
6. For SAD: drag a radius circle to define the engagement area

**Keybinds / chat commands**: none — uses standard DarcChopper GM waypoint UX. See `mod_docs/DarcChopper.md` §4.

**Choosing between the two KA-52 prefabs**:
- `WCS_KA-52` base prefab → **player-piloted only**. AI sits in seat but won't fly autonomously.
- `KA52_UPK_X2_Patrol` (this shim) → **AI-flyable with waypoints**. Use this for any GM-driven CAS scenario.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays) per `MASTER_OBJECTIVE.md` and `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 1.
- **Must load AFTER**:
  - `WCS_KA-52` (`64CB35D07BAEE60F`) at L8 — the shim inherits its base prefab; if this isn't loaded first, the inherit-and-override fails and the shim's prefab cannot register.
  - `DarcChopper` (`689EDED542F881AF`) — provides `SDRC_ChopperComp` that this shim attaches.
  - `DarcCore` (`631EE12D448D7FCC`) — DarcChopper's hard dep. As of 2026-05-16, declared explicitly at L0 in deployed config (was transitive — explicit declaration hardens against Steam-eviction landmine per DarcChopper.md §7).
  - `WCS_Armaments`, `AKI_Core` — additional declared hard deps; both already in stack.
- **Must load BEFORE**: nothing in current stack — no reverse-deps known.
- **Conflicts with**: no known conflicts with the deployed 119-mod stack as of 2026-05-16.
- **Synergies with**: `DarcChopper` (mandatory consumer), `WCS_KA-52` (mandatory base), `AIMortarFireSupportSystem` (orthogonal indirect-fire pairing for full GM CAS suite).

**Declared in `serverconfig-deployed.json` only** — local stack has no `WCS_KA-52` (it's deployed-only), so this shim has no base prefab to inherit from locally. If the shim were declared in local serverConfig.json without WCS_KA-52, registration would fail at boot with a missing-parent-prefab error.

## 6. Performance impact

Negligible at framework level. Each AI-flown KA-52 adds roughly:
- 1 perception agent tick (DarcChopper handles the AI loop)
- 1 rotor physics body
- Rocket spawn cost equivalent to vanilla projectile cost

Per `mod_docs/DarcChopper.md` §6: stress envelope untested above ~6 simultaneously active DarcChopper helis. Two or three KA-52s in a single SAD orbit is a safe ceiling.

## 7. Known issues / landmines

- **HARD-DEP CHAIN IS FRAGILE — 5 deps must all resolve.** Missing any one causes registration failure. The Steam dedicated-server "addon.gproj missing" landmine (see `[[landmine_steam_dedicated_addon_gproj_missing]]` memory) is most likely to bite here — if Steam delivers KA52forDarcChopper or any of its deps without `addon.gproj`, the chain breaks silently and the prefab won't appear in Entity Browser. Detection: `script.log` will show a Cannot create entity line naming `KA52_UPK_X2_Patrol`.
- **DarcCore transitive-dep gotcha (now mitigated)**: pre-2026-05-16, `DarcCore` was on disk but not declared in `mods[]`. A future Steam re-download eviction would have cascade-killed this shim. Mitigation applied 2026-05-16 in snapshot `2026-05-16_15-59-52_pre-darcchopper-shims-2026-05-16`: DarcCore now declared explicitly at L0.
- **Mi-24/28 sister shim is BLOCKED — do not "complete the pair" by installing it.** `Mi24and28forDarcChopper` (`6720D3B2BEBC691E`) hard-deps `WCS_VehicleLock`, which is blacklisted in `CLAUDE.md` § "Known landmines" because it **breaks vehicle occupancy server-wide (only one player can enter any vehicle)**. The folder-presence landmine means even leaving Mi24and28forDarcChopper out of `mods[]` after Steam pulls it does NOT stop WCS_VehicleLock from compiling. Path forward for Mi-24 AI: custom Workbench shim per `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2.
- **Local stack moot**: as noted in §5, this shim's only base prefab (`WCS_KA-52`) is deployed-only. If the operator ever promotes WCS_KA-52 to the local stack, this shim should be promoted in lockstep.

## 8. Extending / modding

_N/A_ — this mod IS itself an extension shim. To extend it to additional KA-52 variants (e.g. a Patrol_Heavy variant with more rockets), Subscribe-to-Source the shim in Workbench, duplicate the prefab, tune the `SDRC_ChopperComp` parameters, save under a new path, republish. See `mod_docs/DarcChopper.md` §8 Option B for the canonical Workbench compat-shim procedure.

To build similar shims for the **6 uncovered airframes** (AH-64D, AH-6M, MH-60 DAP, AH-1S, UH-1Y, H-47), follow the per-airframe parameter table in `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` Phase 2.

## 9. Changelog / verified state

- **Installed version**: unspecified (Workshop description gives no version string as of 2026-05-16); `version: ""` per the WCS_Earplugs 1.0.4 pinning landmine.
- **Declared in `serverconfig-deployed.json`**: yes, added 2026-05-16 at L9 position 77 (right after DarcChopper).
- **Declared in `serverConfig.json` (local)**: no — WCS_KA-52 is deployed-only.
- **Last clean boot**: pending — added during the 2026-05-16 darcchopper-shim work; verification gates from the ask doc:
  - GM-spawn `KA52_UPK_X2_Patrol`
  - Confirm AI accepts SAD waypoint
  - Confirm `script.log` shows SDRC_ChopperComp init lines and no `Cannot create entity` referencing the prefab
- **Snapshot covering this addition**: `state_snapshots/2026-05-16_15-59-52_pre-darcchopper-shims-2026-05-16`

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/684F3C94BD457F85)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/684F3C94BD457F85/changelog)
- **Companion docs**:
  - `mod_docs/DarcChopper.md` — framework that this shim consumes (§3 parameter ref, §8 extension procedure)
  - `mod_docs/WCS_KA-52.md` — base airframe that this shim extends
  - `mod_docs/_asks/2026-05-16_darcchopper-heli-extension.md` — the operator-facing plan that prescribed this shim (Phase 1) and queued the 6 other airframes (Phase 2)
- **Cross-references in memory**:
  - `[[golden_state_2026_05_16_v5]]` — current golden snapshot (note: this shim was added AFTER the v5 snapshot was taken; v5's iter3 mod list doesn't include it)
  - `[[landmine_steam_dedicated_addon_gproj_missing]]` — chain-fragility risk
  - `[[feedback_snapshot_before_changes]]` — mandate that produced the pre-darcchopper-shims-2026-05-16 snapshot
  - `[[feedback_mod_evaluation_gate]]` — gate this mod passed in the ask doc
