# Workbench Bridge Mod — Custom IPC Faction + Cross-Faction Arsenal

> **STATUS 2026-05-16: LOWER PRIORITY.** COE2 delivers configurable factions out-of-box. Bridge mod plan retained for operators wanting IPC-specific behaviors or default-class-per-faction (no Workshop solution exists for the latter — see task #26).
>
> **STATUS 2026-05-14: LOWER PRIORITY / OPTIONAL.** This plan was created when IPC AutonomousCaptureAI was the active scenario controller and the operator wanted to extend its hardcoded 4-faction enum. **The COE2 (Combat Ops Enhanced 2) pivot delivered runtime configurable factions out of the box** — see [[golden_state_2026_05_14_v4]]. This bridge mod is no longer required for normal operation. Keep this doc as a fallback path if a future operator wants to revive IPC or build a different scenario controller. The Workbench setup steps and SampleMod_NewFaction breakdown remain valid Reforger modding references regardless.

**Living plan document.** Pick this up at any point — every step is self-contained. Authored 2026-05-13 during operator absence; updated as work progresses.

## Why this exists

The active scenario `ConflictPVERemixedVanilla2_US4x.conf` registers exactly two `SCR_ECampaignFaction` enum values (US + FIA). The bridge mod `PVEConflictwithRHSandWCS` (`68F2074F389D3186`) only catalogs WCS + RHS items into those factions' `EntityCatalog/InventoryItems.conf`. Result:

- **Arsenal**: only WCS + RHS weapons appear in HQ arsenal boxes. ~100+ DarkGru/Arma2/PMC unique weapons load as prefabs (you can spawn the units in GM and see them holding the weapons) but are **invisible in arsenal UI** because their `SCR_FactionEntityCatalog` slot is never wired into the active scenario.
- **IPC enemies**: only US/USSR/FIA/CIV ever spawn. DarkGru/Arma2/PMC unit prefabs are loaded but no `SCR_CampaignFaction` is registered → IPC's `IPC_GroupList_<Faction>` never builds for them → they never spawn as enemies.

Three mods on the entire Workshop have solved a version of this problem:
- `IPC Modern Faction` (`65766E0A71C84C76`) — RHS US/USSR (depends on **IPC dev branch**, risky)
- `IPC Warhammer Faction` (`6584626743935E61`) — Warhammer 40k
- `Sample Mod - New Faction` (`5614E48126E3ADF2`) — Bohemia's canonical template (cleanest starting point)

Verified empty: 14+ scenarios on the Workshop, including `ConflictPVERemixedTweak`, `Modern2.0`, `Endless Conflict PVE RHS WCS`. None expose runtime config-driven faction extension. **Workbench is the only path.**

## Goal of this mod

A single Workbench-published mod that does THREE things:

1. **Extends `SCR_ECampaignFaction` enum** with one new value per target faction pack (DarkGru, Arma2, PMC; optionally re-add 3DRS later).
2. **Registers each new faction with `CampaignFactionManager`** by shipping a `SCR_CampaignFaction.conf` per faction whose `m_DefendersGroupPrefab` + `m_aEntityCatalogs` point at that faction pack's prefabs. **IPC AutonomousCaptureAI consumes this implicitly** — no separate IPC schema needed.
3. **Cross-faction arsenal merge**: overrides the US faction's `InventoryItems_EntityCatalog_US.conf` to append every faction pack's weapon entries → operator sees ALL weapons in any US arsenal box.

Estimated effort: **6-10 hours of Workbench work** for the operator. Server-side blocked — Claude cannot do this work.

## Prerequisites (operator must do — ~45 min)

1. **Install Reforger Tools (Workbench)** from Steam library → Tools → "Arma Reforger Tools" (~3 GB free download).
2. **Verify Workshop publisher account** — must be linked to the same Bohemia account on Steam. Check at https://reforger.armaplatform.com/ → My Workshop.
3. **Clone Bohemia's sample repo** (`git` required):
   ```
   git clone https://github.com/BohemiaInteractive/Arma-Reforger-Samples C:\Reforger-Samples
   ```
   (Path can be anywhere outside Steam install dirs.)

## Operator's faction-pack inventory (verified 2026-05-13)

Extracted from each pack's `addon.gproj`:

| Faction Pack | GUID | Title (in gproj) | gproj Dependencies |
|---|---|---|---|
| DarkGruFactions | `66E9222820080A19` | "DarkGru Factions" | base game only |
| PMCFaction | `6510F26F66E795D4` | **"Overide"** ⚠️ MISLABELED | CapsWeaponPack `6319242B050D1483`, MisfitsSquadGear `621B35CDE40DB644`, MisfitsGearCryeG4 `64CD46D2FF22E6D2`, RHS_Status_Quo `595F2BF2F44836FB`, BaconSuppressors `5AB301290317994A` |
| Arma2Factions | `5F396C4F713595DB` | "Arma II Factions" | base game, RHS_Status_Quo, TacticalFlava `5D550926D43F1409` |
| (Optional) ModernRussians_3DRS | `666C002F6BB6441C` | "3DRS Modern Russians Faction" | currently REMOVED — only re-add if operator wants modern Russian enemies |

**⚠️ PMCFaction landmine**: its `gproj` ID is "Overide" (typo'd, no second 'r'), not "PMCFaction". Same class of bug as the SGCPvOverrides → AllArsenalItemsToPrivate mislabeling we hit yesterday. When searching for PMC content in Workbench Resource Manager, look under **"Overide"**.

**Arma2Factions noted finding**: ships localization at `Language/SesFactionsLocalization.st` — this is the **source of the documented `'Ses_TKA'/'Ses_TKG'/'Ses_CDF'/'Ses_NAPA'/'Ses_ChDKZ'` SCR_Faction warnings** in CLAUDE.md cosmetic noise list. Those are stale faction string references inside Arma II Factions' configs — non-blocking, but if you later remove Arma2Factions those warnings disappear.

## Step-by-step build procedure

### Phase 1 — Workbench project setup (~30 min)

1. Launch Workbench from Steam.
2. File → New Project → Name: `OperatorBridgeFactions` → Path: `C:\Reforger-Workbench-Projects\OperatorBridgeFactions\`
3. In the new project, click "Add Existing Project" → browse to `C:\Reforger-Samples\SampleMod_NewFaction\SampleMod_NewFaction.gproj`. This brings the Bohemia template in as a reference project (do NOT modify the sample directly — copy from it).
4. **Subscribe to source** (right-click → Subscribe to Source) for these published mods, to get their prefabs into the Resource Manager:
   - `66E9222820080A19` DarkGru Factions
   - `6510F26F66E795D4` PMC ("Overide")
   - `5F396C4F713595DB` Arma II Factions
   - `595F2BF2F44836FB` RHS Status Quo
   - `64610AFB74AA9842` WCS Core
   - `61B514B96692C049` PVE Conflict Remixed Vanilla 2.0 (the active scenario — for `EditablePrefabsComponent_EditableEntity.conf` reference)
5. Optionally subscribe to source for `IPC Modern Faction` (`65766E0A71C84C76`) as a working reference for IPC integration.

### Phase 2 — Modded enum extension (15 min)

In your project, create:

**File**: `Scripts/Game/Editor/Enums/Modded/EEditableEntityLabel_OperatorFactions.c`

```c
modded enum EEditableEntityLabel
{
    // Use unix-time-derived ints to avoid collisions with other modded enums.
    // Pattern: 17471 prefix (= 2026-05-13) + faction index.
    FACTION_DARKGRU = 1747100001,
    FACTION_ARMA2   = 1747100002,
    FACTION_PMC     = 1747100003,
    // FACTION_3DRS = 1747100004,  // uncomment if 3DRS is re-added
}
```

### Phase 3 — Per-faction config (90 min × 3 factions = 4.5 hr)

For EACH target faction (DarkGru first as the simplest with no transitive deps), repeat:

#### 3a. Discover unit/vehicle/weapon GUIDs from the faction pack

In Workbench Resource Manager, navigate into the faction pack's mod tree. Look for:
- `Configs/Editor/PlaceableEntities/Characters_*.conf` — list of soldier prefabs
- `Configs/Editor/PlaceableEntities/Groups_*.conf` — group prefabs (squads/teams)
- `Configs/Editor/PlaceableEntities/Vehicles_*.conf` — vehicle prefabs
- `Configs/EntityCatalog/<Faction>/<Faction>_InventoryItems.conf` — weapon/equipment items

Note 8-12 representative soldier GUIDs, 3-6 group GUIDs, 4-8 vehicle GUIDs. Copy the `m_aEntityEntryList` block from `_InventoryItems.conf` wholesale.

#### 3b. Create the `SCR_Faction` definition

**File**: `Configs/Factions/DarkGruFaction.conf` (copy from `SampleMod_NewFaction/Configs/Factions/SampleFactionBLUFOR.conf`, then edit):

```
SCR_Faction : "{...your-mod-guid...}/Factions.conf" {
 m_sFactionKey "DARKGRU"
 m_FactionName "DarkGru Operators"
 m_FactionFlagMaterial "{...DarkGru-flag-emat-GUID...}"
 m_aEntityCatalogs {
  // Pointers to your _Characters/_Groups/_Vehicles/_InventoryItems configs
 }
 ...
}
```

#### 3c. Create the `SCR_CampaignFaction` wrapper (THE IPC INTEGRATION LINCHPIN)

**File**: `Configs/Factions/DarkGruFaction_Campaign.conf` (copy from sample):

```
SCR_CampaignFaction : "{your-DarkGruFaction-conf-GUID}" {
 m_DefendersGroupPrefab "{...DarkGru-defender-group-GUID...}"  // <— IPC reads this
 m_aStartingVehicles {
  "{...DarkGru-vehicle-GUID-1...}"
  "{...DarkGru-vehicle-GUID-2...}"
 }
 m_MobileHQPrefab "{9CB496688A3BCC3E}"  // West HQ is the standard anchor
 m_RadioPrefab "{...standard-radio-GUID...}"
 m_BaseBuildingHQ "{...standard-base-building-GUID...}"
 m_aEntityCatalogs { ... }
}
```

**This is what makes IPC spawn DarkGru as enemies.** IPC's `IPC_GroupList_DARKGRU` is auto-built from this faction's `EntityCatalog/Groups` after registration.

#### 3d. Create the arsenal catalog override

**File**: `Configs/EntityCatalog/DarkGru/DarkGruFaction_InventoryItems.conf` (copy DarkGru's own InventoryItems.conf wholesale to start):

This is what makes DarkGru weapons APPEAR in DarkGru-faction arsenal boxes.

### Phase 4 — Cross-faction arsenal merge (45 min)

This is the single mod feature that delivers the "operator's stated goal: single arsenal with all weapons in US arsenal box":

**File**: `Configs/EntityCatalog/US/InventoryItems_EntityCatalog_US.conf` (override the vanilla US arsenal catalog)

In Workbench: open the active scenario's `InventoryItems_EntityCatalog_US.conf`, select all `SCR_EntityCatalogEntry` entries, copy. In your override, paste them PLUS append:
- All entries from `DarkGruFaction_InventoryItems.conf`
- All entries from `Arma2Faction_InventoryItems.conf`
- All entries from `PMCFaction_InventoryItems.conf`

Same `EntityCatalogEntry` schema; just expand the array. Engine will handle `MRO last-writer-wins` to merge into one combined US arsenal that surfaces every faction's gear.

(This is the same pattern `ArsenalBox-SoftAddingMods` `66DED7D8E3BF7E8D` uses.)

### Phase 5 — Register with CampaignFactionManager (15 min)

In `Configs/Workbench/EditablePrefabs/EditablePrefabsComponent_EditableEntity.conf`, override the master `CampaignFactionManager` to add pointers to your three new `_Campaign.conf` files in `m_aFactions[]`.

### Phase 6 — Build, publish, deploy (30 min)

1. In Workbench: Tools → Addon Manager → Build & Publish under operator's Workshop account.
2. Note the new mod GUID Workshop assigns (will be a 16-char hex like `1234567890ABCDEF`).
3. **Take server-side snapshot first** (per CLAUDE.md regression-prevention protocol):
   ```powershell
   & 'C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\snapshot_state.ps1' -Label "pre-bridge-mod-install"
   ```
4. Add the new mod to `serverConfig.json` `mods[]` with `version: ""` (per the WCS_Earplugs landmine — never pin a fresh mod's version).
5. Place the new mod entry at **Layer 11 tail**, AFTER `PVEConflictwithRHSandWCS` so its catalog overrides win.
6. Restart server via `start_server.ps1`.

### Phase 7 — Validation gates

Server-side checks (greppable):
- `script.log` should show `Loaded 2 arsenal loadout templates` change to **5** (US + USSR + DARKGRU + ARMA2 + PMC). The `2 != 4` warning becomes `5 = 5`.
- `IPC Groups of Faction DARKGRU,` should appear in `script.log` IPC ticks (currently only US/USSR/FIA/CIV).
- `[AC] SpawnPoint . Faction affliated DARKGRU. WayPoint Updated:` should appear after first FIA base capture.

In-game test:
- Capture an FIA base. Wait 60s. Should see DarkGru units spawning around it (if IPC rotates).
- Open US HQ arsenal box. DarkGru/PMC/Arma2 weapons should appear in the rifle/MG/optic categories.
- Spawn yourself with a faction-pack-specific weapon. Test fires fine.

Recovery (if anything breaks):
```powershell
& 'C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server\restore_state.ps1' -Snapshot pre-bridge-mod-install
```

## ❌ Failed shortcut attempt: IPC Proxy War via IPC_SoldierList.json (2026-05-13 16:18-17:31)

Gemini suggested a shortcut: edit `profile_new/profile/IPC/IPC_SoldierList.json` to swap WCS_RU prefabs into the `FIA` bucket → IPC commands FIA but spawns Russian-looking enemies. **Tested and confirmed dead end.**

Findings (snapshot `pre-IPC-proxy-war-exploration` 16:17:51, restored 17:30):

1. **WCS_RU is weapons-only**, not characters. Its `addon.gproj` deps are only base game + WCS_Attachments + WCS_Scopes + WCS_Sounds. Confirms WCS_NATO/RU are weapon subsets for the WCS framework, NOT character/loadout replacements. Gemini misunderstood what these mods are.
2. **IPC_SoldierList.json is supplementary, not authoritative**. Booted server's script.log shows IPC enumerating 98+ USSR_Army character prefabs from auto-discovery (Spetsnaz/Naval_Infantry/KLMK variants never declared in the JSON). The JSON is an additive override list, not the source of truth.
3. **Even the minimal-change test crashed boot**: populating `FIA` bucket with 8 vanilla USSR_Army prefabs (using known-working GUIDs already in the USSR bucket) caused the boot to hang silently at the IPC prefab enumeration phase (~index [98]). No `Cached 608 items`, no `OnGameStateChanged = GAME`, no crash dump — process exited. Suggests the IPC init has unsafe assumptions about the FIA bucket's contents.
4. **The active scenario's FIA defenders come from the scenario's own SCR_Faction registration**, not IPC_SoldierList.json. Even if the JSON edit had booted, it would only have controlled IPC-spawned reinforcements, not the base-game FIA defender prefabs.

**Verdict**: do NOT attempt IPC_SoldierList.json edits to bypass the bridge mod. Workbench remains the only path. Document committed to CLAUDE.md cosmetic-noise / abandoned-paths section so future sessions don't re-explore.

## Resolved decisions (operator gave Claude permission to proceed with best judgment 2026-05-13 15:05)

1. **Build order**: **DarkGru first, then PMC, then Arma2.** Rationale: DarkGru has zero transitive deps (cleanest gproj), so first iteration validates the IPC bridge mechanism without dep-chain noise. PMC second because its deps (Caps, Misfits, RHS, Bacon) are already loaded — easy. Arma2Factions last because it has localization quirks and the `Ses_*` faction-string warnings are sourced there.
2. **Player faction**: **Enemy-only initially.** DarkGru/PMC/Arma2 register as `SCR_CampaignFaction` so IPC pulls them as enemies, but they're NOT added to `CampaignFactionManager.m_aFactions[playable]`. Simpler, validates IPC integration first. Promote to playable later via a small follow-up edit.
3. **Arsenal merge scope**: **US-only.** Operator's player faction is US. Merge all 3 faction packs' weapon entries into `InventoryItems_EntityCatalog_US.conf` override. USSR isn't a player faction in this scenario — no value adding USSR-arsenal-with-everything.
4. **3DRS re-add**: **NO**. Stays removed. Small per-session perception-spam reduction confirmed. If the operator later wants modern Russian enemies, easier path is to add `FACTION_3DRS` to the bridge mod's enum extension than to re-add the standalone faction pack.

## Files created by this work

- `Scripts/Game/Editor/Enums/Modded/EEditableEntityLabel_OperatorFactions.c` — modded enum
- `Configs/Factions/<Faction>Faction.conf` × 3 — SCR_Faction definitions
- `Configs/Factions/<Faction>Faction_Campaign.conf` × 3 — SCR_CampaignFaction wrappers (IPC linchpin)
- `Configs/EntityCatalog/<Faction>/<Faction>Faction_InventoryItems.conf` × 3 — per-faction arsenals
- `Configs/EntityCatalog/US/InventoryItems_EntityCatalog_US.conf` — cross-faction merged US arsenal
- `Configs/Workbench/EditablePrefabs/EditablePrefabsComponent_EditableEntity.conf` — CampaignFactionManager override

## References

- BI Sample repo: https://github.com/BohemiaInteractive/Arma-Reforger-Samples
- BI Faction Creation wiki: https://community.bistudio.com/wiki/Arma_Reforger:Faction_Creation
- BI Modded Enum wiki: https://community.bistudio.com/wiki/Arma_Reforger:Modded_Enum
- BI Faction tutorial playlist (YouTube): https://www.youtube.com/playlist?list=PLfQwdqWWfpOmogmFw-UpFYvXlXkD9U_t4
- IPC Modern Faction (working reference): https://reforger.armaplatform.com/workshop/65766E0A71C84C76-IPCModernFaction
- IPC AutonomousCaptureAI dev branch: https://reforger.armaplatform.com/workshop/6550E750653AA699
- ArsenalBox-SoftAddingMods (catalog-merge pattern reference): https://reforger.armaplatform.com/workshop/66DED7D8E3BF7E8D

## Progress log

| Date | Status | Notes |
|---|---|---|
| 2026-05-13 14:35 | Plan authored | Operator stepped away; document created so work can resume at any point |
| 2026-05-13 16:18-17:31 | IPC Proxy War shortcut tested + abandoned | See "Failed shortcut attempt" section above. Workbench remains the only path. |
| 2026-05-13 18:20 | **Project skeleton built server-side** | Bohemia samples cloned to `C:\Reforger-Bridge-Build\Arma-Reforger-Samples\`. Project skeleton at `C:\Reforger-Bridge-Build\OperatorBridgeFactions\` (668 files, 58 MB). gproj renamed + deps declared. Modded enum file written with FACTION_DARKGRU/PMC/ARMA2 (unix-time-derived ints). Operator next-steps doc at `C:\Reforger-Bridge-Build\OPERATOR_NEXT_STEPS.md`. |
| _next_ | _operator action_ | **Open `OperatorBridgeFactions.gproj` in Workbench, follow OPERATOR_NEXT_STEPS.md Phase 1.** |
