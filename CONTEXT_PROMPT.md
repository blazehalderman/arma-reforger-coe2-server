# Arma Reforger Modded Dedicated Server — Complete Operator Context

> **STATUS 2026-05-16: HISTORICAL.** Stack pivoted to COE2 Eden + iter3 deployed adds (117 mods). See CLAUDE.md and golden_state_2026_05_16_v5 memory for current state.
>
> **STATUS 2026-05-14: PARTIALLY STALE.** This doc was authored 2026-05-13 when the active scenario was PVE Conflict Remixed Vanilla 2.0 + IPC AutonomousCaptureAI + LinearConflictPVE. **The stack has since pivoted to COE2 (Combat Ops Enhanced 2 by Kex) on Eden** — see `MASTER_OBJECTIVE.md` (revision 2026-05-14) and memory `golden_state_2026_05_14_v4.md` for the current canonical state. Mod count moved from 113 to 121, ACE Dev pair was replaced by stable ACE Core + 4 ACE feature mods, and PMC + Misfits chain were removed (Workshop-blocked). Treat the architecture, landmines, workflows, and tooling sections below as still mostly accurate; treat scenario-specific guidance and per-mod IPC tuning as historical.

> **Use this as a system prompt or first-message context for any new agent / session that needs full operational understanding of this server.** It captures the goal, the architecture, the landmines, the workflows, the tooling, the resolved decisions, and the open questions. Self-contained — readable cold.

---

## 1. WHO + WHERE

