# Ask: Extend DarcChopper to cover all installed modded helicopters

**Date**: 2026-05-16
**Operator**: AcridVaporiZe
**Status**: plan produced; operator decision pending on which path per airframe

---

## TL;DR

Your stack has **8 modded helicopter airframes**. DarcChopper integration breaks into three buckets:

| Airframe | Bucket | Action |
|---|---|---|
| WCS_KA-52 (Hokum) | ✅ **Existing compat shim** | Install `KA52forDarcChopper` (`684F3C94BD457F85`) — deployed only |
| WCS_Mi-24V (Hind) | ⚠️ **Shim exists but BLOCKED** | `Mi24and28forDarcChopper` hard-deps **WCS_VehicleLock** (blacklisted in CLAUDE.md). Custom Workbench shim needed instead. |
| LeesUH-1YVenom | ❌ Custom Workbench shim needed | ~1-2h per airframe (or defer) |
| WCS_AH-64D (Apache) | ❌ Custom Workbench shim needed | ~1-2h |
| AH-6M_LittleBird | ❌ Custom Workbench shim needed | ~1-2h |
| H-47Chinook | ❌ Custom Workbench shim needed (transport) | ~1-2h |
| SikorskyMH60DAPProject (MH-60 DAP) | ❌ Custom Workbench shim needed | ~1-2h |
| WCS_AH-1S (Cobra) | ❌ Custom Workbench shim needed | ~1-2h (deployed-only mod) |

**Recommendation**: phase 1 = install the 2 existing compat shims (~30 min, no Workbench). Phase 2 (optional, 6-12h total) = author custom shims for the 6 airframes you most want AI to fly. The remaining ones stay operator-spawn-only — still usable, just no AI.

---

## Why this is the shape of the problem

DarcChopper's integration is **per-prefab via the `SDRC_ChopperComp` component** (see `mod_docs/DarcChopper.md`). There is **no operator-side JSON** that turns an arbitrary heli into a DarcChopper-flyable one — the component has to be attached in Workbench when the prefab is authored. That's why every compat shim on the Workshop is a separate mod: each one re-publishes a heli prefab with the component attached.

This is different from how the user's `dc_vehicleList.json` (SDRC framework's vehicle catalog) works — that one IS operator-editable and IS read at runtime. But it's a discovery list for SDRC's broader catalog, not a switch for DarcChopper-specific behavior.

---

## Phase 1 — Install the 2 existing compat shims

### Risk assessment

| Mod | Adds | Hard deps | Risk |
|---|---|---|---|
| `KA52forDarcChopper` (`684F3C94BD457F85`) | `KA52_UPK_X2_Patrol` prefab variant with SDRC_ChopperComp | WCS_Armaments, AKI_Core, DarcCore, WCS_KA-52, DarcChopper | Low — all deps present (WCS_KA-52 is deployed-only; AKI_Core present locally) |
| `Mi24and28forDarcChopper` (`6720D3B2BEBC691E`) | Mi-24/28 prefab variants with SDRC_ChopperComp | Pending verification — likely DarcCore, DarcChopper, WCS_Mi-24V | Low pending dep verification |

### Per the operator's mandatory 5-section gate (`feedback_mod_evaluation_gate` memory)

#### KA52forDarcChopper

