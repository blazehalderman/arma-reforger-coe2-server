# Ask: Transitive-dep & state-drift audit

**Date**: 2026-05-16
**Source**: surfaced as a side-effect of the 119-mod doc enrichment pass (parallel specialist subagents)
**Status**: findings collected; operator decision pending per item

---

## TL;DR

The mod-doc enrichment surfaced **11 undeclared transitive dependencies** and **4 documentation/state drifts** between CLAUDE.md / MASTER_OBJECTIVE.md / live config / live profile files.

Per CLAUDE.md "Mod purge safety protocol" + the IPCHigherAISkill 2026-05-13 cascade, **folder-presence triggers script execution regardless of declaration in `mods[]`**. Today these transitive deps work because Steam already pulled them. **Any Steam re-download eviction between sessions silently breaks the depper mod** because:
- Steam ONLY re-downloads what's in `mods[]`
- The depper mod will fail to register
- The cascade is usually a misleading `Game addon '58D0FB3206B6F859' not found` (CLAUDE.md 2026-05-13 landmine)

Mitigation: declare each transitive dep explicitly in `serverConfig.json mods[]` with `version: ""` (per the WCS_Earplugs 1.0.4 version-pin landmine — never pin).

---

## Undeclared transitive deps (11)

Status legend:
- 🔴 **Active risk** — depper mod is in service today; transitive dep is on disk but undeclared
- 🟡 **Likely transitive-pulled** — needs verification by reading the depper's `addon.gproj` against the live addons folder
- ✅ **Resolved** — declared explicitly during the 2026-05-16 audit

| # | Undeclared dep | Depped by | Layer | Status | Risk |
|---|---|---|---|---|---|
| 1 | `631EE12D448D7FCC` DarcCore | DarcChopper | L0 | ✅ Resolved 2026-05-16 (declared in both configs) | n/a |
| 2 | `66DF6C37335B0554` AHCFuelSystems | H-47Chinook | L0/L8 | 🔴 Active risk | H-47 fails to register on Steam eviction |
| 3 | `668B5E64DD9E9041` LeesWeaponFramework | LeesUH-1YVenom | L0 | 🔴 Active risk | UH-1Y fails to register; CLAUDE.md lists this in "Example dep chains" but never declared |
| 4 | `6608FD6F58F3B90A` ADSSway-PIPDOF-TEST | ADSSway-Core + BWI-ADSsway-RHS-TAOcompat | L5 | 🔴 Active risk | Entire sway/aiming chain fails to register |
| 5 | `65735C5643CCC0A6` ADSSway-Conf-LOW | BWI-ADSsway-RHS-TAOcompat | L5 | 🔴 Active risk | BWI bridge fails → L10 weapon-handling overlay silently broken |
| 6 | `61ECB5EFAA346151` TacticalAnimationOverhaulTEST | BWI-ADSsway-RHS-TAOcompat | L0 | 🔴 Active risk | Same bridge cascade |
| 7 | `65BB2D0679BCA058` (Horsemans core, name unknown) | HorsemansBlackBradley | L0 | 🟡 Verify | Bradley reskin silently breaks |
| 8 | `5D5A20A8AE33C21E` (Cougar 4x4 base, name unknown) | Horsemansblackcougar | L0/L8 | 🟡 Verify | Cougar reskin silently breaks |
| 9 | `663B2784961621FB` (FRM VT4 base, name unknown) | VT4FRMblackReskin | L0/L8 | 🟡 Verify | VT4 reskin silently breaks |
| 10 | `68C322898FDCBBEA` ZagoriaBMP-2FIX | GsBTR-90 (cross-author dep) | L0/L8 | 🔴 Active risk | GsBTR-90 fails on dep eviction; ALSO purging ZagoriaBMP-2FIX in a future cleanup pass would break GsBTR-90 |
| 11 | `62FCEB51DF8527B6` (unknown — flagged by ImprovedBloodEffectDeluxe) | ImprovedBloodEffectDeluxe | ? | 🟡 Verify | Possibly soft-resolved; mod hasn't failed in observed sessions |
| 12 | `632F64CB7D65D1FC` (unknown — flagged by WCS_Armaments) | WCS_Armaments → 12+ vehicle mods | L0/L1 | 🟡 Verify | Cascade risk if this is a real script dep — WCS_Armaments is high-value |