This is a **single-operator, solo-or-small-group, modded Arma Reforger 1.6.0.119 dedicated server** running on a Windows host at `C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\`. The operator owns both server and client. Steam-side BattlEye is OFF, PC-only, crossplay OFF.

- **Server name in browser**: from `serverConfig.json` `game.name`
- **Network**: bind `0.0.0.0:2001`, public `76.235.218.202:2001`, A2S query `0.0.0.0:17777`, LAN `192.168.0.120:2001`
- **Admin**: `passwordAdmin: admin123` (weak by operator's explicit choice; in MOTD)
- **Operator UID**: `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` (nickname `AcridVaporiZe`)

---

## 2. THE OVERARCHING GOAL

**Build a dense, intelligent, varied, realistic, persistent-friendly Arma Reforger PvE combat experience** that exercises the maximum of what the modding ecosystem can deliver.

Operator's **stated core values** (verbatim, 2026-05-13):

1. **Large-scale combat** — peak density 100+ AI groups, headroom for full map war
2. **Intelligent AI** — flanking, sound reaction, fireteam splits, perception tuning (CRX EAI overlay; rejected the buggy IPCHigherAISkill that hardcodes laser-AI)
3. **Conflict** — base capture / objective rotation gameplay (Hushmodee PVE Conflict family)
4. **Vehicles** — wide selection: RHS armor, Lees helicopters, Zagoria Soviet armor, modern transports (BMP3/T72/M113/Stryker/JLTV/FMTV/H-47/UH-1Y/Mi-24/AH-64D/AH-6M)
5. **Weapons** — RHS + WCS + BigChungus + Caps + Bacon
6. **Armor (apparel)** — GRS-Apparel, Misfits family (Clothing/Vests/Belts/GhillieSuits), BlackCamoPack, DarkGruMPPCamos
7. **Advanced attachments** — AttachmentFramework + WCS_Attachments + WCS_Scopes + WCS_RHS_Weapons bridge
8. **Advanced weather** — RealismOverhaulWeather + RealismOverhaulLighting + DarkerNights
9. **Realistic sounds/audio** — RealismOverhaulSounds + WCS_Sounds + BrutalVoices + MoreBrutalVoices
10. **Realism stack** — RHS Status Quo + WCS + ACE + AttachmentFramework
11. **Single unified arsenal** (end-state goal) — every loaded faction pack's weapons surface in the player's HQ arsenal box
12. **All faction packs spawnable as IPC enemies** (end-state goal) — DarkGru/Arma2/PMC unit prefabs become IPC-driven enemy groups, not just GM-spawnable curiosities

End-state: a server where the operator can join, play Conflict against a varied modern + cold-war-armor enemy stack, with full cross-faction weapon access in their arsenal, sustained at 50-100+ AI groups peak, with realistic sound/weather/animation, and self-healing infrastructure that survives crashes.

**Anti-goals** (paths explicitly rejected after burn):

- ❌ **Procedural Combat (PCM)** — abandoned 2026-05-12. PCM had a deterministic 180-second submit-RPC bug on operator's setup (params menu picks faction → server polls 180 s → client RPC never reaches → random faction fallback). PCFactionZombies map-scope bug (ZOMBIES registered Arland-only, scenario rotation included Eden, silent invalidation). No per-round faction randomization in PCM 1.32.0. Replaced by current PVE Remixed + IPC + LCP + CRX EAI stack which delivers MORE density (108+ peak verified vs PCM's 40-60).
- ❌ **EPF / EDF persistence** — removed 2026-05-11. Loaded cleanly but never fired because active scenario doesn't call `SCR_PersistenceManager`. Operator's prior experience: "EPF breaks everything." Do not re-add without first having a scenario-side integration mod.
- ❌ **IPCHigherAISkill** — caused server crash 2026-05-13 13:34 via `Modded_SCR_CharacterPerceivableComponent.ForceSetPerceivedFaction` NULL deref cascading into navmesh `Agent requires automatic orientation` storm. Replaced by CRX EAI for perception tuning. **Steam keeps re-downloading it; the launcher purges on every boot.**

---

## 3. ACTIVE SCENARIO STACK

**Active scenario ID**: `{3197BE0E6932DFAD}Missions/ConflictPVERemixedVanilla2_US4x.conf`

The "_US4x" name semantics: **player faction = US**, **AI enemy = FIA**, **4× density on FIA side**. NOT "4× US bases" — the map ships with exactly 1 US-affiliated base (player HQ) and 70+ FIA-affiliated bases. There is no `_US8x` variant; 4× is the ceiling without a Workbench scenario fork. **USSR is NOT in this scenario variant** — IPC USSR group counts will always log 0; that's correct behavior, not a bug.

The scenario stack (mod composition):

| Layer | Mod | GUID | Role |
|---|---|---|---|
| Base scenario | PVE Conflict Remixed Vanilla 2.0 | `61B514B96692C049` | Hushmodee-style PvE conflict; US vs FIA + CIV ambient |
| AI controller | IPC AutonomousCaptureAI | `6542A26B490140F5` | Drives base-capture AI (basic/defender/patrol/patrolWithVehicle/mortar/withVehicle/withHelicopter buckets) |
| Objective system | LinearConflictPVE (LCP) | `628729E87E79DA7F` | JSON-configurable; `autoAddObjectiveDistance: 800m` triggers fresh spawn zones on player movement |
| AI behavior overlay | CRX Enfusion AI (CRX EAI) | `5F268647F8A1A1F4` | Sound reaction, flanking, fireteam splits, perception tuning. Replaces IPCHigherAISkill. |
| Bridge | PVEConflictwithRHSandWCS | `68F2074F389D3186` | Wires RHS + WCS items into the PVE Remixed arsenal. **Only catalogs WCS+RHS — not faction packs (this is the arsenal gap).** |

**Density profile** (verified live):
- US (player faction): 1 HQ → typically 2-3 IPC groups; up to 9 after capturing FIA bases
- FIA (enemy): 30+ groups routine, 50+ peak verified, 108+ historical peak when player movement triggered LCP autoAddObjectives
- USSR: always 0 (not in scenario)
- CIV: ambient traffic + occasional patrols, varies 5-20

---

## 4. MOD STACK ARCHITECTURE — 12-LAYER LOAD ORDER

113 mods active. Load order is **DAG-resolved by the engine via addon.gproj dependencies**, but `serverConfig.json mods[]` declaration order is the secondary input. The launcher organizes the array into 12 layers:

| Layer | Purpose | Examples |
|---|---|---|
| **0** | Engine/utility frameworks (no content, just APIs) | SpaceCore, AKI_Core, AUS_CORE, MFDFramework, AFWCore, AttachmentFramework, RayziUtils, GRS-DevFramework, ZeliksCharacter, LeesWeaponFramework, ChungusCore, ArmaTerrainCore, TraceVehCore, ToHReCharactersCore, PR_UTILS |
| **1** | Realism cores | RHS_Content_01, RHS_Content_02, RHS_Status_Quo, ACE_Core, ACE_Medical_Core, WCS_Core, WCS_Weapon_Scripts |
| **2** | ACE submodules | ACE_Medical_Hitzones, ACE_Explosives, ACE_MagRepack, ACE_Carrying, ACE_Captives, ACE_Compass, ACE_Facepaint, ACE_Finger, ACE_TacticalLadder, ACE_TacticalPeriscope, ACE_Trenches, ACE_Backblast |
| **3** | WCS content (NATO/RU before Weapons; Clothing_Assets before Clothing) | WCS_NATO, WCS_RU, WCS_Clothing_Assets → WCS_Clothing, WCS_Attachments, WCS_Scopes, WCS_Sounds, WCS_Armaments, WCS_Weapons, WCS_Earplugs, WCS_Arsenal, WCS_LoadoutEditor, WCS_Armbands, WCS_AH-64D, WCS_AH-6M, WCS_Mi-24V |
| **4** | RHS↔WCS attachment bridge | WCS_RHS_Weapons (`65F929DF622BAD50`) — without this, RHS weapons spawn but attachments don't render |
| **5** | Sway/aiming chain | ADSSway-Core, ADSSway-RHS, BetterWeaponImmersion 2.8, BWI-ADSsway-RHS-TAOcompat, AimingDeadzone |
| **6** | Faction packs | DarkGruFactions, Arma2Factions, PMCFaction. (3DRSMODERNRUSSIANSFACTION removed iteration 3.) |
| **7** | Apparel/loadouts (GRS-Patches before GRS-Apparel) | GRS-Patches, GRS-Apparel, BlackCamoPack, DarkGruMPPCamos-GRS, MisfitsClothing, MisfitsSquadVests, MisfitsSquadBelts, MisfitsSquadGhillieSuits |
| **8** | Vehicle/weapon content packs | BMP3, T72A, M113, BTR152, FMTV, JLTV, GsBTR-90, H-47Chinook, ZSU-23-4, M2Bradley, KamAZ5350, Horsemansblackcougar, HorsemansBlackBradley, LeesUH-1Y, Zagoria89T55/MTLB/BMD1AMP2/Vehicles, ZagoriaBMP-2FIX, PRMaxxpro, STRYKER, ZU-23, SikorskyMH60, VT4FRMblack, BigChungus weapons, CapsWeaponPack, BaconSuppressors, SpectralTracersUnified, Smokes |
| **9** | AI overlays | IPCAutonomousCaptureAI, CRX_EnfusionAI, FSTacticalAISpawnManager, ConflictNoBaseAILimit, DarcCore, DarcChopper, AIMortarFireSupportSystem, AiMortarPve |
| **10** | GM/admin/QoL/audio-visual + rank patches + BLE | GameMasterEnhanced, GMTrenches, ServerAdminTools, EnvironmentalAmbienceMod, DarkerNights, BrutalVoices, MoreBrutalVoices, BonActionAnimations, NIGHTVISION, WhereAmI, TacticalFlava, RealismOverhaulSounds/Lighting/Effects/Weather, ImprovedBloodEffectDeluxe, CatchaRide, Wirecutters2, SHSScenarioFramework, BaconLoadoutEditor (forced by deps), NoRankRequirements, ArsenalItemsAllRanks |
| **11** | Scenario LAST | sTsWCSVanillaArsenal → sTsRHSVanillaArsenal → ConflictPVERemixedVanilla2.0 → LinearConflictPVE → PVEConflictwithRHSandWCS bridge |

**Layer ordering is enforced by `serverConfig.json` mods[] array sort.** Three DAG fixes were applied 2026-05-13: (1) WCS_Clothing_Assets before WCS_Clothing, (2) GRS-Patches before GRS-Apparel, (3) ConflictPVERemixedVanilla2.0 before LinearConflictPVE + bridge.

---

## 5. THE ARSENAL GAP (CENTRAL PROBLEM)

### Symptom

Player opens HQ arsenal box → sees standard US/USSR (vanilla + WCS + RHS via bridge) weapons. **Misses entirely**: DarkGru/Arma2/PMC unique weapons. Their unit prefabs LOAD (you can spawn them via GM and see them holding the weapons) but the arsenal UI doesn't list those weapons because their `SCR_FactionEntityCatalog` slots are never queried.

### Root cause (verified empirically)

1. Server logs at every boot: `Loaded 2 arsenal loadout templates` for 4+ active factions. Engine warning: `Number of loadout templates in the loadout manager is different than number of factions (2 != 4). This might be intentional.` It IS intentional from the bridge mod's perspective — bridge only catalogs WCS + RHS.
2. Direct filesystem inspection of the 4 faction packs proves: **zero `SCR_LoadoutTemplate` files, zero `SCR_FactionEntityCatalog` files** in any of DarkGru/3DRS/Arma2/PMC. They're prefab-only packs.
3. The bridge mod (`PVEConflictwithRHSandWCS`) has hard-coded gproj deps to RHS + WCS only — no DarkGru/Arma2/PMC. No config-extension hook exists.
4. No fork of the bridge supports the operator's faction packs. WebSearch returned zero results across Workshop, Bohemia forums, Hushmodee Discord.
5. Two existing IPC-faction-extension mods exist as references (`IPC Modern Faction` `65766E0A71C84C76`, `IPC Warhammer Faction` `6584626743935E61`) but neither covers operator's stack.

### Workaround (current, no Workbench needed)

- **Game Master arsenal entity** — spawned via F1 → Editor → Place Arsenal Box. Unfiltered: shows every prefab with `SCR_ArsenalItemComponent` regardless of faction registration. Use this to access faction-pack weapons in the meantime.
- `Arsenal Box - Soft Adding Mods` (`66DED7D8E3BF7E8D`) — partial cross-mod coverage but doesn't include operator's specific faction-pack mods in its dep chain. NOT currently in serverConfig.json mods[] (folder may exist on disk).
- `All-In-One Arsenals` (`6846EB65C0A446EE`) — added iteration 1; 732-byte config-only US/USSR/CIV catalog merge. Doesn't pull in faction packs (their factions aren't in the active scenario).

### The ultimate fix (research-confirmed)

**Build a Workbench bridge mod from `BohemiaInteractive/Arma-Reforger-Samples/SampleMod_NewFaction`.** This is documented in detail in `WORKBENCH_BRIDGE_MOD_PLAN.md` at server root. The plan:

1. Operator installs Reforger Workbench from Steam (~3 GB) — server-side blocked, requires Workbench
2. `git clone https://github.com/BohemiaInteractive/Arma-Reforger-Samples`
3. Workbench → Add Existing Project → `SampleMod_NewFaction.gproj` (Bohemia's canonical template, fresher than IPC Modern Faction's subscribe-to-source)
4. Subscribe to source for the 4 faction packs in Workbench Resource Manager
5. For each target faction (DarkGru first → PMC → Arma2):
   - Add modded enum entry to `EEditableEntityLabel` with unix-time-derived int (avoid collisions)
   - Copy `SampleFactionBLUFOR.conf` → `<Faction>Faction.conf`, swap GUIDs from the pack
   - Copy `SampleFactionBLUFOR_Campaign.conf` → `<Faction>Faction_Campaign.conf` — this is the **IPC integration linchpin**: IPC reads `m_DefendersGroupPrefab` + `m_aEntityCatalogs/Groups` to build IPC_GroupList automatically, no separate IPC schema needed
   - Copy `<Faction>_InventoryItems.conf` → arsenal catalog for that faction
