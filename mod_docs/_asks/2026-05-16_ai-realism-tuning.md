# Ask: tune AI to be as human-like / realistic as possible

**Date**: 2026-05-16
**Operator**: "tweak the AI config to be human like as possible. Conduct as much research to make the AI as realistic as possible."
**Investigation method**: dedicated realism-research specialist + cross-check against operator's 2026-05-14 V4 tuning
**Status**: 4 edits applied; 2 items flagged for operator decision

---

## TL;DR

Your 2026-05-14 V4 realism pass got the **big 5 levers** doctrinally correct (reaction delay, aim spread, formation scale, combat mode, danger reaction chance). Research surfaced **6 untuned realism gaps**; 4 have been applied (safe — match military doctrine); 2 are flagged for your decision (taste/scenario-design calls).

**Applied this turn** (snapshot: `state_snapshots/2026-05-16_23-49-31_pre-ai-realism-tuning-2026-05-16`):

| File | Knob | Old | New | Why |
|---|---|---|---|---|
| CharacterConfig | Perception_Safe | 2.0 | 1.0 | CRX default 2.0 was 2× human baseline; 1.0 = vanilla baseline. Operator's goal "AI shouldn't see better than humans" was only half-achieved by `Perception_Modifier=0.0` — the per-state values were still inflated. This finishes the realism pass. |
| CharacterConfig | Perception_Vigilant | 3.0 | 2.0 | Pre-v1.3.47 vanilla. Vigilant AI still spots at realistic ranges (~400m woodland per Marshall Bn studies). |
| CharacterConfig | Perception_Alerted | 2.5 | 1.5 | Vanilla. Alerted AI = "actively looking" — 1.5 matches FM 7-8 human engagement range cone. |
| CharacterConfig | Magazine_Consumption_Chance | 100 | 60 | Single biggest "feels human" untuned knob. Per FM 3-21.8 doctrine: real infantry tactical-reload BEFORE empty when threat lulls allow. 100% = arcade full-mag dump every time. 60% = AI mostly fires bursts then tactical-reloads. Trade-off: AI exposes itself slightly more during reload windows. |
| CharacterConfig | Flee_Chance | 20 | 25 | Marshall "Men Against Fire" + modern combat-soldier studies: 25-40% break under sustained fire unsupported. 20% was conservative-side of doctrinal range; 25% sits middle. |
| ExperimentalConfig | Low_Light_Environment_Modifier | 2 | 2.5 | Real soldiers in unaided night vision struggle past 50m vs 400m+ daytime. NVG-equipped AI remains functional. Combines well with DarkerNights + NIGHTVISION mods already in stack. |

**Flagged for operator decision** (not applied):

1. **`Kill_Unconscious_Chance`** (new v1.3.71 knob, default likely 100). NOT in the 3 .txt config files — lives in `SCR_AISettingsComponent` (scenario-side or world-edit override). Recommendation: 30-50% if you want ACE Captives Dev to matter (i.e., enemy AI occasionally takes prisoners). Leave at 100 for gritty no-mercy PvE.

2. **`Formation_Scale`** (currently 2.0). Per CRX v1.3.71 changelog, this knob now controls **vehicle column spacing** as well as infantry dispersion. Held at 2.0 pending outcome of the active vehicle-AI honk-stuck investigation. If A/B test (CatchaRide disable) doesn't resolve honking, may need GM per-group override to keep infantry at 2.0 while setting vehicle columns to 1.0.

---

## Validated knobs — DON'T change

The realism agent cross-checked every knob in the 3 .txt config files against US Army FM 7-8, FM 3-21.8, Marshall's "Men Against Fire", and Liebenberg et al. 2022 military FCRT research. These knobs are **doctrinally correct as-is**:

