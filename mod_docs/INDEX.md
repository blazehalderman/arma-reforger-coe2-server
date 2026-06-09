# Mod Index

**Last regenerated**: 2026-05-17 (Ashyl FX iter applied — see CLAUDE.md "Landmines discovered 2026-05-17")
**Source of truth**: `serverConfig.json` (local) + `serverconfig-deployed.json` (deployed)
**Count**: 129 local (post-iter: +4 Ashyl/JLH adds, -1 RO-Effects remove, HFS_Configs tested and rolled back) / 117 deployed (port pending)

Lead agents: read this file to find relevant mods by **role tag** (the rightmost column) or **name**. Then open `mod_docs/<Name>.md` for the full doc on any mod marked `[doc]`.

Status legend: **local** = declared in `serverConfig.json`; **deployed** = declared in `serverconfig-deployed.json`; **both** = in both; **dep-only** = transitive dep, on disk but not declared.

Doc legend: `[doc]` = full mod doc exists; `[stub]` = scaffolded only; `[—]` = no doc yet.

**As of 2026-05-16**: all 119 mods (103 local + 14 deployed-only + KA52 shim + DarcCore explicit + 2 newly-declared) have enriched per-mod docs. Status column shows `[doc]` throughout.

---

## How to use this index

When you receive an ask:
1. Scan the **role tag** column for relevance (e.g. ask mentions "heli AI" → look for `framework:ai-helicopter`, `content:helicopter`).
2. Cross-reference the **must-precede / depends-on** column for load-order constraints.
3. Spawn one specialist subagent per mod whose `[doc]` you intend to consult.

---

## L0 — Engine / utility frameworks

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| SpaceCore | 5E389BB9F58B79A6 | both | [doc] | `framework:core` | utility lib |
| AKI_Core | 62CCD69DD17E4F2F | both | [doc] | `framework:core` | utility lib |
| AUS_CORE | 6276E6E3CC97A22B | both | [doc] | `framework:core` | utility lib |
| MFDFramework | 64EE818E08AFCF94 | both | [doc] | `framework:cockpit-mfd` | multi-function display framework (cockpits) |
| AFWCore | 687CD82F6E41D627 | both | [doc] | `framework:core` | utility lib |
| AttachmentFramework | 645F08FA9E7CDEDE | both | [doc] | `framework:attachments` | universal weapon-attachment slots |
| RayziUtils | 6632F94B46173164 | both | [doc] | `framework:core` | dep of ADSSway chain |
| GRS-DevFramework | 65DACC64CE785B6C | both | [doc] | `framework:core` | GRS mod family dep |
| ZeliksCharacter | 5D0551624969C92E | both | [doc] | `framework:character` | character base library |
| DarcCore | 631EE12D448D7FCC | dep-only | [doc] | `framework:core` | transitive dep of DarcChopper; NOT in `mods[]` |

## L1 — Realism cores (RHS + WCS)

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| RHS_Content_01 | 1337C0DE5DABBEEF | both | [doc] | `content:rhs` | RHS content pack 1 (note the meme GUID — Bohemia honored it) |
| RHS_Content_02 | BADC0DEDABBEDA5E | both | [doc] | `content:rhs` | RHS content pack 2 |
| RHS_Status_Quo | 595F2BF2F44836FB | both | [doc] | `content:rhs-mainline` | RHS Status Quo — primary RHS mod for 1.6 |
| WCS_Core | 64610AFB74AA9842 | both | [doc] | `framework:wcs` | WCS framework core |
| WCS_Weapon_Scripts | 68F006D910E7546F | both | [doc] | `framework:wcs-weapons` | WCS weapon scripting |

## L2 — ACE (Dev branch only)

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| ACE Core Dev | 65AD7D0D9941A380 | both | [doc] | `framework:ace-medical` | Kex hard-deps Dev branch; stable ACE removed |
| ACE Captives Dev | 65AD7C249E4ECDFB | both | [doc] | `framework:ace-captives` | Kex hard-deps Dev branch |

