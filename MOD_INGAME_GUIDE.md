# Arma Reforger Server — In-Game Mod Usage Guide

> **STATUS 2026-05-14: HEAVILY STALE.** This guide was authored 2026-05-10 when the server ran Procedural Combat scenario with 95 mods and "PC Modern" faction. Both PCM and PC Modern faction were abandoned. **Current scenario: COE2 Eden (121 mods)** — see `MASTER_OBJECTIVE.md` revision 2026-05-14. The mod-by-mod usage guidance below is mostly still useful for the mods that remain in the stack (RHS, WCS, ACE, GM Enhanced, ServerAdminTools, etc.) but mod count + scenario header below are obsolete.

Server: **COE2 Eden | RHS + WCS + ACE | High AI density (aiLimit 3500)** (was: PC Modern - Everon Modded Coop)
Mods loaded: **121** (was 95)
Scenario: **COE2 (Combat Ops Enhanced 2 by Kex)** (was Procedural Combat)

This is a player/admin reference for **every active mod**. Mods are grouped by purpose. For each: what it adds, where to find it in-game, and how to use it.

---

## Quick Reference — Default Keybinds

| Category | Key | Action |
|---|---|---|
| Admin | `\` then `#login admin123` | Authenticate as admin |
| Admin | F11 (rebind) | Open Server Admin Tools menu |
| Admin | F12 (rebind) | Become Game Master (via SAT menu → GM tab) |
| Game Master | `Y` | Toggle GM camera (after becoming GM) |
| Game Master | `F1` `F2` `F3` `F4` | Place / Edit / Waypoint / Layers |
| Game Master | `Tab` | Show/hide entity palette |
| Game Master | `T` | Set AI behavior on selected entity |
| Game Master | `Ctrl+S` | Save world state |
| Game Master | `Ctrl+L-click` | Possess AI |
| Player | `Tab` | Inventory |
| Player | `B` (or scroll-wheel action) | Open Arsenal at supply box |
| Player | `J` | Field manual / quick reference |
| Player | `M` | Map |
| Player | `K` | Compass (vanilla) |
| Player | `~` | VON push-to-talk |
| Player | `Esc` → Controls → search "ACE" | All ACE keybinds (rebind as needed) |

---

# 1. SCENARIO & MISSION DIRECTOR

## ProceduralCombat (`67352E1E1F06E599`)
- **What:** Generates random AI vs AI sector battles. Picks two factions, a battle size (S/M/L), and manages reinforcements until one side hits 10% manpower.
- **In-game:** It runs automatically. The HUD top-right shows current sector, faction manpower %, reinforcement timer.
- **Use:** Pick a faction at deploy, then help your AI faction reduce the enemy.
- **Win condition:** Enemy faction at ≤10% → director picks a new sector.

## ProceduralCombat-Modern (`69396D5F1FF80524`)
- **What:** Adds modern factions (US Armed Forces, Russian Armed Forces, CDF, ChDKZ, NAPA, ION Services) into the PC director's pool.
- **Use:** When deploying, prefer **US Armed Forces** or **Russian Armed Forces** for the best kitted arsenals.

## PCFactionZombies (`692176BA1E98A39A`)
- **What:** Registers ZOMBIES as a PC-eligible faction.
- **In-game:** Random matchups will sometimes pit Russians/US/CDF against zombie hordes.

## BaconZombies (`622120A5448725E3`)
- **What:** Adds the ZOMBIES faction with multiple variants.
- **Use in GM:** F1 → Groups → faction filter ZOMBIES → drag to spawn group.

---

# 2. SERVER & ADMIN

## ServerAdminTools (`5AAAC70D754245DD`)
- **What:** The full admin control panel. Player management, GM access, time/weather, teleport, etc.
- **Setup:** Authenticate with `#login admin123` in chat.
- **Open:** Bind a key in Esc → Settings → Controls → search "Admin Menu" (recommended F11).
- **Become GM:** SAT menu → Game Master tab → "Become Game Master" button.

## ScenarioReloadMenu (`606D03292879EF5B`)
- **What:** Restart scenario button in pause menu.
- **Use:** Esc → Scenario → Reload, or admin chat command `#restart`.

---

# 3. ACE — ADVANCED COMBAT ENVIRONMENT

Interaction: hold `Spacebar` (default) while looking at a target/yourself to open ACE's radial menu.

