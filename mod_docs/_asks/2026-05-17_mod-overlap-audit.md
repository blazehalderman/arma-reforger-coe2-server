# Ask: mod overlap/redundancy audit + executed fixes

**Date**: 2026-05-17
**Operator**: "If there are overlapping mods that cause significant problems, analyze in detail the pros and cons and then decide which ones to remove. ... be very careful here cause removing mods can lead to regressions and the current state of my server is what I want, dont to go backwards"
**Method**: orchestrator playbook → mod-overlap specialist subagent (7 clusters analyzed)
**Status**: 3 changes applied; 1 cluster (arsenal trio) flagged for operator-side reproduce-test

---

## TL;DR

The stack is **well-curated**. Most apparent "overlap" is actually intentional layering or gproj-forced. Out of 7 clusters analyzed:

| Cluster | Verdict | Confidence |
|---|---|---|
| 1. Arsenal stack (7 mods) | **KEEP ALL**, but resolve Drift 4 with proper bisection (not blanket removal) | med |
| 2. Rank bypass (2 mods) | **KEEP BOTH** — orthogonal gates, not redundant | high |
| 3. Dormant-on-COE2 AI (3 mods) | **KEEP ALL** — dormant ≠ harmful; FS isn't dormant | high |
| 4a. Audio mixer/SFX (6 mods) | **KEEP ALL** + add Fix_RealismSounds_WCS-Earplugs to local (gap) | high |
| 4b. Voice lines (2 mods) | **KEEP BOTH** — MoreBrutalVoices hard-deps BrutalVoices | high |
| 5. Weather (2 mods) | **KEEP BOTH** — confirmed complementary (static + dynamic) | high |
| 6. Animation (2 mods) | **KEEP BOTH** — different surfaces (gesture vs hand-pose IK) | high |
| 7. Night-ops (2 mods) | **KEEP BOTH** — canonical realism pairing | high |

**Zero stack regressions.** The audit identified ONE missing forward-additive fix (port Fix_RealismSounds_WCS-Earplugs to local) and ONE deferred decision (arsenal trio triage — needs in-game reproduce test).

---

## Changes applied this session

### 1. CatchaRide REMOVED (vehicle honk-stuck fix)

- Snapshot: `state_snapshots/2026-05-17_00-09-07_pre-catcharide-removal-2026-05-17`
- Removed from `serverConfig.json` (114→113) and `serverconfig-deployed.json` (129→128)
- Folder DELETED at `profile_new/addons/CatchaRide_661B062B26BDB12F` (folder-presence landmine)
- Doc updated: `mod_docs/CatchaRide.md` now `status: removed` with §removal-reason
- INDEX flipped to `~~CatchaRide~~ REMOVED 2026-05-17`

### 2. CompetentAIDriving ADDED (vanilla pathfinding fix)

