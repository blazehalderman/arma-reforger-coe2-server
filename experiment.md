# experiment.md — Deployment Post-Mortem

> **STATUS 2026-05-16: HISTORICAL.** Stack pivoted to COE2 Eden + iter3 deployed adds (117 mods). See CLAUDE.md and golden_state_2026_05_16_v5 memory for current state.
>
> **STATUS 2026-05-14: HISTORICAL** — covers 2026-05-09 through 2026-05-13. The IPC/PVE-Remixed era ended with the COE2 pivot. New post-mortems for 2026-05-14 work (PMC/Misfits Workshop-block, COE2 stack adoption, ACE Dev→stable swap, vehicle prefab ref fixes) live in memory files (`golden_state_2026_05_14_v4.md`, `landmine_misfits_pmc_workshop_takedown.md`) — not appended here.

> Punch list of failed experiments on this Arma Reforger 1.6.0.119 dedicated server stack.
> Each entry classified per the Enfusion Manifesto rules in `MASTER_OBJECTIVE.md`.
> Companion to `CLAUDE.md` — this file is the chronological autopsy, not the operations manual.
> Generated 2026-05-13.

---

## 1. EPF + EDF + RHSEPFpersistence persistence experiment (2026-05-11)

- **Scenario** — Add a save layer so player loadouts and scenario parameters survive restarts.
- **Build Order/Architecture** — Added `EnfusionDatabaseFramework_5D6EA74A94173EDF`, `EnfusionPersistenceFramework_5D6EBC81EB1842EF`, `RHSEPFpersistence_66F87A85382A0B17` to Layer-1 cores, running under Procedural Combat scenario controller.
- **Outcome** — Frameworks loaded silently. No SQLite file created. No writes to `.save/playersave/` beyond the vanilla engine profile sync. After 3.5 min in-game, `script.log` produced nothing in the EPF namespace beyond one cosmetic `EDF_WebProxyDbDriverBase.c,606: 'reset' is obsolete`. Zero persistence delivered for ~0.4 MB of mods + boot weight.
- **Root Cause** — **Persistence Absence**. ProceduralCombat's `resourceDatabase.rdb` has zero `persist*` strings — the scenario never calls into `SCR_PersistenceManager`, so the EPF subscribers had nothing to subscribe to. No scenario-side integration mod existed to wire player entities into the persistence manager. Removed 2026-05-11 21:30 in `logs_2026-05-11_21-13-15`.

## 2. Procedural Combat 180-second submit-RPC bug (multi-session, 2026-05-11)

- **Scenario** — Use Hushmodee's Procedural Combat as the primary game mode for random-location random-size battles on Eden / Arland.
- **Build Order/Architecture** — `ProceduralCombat` + `Procedural Combat - Modern` + `PCFactionZombies` + `ScenarioReloadMenu` (Eden ↔ Arland rotation, 25 s gap), with full RHS+WCS+ACE realism stack underneath.
- **Outcome** — Deterministic across 6+ verified sessions. Menu opens (`SF_Log: Dedicated server asked playerId 1 to choose match parameters`). Operator picks factions. Server emits `SF_Log: Skirmish parameters saved` **exactly 180.000 s ± a few ms** later, followed by `Faction selection - A selected: false, B selected: false` → `Using factions (with Random): N vs M` random fallback. Operator's submit RPC never reached the server in any session.
- **Root Cause** — **State Machine Singularity** (client-side submit gate never fired). PCM's chooser-poll wall-clock deadline is 180 s; with no RPC inbound the server commits empty defaults. Operator's client showed an extra empty top dropdown (likely a required field) gating the submit. Ruled out: ServerAdminTools recursion, GME/GMTrenches, ZOMBIES catalog, server-name mojibake, mod CRC mismatch. Permanently blacklisted 2026-05-12. See `feedback_no_procedural_combat.md`.

## 3. PCFactionZombies map-scope mismatch on Eden (2026-05-11)