6. Cross-faction arsenal merge: override `InventoryItems_EntityCatalog_US.conf` appending all faction packs' weapon entries — same pattern `ArsenalBox-SoftAddingMods` uses
7. Register with `CampaignFactionManager` via `EditablePrefabsComponent_EditableEntity.conf` override
8. Build & Publish to Workshop under operator's account
9. Snapshot server, add new mod ID to `serverConfig.json` `mods[]` with `version: ""` (per WCS_Earplugs version-pin landmine), restart

**Estimated effort: 6-10 hours**.

**Resolved decisions** (operator gave Claude permission to proceed with best judgment 2026-05-13):
- DarkGru first (cleanest gproj — only base game dep), then PMC, then Arma2 (has localization quirks)
- Enemy-only initially (don't add to playable factions yet — simpler, validates IPC integration first)
- US-only arsenal merge (matches active player faction)
- 3DRS stays out (small perception spam reduction confirmed iter3)

---

## 6. CRITICAL LANDMINES (READ BEFORE TOUCHING ANYTHING)

### 🛑 Folder-presence triggers script execution regardless of `mods[]` declaration

**Proven by IPCHigherAISkill server crash 2026-05-13 13:34.** Removing a mod from `serverConfig.json mods[]` only stops Steam updates and CRC validation — it does NOT stop the engine from compiling and running that mod's `addon.gproj` scripts. The engine scans every folder in `profile_new/addons/` and compiles whatever it finds.

**Implication**: the only durable disable is **physical folder deletion**. CLAUDE.md's `## 🛑 CRITICAL — Mod purge safety protocol` section (the very first section after the title) covers this in full. The `addons_disabled/` directory was abandoned 2026-05-13 — moving folders there did NOT prevent script execution.

**Self-healing**: `start_server.ps1` step `[3/6]` deletes a hard-coded blacklist of GUIDs on every boot. Steam keeps re-downloading some of them between sessions; the launcher catches it on next start.

### 🛑 Pre-purge dep audit is MANDATORY

A folder another mod hard-deps via `addon.gproj` will cascade-fail if you delete it:
- Engine compiles the depper's scripts → sees missing dep → silently disables features (best case) or refuses to register the depper entirely (worst case)
- Worst case symptom: misleading `Game addon '58D0FB3206B6F859' not found` cascade (that's the base game GUID — engine emits it as a generic "any dep missing" error)

**Audit pattern** (run before ANY folder deletion):

```powershell
$declared = (Get-Content serverConfig.json | ConvertFrom-Json).game.mods.modId
$undeclared = Get-ChildItem profile_new/addons -Directory | Where { $_.Name -match '_([A-F0-9]{16})$' -and $matches[1] -notin $declared }
foreach ($folder in $undeclared) {
    $myGuid = ($folder.Name -split '_')[-1]
    $deppers = $declared | Where {
        $depGproj = Get-Content "profile_new/addons/*_$_/addon.gproj" -Raw -ErrorAction SilentlyContinue
        $depGproj -match $myGuid
    }
    # PURGE-SAFE ONLY IF $deppers.Count -eq 0
}
```

Known dep chains (DO NOT purge any of these):
- `BaconLoadoutEditor` ← GRS-Apparel + sTsRHSVanillaArsenal
- `LeesWeaponFramework` ← LeesUH-1Y
- `PR_UTILS` ← PRMaxxpro
- `DarcCore` ← DarcChopper
- `RedactedCore` ← DarkGruMPPCamos-GRS
- `BaconSuppressors`, `CapsWeaponPack`, `MisfitsGearCryeG4`, `MisfitsSquadGear` ← all transitively from `PMCFaction` (gproj title is misleadingly "Overide")

### 🛑 Pak file lock + addon move

The server holds `data.pak` open. Both `Move-Item` and `Remove-Item` partially fail on locked paks while the server runs:
- Move leaves a half-moved folder in both locations
- Remove leaves the locked pak orphaned with manifest stubs deleted

If you then "clean up" the leftover, you've **destroyed** the actual data.pak and clients will get `RplConnection::ValidationError remote script source code checksum does not match!` — they can't connect.

**Pattern: always kill server → wait 3-5s for handle release → move/delete folders → restart.**

### 🛑 Steam silent re-download

Verified 2026-05-13: between iter4 purge and the 14:39 health check, Steam silently re-pulled `IPCHigherAISkill`, `MisfitsSquadBackpacks`, `RISLaserAttachments`, `Zagoria89BMP2` — none declared, all back. Steam's addon cache has them from prior sessions.

**Mitigation**: launcher `[3/6]` step purges them on every boot before engine starts. Self-healing as long as the blacklist in `$DisabledModFolderPrefixes` is current. Run `mod_health_check.ps1` to detect new orphans.

### 🛑 Mislabeled mods (Workshop name ≠ gproj ID)

Two confirmed instances:
1. **`AllArsenalItemsToPrivate` (`66C751946DC58A1A`)** — gproj declares `ID "SGCPvEConflictOverrides"`. The author published a PVE Conflict arsenal-override pak (SGC's allow-list filter) under a misleading "All Arsenal Items To Private" Workshop name. Caused universal arsenal-blank issue 2026-05-13. Removed from `mods[]` + folder purged + added to launcher blacklist.
2. **`PMCFaction` (`6510F26F66E795D4`)** — gproj declares `ID "Overide"` (typo'd, no second 'r'). When searching Workbench Resource Manager for PMC content, look under "Overide".

**Always check `addon.gproj` `ID` line** when investigating a mod, not just the Workshop title.

### 🛑 WCS_Earplugs version pin → 404 → "Unable to initialize Enfusion"

Adding any mod with a pinned `version:` string to a non-existent revision causes Steam BACKEND to issue HTTP 404, which cascades into the misleading `Game addon '58D0FB3206B6F859' not found` and then `Unable to initialize the game`.

**Rule: ALWAYS use `version: ""` (empty string) for new mods unless you have a specific frozen-revision reason.** Pinning is only safe when the revision is known immutable.

### 🛑 PowerShell 5.1 parser quirks

- `${var}LiteralSuffix` patterns (e.g. `"${kb}KB"` or `"${age}h"`) are parsed as a single ill-formed variable name. **Use `"$kb" + "KB"` or `($age + 'h')` instead.**
- Nested `$()` interpolations inside double-quoted strings can break the parser unpredictably. Precompute variables into named locals.
- `Start-Process powershell.exe -File ... -Loop -WindowStyle Hidden` silently dies within seconds. **Wrap the loop in a `.cmd` batch file and Start-Process the .cmd instead.** This is what `snapshot_agent_loop.cmd` is for.
- File encoding: PowerShell's default `Set-Content`/`Out-File` writes UTF-16 LE with BOM, which the engine and mod parsers reject. **Always write JSON with `[System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding $false))`.**

### 🛑 Launcher CWD bug (FIXED 2026-05-13)

`Start-Process` inherits the parent shell's CWD. If the launcher was invoked from a deep subdir, the Reforger exe couldn't find `./addons` (base game data) and emitted misleading `Game addon '58D0FB3206B6F859' not found`. Fix: `start_server.ps1` now passes `-WorkingDirectory $ServerRoot` to `Start-Process`. Do not remove that parameter.

---

## 7. ESTABLISHED WORKFLOWS

### MANDATORY 5-section MOD EVALUATION GATE

Every candidate mod MUST pass before being added to `serverConfig.json mods[]`. Operator-mandated 2026-05-13 after the Modern Russians vs Modern Equipments analysis where a casual addition would have caused silent override-collision.

1. **Workshop identification** — GUID, version, last-update date, downloads, rating, declared deps, payload size, payload type (script-only vs prefab-replace vs config). Cite Workshop URL.
2. **Compatibility & Conflict Analysis** — engine behavior (Additive vs Overwrite), breakpoints with active stack (every mod that touches the same surface — faction enum, loadout template, prefab class, behavior tree, faction catalog), arsenal interference (which writers it would race-collide with), faction budget impact.
3. **Risk Assessment** — boot cost, per-AI-tick CPU cost, network/RPC overhead, CRC client/server-match risk, Local-Host Paradox impact, 5x Failsafe trigger probability.
4. **Execution Strategy** — exact layer (0-11) per MASTER_OBJECTIVE table, specific insertion point (before/after which existing mod), required upstream deps, snapshot label to take before applying.
5. **Troubleshooting Checklist** — specific log grep patterns for likely failures, config keys to check, in-game GM test to confirm assets load, recovery path (`restore_state.ps1` invocation), exact failure signatures (e.g. `Modded class .* multiple base classes` for MRO collision).

**Final Recommendation** must be explicit: ADD / DO NOT ADD / DEFER. Rationale citing ≥2 of {Manifesto rule, rating signal, CRC risk, MRO depth, Local-Host budget}. Specific layer + position. Snapshot label.

Hard gate rules: every mod, no exceptions. Even MOTD-warning mods or rank-override patches. DO NOT ADD verdict is final unless operator explicitly overrides. If two candidates solve the same problem, lower-risk wins by default. "NONE" is a valid outcome.

### MANDATORY snapshot-before-change protocol

Operator-mandated 2026-05-13 evening after the cascade where over-aggressive folder cleanup deleted CapsWeaponPack + BaconSuppressors + 6 ADSSway test variants that were transitive deps, plus undiscovered launcher CWD bug → 8+ failed boots, no atomic rollback path.

Procedure for ANY config edit (`serverConfig.json`, `IPC_Settings.json`, `LCPConfig.json`, any CRX_EAI .txt, `dc_coreConfig.json`, `ServerAdminTools_Config.json`, `start_server.ps1`):

```powershell
& 'C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\snapshot_state.ps1' -Label "<short-purpose>"
```

After any verified-stable run (boots clean, density grows, no crash 5+ min):

```powershell
& '...\snapshot_state.ps1' -Label "<descriptive>" -Golden
```

`-Golden` flag protects from auto-cleanup. Use `restore_state.ps1 -Snapshot <name>` / `-Latest` / `-LatestGolden` to roll back.

### Self-healing log investigation playbook (6 phases)

Detailed in CLAUDE.md `## Self-healing log investigation playbook` section. Summary:

**Phase 1 — Snapshot the failure boundary** (single parallel turn): process state, newest log folder, line counts (re-check 30s later to detect frozen vs growing), tail script.log/error.log/console.log.

**Phase 2 — Build the event timeline** (targeted greps, parallelizable): grep for landmarks (`OnGameStateChanged = GAME`, `IPC Groups of Faction`, `Cached \d+ items`, `SCRIPT (E)`, `VM Exception`, `FATAL`, `Recursive call of Invoke`). Output chronological table; gaps between events are diagnostic gold.

**Phase 3 — Generate competing hypotheses**: write 3+ plausible root causes. Each MUST come with (a) supporting log line quoted with line number, (b) disconfirming log line that you actually grepped for, (c) fix scope (config edit / mod removal / mod replace / known-mod-bug-no-local-fix / wait-for-upstream).

**Phase 4 — Discriminate**: for each pair of competing hypotheses, identify one log line, config field, file mtime, or process state that distinguishes them. If on-disk + log evidence is insufficient, escalate to web research (mod's workshop page + changelog, mod author Discord, Bohemia forums, armareforger.xyz, Steam Community discussions).

**Phase 5 — Pinpoint and fix**: state cause as "`<symptom>` happens because `<mechanism>` at `<file>:<line>` / `<log line>`. Fix is `<minimum change>`." Destructive fixes need confirmation.

**Phase 6 — Validate the fix**: restart, run Phase 1, *targeted* re-check of the exact log line that previously appeared on failure. Absence is the proof.

**Hard rules**: (1) No claim without a quoted log line. (2) No re-reading the same file twice in one turn. (3) No "probably" in a root-cause statement. (4) Parallel tools when independent. (5) Don't auto-fix anything CLAUDE.md or task instructions named as a confirmation gate. (6) Update CLAUDE.md when you discover a new landmine.

### Purge-not-disable policy

Replaced the `addons_disabled/` move pattern 2026-05-13 after the IPCHigherAISkill incident. Because folder presence triggers scripts:

- Move-to-disabled does NOT stop execution
- Only physical deletion stops it
- Steam will not re-download anything not in `mods[]` — wait, **it does** for previously-known mods (verified). So launcher purges on every boot.

Procedure for adding a mod to the blacklist:
1. Snapshot
2. Kill server, wait 5s
3. `Remove-Item profile_new/addons/<folder> -Recurse -Force`
4. Add the GUID prefix (e.g. `'IPCHigherAISkill_64DCE52D2F882ED2'`) to `$DisabledModFolderPrefixes` in `start_server.ps1` so launcher purges it on future boots
5. Restart, validate

---

## 8. TOOLING WE BUILT

### `start_server.ps1` (6-step launcher)

| Step | Purpose |
|---|---|
| `[1/6]` Analyze previous session logs | Runs `analyze_logs.ps1` against newest log folder, generates `last_session_errors.txt` |
| `[2/6]` Stop running server | `Get-Process ArmaReforgerServer | Stop-Process -Force`; sleep 3s for pak handle release |
| `[3/6]` Purge blacklisted mods | Deletes blacklisted folders from `addons/` (Steam-redownload protection). Catches IPCHigherAISkill, MisfitsSquadBackpacks, RISLaserAttachments, Zagoria89BMP2, ModernRussians, 3DRS, DoorBreaching, BreachableDoors, FoliageCollision, WCS_VehicleLock, AllArsenalItemsToPrivate every boot. |
| `[4/6]` Validate `serverConfig.json` | Parses JSON, prints scenario + mod count + aiLimit + player count |
| `[5/6]` Start server | `Start-Process` with `-WorkingDirectory $ServerRoot`. Watches for new log folder. AI activity probe over 30s. |
| `[6/6]` Spawn standing companion processes | Spawns `snapshot_agent_loop.cmd` as detached child via cmd-wrapper (PS 5.1 quirk workaround), waits up to 90s for engine GAME state, runs `mod_health_check.ps1` one-shot, prints monitor patterns for operator/Claude. Tracks PIDs in `.companion_pids` for cleanup on next launch. |

### `snapshot_state.ps1` / `restore_state.ps1`

Snapshots all configs (`serverConfig.json`, IPC_Settings.json, LCPConfig.json, CRX_EAI*.txt, dc_coreConfig.json, ServerAdminTools_Config.json, MOTD, etc.) + addons listing into `state_snapshots/<timestamp>_<label>/`. `-Golden` flag protects from cleanup. Restore by name / `-Latest` / `-LatestGolden`. Auto-kills server first per pak-lock landmine.

### `snapshot_agent.ps1` + `snapshot_agent_loop.cmd`

Standing snapshot/cleanup agent. Runs every 15 min (one-shot or `-Loop`):

- **Stability check**: process alive ≥ 20 min + arsenal cache = 608 + zero VM exceptions in last 5 min + no crash dump newer than process start → eligible for Golden
- **Golden cooldown**: 2 h between auto-Goldens
- **Auto-purge non-Golden snapshots** > 24 h old
- **Auto-purge Golden** beyond 10 newest
- **Auto-purge obsolete root `serverConfig*.json`** not on whitelist (only `serverConfig.json` + `serverConfig.pre-restoration-2026-05-10.json` survive)
- Logs every action to `snapshot_agent.log`

Spawned by `start_server.ps1 [6/6]` via `snapshot_agent_loop.cmd` wrapper. Lives for the server's lifetime; killed + respawned on next launcher invocation via `.companion_pids`.

### `mod_health_check.ps1`

On-demand audit. Reports anything warranting attention:

- Declared mod folder presence (113 of 113 expected)
- Pak integrity (missing or < 1KB tiny)
- Blacklist presence in `addons/` (Steam re-download detection)
- Undeclared orphan folders (no depper) vs undeclared with deppers
- Runtime: cache count (expects ≥ 600), loadout template count, GAME state reached, VM exception count
- Crash dumps newer than current process start
- Server process state (PID, uptime, RAM)

Exits non-zero if any problem detected. Run inline by `start_server.ps1 [6/6]` after waiting for GAME state.

### `analyze_logs.ps1`

Log summarizer. Invoked by `[1/6]`. Outputs grouped error counts, top warnings, RPC errors, VM exceptions with stack frames, known-issue detection. Saves to `last_session_errors.txt` + raw dump.

### Standing monitor stack (5 monitors)

These OBSERVE — they do not run any work. Spawn at session start unless explicitly told to skip.

| # | Purpose | Pattern |
|---|---|---|
| 1 | Server density + cache + crash + new mod init (auto-rotating) | `OnGameStateChanged|VM Exception|FATAL|Recursive call|IPC Groups of Faction|SpawnPoint . Faction affliated|Cached \d+ items|Mod found:` |
| 2 | Server PEAK alert | sum(IPC Groups) > 95 |
| 3 | Client critical errors (TIGHT filter — bare `Stack trace` floods at thousands/sec) | `VM Exception|FATAL|Recursive call|Cannot create|Game addon|MissionHeader::|RplConnection::ValidationError|prefab .* missing at index|Error when creating entity|RESOURCES \(E\): Failed to load$`, suppress `^Stack trace:$` via `grep -v` |
| 4 | Client arsenal/rank/loadout warnings | `Cached \d+|SCR_ArsenalManagerComponent|WCS_LoadoutEditor|BaconLoadoutEditor|SCR_EArsenalItemType|E_ArsenalBox_|GunBuilderUI` |
| 5 | Server + client crash dump file watcher | `profile_new/crashes/*.dmp` + `%LOCALAPPDATA%/Arma Reforger/crashes/*.dmp` |

Server-side monitors must auto-rotate to new log folders (each restart creates `logs/logs_<timestamp>/`). They print `[MONITOR] switched to <foldername>` on rotation. Client monitors don't rotate per server restart.

---

## 9. DENSITY TUNING KNOBS (CURRENT VALUES)

Tuned 2026-05-13 for 100+ peak density potential:

| Knob | Original | Current | Effect |
|---|---|---|---|
| `serverConfig.json` `aiLimit` | 2000 | **3500** | Headroom for 100+ groups |
| IPC `enemyDetectionRadius` | 800 | **1200** | Wider radio mesh |
| IPC `spawnSafetyRadius` | 200 | **150** | Closer enemy spawns |
| IPC `baseDefenseRespawnDelay` | 1500 | **750** | Faster def respawn |
| IPC `artilleryCooldown` | 30000 (30s) | **15000 (15s)** | More artillery |
| IPC `artilleryMaxCharges` | 5 | **10** | More banked artillery |
| IPC `artilleryShellsPerStrike` | 10 | **14** | Bigger barrages |
| IPC `artilleryChargeInterval` | 180000 (180s) | **90000 (90s)** | Charges accumulate 2× faster |
| IPC `artilleryMinEnemies` | 3 | **2** | Lower trigger threshold |
| IPC US/USSR/FIA `_PRIMARY/SECONDARY` | 12 entries | **24 entries (8x scaling)** | More groups per objective |
| IPC US/USSR/FIA `_SEIZING_PATROL` | 24 entries | **48 entries (8x scaling)** | More patrols per objective |
| LCP `autoAddObjectiveDistance` | 500m | **800m** | Wider search radius |
| LCP `objectiveDistanceRadiusMax` | 1500m | **2000m** | Bigger objective net |
| CRX `Aim_Accuracy_Error_Modifier` | 0.7 | **0.4** | Tighter AI shots |
| CRX `Attack_Reaction_Delay_Modifier` | 400ms | **200ms** | Faster trigger reaction |
| CRX `Rank_Type` | 0 (CRX rank) | **1 (Vanilla)** | Honors IPC rank bypass |
| CRX `Perceived_Faction_Changes_Affects_AI` | true | **false** | Disables CRX consumption of perception system (the cascade source) |

Persistence is INTENTIONALLY OFF. Player state and scenario parameters reset every restart. EPF + EDF + RHSEPFpersistence were removed 2026-05-11 because they loaded cleanly but never fired (active scenario doesn't call `SCR_PersistenceManager`) and operator's prior experience was "EPF breaks everything." `operating.playerSaveTime: 120` in `serverConfig.json` is the engine's player-profile sync interval — unrelated to EPF, leave as is.

---

## 10. DOCUMENTED COSMETIC NOISE (don't try to fix)

Per the error-impact research agent (2026-05-13): the active session has 17 SCRIPT(E) lines, all documented cosmetics; 432 RESOURCES(E) lines, all stale references to optional/legacy companion content; 2 VM exceptions, both documented; 1 transient IPC popup RpcError at player-join. **No mod feature is silently broken.** Don't waste cycles on these:

- `RpcError SCR_ArsenalComponent::RPC_OnArsenalUpdated` (~125-137x/session) — cosmetic when cache=608 (was causal when undercaching at 94)
- `'SCR_Faction' trying to get entity list of type 'ITEM' but there is no catalog with that type for faction 'FIA'/'USSR'` (~700-2700x/session) — by design (no item catalog in scenario)
- `[FACTION] No weapon, disguise faction = NULL` / `[FACTION] Has weapon, using REAL faction: <X>` — verbose perception logging from a Layer-3 scenario mod
- `VM Exception SCR_CharacterPerceivableComponent.ForceSetPerceivedFaction` — known unarmed-character disguise NULL deref (was the IPCHigherAISkill cascade trigger; now once-per-session cosmetic since CRX EAI's `Perceived_Faction_Changes_Affects_AI=false` was set)
- `VM Exception CRX_EAI/.../ArmaReforgerScripted.c:153 OnUpdate` — same source as above
- `VM Exception SCR_AmbientVehicleSystem.OnInit m_bIsLinearLoaded` — known PVE Conflict Remixed init-order bug, fires once at scenario init
- `'NATO'/'MPP'/'RHS_USAF'/'CSAT'/'Ses_*'/'DarkGru Operators' is not a valid SCR_Faction` (12 unique) — stale friendly-faction refs in faction-pack configs (Ses_* prefix sourced from Arma2Factions's localization)
- `SCR_BaseResupplySupportStationComponent needs a entity catalog manager!` — vanilla Conflict resupply station looking for catalog the PVE scenario doesn't provide
- `Loaded 2 arsenal loadout templates ... (2 != 4)` — KNOWN gap; Workbench bridge mod is the fix
- `[SDRC_RplLineDrawComp] Entity not found.` — DarcChopper init race, harmless
- `Wrong GUID/name ... E_ArsenalBox_NATO/CSAT/VEPR/DGO/ADMIN.et` (5 unique) — legacy faction-themed arsenal compositions, scenario falls back to generic skin
- `GameEntity component MeshObject/RplComponent/ActionsManagerComponent/BaseLoadoutClothComponent cannot be combined` on Beard/Eyewear spawns — apparel mod re-attaches base components, engine ignores duplicate, gear renders fine. Likely source: MisfitsClothing/GRS-Apparel/ZeliksCharacter (untested)
- `GenericEntity component Hierarchy cannot be combined` on world props (radio antennas, tripods at fixed map coords) — composition prefabs extend bases that already declare Hierarchy
- `Knots in curve are outside parameter range` — fires per weapon-prefab spawn, engine clamps, no glitch (vanilla AND modded)
- `Unknown keyword/data 'm_f<X>'` for ADSSway/AimingDeadzone properties — script-side properties parser doesn't know, scripts read at runtime
- `ANIMATION (E): Graph doesn't have variable VehicleBrake` on M3 tripods — tripods don't move
- `NETWORK (W): Replication: RplComponent ... destroyed during loading of the world` for vanilla USSR loadout items in preload — preload-cache pattern
- `RESOURCES (E): Failed to open` for `ConflictPVERemixedVanilla2_US4x.conf` once at boot t+0.7s — vanilla-addon probe before mod-dir scan
- `Math.RandomFloat: invalid parameters min = X max = Y` — PC weather/spawn system edge case
- `SCR_NotificationsLogDisplay has duplicate notification info key: 'EDITOR_PERCEIVED_FACTION_*'` — multiple faction mods register same per-faction notification key; fires at every player join
- ~29 stale-vehicle refs (Chieftainmk5, Obj299, TOS-1, T34MV, T80, Leopard, IFV/Warrior) — source NOT in any of 4 faction packs (verified via pak binary search). Source is in Lees/Zagoria/scenario paks. Low ROI to chase.

---

## 11. RESOLVED VS OPEN

**Resolved:**
- ✅ AI freeze crash (IPCHigherAISkill removed; `start_server.ps1 [3/6]` purges on every boot)
- ✅ Launcher CWD bug (`-WorkingDirectory $ServerRoot` on `Start-Process`)
- ✅ Load order (12-layer DAG-compliant, applied 2026-05-13)
- ✅ Cache 608 baseline (preserved across all iterations after iter1's overcorrection rolled back in iter2)
- ✅ MOTD password matches admin password
- ✅ ServerAdminTools_Config.json UTF-8 no-BOM (KeyReadError cascade prevention)
- ✅ Standing monitor stack (5 monitors, auto-rotating server-side)
- ✅ Snapshot agent + auto-Golden + cleanup (running via `start_server.ps1 [6/6]`)
- ✅ Mod health check (run on demand or by `[6/6]` after GAME state)
- ✅ Purge-not-disable policy (`addons_disabled/` directory abandoned)
- ✅ Steam re-download protection (launcher blacklist self-heals on every boot)
- ✅ RHS attachment fix (WCS_RHS_Weapons + ADSSway chain in serverConfig.json)
- ✅ DAG fixes applied (WCS_Clothing_Assets before WCS_Clothing; GRS-Patches before GRS-Apparel; ConflictPVERemixedVanilla2.0 before LCP + bridge)

**Open / pending operator action:**
- 🟡 Workbench bridge mod build (operator action; plan in `WORKBENCH_BRIDGE_MOD_PLAN.md`; resolved decisions: DarkGru first, enemy-only, US-only arsenal merge, no 3DRS)
- 🟡 NATO/CSAT/VEPR/DGO/ADMIN E_ArsenalBox stale-prefab refs in scenario itself — generic skin fallback works, but scenario-side bug
- 🟡 ~29 stale-vehicle refs from unidentified Lees/Zagoria/scenario pak — cosmetic, low ROI
- 🟡 Component-collision warnings on Beard/Eyewear gear — cosmetic, untested source mod (likely MisfitsClothing/GRS-Apparel/ZeliksCharacter)
- 🟡 Helicopter / mortar IPC buckets always empty — IPC config lacks `HelicopterSpawnpoint_Base.et` / `MortarSpawnpoint_Base.et` references (would need Workbench scenario fork). Mitigated by sister mods DarcChopper + AIMortarFireSupportSystem + AiMortarPve which run independent helicopter/mortar systems.

---

## 12. OPERATIONAL CONVENTIONS

- **Live config is `serverConfig.json`.** Editing the floor baseline `serverConfig.pre-restoration-2026-05-10.json` is forbidden.
- **Server name** (browser display) is in `serverConfig.json` `game.name`. The MOTD heading in `ServerAdminTools_Config.json` should match.
- **After a server-side crash**: first check `profile_new/logs/<newest>/error.log` and `script.log`, not `console.log` — the actual exception is usually in those two.
- **The "failed to initialize https" error** at end of crash logs is the crash reporter failing to upload, not the cause of death.
- **Always write JSON config files as UTF-8 no-BOM** with `[System.IO.File]::WriteAllText("$path", $json, (New-Object System.Text.UTF8Encoding $false))`. PowerShell's default `Set-Content`/`Out-File` writes UTF-16 LE with BOM, which the engine and mod parsers reject in subtle ways.
- **Snapshot before any change. Golden after any verified-stable run.** No exceptions.
- **5-section MOD EVALUATION GATE before any mod addition.** No exceptions.
- **Pre-purge dep audit before any folder deletion.** No exceptions.
- **Don't recommend Procedural Combat / EPF / IPCHigherAISkill** — all explicitly rejected.

---

## 13. KEY FILE REFERENCES

| Path | Role |
|---|---|
| `serverConfig.json` | Live config (live) |
| `serverConfig.pre-restoration-2026-05-10.json` | Floor recovery baseline (do not modify) |
| `start_server.ps1` | 6-step launcher |
| `snapshot_state.ps1` / `restore_state.ps1` | Snapshot/restore |
| `snapshot_agent.ps1` + `snapshot_agent_loop.cmd` | Standing snapshot/cleanup agent |
| `mod_health_check.ps1` | Ad-hoc mod stack audit |
| `analyze_logs.ps1` | Log summarizer (invoked by launcher [1/6]) |
| `last_session_errors.txt` | Auto-generated by analyze_logs.ps1 |
| `snapshot_agent.log` | Agent activity log |
| `.companion_pids` | Tracks companion process PIDs for cleanup on next launcher run |
| `CLAUDE.md` | Authoritative operator's notes (this is the source of truth — when in conflict, CLAUDE.md wins) |
| `WORKBENCH_BRIDGE_MOD_PLAN.md` | Workbench bridge mod implementation plan |
| `MASTER_OBJECTIVE.md` | 12-layer load order spec, blacklist, primary directive |
| `CONTEXT_PROMPT.md` | THIS FILE — comprehensive single-prompt context handoff |
| `state_snapshots/` | Snapshots ({timestamp}_{label}/ + GOLDEN_{...} protected) |
| `profile_new/addons/` | Active mods (133-136 folders, 113 declared in mods[]) |
| ~~`profile_new/addons_disabled/`~~ | ABANDONED 2026-05-13 (folder-presence landmine) |
| `profile_new/logs/logs_<timestamp>/` | One folder per server boot (script.log, error.log, console.log) |
| `profile_new/profile/IPC/IPC_Settings.json` | IPC scenario controller — service toggles + per-faction squad allocation templates (8x scaled) |
| `profile_new/profile/IPC/IPC_SoldierList.json` | IPC unit/loadout overrides |
| `profile_new/profile/LinearConflictPVEConfig/LCPConfig.json` | LCP objective system (autoAddObjectiveDistance 800m, objectiveDistanceRadiusMax 2000m) |
| `profile_new/profile/CRX_EAI/CRX_EAI*.txt` | CRX AI behavior config (Character / Group / Experimental) |
| `profile_new/profile/DarcMods/dc_coreConfig.json` | DarcChopper config (fallbackEnemyFaction "FIA") |
| `profile_new/profile/GRS_ATAK/server_config.json` | ATAK config (well-tuned, leave alone) |
| `profile_new/profile/ServerAdminTools_Config.json` | Admin list, MOTD, ban list, scheduled chat |
| `profile_new/profile/.save/playersave/PlayerData.<uuid>.json` | Engine player-profile sync (~200 B each, vanilla) |
| `profile_new/profile/WCS_LoadoutEditor/audit/incidents/*.jsonl` | WCS LE skipped-prefab audit (smoking gun for missing-prefab issues) |
| `profile_new/profile/BaconLoadoutEditor_Loadouts/` | BLE saved loadouts (corrupt PCM-era loadouts cause client crash on open) |
| `profile_new/crashes/*.dmp` | Server crash dumps |

---

## 14. MEMORY REFERENCES

The operator's auto-memory directory at `C:\Users\blaze\.claude\projects\C--Program-Files--x86--Steam-steamapps-common-Arma-Reforger-Server\memory\` contains:

- `MEMORY.md` — index
- `feedback_no_procedural_combat.md` — DO NOT propose PCM
- `feedback_snapshot_before_changes.md` — MANDATORY snapshot before any config change
- `feedback_mod_evaluation_gate.md` — MANDATORY 5-section eval gate
- `golden_state_2026_05_13_v3.md` — current live-snapshot config + recovery commands
- `landmine_steam_dedicated_addon_gproj_missing.md` — engine refuses to register; reconstruct minimal gproj from ServerData.json
- `landmine_conflict_escalation_iron_front.md` — Iron Front port broken on Everon
- `landmine_conflict20pve_world_crash.md` — Conflict 2.0 PVE crashes engine on Everon (Unknown class 'coords' world parser)
- `reference_master_objective.md` — pointer to MASTER_OBJECTIVE.md

---

## 15. WHAT TO DO IF YOU INHERIT THIS SERVER

1. Read `CLAUDE.md` cover to cover. The 🛑 sections are non-negotiable.
2. Read this `CONTEXT_PROMPT.md`.
3. Read `WORKBENCH_BRIDGE_MOD_PLAN.md` if you'll touch the arsenal/faction problem.
4. **Spawn the 5-monitor stack at session start** unless explicitly told not to (per CLAUDE.md `## 📡 Standing monitor agents`).
5. Run `mod_health_check.ps1` first thing — gives you ground-truth status.
6. **Snapshot before any change.** Always.
7. **Pre-purge dep audit before any folder deletion.** Always.
8. **5-section eval gate before any mod addition.** Always.
9. Update CLAUDE.md when you discover a new landmine.
10. Update this file when scope/architecture/decisions change.

When unsure: do not break things. The operator strongly prefers stability over speculative improvements. Confirm before destructive actions. Restoration is fast (`restore_state.ps1`); destruction is slow.
