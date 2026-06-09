# Ask: AI in vehicles honk horn endlessly + get stuck

**Date**: 2026-05-16
**Operator report**: "the AI when in vehicles honk the horn endlessly, and repeatedly get stuck"
**Investigation method**: orchestrator playbook — 4 specialist subagents in parallel
**Status**: root causes identified (multi-root); recommended action below

---

## TL;DR

The symptom has **2-3 contributing roots**, NOT one. In descending confidence:

1. **CatchaRide exterior-seat injection** (HIGHEST confidence) — adds exterior passenger seats to Bradley/M1/T-72/BTR/LAV. AI driver pathfinding can prioritize the new exterior seat over the actual driver slot. Result: vehicle has no driver → squad leader honks endlessly waiting for crew. Author's own roadmap admits this bug.
2. **Vanilla forward-reverse pathfinding stuck loop** — well-known Reforger bug, partially mitigated 1.6.0.48-54 but not fully fixed in 1.6.0.119. A purpose-built community mod exists.
3. **CRX EAI tight column coupling × SDRC empty include filters × COE2 high vehicle density** — amplifier, not root cause. Stuffs unmaintained vehicle prefabs into AI-crewed patrols, with tight CRX column coupling that compounds blockages.

**The honking itself is by-design** per BI dev quote on Feedback Tracker T177755: *"we didn't want friendly soldiers to give up fighting when a friendly vehicle is driving by, which is why we added the car horn reaction."* What feels like a bug is the **endlessness** — vanilla has no abort timer, so when CatchaRide leaves a vehicle driverless OR vanilla pathfinding traps a driver in forward-reverse oscillation, the honking loops forever.

---

## Recommended order of operations (by ROI)

### A. Disable CatchaRide as A/B test (10 min, fully reversible) — DO FIRST

This is the highest-confidence direct cause. The author's Workshop description explicitly mentions the AI seat-priority bug in their roadmap. Folder-presence landmine applies — must DELETE the folder, not just remove from `mods[]`.

```powershell
.\snapshot_state.ps1 -Label "pre-catcharide-disable-2026-05-16"
# Remove from both serverConfig.json + serverconfig-deployed.json mods[] (modId 661B062B26BDB12F)
# Then:
Stop-Process -Name ArmaReforgerServer -Force -ErrorAction SilentlyContinue
Start-Sleep 5  # pak handle release
Remove-Item "profile_new\addons\CatchaRide_661B062B26BDB12F" -Recurse -Force
.\start_server.ps1
```

**Verification**: GM-spawn a Bradley patrol; have AI mount + drive. Watch for honking. If gone → CatchaRide confirmed; keep removed.