## L3 — WCS content (NATO/RU + clothing + weapons)

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| WCS_NATO | 615806DC6C57AF02 | both | [doc] | `content:wcs-faction-us` | NATO weapons prefabs |
| WCS_RU | 615818DA7C0343FD | both | [doc] | `content:wcs-faction-ru` | RU weapons prefabs |
| WCS_Clothing_Assets | 6602C1EC7E5A4A87 | both | [doc] | `content:wcs-clothing` | **MUST load before** WCS_Clothing (DAG fix) |
| WCS_Clothing | 6152CB0BD0684837 | both | [doc] | `content:wcs-clothing` | depends on Clothing_Assets |
| WCS_Attachments | 61C74A8B647617DA | both | [doc] | `content:wcs-attachments` | attachment prefabs |
| WCS_Scopes | 62A668F513428630 | both | [doc] | `content:wcs-optics` | optic prefabs |
| WCS_Sounds | 631C3C1AEE9C90BC | both | [doc] | `content:wcs-audio` | gun sound mixer |
| WCS_Armaments | 629B2BA37EFFD577 | both | [doc] | `content:wcs-armaments` | armament prefabs |
| WCS_Weapons | 65CF7AE8574E06D2 | both | [doc] | `content:wcs-weapons` | WCS weapons base; dep of WCS_RHS_Weapons bridge |

## L4 — RHS ↔ WCS bridge

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| WCS_RHS_Weapons | 65F929DF622BAD50 | both | [doc] | `bridge:rhs-wcs` | **CRITICAL** — without this RHS guns have no WCS attachment slots (2026-05-12 incident) |

## L5 — Sway / aiming chain

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| AimingDeadzone | 684608DD7C7E0DFB | both | [doc] | `framework:aiming` | precedes ADSSway-Core (DAG) |
| ADSSway-Core | 648D682E7038491E | both | [doc] | `framework:aiming-sway` | sway core |
| ADSSway-RHS | 656B3A0955474CB7 | both | [doc] | `bridge:ads-rhs` | RHS sway tuning |
| BetterWeaponImmersion (BWI 2.8) | 5A7B79D8A910A4D1 | both | [doc] | `gameplay:weapon-handling` | **load LAST** of weapon-handling overlays (author Workshop note) — L10 per CLAUDE.md |
| BWI-ADSsway-RHS-TAOcompat | 663A654A6BB0AEA4 | both | [doc] | `bridge:bwi-ads-rhs` | BWI ↔ ADSsway ↔ TAO compat |

## L6 — Faction packs

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| DarkGruFactions | 66E9222820080A19 | both | [doc] | `content:faction-darkgru` | adds DarkGru unit prefabs |
| Arma2Factions | 5F396C4F713595DB | both | [doc] | `content:faction-a2` | CDF, CHDKZ, NAPA, TKM units |

## L7 — Apparel / loadouts

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| GRS-Patches | 657B064AE0E231DF | both | [doc] | `content:apparel-patches` | **MUST precede** GRS-Apparel (DAG fix) |
| GRS-Apparel | 65157D09F042428A | both | [doc] | `content:apparel` | hard-deps BaconLoadoutEditor |
| BlackCamoPack | 618EBC907D93DE97 | both | [doc] | `content:apparel-camo` | black camo set |
| DarkGruMPPCamos-GRS | 66577E328BF1401E | both | [doc] | `content:apparel-camo` | GRS dep chain dep |
| BaconLoadoutEditor | 606B100247F5C709 | both | [doc] | `framework:loadout-editor` | first-class — see CLAUDE.md landmine table |

## L8 — Vehicle / weapon content packs

### Helicopters (the focus of the current ask)

| Name | GUID | Status | Doc | Role tag | DarcChopper-ready? |
|---|---|---|---|---|---|
| LeesUH-1YVenom | 66726C1CF64BDCDC | both | [doc] | `content:helicopter:uh-1y` | ❌ no compat shim |
| WCS_AH-64D | 6303360DA719E832 | both | [doc] | `content:helicopter:apache` | ❌ no compat shim |
| AH-6M_LittleBird | 6273146ADFE8241D | both | [doc] | `content:helicopter:little-bird` | ❌ no compat shim |
| WCS_Mi-24V | 628933A0D3A0D700 | both | [doc] | `content:helicopter:hind` | ✅ `Mi24and28forDarcChopper` exists |
| H-47Chinook | 61957C5C6FB7A773 | both | [doc] | `content:helicopter:chinook` | ❌ no compat shim (transport) |
| SikorskyMH60DAPProject | 60ED3CC6E7E40221 | both | [doc] | `content:helicopter:mh-60-dap` | ❌ no compat shim |
| WCS_AH-1S | 64CB39E57377C861 | deployed | [doc] | `content:helicopter:cobra` | ❌ no compat shim |
| WCS_KA-52 | 64CB35D07BAEE60F | deployed | [doc] | `content:helicopter:hokum` | ✅ `KA52forDarcChopper` exists |

