---
workshop_id: "689EDED542F881AF"
workshop_url: https://reforger.armaplatform.com/workshop/689EDED542F881AF
version: "1.0.18"
author: "darc / mokdevel"
load_order_layer: L9
status: active
last_verified: 2026-05-16
declared_in:
  - local
  - deployed
hard_deps:
  - "631EE12D448D7FCC # DarcCore"
  - "58D0FB3206B6F859 # base game"
reverse_deps:
  - "684F3C94BD457F85 # KA52forDarcChopper (compat shim, not installed)"
  - "6720D3B2BEBC691E # Mi24and28forDarcChopper (compat shim, not installed)"
  - "691240864B9FFF22 # DarcChopperExample (tutorial, not installed)"
related_memories: []
github: https://github.com/mokdevel/DarcMods/tree/main/DarcChopper
---

# DarcChopper

> **One-line role**: drop-in component (`SDRC_ChopperComp`) that turns any helicopter prefab into an AI-flyable, GM-commandable air asset with waypoint-driven combat behavior.

## 1. Overview

DarcChopper is a **framework** — its value is unlocked by **attaching one component to a heli prefab**. With the component on, the heli will: auto-take-off, follow waypoints, search for and engage ground/air targets within configurable rocket/MG envelopes, evac on damage, and accept Game Master commands. The mod ships **no operator-visible content of its own** beyond a tutorial example world; integrations live in companion mods (one per heli airframe).

Critical detail: the engine resolves `SDRC_ChopperComp` from DarcChopper's data.pak at runtime. **A modded heli does NOT have the component baked in unless someone has built a Workbench compat-shim mod that re-saves the heli's prefab with SDRC_ChopperComp attached.** This is why only specific airframes (KA-52, Mi-24/28, Z-9, WZ-10) work out-of-the-box — they have published compat shims.

## 2. Functionality / Features

- **AI flying**: auto-takeoff, waypoint-following, hill/obstacle avoidance, fuel-aware (default unlimited)
- **AI combat (air-to-ground)**: MG strafing + rocket runs, with `Rocket Sector` (cone), `Rocket Range`, `Rocket Count` (-1 = unlimited), and `Rocket Delay` per heli
- **AI combat (air-to-air)**: heli vs heli engagement
- **GM commands** (waypoints):
  - **Move** — fly to point at default height
  - **Force Move** — fly to point ignoring obstacles
  - **Move Relaxed** — slower / curve fly
  - **Search And Destroy** — orbit & engage targets in radius
  - **Suppressive Fire** — strafe area with MG
  - **Artillery Fire** — fire rockets at point (single salvo)
  - **Get Out** — land + disembark crew
  - **Defend** — orbit and defend a point
- **Damage handling**: heli will evac (land + disembark) when damaged beyond a configurable threshold; crew survives
- **Crew spawning**: auto-spawns crew matching `Faction` parameter, OR uses operator-supplied `Crew` prefab array
- **Cargo seat fill**: enum `NONE / RANDOM / LOW / HALF / FULL` — passenger occupancy for transport tasks

## 3. Configuration

**Config files**: none in `$profile:/` — DarcChopper is config-LESS at the framework level. **All configuration is per-prefab** via `SDRC_ChopperComp` parameters set in Workbench when the prefab is authored.