If gone, you also lose the exterior-seat ride-along feature. If you want it back, monitor [CatchaRide Workshop](https://reforger.armaplatform.com/workshop/661B062B26BDB12F) for a release past v1.0.5 that ships the "AI prioritizes interior seats" fix.

### B. Install "Competent AI Driving" mod (15 min)

Independent of CatchaRide — addresses the vanilla forward-reverse stuck loop on any AI-driven vehicle.

**5-section evaluation gate**:
1. **Workshop ID**: `68FCF11534562F2E` — verified via [Workshop page](https://reforger.armaplatform.com/workshop/68FCF11534562F2E)
2. **Conflict analysis**: small script-only mod (March 2026); forces wider turns to break the forward-reverse loop. No documented mod conflicts.
3. **Risk**: low. Tweaks vanilla AI driving subsystem; rollback is `restore_state.ps1`.
4. **Execution**:
   - Snapshot
   - Add to `serverConfig.json` + `serverconfig-deployed.json` `mods[]` at L9 (AI overlay layer), with `version: ""`
   - Boot test
5. **Troubleshooting**: cache count delta + no `VM Exception` referencing the mod's scripts.

### C. Curate SDRC vehicle bucket includes (30 min) — only if A+B don't resolve

`profile_new/profile/DarcMods/default/dc_vehicleList.json` currently has **empty `include` filters** on `VEHICLE_WHEELED_ARMED` (193 prefabs), `VEHICLE_WHEELED_MILITARY_ALL` (471 prefabs), `VEHICLE_CHOPPER_ARMED` (8 prefabs). Means every modded vehicle in the stack — including ones with poor driver-AI tuning — is eligible for SDRC AI-crewed patrols.

Edit to add `include` allow-lists with vehicles whose driver pathing is known good:
```json
"VEHICLE_WHEELED_ARMED": {
  "include": ["BTR70", "BTR80", "BRDM2", "M1025_Armed", "Technical_"],
  "exclude": [...existing..., "_Open", "_Soft"]
}
```

Tune `m_iCOE_EnemyArmedVehicleCount` down via the COE2 in-game commander UI (votable, no restart).

### D. CRX softening (5 min) — last-resort, optional

If A+B+C aren't enough:
- `Formation_Scale` 2.0 → 2.5 or 3.0 in `CRX_EAIGroupConfig.txt` — widens vehicle column spacing, fewer blocking events
- Note: this also widens dismounted-infantry formations; may impact perceived squad tightness

**Don't change `Combat_Mode` for this**. Specialist 1 speculated YELLOW would help but Specialist 4 noted GREEN/defensive is the realism-tuned value. Realism > honk frequency.

---

## Per-specialist findings (raw)

### Specialist 1 — CRX EAI deep dive

**Relevance**: high (initially hypothesized as root cause; downgraded after Specialist 2 evidence)

**Key facts**:
- CRX v1.3.71 added: "Mechanized Infantry stays with vehicle", "Column Driving 2.0", "Vehicle Speed waypoints", "Multiple A.I. Column Driving fixes"
- No `Vehicle_*` kill-switch in any of the 3 .txt config files
- Only documented per-character vehicle control is GM "Force Stay In Vehicle" toggle
- Formation_Scale widens column spacing per v1.3.71 changelog
- Author Discord is the only path to a CRX-side fix

### Specialist 2 — Vanilla AI bug status (THE REFRAMER)

**Relevance**: high — re-routed the entire investigation

**Key facts**:
- **The honk is BY DESIGN** per BI dev quote on [T177755](https://feedback.bistudio.com/T177755): "we added the car horn reaction" intentionally as friendly-avoidance
- **The stuck behavior is a separate vanilla pathfinding bug** — partially mitigated 1.6.0.48-54 but not fully fixed in 1.6.0.119
- **"Competent AI Driving" mod** (`68FCF11534562F2E`, March 2026) is the purpose-built community fix for the forward-reverse loop
- CRX EAI does NOT touch vehicle pathfinding — only formation/perception/aim/morale
- 1.6.0.119 changelog has zero AI-driver/pathfinding entries

### Specialist 3 — Vehicle reskin chain (THE ROOT-CAUSE-FINDER)

**Relevance**: high — identified the most-confident direct cause

**Key facts**:
- **CatchaRide is mis-documented in mod_docs/CatchaRide.md** — actual Workshop description says it "adds exterior passenger seats atop armored vehicles" (Bradley, M1, T-72, BRDM, BTR-70, LAV-25), NOT "hail a ride"
- **Author's own roadmap admits** the AI seat-priority bug: "Prevent AI from prioritizing exterior seats over interior seats when ordered to mount a vehicle."
- AI assigns driver to the new exterior seat → vehicle is driverless → squad leader honks for missing crew → loops
- HorsemansBlackBradley reskin inherits the M2A2 base prefab → inherits CatchaRide's modified compartments → symptom appears on the reskin too
- Horsemansblackcougar and VT4FRMblackReskin are texture-only (not directly implicated)
- TraceVehCore is localization-only (not implicated)

### Specialist 4 — Scenario controller AI vehicle interaction

**Relevance**: high (amplifier rather than root cause)

**Key facts**:
- **COE2 spawns AI-crewed armed-vehicle patrols** via `m_iCOE_EnemyArmedVehicleCount`
- **SDRC vehicle buckets have empty `include` filters** — every modded vehicle is a candidate, including ones with poor driver pathing
- Bucket counts (from logs): `VEHICLE_WHEELED_ARMED: 193`, `VEHICLE_WHEELED_MILITARY_ALL: 471`, `VEHICLE_CHOPPER_ARMED: 8`
- **`COE2 FIX`** Workshop mod (`68C6B5938D681237`) exists as a community patch for COE2 issues — operator should evaluate if A+B+C don't resolve
- FSTacticalAISpawnManager doesn't spawn mounted patrols (state-machine overlay only)
- ConflictNoBaseAILimit is dormant on COE2 stack

---

## Cross-specialist conflicts resolved

Per orchestrator playbook §"How the lead synthesizes" rule 2 — flag conflicts, don't silently pick.

| Conflict | Resolution |
|---|---|
| Specialist 1 says CRX is root cause; Specialist 2 says it's vanilla | **Specialist 2 wins** on direct-evidence (BI dev quote on T177755). Specialist 1 misread CRX's vehicle features as the cause when CRX doesn't touch pathfinding. CRX is an amplifier via formation density, not a root cause. |
| Specialist 1 recommends Combat_Mode = 1 (YELLOW); Specialist 4 says GREEN is operator-tuned for realism | **Don't change Combat_Mode for this**. Realism > honk reduction. If honking is intolerable AFTER A+B+C, revisit. |

---

## Citations (full)

- **Honk is by-design**: BI Feedback Tracker [T177755](https://feedback.bistudio.com/T177755) — dev quote re car horn reaction being intentional
- **v1.3.0.130 fix (March 2025)**: "Deactivated AIs causing AI drivers to stop and honk" — [changelog](https://reforger.armaplatform.com/news/changelog-march-27-2025)
- **CatchaRide actual scope + AI seat-priority bug**: [Workshop page](https://reforger.armaplatform.com/workshop/661B062B26BDB12F)
- **Competent AI Driving fix mod**: [Workshop page](https://reforger.armaplatform.com/workshop/68FCF11534562F2E)
- **CRX EAI v1.3.71 vehicle features**: [CRX changelog](https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4/changelog)
- **SDRC vehicle bucket populations**: `profile_new/logs/logs_2026-05-15_15-22-32/script.log:6161,6691,7705`
- **SDRC empty include filters**: `profile_new/profile/DarcMods/default/dc_vehicleList.json:5-143`
- **HorsemansBlackBradley M2A2 inheritance**: `profile_new/addons/HorsemansBlackBradley_68C510533F2D16C5/addon.gproj:6`
- **COE2 enemy vehicle count param**: `mod_docs/COE2_-_Combat_Ops_Enhanced_2.md` §2-3, §7
- **COE2 FIX community patch**: [Workshop page](https://reforger.armaplatform.com/workshop/68C6B5938D681237)
- **CatchaRide doc fix needed**: `mod_docs/CatchaRide.md` (described as hail-a-ride; actually exterior-seat injection)

---

## Follow-up actions

- [ ] **Operator decision**: proceed with A (CatchaRide disable A/B)?
- [ ] **Fix `mod_docs/CatchaRide.md`** — wrong description; need to rewrite §1-§2 and add §7 known issue. (Lead can do as a doc-only edit, no operator input needed.)
- [ ] If A doesn't resolve: install B (Competent AI Driving)
- [ ] If A+B don't resolve: do C (SDRC curation) + D (CRX softening)
- [ ] Long-term: monitor BI T177755 + experimental branch changelogs for proper avoidance fix
- [ ] Long-term: consider opening a CRX author Discord report with current config + symptom (if CRX is identified as material amplifier post-A/B)