- **Scenario** — Run USAF vs ZOMBIES rounds on Eden via PCM.
- **Build Order/Architecture** — `PCFactionZombies_692176BA1E98A39A` + base `ProceduralCombat` + `BaconZombies` deps, with `serverConfig.json` `scenarioId = {C41D6575F3DAA075}Missions/ProceduralCombat_Eden.conf`.
- **Outcome** — Operator picked USAF vs ZOMBIES at the params menu. Server logged `Faction selection - A selected: false, B selected: false` → `Using factions (with Random): 2 vs 8` → round ran with **CDF vs FIA** (the engine's stock fallback pair).
- **Root Cause** — **Faction Reality Check**. ZOMBIES is registered uniquely against Arland by the mod's own data: `PC_LOG: PCFactionZombies registered SF_EFaction.ZOMBIES on Arland (Infected: ...)`. The dedicated server's menu validator rejected the ZOMBIES pick against Eden's per-scenario faction registry, then cleared *both* side flags (cannot 1v1 with one invalid side). The mod was designed for Arland only — not a configuration bug, an unsupported map pairing. Evidence in `logs_2026-05-11_21-29-44/script.log` lines 594–601.

## 4. Conflict Escalation Iron Front port on Everon (2026-05-12)

- **Scenario** — Deploy `Conflict Escalation` (`651F6696EA91070C`, scenario `{15193A6F0AE4F7E6}Missions/FullEveronHQCRandom.conf`) as a structured CTI war-on-Everon mode.
- **Build Order/Architecture** — Layered on top of RHS Status Quo + WCS + ACE + AttachmentFramework, full ~85-mod stack.
- **Outcome** — Boots to GAME state, `Iron_AmbientAIBattleSystem: OnInit: Found Ambient Spawns: 1` (engine-trivial). No actual AI war begins. `IRON_AmbientVehicleAreaMeshComponent: EOnInit: Unable to find Building Component` fires for every vehicle ambient spawn. `SCR_Iron_CaptureAndHoldSpawnProtectionArea.ScriptedEntityFilterForQuery` stack-traces every frame from `OnFrame` — ~3000 VM exceptions over 22 min uptime. `Player joined` fires but `OnPlayerSpawned` never does. Plus 3000+ `WORLD (E): Unknown class 'coords'` and hundreds of bad Iron Front tank/IFV ammo GUIDs.
- **Root Cause** — **Faction Reality Check + Additive vs Overwrite**. Conflict Escalation is an Iron Front WW2 port whose data references Iron-Front-specific faction enums, building components, and ammo GUIDs that do not exist on Everon or in the Reforger faction registry. The spawn-protection-area filter rejects every queried entity because no Reforger entity matches its Iron Front filter. The mod's data assumes a world layout it was authored against, not Everon. Evidence in `landmine_conflict_escalation_iron_front.md`, logs from 2026-05-12 17:32–17:55.

## 5. Conflict 2.0 PVE engine hard crash on Everon (2026-05-12)

- **Scenario** — Deploy `Conflict 2.0 PVE` (`59AA05D219B91F43`, scenario `{272AE992E942F891}Missions/Conflict20PVE.conf`) as Everon high-density PVE replacement for PCM.
- **Build Order/Architecture** — Same ~85-mod stack on top of RHS Status Quo + WCS + ACE + AttachmentFramework.
- **Outcome** — **Hard crash during world load.** `error.log` from `logs_2026-05-12_17-57-04`: 100+ consecutive `WORLD (E): Unknown class 'coords'` at byte offsets 110000–160000 inside the binary world resource, interleaved with `Unexpected end of scope at offset NNNNNN`. Then `ENGINE (F): Crashed` and `ArmaReforgerServer_2026-05-12_18-00-28.mdmp`. crash.log: `Access violation. Illegal write by 0x7ff721d68056 at 0x0` — NULL write in the world deserializer when it hit the unknown class.
- **Root Cause** — **Additive vs Overwrite**. Conflict 2.0 PVE's custom Everon world data declares a `coords` class type that this engine version (1.6.0.119) does not recognize — either built against a different Reforger version or colliding with another mod that overrides world prefab classes. The deserializer dereferences NULL when it cannot resolve the class. Permanently blacklisted. See `landmine_conflict20pve_world_crash.md`.

## 6. Steam dedicated gproj-missing + GRS apparel client CRC mismatch (2026-05-12)

- **Scenario** — Cleanly purge orphan transitive-dependency mods from `addons/`, then re-add via Steam Workshop dedicated-server download channel.
- **Build Order/Architecture** — Orphan-mod purge of ~32 transitive deps, then Steam re-download via "Required addons" channel.
- **Outcome** — Steam re-delivered `data.pak`, `resourceDatabase.rdb`, `meta`, `ServerData.json` **but NOT `addon.gproj`** for many mods. Engine logged `Addon '<X>' dependency '<GUID>' can't be added` → `Cannot initialize game project settings!` → `Cannot create game!` → `Unable to initialize the game`. PID lived ~10 s then died (launcher's `[OK]` was a false positive). After reconstructing gprojs from `ServerData.json` and rebooting successfully, **clients with the original Workshop versions of GRS-Patches/GRS-DevFramework could not join** — `RplConnection::ValidationError remote script source code checksum does not match!`. Reconstructed gproj had TITLE `"GRSPatches"`, Workshop has `"GRS - Patches"` → different script CRC → connection rejected.
- **Root Cause** — **Load Order DAG** (dependency resolution gate) combined with **Proxy Node Preservation** (script-CRC validation). Engine validates registered addons by `addon.gproj` GUID; missing gproj → mod unregistered → cascading dep failures. Once reconstructed locally, the gproj TITLE field's spaces/dashes propagate into the client-server CRC handshake. Workarounds in `landmine_steam_dedicated_addon_gproj_missing.md`; current production drops the affected mods from `serverConfig.json` until verified byte-identical to Workshop manifests (sha512).

## 7. Pak file lock when moving addon folders with server running (2026-05-11)

- **Scenario** — Disable a misbehaving mod by moving its folder from `addons/` to `addons_disabled/` while the server was live.
- **Build Order/Architecture** — `Move-Item profile_new/addons/<mod> profile_new/addons_disabled/` against a live `ArmaReforgerServer.exe` process.
- **Outcome** — PowerShell silently moved the unlocked files (gproj, rdb, manifests, meta) but failed on `data.pak` (held open by the engine). The folder existed in **both** locations partially. Cleaning up the "leftover" source folder destroyed the only complete `data.pak`. On next boot the mod loaded as a manifest stub with no content; clients hit `RplConnection::ValidationError remote script source code checksum does not match!` and could not connect.
- **Root Cause** — **Load Order DAG** at the filesystem layer. Engine maintains exclusive file handles on `data.pak` while running; Windows `MOVEFILE_*` semantics allow partial moves with no atomic guarantee. Fix protocol now codified: **kill server → wait 3 s for handles to release → move/delete folders → restart**. `Get-ChildItem -Filter 'data.pak'` is the integrity check.

## 8. WCS_VehicleLock breaks vehicle occupancy

- **Scenario** — Add per-vehicle locking so players can claim a vehicle.
- **Build Order/Architecture** — `WCS_VehicleLock_61BA4EB5C886D396` enabled alongside base vehicle prefabs.
- **Outcome** — Vehicles became single-seat de facto: only one player could enter any given vehicle. Subsequent entry attempts by other players failed.
- **Root Cause** — **Additive vs Overwrite**. WCS_VehicleLock overrides the base vehicle occupancy state machine in a way that conflicts with multi-seat entry checks. Permanently disabled.

## 9. Door mods (DoorBreaching + BreachableDoors) → see-through doors

- **Scenario** — Add breachable/destructible doors for tactical entry.
- **Build Order/Architecture** — `DoorBreaching_627D0C6AE5F771FB` + `BreachableDoors_646B350F36C6D3E4` enabled, both targeting base door prefabs.
- **Outcome** — Every door on every building rendered as transparent / see-through. Players could visually look through closed doors.
- **Root Cause** — **Additive vs Overwrite**. Both mods reference a `TransparentMat.emat` asset that does not ship with either mod — the material slot exists in the overridden door prefab but the asset is missing, so the engine falls back to fully transparent. Both permanently disabled.

## 10. FoliageCollision VM exception spam

- **Scenario** — Add physical foliage collision for realism (bushes/trees actually block movement).
- **Build Order/Architecture** — `FoliageCollision_655C4558B6ED57B2` enabled.
- **Outcome** — Constant `VM Exception` spam in `script.log`, degrading server tick performance.
- **Root Cause** — **State Machine Singularity**. Foliage collision script asserts state every frame against a foliage entity model that does not match this engine version's foliage representation. Permanently disabled.

## 11. IPC_DynamicCombat_Rework `RecalculateRadioRange` ambiguous compile

- **Scenario** — Add dynamic radio-range-driven combat behavior on top of IPC.
- **Build Order/Architecture** — `IPC_DynamicCombat_Rework_68B0F1527A825B69` enabled with IPC AutonomousCaptureAI at Layer 9.
- **Outcome** — Script compile error on boot: `RecalculateRadioRange` ambiguous symbol. Mod failed to register. Engine never reached GAME state.
- **Root Cause** — **Additive vs Overwrite**. The mod redefines a method symbol that already exists in 1.6.0.119's base IPC namespace, producing an ambiguous resolution. The mod was authored against an earlier engine where the symbol did not exist. Permanently blacklisted.

## 12. IPCHigherAISkill "across-the-map laser AI"

- **Scenario** — Make IPC's AI harder by raising skill and perception.
- **Build Order/Architecture** — `IPCHigherAISkill_64DCE52D2F882ED2` enabled alongside IPC AutonomousCaptureAI.
- **Outcome** — AI engaged players at hostile ranges with near-instant headshots. Operator described it as "across the map laser AI". Gameplay unfun.
- **Root Cause** — **State Machine Singularity**. Mod hardcoded skill 70–100 + perception 1.5–2.0 with no taper curve, overriding IPC's tuned defaults. Replaced by CRX Enfusion AI (`5F268647F8A1A1F4`) with PCM-mimicking config in `profile_new/profile/CRX_EAI/*.txt` — see `golden_state_2026_05_12_v2.md`.

## 13. RHS attachments useless until WCS_RHS_Weapons bridge added (2026-05-12)

- **Scenario** — RHS weapons (M4, AK family) should accept WCS attachments (scopes, grips, suppressors).
- **Build Order/Architecture** — RHS Status Quo + WCS_Attachments + WCS_Scopes loaded, but the bridge `WCS_RHS_Weapons_65F929DF622BAD50` was downloaded on disk and **never declared in `serverConfig.json`**. Its hard dep `WCS_Weapons_65CF7AE8574E06D2` was also undeclared.
- **Outcome** — RHS weapons spawned in arsenal but had no attachment slots. Scopes/grips/suppressors had nothing to bind to.
- **Root Cause** — **Proxy Node Preservation + Load Order DAG**. WCS_RHS_Weapons is the canonical bridge that grafts WCS attachment proxy nodes onto RHS weapon prefabs. Without it, the proxy slots simply do not exist on the RHS side. Verified disk-presence is not sufficient — must be declared in `serverConfig.json` `mods[]`. Fix applied 2026-05-12; snapshot at `serverConfig.pre-rhs-attachment-fix-2026-05-12.json`. Bridge must load after both `WCS_Weapons` and `RHS-StatusQuo` per its gproj `Dependencies` block.

## 14. BaconLoadoutEditor client crash + misclassification

- **Scenario** — Provide a player-facing loadout editor for arsenal customization.
- **Build Order/Architecture** — `BaconLoadoutEditor_606B100247F5C709` declared in `serverConfig.json` `mods[]` alongside `GRS-Apparel` (which has it as a hard dep via `addon.gproj`).
- **Outcome** — Clients who opened the loadout editor crashed or froze. Investigation revealed it is **not a generic loadout editor** — only an M4 Block II / URG-I customizer, mislabeled and mismarketed.
- **Root Cause** — **State Machine Singularity** (client-side UI bug — known upstream, unfixed). Originally removed from `serverConfig.json` `mods[]` to prevent server from advertising it. **Folder kept on disk** because GRS-Apparel's `addon.gproj` hard-depends on it (engine's resolver checks folder presence, not modlist declaration). The actual generic loadout editor for this stack is `WCS_LoadoutEditor_61D57616CAFBB23D`. MOTD warns players. **Update 2026-05-13**: re-added as first-class mod after discovering folder-presence ALSO triggers script execution (see #18 below). Real fix is to delete corrupt loadout blobs (see #21 below).

## 15. WCS_Earplugs version pinning to deleted Workshop revision (2026-05-13)

- **Scenario** — Add WCS_Earplugs hearing-protection mod to the stack.
- **Build Order/Architecture** — `serverConfig.json` `mods[]` declared `WCS_Earplugs` GUID `612F512CD4CB21D5` with a specific version (1.0.4). Installed disk folder was version 6.0.2.
- **Outcome** — Boot at 2026-05-13 00:13:55 logged in `logs_2026-05-13_00-13-55/console.log`:
  ```
  00:14:01.765 BACKEND      : Addon Download started 612F512CD4CB21D5 - WCS_Earplugs
  00:14:02.661 BACKEND   (E): [RestApi] ID:[5] TYPE:[EBREQ_CONTENT_DirectDownloadFile] Error Code:404 - Not Found
  00:14:02.860 ENGINE    (E): Unable to initialize the game
  ```
  Server died during init. The pinned 1.0.4 revision had been deleted from Workshop; Steam returned HTTP 404 and the engine bailed.
- **Root Cause** — **Load Order DAG** (download-time dependency gate). Reforger's dedicated-server backend treats version mismatch as a forced re-download; when the pinned version is gone from Workshop, the entire game init aborts. Fix: drop the explicit version pin in `serverConfig.json` so the engine accepts whatever is on disk, OR update the pin to the current Workshop revision.

## 16. Realistic Combat Drones soft-lock on custom factions

- **Scenario** — Add drone-camera operator gameplay.
- **Build Order/Architecture** — `Realistic Combat Drones` enabled alongside custom faction packs including ION.
- **Outcome** — When a player on a custom faction (e.g. ION) entered drone camera view, the client soft-locked — camera could not be exited, no input response.
- **Root Cause** — **Faction Reality Check**. The drone mod's exit-camera state machine keys off a faction-enum match against a hardcoded list; custom factions are not in that list, so no exit transition exists. Permanently disabled.

## 17. ProceduralCombatRHS broken with this stack

- **Scenario** — Run the RHS-themed Procedural Combat variant (`68776D13266976ED`).
- **Build Order/Architecture** — `ProceduralCombatRHS` stacked on top of base `ProceduralCombat` + the existing RHS content layer.
- **Outcome** — Scenario failed to initialize correctly; previously documented as "broken" in the disabled-mods table without surviving log evidence (predates the current investigation cycle). PCM stack is now entirely abandoned regardless.
- **Root Cause** — **Additive vs Overwrite** (suspected — stacking PCM-RHS on top of an already-present RHS Status Quo content layer creates duplicate prefab registrations). Permanently blacklisted irrespective of the broader PCM abandonment.

## 18. WCS_Earplugs version-pin to deleted Workshop revision (2026-05-13 ~00:14)

- **Scenario** — Add `WCS_Earplugs` (`612F512CD4CB21D5`) hearing-protection mod to the stack as part of the 2026-05-13 modlist expansion.
- **Build Order/Architecture** — Declared in `serverConfig.json` `mods[]` with explicit `version: "1.0.4"`. Workshop only ships v6.0.2.
- **Outcome** — Boot at 2026-05-13 00:13:55 logged in `logs_2026-05-13_00-13-55/console.log`:
  ```
  00:14:01.765 BACKEND      : Addon Download started 612F512CD4CB21D5 - WCS_Earplugs
  00:14:02.661 BACKEND   (E): [RestApi] ID:[5] TYPE:[EBREQ_CONTENT_DirectDownloadFile] Error Code:404 - Not Found
  00:14:02.860 ENGINE    (E): Unable to initialize the game
  ```
  The downstream cascade emitted the **misleading** `Game addon '58D0FB3206B6F859' not found` (the base game GUID) — wasted ~30 minutes of investigation before the BACKEND 404 above was identified as the real cause.
- **Root Cause** — **Load Order DAG** (download-time dependency gate). Reforger's dedicated-server backend treats version mismatch as a forced re-download; when the pinned version is deleted from Workshop, the entire game init aborts. **Two rules codified**: (1) **ALWAYS use empty `version: ""` for new mods unless you have a specific frozen-revision reason** — engine then accepts on-disk version OR pulls latest. (2) **The `Game addon '<base game GUID>' not found` error is a misleading downstream symptom** of ANY mod's dep chain failing to resolve, not literally about the base game; always look at console.log BACKEND lines for the actual download failure.

## 19. Folder-presence triggers script execution (2026-05-13)

- **Scenario** — Disable BaconLoadoutEditor by removing it from `serverConfig.json` `mods[]` while leaving the folder in `profile_new/addons/` (the half-measure from entry #14).
- **Build Order/Architecture** — `serverConfig.json` `mods[]` had no `BaconLoadoutEditor` entry, but `profile_new/addons/BaconLoadoutEditor_606B100247F5C709/` was present on disk (because GRS-Apparel's gproj hard-depends on it).
- **Outcome** — `console.log` still logged the BLE `addon.gproj`, and `script.log` emitted compile warnings for BLE scripts as if it were declared. Two other mods (GRS-Apparel, sTsRHSVanillaArsenal added 2026-05-13) hard-dep BLE via gproj, so its scripts loaded via the dep chain regardless of `mods[]` declaration.
- **Root Cause** — **Load Order DAG**. Reforger's resolver does NOT use `mods[]` as a positive whitelist for script execution — it walks the gproj dependency graph from declared mods AND from any mod with a folder present. Removing from `mods[]` only suppresses the engine from advertising the mod to clients in the lobby manifest; it does not prevent compile or execution. **Rule**: to truly disable a mod, move folder OR remove from disk. Re-added BLE as first-class 2026-05-13 since suppression was illusory anyway.

## 20. PVE Conflict Remixed `_US4x` scenario name semantics (2026-05-13)

- **Scenario** — Operator expected `ConflictPVERemixedVanilla2_US4x.conf` to mean "4× US bases" → high US AI count. After hours of running, US IPC group count plateaued at ~3 across all sessions while FIA grew unbounded.
- **Build Order/Architecture** — Standard active stack with 8x-scaled IPC `US_PRIMARY/SECONDARY/SEIZING_PATROL` templates. Operator assumed the templates would multiply across multiple US bases.
- **Outcome** — `IPC Groups of Faction US,` consistently logged at ~3. Diagnostic via the `LOGLOGLOG. Dynamic HQ RADIO` lines (which name each base's affiliated faction at boot) revealed the map has **exactly 1 US-affiliated base** (the player HQ). All 70+ other bases are FIA. So US AI is gated to `1 base × N templates = ~3 groups regardless of IPC array length`.
- **Root Cause** — **Faction Reality Check**. The `_US4x` suffix means **player spawn faction = US** (1 base) and **4× AI density on the FIA enemy side**, NOT 4× US bases. Naming convention is non-obvious; operator's intuition was wrong. There is **no `_US8x` scenario variant** — 4x is the ceiling without a Workbench scenario fork. Mitigation: rely on FIA density (which the 8x templates DO scale) for combat encounters; player HQ always has minimal US presence by design.

## 21. Corrupt BaconLoadoutEditor loadout blobs cause client crash (2026-05-13)

- **Scenario** — Players opening BLE in-client crashed or froze, even after deleting and re-installing the mod. Symptom appeared related to the entry #14 client-UI bug but persisted after upstream UI fixes.
- **Build Order/Architecture** — BLE re-added as first-class mod 2026-05-13. `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` and `profile_new/profile/BaconLoadoutEditor_Loadouts/1.6.0/admin_loadouts` carried over from PCM-era sessions.
- **Outcome** — Audit of the loadout blob JSON revealed 22 prefab GUID references that no longer exist on disk (e.g. `{083483A1C5B8CA13}` SCAR-H mag, `{24880E53C1ED467A}` SCAR-H, `{6B42F5E6DC8C7E47}` M18 grenade attachment — all from PCM/RHS-PCM-era mods removed weeks ago). BLE's loader iterates the blob's prefab list and dereferences each lookup result without null-checking. Missing prefab → null → crash.
- **Root Cause** — **State Machine Singularity** (BLE has no skip-and-continue path). The loadout file format references prefabs by GUID; when a prefab disappears from the engine's catalog (because its source mod was uninstalled), BLE's loader hits null and crashes the client UI. Fix: delete the storage files (`BaconLoadoutEditor_Loadouts/1.6.0/US/cc/<UID>` and `admin_loadouts`); BLE re-inits empty on next open. **Diagnostic side-channel**: `profile_new/profile/WCS_LoadoutEditor/audit/incidents/*.jsonl` is the canonical place to read for "missing prefab" diagnostics — engine doesn't surface these in script.log, only this audit subfolder does.

## 22. CRX_EAI Rank_Type silently overrides IPC removeRankRequirements (2026-05-13)

- **Scenario** — IPC `IPC_Settings.json` had `removeRankRequirements: true` to allow all players to access all loadouts regardless of rank. Players still could not access higher-rank loadouts.
- **Build Order/Architecture** — IPC AutonomousCaptureAI + CRX Enfusion AI both active. CRX_EAI `CRX_EAICharacterConfig.txt` had default `Rank_Type=0` (CRX rank system).
- **Outcome** — Rank gating still applied client-side; players received "insufficient rank" UI feedback when attempting to access higher-tier loadouts despite IPC's bypass flag.
- **Root Cause** — **State Machine Singularity** (two rank systems competing). CRX_EAI's `Rank_Type=0` (CRX rank) hooks the rank-check pipeline at a layer above IPC's `removeRankRequirements: true`. Setting CRX `Rank_Type=1` (vanilla) defers to IPC's rank bypass. Currently set correctly (verified `CRX_EAICharacterConfig.txt:13`). **Rule**: when stacking rank-affecting mods, audit each one's rank-type setting and ensure only one is the source of truth.

## 23. DAG load-order violations applied (2026-05-13)

- **Scenario** — `serverConfig.json` `mods[]` array had three forward-dependency violations where a mod was listed before a mod it hard-depends on via `addon.gproj`.
- **Build Order/Architecture** — Three violations identified by gproj audit: WCS_Clothing listed before WCS_Clothing_Assets; GRS-Apparel listed before GRS-Patches; LinearConflictPVE + PVEConflictwithRHSandWCS bridge listed before ConflictPVERemixedVanilla2.0 base scenario.
- **Outcome** — Cosmetic warnings + occasional asset-resolution timing race. Not a hard failure (Reforger's resolver topologically sorts), but creates noisy boots and risks subtle init-order bugs as the modlist grows.
- **Root Cause** — **Load Order DAG hygiene**. Engine resolver handles forward-deps gracefully via topological sort, but the `mods[]` array order is the canonical reference for human triage and for any tooling that walks it linearly (including the launcher's preflight). Reordered 2026-05-13 to match the gproj DAG. Three other forward-dep violations remain but are cosmetic-only (engine handles them): SpaceCore/AKI_Core/AUS_CORE deps WCS_Armaments; Arma2Factions deps TacticalFlava; 3DRSMODERNRUSSIANSFACTION deps T72A/Zagoria89BMD/ZSU-23-4.

---

## What we learned

Five dominant failure modes consume nearly every entry above. **Load-order ignorance** (#6, #7, #13, #15, #18, #19, #23) — Enfusion's runtime trusts the gproj DAG, not user intent: missing gprojs, locked paks, undeclared bridge mods, unresolvable version pins, suppression-via-modlist-omission (folder-presence still triggers compile + execution), and forward-dep ordering all manifest as silent breakage or hard init death. **Version-pinning to deleted Workshop revisions** (#15, #18) — Steam Workshop is mutable upstream, and Reforger's backend treats 404s on pinned downloads as fatal; pin only when the revision is known-frozen, otherwise let the engine accept on-disk content with `version: ""`. The downstream `Game addon '<base game GUID>' not found` error is misleading — always look at console.log BACKEND lines for the actual download failure. **Scenario-mod-vs-content-mod confusion** (#1, #2, #4, #5, #17, #20) — content mods provide unit prefabs and assets independently of the scenario controller, but scenario controllers must be authored against the specific maps and engine version they target; scenario filename suffixes like `_US4x` mean "player faction = US, 4× enemy density", NOT 4× player bases — operator intuition often misfires here. **Faction enums cannot be runtime-extended** (#3, #11, #12, #16) — every faction-keyed system (PCM menu validator, IPC `SCR_ECampaignFaction`, drone exit-camera dispatch, Iron Front entity filter, WCS_Arsenal `SCR_LoadoutTemplate`) compiles its faction set at script load; faction packs that add unit prefabs do not extend these enums, and there is no JSON runtime hook to inject one. Custom faction support requires Reforger Workbench + Workshop publishing. **Stale state-blob persistence across mod-version churn** (#21, #22) — files written under `profile_new/profile/<mod>/` by mod sessions weeks ago can reference prefabs and rank-system schemas that no longer exist; the loaders in those mods often have no skip-and-continue path and crash the client UI. The current golden state (`golden_state_2026_05_13_v3.md`, supersedes v2) is the cumulative scar tissue of all 23 failures above: PVE Conflict Remixed Vanilla 2.0 (US4x) + IPC (8x scaled, aiLimit 3500) + LCP (800m/2000m radii) + CRX EAI + sister AI mods (DarcChopper + AI Mortar), 113 mods total, no persistence, no Procedural Combat, no faction enum extensions attempted, every bridge mod explicitly declared in `serverConfig.json`, all DAG load-order violations resolved.