1. **Workshop ID**: `684F3C94BD457F85` — verified via [Workshop page](https://reforger.armaplatform.com/workshop/684F3C94BD457F85)
2. **Conflict analysis**: only present in `serverconfig-deployed.json` candidate (since WCS_KA-52 is deployed-only). Adds one new prefab path; no override of vanilla. No mod in the current 117-mod deployed set conflicts.
3. **Risk assessment**: Low. 28.51 KB mod, single compat shim. Worst case: prefab fails to register, KA-52 falls back to non-DarcChopper spawn (no regression).
4. **Execution strategy**:
   - **DEPLOYED only** (WCS_KA-52 not in local stack). Add to `serverconfig-deployed.json mods[]` at L9 (after WCS_KA-52 at L8, after DarcChopper).
   - `version: ""` (per the WCS_Earplugs 1.0.4 landmine — never pin).
   - `snapshot_state.ps1 -Label "pre-darcchopper-shims-2026-05-16"` first.
5. **Troubleshooting checklist**:
   - [ ] Boot the server post-install; confirm `Cached <N> items` count unchanged or increased
   - [ ] GM-spawn `KA52_UPK_X2_Patrol` — verify it AI-flies and accepts SAD waypoint
   - [ ] Check `script.log` for `SDRC_ChopperComp` init lines (positive signal)
   - [ ] Verify no `VM Exception` or `Cannot create entity` lines naming the KA-52 prefab

**Final recommendation**: **install** for deployed only.

#### Mi24and28forDarcChopper — ⚠️ DO NOT INSTALL

1. **Workshop ID**: `6720D3B2BEBC691E` — verified via [Workshop page](https://reforger.armaplatform.com/workshop/6720D3B2BEBC691E-Mi24and28forDarcChopper)
2. **Conflict analysis**: **BLOCKED**. The mod's full hard-dep list (verified via Workshop page fetch 2026-05-16):
   - SpaceCore ✅
   - **Mi-28 ❌ NOT in our stack** (would be no-op'd; not a blocker by itself)
   - **WCS_VehicleLock ❌ BLACKLISTED** in `CLAUDE.md` § "Known landmines" — *"Breaks vehicle occupancy — only one player can enter"*
   - WCS_Mi-24V ✅
   - WCS_Armaments ✅
   - AKI_Core ✅
   - DarcCore ✅
   - DarcChopper ✅
3. **Risk assessment**: **HIGH**. Installing forces Steam to pull `WCS_VehicleLock`. Per the *"folder-presence triggers script execution regardless of declaration"* landmine (CLAUDE.md 2026-05-13), even leaving the mod out of `mods[]` after install does not stop its scripts from compiling → vehicle occupancy breaks server-wide. Cascades to entire vehicle fleet — far worse blast radius than a Mi-24 not having DarcChopper integration.
4. **Execution strategy**: **DEFER**. Build a custom Workbench shim for Mi-24V instead, following the procedure in `mod_docs/DarcChopper.md` §8 Option B. ~1-2h work; carries no WCS_VehicleLock dep.
5. **Troubleshooting checklist**: N/A — not installing.

**Final recommendation**: **DO NOT install.** This is exactly the kind of landmine the per-mod doc architecture is designed to catch — a sensible-sounding compat shim that quietly pulls a blacklisted dep. Add Mi-24V to the Phase 2 custom-shim queue alongside AH-64D, AH-6M, UH-1Y, MH-60 DAP, AH-1S, H-47.

### Phase 1 implementation — STATUS: applied 2026-05-16 15:59 UTC

Snapshot: `state_snapshots/2026-05-16_15-59-52_pre-darcchopper-shims-2026-05-16`

**Edits applied**:
- `serverConfig.json` (local): 103 → 104 mods. **DarcCore (`631EE12D448D7FCC`)** inserted at L0 position 9 (explicit declaration; was transitive dep).
- `serverconfig-deployed.json` (deployed): 117 → 119 mods. **DarcCore** at L0 position 9 + **KA52forDarcChopper (`684F3C94BD457F85`)** at L9 position 77 (right after DarcChopper).
- Mi-24 shim **NOT installed** — see WCS_VehicleLock landmine above.

**Pending operator action**:
- [ ] **Local**: `.\start_server.ps1` next time you're ready to verify. Watch monitor stack for cache count delta + any `VM Exception` referencing DarcCore. Expected: same `Cached <N>` count; no errors.
- [ ] **Deployed**: push `serverconfig-deployed.json` via Pterodactyl panel; restart container; GM-spawn KA-52 → verify it accepts SAD waypoint and auto-flies.
- [ ] **Rollback if needed**: `.\restore_state.ps1 -Snapshot 2026-05-16_15-59-52_pre-darcchopper-shims-2026-05-16`

---

## Phase 2 — Custom Workbench shims for the 6 uncovered airframes

This is **Workbench work** (you have Arma Reforger Tools installed at `C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Tools`). The procedure is documented in `mod_docs/DarcChopper.md` §8 Option B. Per-airframe time estimate: **1-2 hours**, including in-game test.

### Build-order recommendation (by ROI)

I'd rank the airframes by how much value DarcChopper adds:

1. **WCS_AH-64D Apache** — heavy gunship, ideal SAD/Suppress role. Highest gameplay value. Build first.
2. **AH-6M Little Bird** — fast, low-profile gunship for tight infiltration. Different envelope from Apache.
3. **SikorskyMH60DAPProject (MH-60 DAP)** — Direct Action Penetrator variant, gunship.
4. **WCS_AH-1S Cobra** — deployed-only. Build only if you're still using the deployed stack.
5. **LeesUH-1YVenom** — utility/transport; benefits less from DarcChopper since transport role is less SAD-driven, but still useful for AI-piloted insertion missions.
6. **H-47Chinook** — pure transport. Lowest ROI for SDRC_ChopperComp (no rockets to configure); only useful if you want AI-piloted Chinook waypoint runs.

### Per-airframe parameter recommendations (starting points)

These are reasonable initial values to plug into `SDRC_ChopperComp` for each airframe. Tune in-game after first test.

| Airframe | RotorForce0 / 1 | Speed Min/Max | Fly Height Low/High | Rocket Prefab | Rocket Count | Enemy Search |
|---|---|---|---|---|---|---|
| WCS_AH-64D | high lift, high rear | 30 / 90 m/s | 80 / 200 m | Hydra70_HEDP_M247 | -1 | VEHICLE_ARMORED |
| AH-6M | low lift, agile rear | 40 / 75 m/s | 50 / 150 m | Hydra70_HE_M229 | 24 | ANY_CHAR |
| MH-60 DAP | medium lift | 35 / 80 m/s | 80 / 180 m | Hydra70 (mixed) | -1 | ANY |
| WCS_AH-1S | medium lift | 30 / 80 m/s | 80 / 180 m | Hydra70 | -1 | VEHICLE_ARMORED |
| LeesUH-1YVenom | medium lift, agile | 30 / 75 m/s | 60 / 150 m | _none_ (door gunner only) | 0 | ANY_CHAR |
| H-47Chinook | very high lift | 25 / 65 m/s | 100 / 250 m | _none_ | 0 | NONE (no offensive role) |

**Faction parameter per airframe**:
- US-side: AH-64D, AH-6M, MH-60, AH-1S, UH-1Y → `US` (or whatever your COE2 BLUFOR string is)
- USSR-side: KA-52, Mi-24V → `USSR`
- Either-side: H-47 (most operators are US but Iran/Iraq use it too) → `US` default; override per scenario

**Crew parameter**: leave **empty** initially — the engine spawns random AI matching `Faction`. Empty + Faction is the safer default (per `mod_docs/DarcChopper.md` §7 landmines).

### Workbench build outline (per airframe)

```
1. Reforger Tools → Workbench → New Project
   Name: <Airframe>forDarcChopper  (e.g. AH64DforDarcChopper)
   Project type: Addon

2. Dependencies (in addon.gproj):
   - DarcCore (631EE12D448D7FCC)
   - DarcChopper (689EDED542F881AF)
   - <upstream heli mod GUID, e.g. WCS_AH-64D = 6303360DA719E832>
   - Base game (58D0FB3206B6F859)

3. Subscribe-to-Source the upstream heli mod
   Browse Workshop → <heli mod> → Right-click → Subscribe to source

4. Find the upstream heli's primary _Patrol or _AI prefab
   (typically Prefabs/Vehicles/Helicopters/<Airframe>/<Airframe>_X_Patrol.et)

5. In your project: create child prefab
   File → New → Prefab → Inherit → select the upstream prefab

6. Open child prefab → Add Component → SDRC_ChopperComp
   Configure parameters per the table above

7. Save prefab in your project's Prefabs/ tree
   (e.g. AH64DforDarcChopper/Prefabs/Vehicles/Helicopters/AH64D/AH64D_Patrol_DC.et)

8. Build the addon (Workbench → Build → Build Project)

9. Test locally:
   - Launch Workbench's "Run game with mod" — opens the example world
   - Spawn your new prefab in GM
   - Issue an SAD waypoint
   - Verify: takes off, flies to target, engages, returns

10. Publish to Workshop (Workbench → Publish) OR keep local

11. Add to serverConfig.json mods[] with version: ""
```

### Tuning tips (post-deploy)

- If heli **flies too low and clips trees**: bump `Fly Height Low` by 20-40m
- If heli **misses fast targets**: reduce `Rocket Delay` and increase `AI Skill`
- If heli **takes ages to engage**: tighten `Rocket Range` to a more realistic envelope (e.g. 1500m for Hydra-70)
- If heli **explodes mid-air on rocket launch**: `Rocket Position X` too small — increase to spawn rocket further from nose
- If heli **cannot find targets**: change `Enemy Search Type` to `ANY` or `ANY_CHAR`

---

## Open questions / verification gaps

1. **Mi24and28forDarcChopper full dep list**: I asserted DarcCore+DarcChopper+WCS_Mi-24V. Verify by reading the mod's `addon.gproj` after install (it's tiny; takes 30s). If it also deps on a vanilla Mi-28 mod we don't have, that prefab will be a no-op — not a boot failure but worth knowing.
2. **DarcCore is currently a transitive dep (not in `mods[]`)**. Strongly recommend declaring it explicitly during Phase 1 to harden against Steam re-download eviction (see DarcChopper.md §7 landmine).
3. **WCS_AH-64D Apache "Upgrade" variant** — there's a separate `WCS_AH-64D_Upgrade` mod (`6326F0C7E748AB8A`) on the Workshop. You don't have it. Worth knowing it exists in case Apache base is short on prefab variants.
4. **CRX EAI x SDRC_ChopperComp interaction** — CRX EAI's perception system has a known NULL deref (cosmetic, per CLAUDE.md). Test whether high heli density (say, 4 SDRC choppers + ground AI) elevates the rate. If yes, consider `CRX_EAI/Combat_Mode = 1` for heli-heavy ops.

---

## Citations

- **DarcChopper mechanics + SDRC_ChopperComp parameters**: `mod_docs/DarcChopper.md` §3-§8
- **Component-not-JSON architecture**: [P_HELICOPTER_FLY.md](https://raw.githubusercontent.com/mokdevel/DarcMods/main/DarcChopper/docs/P_HELICOPTER_FLY.md) verbatim
- **Existing compat shims**: Workshop search 2026-05-16 (KA-52, Mi-24/28, Z-9, WZ — only first two apply to user's stack)
- **Heli mod inventory**: `serverConfig.json` + `serverconfig-deployed.json` 2026-05-16
- **5-section evaluation gate**: `memory/feedback_mod_evaluation_gate.md`
- **Snapshot-before-changes mandate**: `memory/feedback_snapshot_before_changes.md`
- **Version-pin landmine**: `CLAUDE.md` §"Landmines discovered 2026-05-13"
- **Workbench install path**: probed `C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Tools` — Workbench present