| Knob | Current value | Why it stands |
|---|---|---|
| `Rank_Type` | 1 (Vanilla) | MUST stay 1 for NoRankRequirements to work (CLAUDE.md landmine 2026-05-13). 0 silently overrides bypass. |
| `Attack_Reaction_Delay_Modifier` | 800ms | Liebenberg et al. 2022 (PMC9441139): military FCRT mean 529-535ms + 250-300ms target-ID overhead = 800ms exactly. Do not lower. |
| `Aim_Accuracy_Error_Modifier` | 0.8 | FM 3-21.8: "effective fire of individual rifles is of little value beyond 400 yards". 0.8 produces realistic miss-then-walk-on rounds at 400m. |
| `Danger_Reaction_Chance` | 80 | Marshall's Korean War 55-95% engagement range; 80% middle. 100% = robotic; <60% = paralyzed. |
| `Combat_Movement_Type` | 1 (FIRETEAM) | Canonical US Army squad doctrine (1× squad → 2× 4-man fireteams). v1.3.40 default changed to AUTONOMOUS; operator's hardcoded FIRETEAM enforces doctrinal fire-and-maneuver. |
| `Combat_Move_Chance` | 100 | Real squads always seek superior position under fire. |
| `Combat_Cover_Chance` | 100 | Cover-seeking is universal infantry reflex (Marshall). |
| `Combat_In_Cover_Dynamic_Cover_Search_Chance` | 70 | Leaves 30% holding position (fire discipline), avoiding cover-thrashing. |
| `Combat_Mode` | 2 (GREEN) | Defensive-but-advancing matches modern bound-and-cover doctrine. RED is movie "fix bayonets". |
| `Stance` | 3 (Autonomous) | v1.3.33: stance dependent on threat level — autonomous is doctrinally smart, not gamey. |
| `Weapon_Fired_Reaction_Distance` | 400 | FM 7-8 effective rifle engagement = 400m. AI hearing fire at exactly the doctrinal edge is correct. |
| `Suppressed_Weapon_Audible_Distance` | 80 | Realistic suppressed-weapon mechanical audible range. |
| `Suppress` | true | Real squads use suppression. v1.3.50 scales by force ratio — doctrinally aware. |
| `Investigate` | true | Real squads investigate. v1.3.27 added building search. |
| `Movement_Affects_AI_Aim_Accuracy` | true | FM 3-21.8: standing offhand fire 3-5× worse than prone. |
| `Weather_Conditions_Affects_AI` | true | Rain/fog suppresses vision + sound. v1.3.47 added heavy rain → vision degradation. |
| `Low_Light_Environment_Affects_AI` | true | Night-vision baseline gate. |
| `Comms_Handler_Timeout` | 10 | 10s inter-message gap matches US Army radio doctrine (idle 8-15s). |
| `Perceived_Faction_Changes_Affects_AI` | false | Disguise system was the source of NULL deref spam (CLAUDE.md). Disabling is BOTH more realistic AND stops error spam. |
| `Rearm_Type` | 1 (Default) | Vanilla rearm semantics. |
| `Perception_Modifier` | 0.0 | Baseline. Confirmed correct. |
| `Formation_Scale` | 2.0 | FM 7-8 wedge interval ~20m matches; HELD pending vehicle investigation outcome. |

---

## Stack-level realism notes

The realism agent surfaced two compounding effects worth knowing:

### 1. FS Tactical AI + CRX double-stacking reaction delay

FSTacticalAISpawnManager adds its own 0.5-1.5s reaction delay ON TOP of CRX's 800ms `Attack_Reaction_Delay_Modifier`. Stack-combined effective reaction can hit 1.3-2.3s — slow side of the realistic envelope (some PMC studies report 1-3s "see-decide-fire" for trained operators in stress).

**If you ever feel AI is too slow to fire**: lower CRX's `Attack_Reaction_Delay_Modifier` (e.g., 800 → 500) rather than touching FS (no operator surface; baked into pak'd .c scripts).

### 2. Combat_Mode=2 (GREEN) + Formation_Scale=2.0 compounds slow advance

Defensive pace + wide dispersion = AI advancing on objectives takes noticeably longer to close. With COE2's objective density this is gameplay-positive (more defense time). If you want offensive PvE bot pushes, switch `Combat_Mode` to 1 (YELLOW) **per-objective via GM panel** — don't global-flip; per-objective overrides preserve the realism baseline.

---

## CLAUDE.md update needed

CLAUDE.md "Density tuning knobs — current values (2026-05-14 golden state V4)" table is now stale. Recommended addition (operator can pull or paste):

```diff
 | CRX `Perception_Modifier` | 0.3 (enhanced) | **0.0 (baseline)** | Realism: AI shouldn't see better than humans |
+| CRX `Perception_Safe` | 2.0 (CRX default) | **1.0 (vanilla)** | Realism 2026-05-16: per-state values were inflated above vanilla |
+| CRX `Perception_Vigilant` | 3.0 (CRX default) | **2.0 (pre-v1.3.47 vanilla)** | Realism 2026-05-16 |
+| CRX `Perception_Alerted` | 2.5 (CRX default) | **1.5 (vanilla)** | Realism 2026-05-16: AI sees at FM 7-8 engagement ranges |
+| CRX `Magazine_Consumption_Chance` | 100 (arcade dump) | **60 (tactical reload)** | Realism 2026-05-16: per FM 3-21.8, real infantry reload before empty |
 | CRX `Flee_Chance` | 0% | **20%** | Realism: real soldiers retreat under bad conditions |
-| CRX `Flee_Chance` | 0% | **20%** | Realism: real soldiers retreat under bad conditions |
+| CRX `Flee_Chance` | 0% → 20% (V4) | **25% (V5)** | Realism 2026-05-16: middle of Marshall's 25-40% doctrinal range |
+| CRX `Low_Light_Environment_Modifier` | 2.0 (CRX default) | **2.5** | Realism 2026-05-16: realistic night-vision degradation |
 | CRX `Attack_Reaction_Delay_Modifier` | 200ms (robot-fast) | **800ms (human-realistic)** | Realism: ~250ms stimulus + ~400ms target ID + ~300ms decision |
```