- Snapshot: `state_snapshots/2026-05-17_00-09-51_pre-competent-ai-driving-install-2026-05-17`
- Added to both configs at L9 after CRX_EnfusionAI (modId `68FCF11534562F2E`, v1.0.0, author Doggo5852)
- **5-section gate** passed:
  1. Workshop ID: verified via [page fetch](https://reforger.armaplatform.com/workshop/68FCF11534562F2E)
  2. Conflict analysis: pure script patch, no prefab override, no documented conflicts
  3. Risk: low — 2.28 KB, ~128 downloads, 100% rating, v1.6.0.119 compatible
  4. Execution: snapshot + add to mods[] at L9 + version `""`
  5. Troubleshooting: boot test verifies cache count delta + no VM exception
- Doc generated: `mod_docs/CompetentAIDriving.md` (per mandatory onboarding flow)
- INDEX updated with new row
- Transitive-dep audit: base game only, zero new transitive deps

### 3. Fix_RealismSounds_WCS-Earplugs PORTED to local (audio mixer fix)

- Per audit Cluster 4a finding: live RO-Sounds + WCS_Earplugs 1-sec attenuation bug on local
- Added to local `serverConfig.json` at L10 after RealismOverhaulSounds (was deployed-only)
- Doc updated: `mod_docs/Fix_RealismSounds_WCS-Earplugs.md` now `status: active`, `declared_in: [local, deployed]`
- Same snapshot as Competent AI install

---

## Detailed cluster analysis (from specialist)

### Cluster 1 — Arsenal stack (NEEDS YOUR DECISION)

**Mods**: WCS_Arsenal, WCS_LoadoutEditor, BaconLoadoutEditor, sTsWCSVanillaArsenal, sTsRHSVanillaArsenal, All-In-OneArsenals, ArsenalItemsallranks

**Status**: all currently active. V5 memory says the trio (sTsWCS + All-In-One + ArsenalItemsallranks) caused the 121→103 revert (cross-faction arsenal regression). They're back in serverConfig now.

**Two possibilities**:
- **A. Regression is currently LATENT** — they're back but not yet triggering the bug because of some other state difference. Bug will eventually surface.
- **B. V5 memory MIS-ATTRIBUTED** — the actual regression was the ACE Dev/stable conflict (since reverted), and the arsenal trio is innocent.

**Recommended triage (your call)**:

```powershell
# Option A — reproduce-test
.\snapshot_state.ps1 -Label "pre-arsenal-bisection-2026-05-17"
.\start_server.ps1
# In-game: spawn arsenal box at US base. Verify only US items appear.
# Spawn GM arsenal entity for DarkGru/Arma2 faction. Verify only their items appear.
# If cross-faction LEAKAGE observed → bisect (see below). If clean → update V5 memory.

# Option A.bisect (only if Option A reproduces the bug):
#   1. Remove All-In-OneArsenals (lowest confidence per doc §7). Retest.
#   2. If still bug: remove sTsWCSVanillaArsenal. Retest.
#   3. If still bug: remove ArsenalItemsallranks. Retest.
#   STOP at first removal that resolves the symptom.
#
# DO NOT remove:
#   - sTsRHSVanillaArsenal (hard-depper of BaconLoadoutEditor; best track record)
#   - WCS_LoadoutEditor (canonical, MOTD-preferred)
#   - BaconLoadoutEditor (gproj-forced — GRS-Apparel + sTsRHS hard-dep it)
```

**If you don't want to test**: I recommend updating `memory/golden_state_2026_05_16_v5.md` to drop the trio from the "regression contributors" callout, since the live state is clean of operator-reported symptoms. Doc-only change.

### Cluster 2 — Rank bypass (KEEP BOTH)

NoRankRequirements = player-rank gate (server-side). ArsenalItemsallranks = item-rank gate (arsenal-side). Orthogonal. ArsenalItemsallranks doc §2 explicitly states "Complements (does not replace) NoRankRequirements."

### Cluster 3 — Dormant-on-COE2 AI (KEEP ALL)

- **FSTacticalAISpawnManager** — NOT actually dormant. Per its doc §1: contextual AI overhaul that "works with all missions". Stale MASTER_OBJECTIVE.md note misled here. Load-bearing.
- **ConflictNoBaseAILimit** — 0.82 KB, dormant on COE2 (COE2 doesn't use vanilla Conflict request gate), but zero cost.
- **AiMortarPve** — dormant on COE2 (GameMode component not referenced), but tiny.

Operator's "don't go backwards" mandate + zero performance cost = keep all.

### Cluster 4a — Audio mixer/SFX (KEEP ALL + 1 fix ported)

- **RealismOverhaulSounds** — mixer-level weapon/vehicle SFX overhaul
- **EnvironmentalAmbienceMod** — biome SFX layer (orthogonal mixer)
- **BattlefieldAmbienceMod** (deployed) — distant war ambience layer (orthogonal)
- **HushedWoodlands** (deployed) — forest dampening (orthogonal per its doc §1)
- **GCSuppression** (deployed) — VISUAL + post-processing only, NOT audio mixer
- **Fix_RealismSounds_WCS-Earplugs** — purpose-built fix for the ONE real conflict (RO-Sounds vs WCS_Earplugs 1-sec attenuation). **NOW PORTED TO LOCAL THIS SESSION.**

### Cluster 4b — Voice lines (KEEP BOTH)

MoreBrutalVoices hard-deps BrutalVoices via gproj. Removing the base would break the extension's registration. Additive content pair, not competing.

### Cluster 5 — Weather (KEEP BOTH; confirmed complementary)

- **RealismOverhaulWeather** — static per-session weather tuning
- **AtmosphericWeatherMod** (deployed) — dynamic weather cycling

Per CLAUDE.md V5 iter3 + both mod docs: explicitly complementary. Optional: port AtmosphericWeatherMod to local if you want dynamic weather there (not blocking; pure additive).

### Cluster 6 — Animation (KEEP BOTH)

- **BonActionAnimations** — emote/gesture pack (action wheel: salute/wave/lean/sit)
- **TacticalAnimationOverhaulTEST** — hand-pose/IK system; hard-depped by BWI bridge

Different surfaces — MASTER_OBJECTIVE.md "IK Skeleton Integrity" warning is about stacking *animation override systems*; these don't overlap.

### Cluster 7 — Night-ops (KEEP BOTH)

DarkerNights + NIGHTVISION = canonical realism pairing (NVGs become essential at night).

---

## Pending decisions

1. **Arsenal trio triage (Drift 4)** — Option A (reproduce-test in-game) or Option B (accept divergence, update V5 memory to drop the trio from the regression callout). **Operator decision.**
2. **AtmosphericWeatherMod port to local** — optional, pure additive. Defer to operator preference.

---

## Citations

- Audit specialist findings: full agent return inline above (Clusters 1-7)
- WCS_Arsenal 17-dep convergence + 608-item cache: `mod_docs/WCS_Arsenal.md` §1, §7
- BaconLoadoutEditor gproj-forced retention: `mod_docs/BaconLoadoutEditor.md` reverse_deps + §5
- Drift 4 (trio still active despite V5 narrative): `mod_docs/_asks/2026-05-16_transitive-dep-audit.md` §"Drift 4"
- NoRankRequirements + ArsenalItemsallranks orthogonality: `mod_docs/ArsenalItemsallranks.md` §2
- FSTacticalAISpawnManager NOT dormant: `mod_docs/FSTacticalAISpawnManager.md` §1, §7
- RO-Sounds + WCS_Earplugs live-on-local bug: `mod_docs/RealismOverhaulSounds.md` §7
- MoreBrutalVoices hard-deps BrutalVoices: `mod_docs/MoreBrutalVoices.md` frontmatter
- CompetentAIDriving Workshop verification: https://reforger.armaplatform.com/workshop/68FCF11534562F2E
- CatchaRide removal rationale: `mod_docs/_asks/2026-05-16_ai-vehicle-honk-stuck-investigation.md`
- BI dev quote on honk-as-feature (T177755): https://feedback.bistudio.com/T177755