**SDRC_ChopperComp parameters** (per-prefab, source: [P_HELICOPTER_FLY.md](https://raw.githubusercontent.com/mokdevel/DarcMods/main/DarcChopper/docs/P_HELICOPTER_FLY.md), verified 2026-05-16):

### Flight

| Parameter | Type | Meaning |
|---|---|---|
| `Auto Start` | bool | If enabled, heli starts flying immediately on spawn |
| `Throttle` | float | Acceleration — higher = reaches max speed faster |
| `Rotor Force0` | float | Main rotor upward force |
| `Rotor Force1` | float | Rear rotor force |
| `Speed Min` | float | Minimum flight speed |
| `Speed Max` | float | Maximum flight speed |
| `Fly Height Low` | float | Min altitude (from ground/sea) |
| `Fly Height High` | float | Max altitude |
| `Distance Low` | float | Min waypoint distance |
| `Distance High` | float | Max waypoint distance |

### AI

| Parameter | Type | Options/Meaning |
|---|---|---|
| `Faction` | string | Override crew faction |
| `Cargo Seat Fill` | enum | `NONE / RANDOM / LOW / HALF / HIGH / FULL` |
| `Crew` | prefab[] | Custom crew prefabs (empty = random AI of `Faction`) |
| `AI Skill` | float | Combat proficiency (vanilla 0.0-1.0 scale) |
| `AI Perception` | float | Reaction speed |
| `Enemy Search Type` | enum | `NONE / ANY / PLAYER / ANY_CHAR / VEHICLE / VEHICLE_ARMORED` |

### Weapons

| Parameter | Type | Meaning |
|---|---|---|
| `Rocket Sector` | float (deg) | Firing cone angle (left-right symmetry) |
| `Rocket Delay` | float (sec) | Time between salvos |
| `Rocket Position X` | float | Distance from nose to rocket spawn |
| `Rocket Position Y` | float | Target Y (height) modifier |
| `Rocket Position Z` | float | Left/right offset |
| `Rocket Prefabs` | string[] | Rocket prefab resource paths (see "tested rocket prefabs" below) |
| `Rocket Count` | int | Available rockets (-1 = unlimited) |
| `Rocket Range` | float | Max firing distance |

### Tested rocket prefab paths

```
{ECD8628EBF7E5F6B}Prefabs/Weapons/Ammo/Ammo_Rocket_Hydra70.et
{072A755D5CB85D47}Prefabs/Weapons/Ammo/Ammo_Rocket_Hydra70_HE_M229.et
{61AF60E0235DC3B1}Prefabs/Weapons/Ammo/Ammo_Rocket_Hydra70_HEDP_M247.et
{C9A1612DC5340613}Prefabs/Weapons/Ammo/Ammo_Rocket_S5.et
{EF17BED6DCEE4DE4}Prefabs/Weapons/Ammo/Ammo_Rocket_S5_FRAG_S5MO.et
{EE65544BA845C458}Prefabs/Weapons/Ammo/Ammo_Rocket_S5_HEDP_S5KO.et
```

Hydra-70 family = NATO; S-5 family = WARSAW PACT. Match airframe to munition convention or accept the visual mismatch.

## 4. Operator usage

**In-game (Game Master)**:
1. Open GM panel (default keybind `M` then GM mode)
2. Entity Browser → search "Chopper" or the airframe name (e.g. "KA52_UPK_X2_Patrol")
3. Place the helicopter at desired spawn point
4. If `Auto Start = true` on the prefab, the heli takes off immediately
5. Right-click the heli → Waypoint menu → select command (Move / SAD / Suppress / Artillery / Defend / Get Out)
6. For SAD: drag a radius circle to define the search area

**Keybinds**: no DarcChopper-specific keybinds — uses standard GM waypoint UX. Default GM keybind is `M` (entity manager).

**Chat / admin**: no `#commands` from this mod.

## 5. Compatibility & load order

- **Load order layer**: **L9** (AI overlays) per `MASTER_OBJECTIVE.md`. Heli content packs at L8 must load before this.
- **Must load before**: nothing in our stack — DarcChopper is consumed by per-prefab Workbench changes baked into compat shims at L8/L9.
- **Must load after**: `DarcCore` (its hard dep). DarcCore is now declared explicitly in `mods[]` at L0 position 9 (both local + deployed) as of 2026-05-16 — hardened against Steam re-download eviction. (Prior to 2026-05-16 it was a transitive-only dep; that's now fixed.)
- **Conflicts with**: no known conflicts with current stack.
- **Synergies with**: any L8 heli pack with a published compat shim (currently: WCS_Mi-24V → Mi24and28forDarcChopper; WCS_KA-52 → KA52forDarcChopper). Other heli mods need a custom Workbench shim.

## 6. Performance impact

Empirically negligible at framework level. Each AI-flown heli adds:
- ~1 AI agent's worth of perception tick
- 1 rotor physics body per active heli
- Rocket spawn cost = vanilla projectile cost

Stress envelope: untested above ~6 simultaneously active DarcChopper helis on this stack. Worth a monitor session if running large air ops.

## 7. Known issues / landmines

- ~~DarcCore transitive-dep gotcha~~ — **RESOLVED 2026-05-16**: DarcCore now declared explicitly in both `serverConfig.json` (local L0:9) and `serverconfig-deployed.json` (L0:9). Steam will no longer evict it.
- **No JSON config means no operator-side tuning of unmodded prefabs.** You cannot make `Vanilla_UH-1H.et` AI-fly by editing a JSON file — the component must be on the prefab at build time. This is the central extension constraint.
- **Air-to-air targets fly low.** Author note: AI doesn't navigate at very high altitudes well.
- **`Crew` parameter expectations** — supplying a `Crew` prefab array that doesn't match the heli's compartments (number of crew seats) causes seating failures. Leaving `Crew` empty + setting `Faction` is the safer default.

## 8. Extending / modding — the central question

To add DarcChopper support for **a new helicopter** that doesn't already have a compat shim:

### Option A — Use an existing compat shim (no Workbench)

If a shim mod exists for your airframe (KA-52, Mi-24/28, Z-9, WZ helis), just install it and add to `serverConfig.json mods[]`. Done.

### Option B — Build a custom compat shim in Workbench (~1-2h per airframe)

Procedure (from the GitHub README + DarcChopperExample):

1. **Install** Reforger Tools (Workbench) — already installed on this machine (`C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Tools`).
2. **Subscribe-to-Source** the upstream heli mod via Workbench (e.g. for AH-64D: subscribe to `WCS_AH-64D` source).
3. **Create a new addon project** (e.g. `AH64forDarcChopper`) that depends on:
   - The base heli mod (the one shipping the prefab to extend)
   - `DarcCore` + `DarcChopper`
4. **Open** the upstream heli's prefab in Workbench's prefab editor (e.g. `Prefabs/Vehicles/Helicopters/AH64/AH64D_Patrol.et`).
5. **Inherit-and-override** the prefab: in your new addon, create a child prefab that derives from the upstream one.
6. **Add component** `SDRC_ChopperComp` to the inherited prefab root.
7. **Configure parameters** per §3 above:
   - `Rotor Force0` / `Force1` — tune for the airframe (a Mi-24 needs more lift than a Little Bird)
   - `Speed Min/Max` — match the airframe's documented top speed
   - `Faction` — match the heli's intended user (e.g., `US` for AH-64D, `USSR` for KA-52)
   - `Rocket Prefabs` — pick from the tested list matching the airframe's munition convention (Hydra for NATO, S-5 for Warsaw Pact)
   - `Enemy Search Type` — typically `VEHICLE_ARMORED` for gunships, `ANY_CHAR` for utility helis
8. **Build + publish** to Workshop (or keep local) and add the new mod's GUID to `serverConfig.json mods[]`.

The mod **DarcChopperExample** (`691240864B9FFF22`) is the canonical reference — opens the "ArlandEmpty" world with two pre-configured DarcChoppers running programmed actions.

### Option C — Defer (heli stays operator-only)

The heli remains spawnable by GM but won't AI-fly. Acceptable for transport helis or rarely-used airframes.

## 9. Changelog / verified state

- **Installed version**: 1.0.18 (as of folder `DarcChopper_689EDED542F881AF`, mtime 2026-05-13)
- **Last clean boot**: continuously loaded since 2026-05-13 COE2 pivot
- **Workshop changelog**: https://reforger.armaplatform.com/workshop/689EDED542F881AF/changelog

## 10. References

- [Workshop page](https://reforger.armaplatform.com/workshop/689EDED542F881AF)
- [GitHub repo](https://github.com/mokdevel/DarcMods/tree/main/DarcChopper)
- [P_HELICOPTER_FLY.md docs](https://raw.githubusercontent.com/mokdevel/DarcMods/main/DarcChopper/docs/P_HELICOPTER_FLY.md) — primary parameter reference
- [DarcChopperExample (tutorial)](https://reforger.armaplatform.com/workshop/691240864B9FFF22)
- [Mi24and28forDarcChopper (compat shim ref)](https://reforger.armaplatform.com/workshop/6720D3B2BEBC691E)
- [KA52forDarcChopper (compat shim ref)](https://reforger.armaplatform.com/workshop/684F3C94BD457F85)
- CLAUDE.md "What this is" section — DarcChopper listed as GM-fired heli CAS tool