### Recommended action (per item)

**Phase A — Declare the verified deps (zero-risk, monotonic)**:
- Add to `serverConfig.json` (local) AND `serverconfig-deployed.json`, at L0 cluster (around position 9-15):
  - `66DF6C37335B0554` AHCFuelSystems
  - `668B5E64DD9E9041` LeesWeaponFramework
  - `6608FD6F58F3B90A` ADSSway-PIPDOF-TEST
  - `65735C5643CCC0A6` ADSSway-Conf-LOW
  - `61ECB5EFAA346151` TacticalAnimationOverhaulTEST
- All with `version: ""`. All have working transitive dep folders on disk today.

**Phase B — Investigate the mystery GUIDs** (read each addons folder's gproj, identify the mod, then decide):
- `65BB2D0679BCA058`, `5D5A20A8AE33C21E`, `663B2784961621FB`, `62FCEB51DF8527B6`, `632F64CB7D65D1FC`
- Probable: each is a base content pack the reskin/extension references. Likely present on disk if the depper mod has ever loaded cleanly. Run:
  ```powershell
  Get-ChildItem profile_new/addons -Directory | Where-Object { $_.Name -match '_(65BB2D0679BCA058|5D5A20A8AE33C21E|663B2784961621FB|62FCEB51DF8527B6|632F64CB7D65D1FC)$' }
  ```
  Then read each found folder's `addon.gproj` to get the human name + decide on declaration.

**Phase C — `ZagoriaBMP-2FIX` decision**:
- Either declare it explicitly (preferred — defends GsBTR-90), OR
- Mark it in `CLAUDE.md` "Example dep chains" as a "do not purge" item alongside the existing protected list.

### Snapshot gate
- `snapshot_state.ps1 -Label "pre-transitive-dep-declarations-2026-05-16"` before any of the above.
- Verify mod count delta matches expectation (5 new in Phase A).
- Boot test — expect zero behavioral change since the same scripts were already compiling via folder-presence.

---

## Documentation drifts (4)

Findings where on-disk reality contradicts a canonical doc (CLAUDE.md / MASTER_OBJECTIVE.md / a config file).

### Drift 1 — MASTER_OBJECTIVE.md L2 table stale (ACE)

- **Claim** (MASTER_OBJECTIVE.md L2 row): "stable ACE Core + 4 feature mods (Trenches/Tactical Ladder/Tactical Periscope/Facepaint)"
- **Reality** (`serverConfig.json` 2026-05-16): **ACE Core Dev + ACE Captives Dev** are declared; no stable ACE; no 4 feature mods.
- **Root cause**: the 2026-05-14 121-mod state did include stable ACE + features, but the revert restored Dev pair. The 12-layer table was never updated.
- **Fix**: edit `MASTER_OBJECTIVE.md` L2 row to read: *"ACE Dev pair (ACE Core Dev → ACE Captives Dev — Kex hard-deps these specific Dev mods; stable ACE swap broke Kex registration 2026-05-14)"*.
- Found by: agent 2 (RHS+WCS foundation batch).

### Drift 2 — MASTER_OBJECTIVE.md L9 table stale (AI overlays)

- **Claim** (MASTER_OBJECTIVE.md L9 row): "FSTacticalAISpawnManager + ConflictNoBaseAILimit + AiMortarPve removed in COE2 pivot"
- **Reality**: all three are declared **both local + deployed** as of 2026-05-16.
- **Root cause**: the COE2 pivot DID remove the IPC chain (IPCHigherAISkill, IPC AutonomousCaptureAI, LinearConflictPVE, PVEConflictwithRHSandWCS), but FSTacticalAISpawnManager + ConflictNoBaseAILimit + AiMortarPve are separate mods that survived (or were re-added). The MO doc treated them as IPC-adjacent and dropped them.
- **Fix**: edit L9 row to add: *"FSTacticalAISpawnManager + ConflictNoBaseAILimit + AiMortarPve (all active despite earlier removal note — verified 2026-05-16)"*.
- Note: AiMortarPve is **functionally dormant on COE2** (its GameMode component isn't referenced by COE2 — see `mod_docs/AiMortarPve.md`). Active in declaration only.
- Found by: agent 7 (AI overlay + scenario batch).

### Drift 3 — ServerAdminTools MOTD references abandoned scenario stack

- **Claim** (CLAUDE.md §"What this is" + §"Admin"): MOTD was rewritten 2026-05-14 to COE2 stack.
- **Reality** (`profile_new/profile/ServerAdminTools_Config.json serverMessage`): still references the PRE-COE2 PVE Remixed scenario stack.
- **Root cause**: the 2026-05-14 121-mod state likely had the new MOTD; the 121→103 revert restored configs from before the MOTD rewrite.
- **Fix**: rewrite `serverMessage` to match the COE2 active scenario + current 103-mod stack. Per CLAUDE.md §"Admin", ALWAYS write the file with UTF-8 no-BOM. Use the template:
  ```
  Welcome to <ServerName>! Scenario: COE2 on Eden. Stack: 103 mods (RHS + WCS + ACE Dev + COE2 + CRX EAI). Admin: #login admin123 (DO NOT abuse).
  ```
- Found by: agent 8 (GM/admin/QoL batch).

### Drift 4 — Arsenal regression trio still active

- **Claim** (CLAUDE.md V5 state summary): the 103-mod baseline excludes `sTsWCSVanillaArsenal`, `sTsRHSVanillaArsenal`, `All-In-OneArsenals`, `ArsenalItemsallranks` (described as cross-faction arsenal regression contributors removed in the 121→103 revert).
- **Reality**: all four are declared in both local + deployed configs **right now**.
- **Possible explanations**:
  - The revert didn't actually drop them (V5 memory wrong about which mods were the regression contributors)
  - They were re-added after the revert and CLAUDE.md / V5 memory was never updated
  - The regression was about a SPECIFIC combination, not these mods individually
- **Fix**: needs operator input. Options:
  - **A**: re-test the regression — boot the server, verify cross-faction arsenal behavior matches "good" expectation; update CLAUDE.md V5 to remove the trio from the regression callout.
  - **B**: if cross-faction arsenal IS still broken, remove the trio. Snapshot first; bisect to confirm which is the actual culprit (V5 memory points at the trio + ACE Dev/stable conflict — ACE Dev pair is current, so the trio is the remaining variable).
- Found by: agent 8 (GM/admin/QoL batch).

---

## How the architecture caught these

None of these would have been visible from CLAUDE.md alone. They surfaced because:

1. **Per-mod gproj reads** during stub scaffolding pulled the actual hard-dep GUIDs and reverse-deps for all 134 addons folders — exposing the gap between `mods[]` declarations and gproj dep declarations.
2. **Specialist subagents** independently read CLAUDE.md / MASTER_OBJECTIVE.md while writing their assigned docs, and reported every place the file disagreed with on-disk state.
3. **Cross-references** in the doc template (`reverse_deps` frontmatter, §5 Compatibility cross-mod refs) forced agents to look up the OTHER mod's reality, not just their own.

This is exactly the Anthropic multi-agent research pattern's "compression of insights from vast information sources" — 9 agents in parallel each read a small slice of the stack and reported anomalies; the lead synthesizes them here.

---

## Recommended order of operations

1. **Phase A** (declare 5 verified transitive deps) — safest, monotonic. Boot test. ~15 min.
2. **Drift 1 + Drift 2** (MASTER_OBJECTIVE.md edits) — pure documentation, zero behavioral risk. ~5 min.
3. **Phase B** (resolve 5 mystery GUIDs) — read each folder's gproj, identify mod name, decide on declaration. ~20 min.
4. **Drift 3** (rewrite MOTD with UTF-8 no-BOM) — 5 min once you decide on the text.
5. **Drift 4** (arsenal regression triage) — needs operator decision: re-test vs. accept the divergence.

Total: ~1-2 hours of cleanup, all backed by `snapshot_state.ps1`.