### Ground vehicles

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| BMP3 | 5B383D4CB27E0D54 | both | [doc] | `content:vehicle-armor-ru` | BMP-3 IFV |
| BTR152 | 65171C2883CB81B4 | both | [doc] | `content:vehicle-apc-ru` | BTR-152 |
| FMTV | 65B60A48AEC31157 | both | [doc] | `content:vehicle-truck-us` | FMTV truck |
| GsBTR-90 | 618C2492CC62D0D5 | both | [doc] | `content:vehicle-apc-ru` | BTR-90 |
| HorsemansBlackBradley | 68C510533F2D16C5 | both | [doc] | `content:vehicle-ifv-us` | M2 Bradley reskin |
| Horsemansblackcougar | 68C50A99234F97E7 | both | [doc] | `content:vehicle-mrap-us` | Cougar MRAP reskin |
| JLTV | 5C721177A220B42F | both | [doc] | `content:vehicle-light-us` | JLTV |
| KamAZ5350 | 633343E891C1CD38 | both | [doc] | `content:vehicle-truck-ru` | KamAZ truck |
| M113 | 5E5C154FEE1094BB | both | [doc] | `content:vehicle-apc-us` | M113 |
| M2A2 | 63120AE07E6C0966 | both | [doc] | `content:vehicle-ifv-us` | M2A2 Bradley |
| PRMaxxpro | 684D34D51DC5E22A | both | [doc] | `content:vehicle-mrap-us` | MaxxPro MRAP |
| STRYKER | 5B02128D896F7DE8 | both | [doc] | `content:vehicle-apc-us` | Stryker |
| T72A | 5E0AB16BEB16D6A4 | both | [doc] | `content:vehicle-tank-ru` | T-72A |
| VT4FRMblackReskin | 672EECC96D789BAA | both | [doc] | `content:vehicle-tank-cn` | VT-4 tank reskin |
| Zagoria89BMD1and2 | 6734FB8B6716853D | both | [doc] | `content:vehicle-airborne-ru` | BMD-1/2 |
| Zagoria89MTLB | 67350654558A9C3D | both | [doc] | `content:vehicle-apc-ru` | MT-LB |
| Zagoria89T55 | 6730FB5A6302F4C7 | both | [doc] | `content:vehicle-tank-ru` | T-55 |
| Zagoria89Vehicles | 617AC5E57EF1D9E3 | both | [doc] | `content:vehicle-pack-ru` | Zagoria vehicle pack |
| ZSU-23-4 | 62D15D0025AE021B | both | [doc] | `content:vehicle-aa-ru` | Shilka SPAAG |
| ZU23 | 5C9AD9EF76F6B5EA | both | [doc] | `content:weapon-aa-ru` | ZU-23 towed |

### Weapons / projectiles / misc content

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| WCS_Earplugs | 612F512CD4CB21D5 | both | [doc] | `gameplay:hearing-protection` | use empty version; v1.0.4 pin causes 404 cascade (CLAUDE.md landmine) |
| WCS_LoadoutEditor | 61D57616CAFBB23D | both | [doc] | `framework:loadout-editor` | preferred over BaconLoadoutEditor |
| WCS_Arsenal | 615CC2D870A39838 | both | [doc] | `framework:arsenal` | base arsenal |
| WCS_Armbands | 61E42AE6714A3CC2 | both | [doc] | `content:apparel-armband` | armband identification |
| Smokes | 65D050C86106E5BC | both | [doc] | `content:throwable` | smoke grenades |
| SpectralTracersUnified | 66EE300214703AC9 | both | [doc] | `content:tracer-fx` | tracer rounds |

## L9 — AI overlays + sister AI mods

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| CRX_EnfusionAI | 5F268647F8A1A1F4 | both | [doc] | `ai:behavior-overlay` | perception/flank/squad behavior — realism-tuned 2026-05-14 |
| FSTacticalAISpawnManager | 68494CE78A849933 | both | [doc] | `ai:spawn-mgr` | tactical AI spawn manager |
| ConflictNoBaseAILimit | 60E547E88A9221E5 | both | [doc] | `ai:density-cap-bypass` | removes vanilla 200-AI base cap |
| DarcChopper | 689EDED542F881AF | both | **[doc]** | `framework:ai-helicopter` | AI-flown heli framework |
| AIMortarFireSupportSystem | 6884BEDB4F582595 | both | [doc] | `ai:mortar-fire-support` | AI mortar IDF (GM-fired) |
| **CompetentAIDriving** | 68FCF11534562F2E | both | [doc] | `ai:vehicle-pathfinding-fix` | **NEW 2026-05-17** — fixes vanilla forward-reverse stuck loop on larger AI vehicles |
| **JLH_NoAIVehicleHorn** | 7A19B6D4C8E23F10 | local | [doc] | `ai:vehicle-horn-suppress` | **NEW 2026-05-17 iter** — silences AI vehicle horn reaction (player horn preserved). Symptom-mute pairing with CompetentAIDriving's cause-fix |
| AiMortarPve | 68690CA04E7FFB75 | both | [doc] | `ai:mortar-pve` | PvE mortar variant |
| NoRankRequirements | 66D55C5BEC1BD82F | both | [doc] | `gameplay:rank-bypass` | works only if CRX `Rank_Type=1` (CLAUDE.md) |