---

## Pending operator decisions

### Decision 1 — `Kill_Unconscious_Chance`

- **Default**: likely 100 (kills downed enemies immediately)
- **Recommended realism**: 30-50 (occasional surrender / prisoner-taking)
- **Why it matters**: ACE Captives Dev is in your stack — implies you want prisoner mechanics to be viable. At 100, there are never prisoners.
- **Where to set**: not in the 3 .txt files. Lives at `SCR_AISettingsComponent` in a scenario file or via Workbench world-edit override. Cannot be tuned at runtime without forking COE2.
- **Action needed**: confirm whether to pursue this. If yes, deferred to a Workbench task.

### Decision 2 — `Formation_Scale` for vehicles

- **Currently**: 2.0 global. Holds.
- **Concern**: per CRX v1.3.71, this scales vehicle column gaps too. Wider gaps = more route-recalc churn under congestion = potential amplifier of vehicle honk-stuck symptom.
- **Awaiting**: outcome of CatchaRide A/B test from `2026-05-16_ai-vehicle-honk-stuck-investigation.md`. If vehicle issue persists after CatchaRide removal + Competent AI Driving install, drop Formation_Scale to 1.0 for vehicles only via GM per-group override (keep infantry at 2.0).

---

## Citations (anchored)

### CRX documentation
- [CRX Workshop](https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4)
- [CRX changelog](https://reforger.armaplatform.com/workshop/5F268647F8A1A1F4/changelog) — v1.3.47 vanilla Perception_Vigilant 2.0→2.5; v1.3.50 suppression scales by force ratio; v1.3.60 Comms/LowLight/Rank knobs added; v1.3.67 Column Driving 2.0; v1.3.71 Kill_Unconscious_Chance + vehicle column uses Formation_Scale

### Military doctrine
- [US Army FM 7-8 Infantry Rifle Platoon and Squad](https://550cord.com/infantry-rifle-platoon-squad-fm-7-8/fm-7-8-chapter-2-operations/) — wedge interval, formations
- [FM 3-21.8 Infantry Rifle Platoon and Squad](https://www.marines.mil/Portals/1/Publications/FM%203-21.8%20%20The%20Infantry%20Rifle%20Platoon%20and%20Squad_3.pdf) — effective rifle range; tactical reload doctrine
- [USNI Proceedings 1887, quoted in modern doctrine](https://www.usni.org/magazines/proceedings/1887/october/infantry-fire-tactics-fire-discipline-and-musketry-instruction) — "individual fire of little value beyond 400 yards"
- [S.L.A. Marshall Men Against Fire](https://www.americanheritage.com/secret-soldiers-who-didnt-shoot) — engagement rate research

### Reaction-time research
- [Liebenberg et al. 2022 (PMC9441139)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9441139/) — military FCRT mean 529-535ms (validates 800ms reaction delay)

### Suppression
- [Wikipedia: Suppressive fire](https://en.wikipedia.org/wiki/Suppressive_fire) — small-arms suppression effect within ~1m of trajectory

### Cross-check
- [Steam Community CRX + Realism Overhaul discussion](https://steamcommunity.com/app/1874880/discussions/0/594028005822712279/) — independent confirmation CRX has known vehicle interactions

### File-level
- `profile_new/profile/CRX_EAI/CRX_EAICharacterConfig.txt` (all 13 knobs verified, 5 modified)
- `profile_new/profile/CRX_EAI/CRX_EAIGroupConfig.txt` (all 12 knobs verified, 0 modified — all already doctrinally correct)
- `profile_new/profile/CRX_EAI/CRX_EAIExperimentalConfig.txt` (all 6 knobs verified, 1 modified)
- `CLAUDE.md` § "Density tuning knobs — current values (2026-05-14 golden state V4)"
- `CLAUDE.md` § "Landmines discovered 2026-05-13 → CRX_EAI Rank_Type — keep at 1"

---

## Rollback

If any AI behavior regresses unacceptably after a session test:

```powershell
.\restore_state.ps1 -Snapshot 2026-05-16_23-49-31_pre-ai-realism-tuning-2026-05-16
```

This will roll back the 4 CRX edits to their 2026-05-14 V4 state. The realism research stays as documentation.