## ACE_Core (`60C4CE4888FF4621`)
- **What:** Foundation. Enables interaction menus and core realism systems.

## ACE_Medical_Core (`60C4C12DAE90727B`) + ACE_Medical_Hitzones (`65860252A17554C7`)
- **What:** Body-part hitzones, bleeding, fractures, pain, unconsciousness.
- **In-game:** Hold interaction key on injured player → ACE Medical menu. Examine, bandage, apply tourniquet, inject meds, IV, CPR.

## ACE_Explosives (`61B7763A8AEB53B7`)
- **What:** C4, claymores, IEDs, detonators.
- **In-game:** Place explosive → ACE menu → Set timer / connect to clacker.

## ACE_MagRepack (`611CB1D409001EB0`)
- **What:** Consolidate ammo.
- **In-game:** Hold interaction → Repack Magazines.

---

# 4. WEAPON CRAFTING SYSTEM (WCS)

## WCS_Weapons / NATO / RU
- **What:** Modern weapon families (Rifles, MGs, Sidearms) with realistic handling.

## WCS_Attachments / Scopes
- **What:** Rail, optic, laser, and grip library.
- **In-game:** In Arsenal → select weapon → attachment slots show compatible WCS parts.

## WCS_Sounds (`631C3C1AEE9C90BC`)
- **What:** Custom gunshot sounds.

---

# 5. REALISM & IMMERSION (HIGH FIDELITY)

## RealismOverhaul Suite (Lighting/Effects/Sounds/Weather)
- **Effect:** Completely overhauls lighting (better shadows/falloff), particles (explosions/smoke), and environmental sounds.
- **Weather:** ROW + AtmosphericWeatherMod adds volumetric clouds and realistic storm cycles.

## DarkEchoes (`658B25CD90247D38`)
- **Effect:** Adds acoustic reverb/echoes for distant combat. Battels sound large-scale from 2km away.

## HushedWoodland (`693323B2E7B456F4`)
- **Effect:** Sound dampening inside forests. It creates a physical acoustic boundary in dense foliage.

## AimingDeadzone (`684608DD7C7E0DFB`)
- **Effect:** Uncouples weapon movement from camera for a more tactile, physical feel.

## ImprovedBloodEffect (`62FCEB51DF8527B6`) + Deluxe
- **Effect:** Realistic pooling, splatters, and physical wound reactions.

---

# 6. VEHICLES (CUSTOM & STANDALONE)

Spawn in GM (F1 → Vehicles) or find in PC base depots.

| Category | Vehicle | Mod |
|---|---|---|
| US / NATO | AH-64D Apache Longbow | 6303360DA719E832 |
| US / NATO | H-47 Chinook | 61957C5C6FB7A773 |
| US / NATO | AH-6M Little Bird | 6273146ADFE8241D |
| US / NATO | UH-1Y Venom | 66726C1CF64BDCDC |
| US / NATO | MH-60 DAP Black Hawk | 60ED3CC6E7E40221 |
| US / NATO | MaxxPro MRAP | 684D34D51DC5E22A |
| US / NATO | M113 APC | 5E5C154FEE1094BB |
| US / NATO | JLTV / STRYKER / Bradley | Core Pack |
| RU / OPFOR | Mi-24V Hind | 628933A0D3A0D700 |
| RU / OPFOR | T-72A / T-55 | Core / Zagoria |
| RU / OPFOR | MTLB / BMD-1/2 / BTR152 | Zagoria / BTR152 |
| RU / OPFOR | ZU23 / ZSU-23-4 Shilka | AA Support |
| Civilian | Weathered/Used Cars | 6659622FA432A13D |

---

# 7. QOL IMPROVEMENTS

| Mod | Feature |
|---|---|
| **NIGHTVISION** | Enhanced NVG visuals and pairable IR lasers. |
| **EnvironmentalAmbience** | Reactive insects (bees/fireflies) and wind-blown debris. |
| **BetterVanillaAudio** | Enhanced footstep and ambient environmental audio. |
| **WhereAmI** | Grid coordinates and heading shown on HUD. |
| **CatchaRide** | "Hitch ride" interaction on friendly vehicles. |
| **Wirecutters2** | Ability to cut through fences and barbed wire. |

---

# 8. TERRAINS (NOT LOADED)

Kunar, Anizay, and Takistan are on disk but inactive to maintain Everon performance. Let admin know if you want to switch maps.

---

End of guide.