## L10 — GM / admin / QoL / audio-visual

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| Game Master Enhanced | 5964E0B3BB7410CE | both | [doc] | `gm:tools` | GM tooling |
| GMTrenches | 666947D8218E3B3F | both | [doc] | `gm:trenches` | GM trench placement |
| ServerAdminTools | 5AAAC70D754245DD | both | [doc] | `admin:tools` | admin login, MOTD, ban list, scheduled chat |
| ScenarioReloadMenu | 606D03292879EF5B | both | [doc] | `gm:scenario-reload` | scenario hot-reload |
| GMPersistentLoadouts | _(in profile only)_ | n/a | [doc] | `gm:loadout-persist` | profile-side persistence dir |
| ~~CatchaRide~~ | 661B062B26BDB12F | **REMOVED 2026-05-17** | [doc] | `gameplay:vehicle-mount-exterior` | Removed as root cause of AI vehicle honk-stuck (author's AI seat-priority bug). Re-add only after upstream fix. |
| DarkerNights | 5F340B3613F49010 | both | [doc] | `env:lighting-night` | darker nights |
| EnvironmentalAmbienceMod | 6528C95796EBEDE0 | both | [doc] | `env:ambience` | environmental sound layer |
| ImprovedBloodEffectDeluxe | 660896EB172D4B7F | both | [doc] | `fx:blood` | gore FX |
| MoreBrutalVoices | 66FAF6113997388F | both | [doc] | `audio:vo` | additional VO lines |
| BrutalVoices | 6174A376E06661BF | both | [doc] | `audio:vo` | base brutal voices |
| NIGHTVISION | 59A30ACC02650E71 | both | [doc] | `gameplay:nvg` | NVG access |
| ~~RealismOverhaulEffects~~ | 631D61C22E30D845 | **REMOVED 2026-05-17** | [doc] | `fx:realism-effects` | Replaced in-place by `[[BHE_EXP]]` 4.3 Beta. Folder deleted from `addons/`. Suite siblings (Lighting/Sounds/Weather) remain. |
| **BHE_EXP** (Ashyl 4.3 Beta) | 661D33952728B63D | local | [doc] | `fx:hit-effects-physical` | **NEW 2026-05-17 iter** — Ashyl's active hit-effects line. Replaces RO-Effects. Adds scripted physical particles. Beta cadence — pin `version: ""` |
| **BetterCasings** (Ashyl) | 59822DF3A86DA197 | local | [doc] | `fx:shell-casings-3d` | **NEW 2026-05-17 iter** — 3D physics shell casings. 2022-vintage code; clean fit (zero surface conflict in stack) |
| **Shrapnel** (Ashyl 2.1) | 59BA048FA618471A | local | [doc] | `fx:shrapnel-physics` | **NEW 2026-05-17 iter** — physics-driven shrapnel projectiles. Additive (not overwrite). Co-designed with BHE_EXP |
| ~~HFS_Configs~~ | 65351DA1585DF3BF | **TESTED+ROLLED-BACK 2026-05-17** | [doc] | `fx:heli-faction-cfg` | Caused placeholder icons + wrong-heli routing on this stack (private-server prefab conventions don't fit mixed RHS+WCS+COE2). See CLAUDE.md Known landmines |
| RealismOverhaulLighting | 631CC0C323562CC7 | both | [doc] | `env:realism-lighting` | realism — lighting |
| RealismOverhaulSounds | 631B695913C7781F | both | [doc] | `audio:realism-sounds` | realism — sounds. Conflicts w/ WCS_Earplugs without `Fix_RealismSounds_WCS-Earplugs` |
| RealismOverhaulWeather | 64AB5D83872CCF87 | both | [doc] | `env:realism-weather` | static weather tuning only (not dynamic) |
| BonActionAnimations | 5C9758250C8C56F1 | both | [doc] | `gameplay:animations` | extra animations |
| TacticalFlava | 5D550926D43F1409 | both | [doc] | `qol:tactical-misc` | misc tactical tweaks |
| WhereAmI | 5965550F24A0C152 | both | [doc] | `ui:position-info` | shows location info |
| Wirecutters2 | 62F364B35E9B51B0 | both | [doc] | `gameplay:wirecutters` | cut wire fencing |
| AhcFuelSystems | 66DF6C37335B0554 | dep-only | [doc] | `gameplay:fueling` | dep of some vehicles |
| ArsenalItemsallranks | 64FC36E952FD8E58 | both | [doc] | `arsenal:rank-bypass` | arsenal items at all ranks |
| sTsWCSVanillaArsenal | 690EE89CA417ECD8 | both | [doc] | `arsenal:bridge-wcs-vanilla` | known regression contributor (CLAUDE.md state summary) |
| sTsRHSVanillaArsenal | 69075EC0BD287A6E | both | [doc] | `arsenal:bridge-rhs-vanilla` | known regression contributor; hard-deps BaconLoadoutEditor |
| All-In-OneArsenals | 6846EB65C0A446EE | both | [doc] | `arsenal:meta` | meta arsenal mod; reverted-state contributor |

## L11 — Scenario controllers (must load last)

| Name | GUID | Status | Doc | Role tag | Notes |
|---|---|---|---|---|---|
| Kex Scenario Core | 5ED61DC0AFE17E8E | both | [doc] | `scenario:framework` | COE2's required framework |
| COE2 - Combat Ops Enhanced 2 | 60926835F4A7B0CA | both | [doc] | `scenario:coe2` | active scenario |
| SHSScenarioFramework | 687B6840885E539D | both | [doc] | `scenario:sdrc-framework` | SDRC controller running on top of COE2; reads `$profile:/DarcMods/dc_*.json` |

---

## Deployed-only mods (iter3 — not in local config)

| Name | GUID | Role | Status |
|---|---|---|---|
| WCS_AH-1S | 64CB39E57377C861 | Cobra heli | deployed |
| WCS_KA-52 | 64CB35D07BAEE60F | Hokum heli | deployed |
| MRZR | 64900A5A31F5DCB5 | light vehicle | deployed |
| BaconZombies | 622120A5448725E3 | zombie faction | deployed |
| AtmosphericWeatherMod | 64ED6553B8AF6B62 | dynamic weather | deployed |
| Fix_RealismSounds_WCS-Earplugs | 670E8DD9DA6ADF59 | sound-mixer fix | deployed |
| BattlefieldAmbienceMod | 655B341B90518659 | atmospheric SFX | deployed |
| HushedWoodlands | 693323B2E7B456F4 | woodland ambient SFX | deployed |
| GCSuppression | 684CE8AA3B1D6573 | suppression FX | deployed |
| GameMasterSafeZones | 5CE334EA7649C7CC | safezones (v1.4 mod, low confidence) | deployed |
| COE2-Anizay | _(see deployed cfg)_ | scenario variant | deployed |
| COE2-KhanhTrung | _(see deployed cfg)_ | scenario variant | deployed |
| COE2-KunarProvince | _(see deployed cfg)_ | scenario variant | deployed |
| COE2-Fallujah | _(see deployed cfg)_ | scenario variant | deployed |

---

## Compat shim mods (Workshop — not yet installed)

These exist on the Workshop but are NOT in either serverConfig. Listed here so the orchestrator knows what's available.

| Name | GUID | Bridges | Notes |
|---|---|---|---|
| Mi24and28forDarcChopper | 6720D3B2BEBC691E | Mi-24/28 ↔ DarcChopper | viable for our WCS_Mi-24V |
| KA52forDarcChopper | 684F3C94BD457F85 | KA-52 ↔ DarcChopper | viable for our WCS_KA-52 (deployed-only) |
| Z-9forDarcChopper | 69270DE847ED6453 | Z-9 ↔ DarcChopper | we don't have Z-9 |
| WZHelisforDarcChopper | 672F2BB6523FBA29 | WZ helis ↔ DarcChopper | we don't have WZ |
| DarcChopperCompatFF | 692121914CDE6746 | Forgotten Few ↔ DarcChopper | we don't have FF |
| DarcChopperExample | 691240864B9FFF22 | tutorial/example | reference for building custom shims |
| DarcMissions | 5ED0FAC84A48D018 | reads `dc-missionConfig_Chopper` | we don't use; use SHSScenarioFramework instead |

---

## Regeneration

This index is currently maintained by hand. A future improvement is `mod_docs/regen_index.ps1` that scans `serverConfig*.json` + `profile_new/addons/*/addon.gproj` and emits this table fresh. For now, regenerate the rows when:
- A mod is added/removed from either serverConfig
- A new compat-shim becomes available on Workshop
- A `[doc]` is added (flip from `[—]` to `[doc]` / `[stub]`)
