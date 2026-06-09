# Arma Reforger Dedicated Server — Current State (2026-05-10 snapshot, HISTORICAL)

> **STATUS 2026-05-14: HISTORICAL.** This handoff doc is from 2026-05-10. The server has gone through major pivots since then (Procedural Combat → IPC/PVE Remixed → COE2). Operator identity (UUID, username) at the bottom is still accurate. Everything else is stale. **Current state is documented in `MASTER_OBJECTIVE.md` and memory `golden_state_2026_05_14_v4.md`.**

## Who I am
- Username: **AcridVaporiZe**
- Identity UUID (Bohemia account): `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3`
- I own and run a private Arma Reforger dedicated server on Windows

---

## What I'm trying to build

A **large-scale persistent sandbox wargame** server for me and friends:
- **Procedural Combat Modern** (auto-generated AI vs AI sector battles with US/Russian/CDF factions) as the backbone
- **Game Master overlay** on top (I place bases, vehicles, weapons arsenals, helicopter pads, boat docks)
- **BaconZombies** painted in GM as a third threat faction
- **99 mods** active — RHS weapons/vehicles, ACE medical/explosives, WCS weapons, NATO Helicopters, Weather overhauls, Expanded vehicle fleet, High-fidelity realism, 30+ individual guns, full character packs, audio/visual overhauls
- Vision: arrive at session, kit up at Arsenal, hop in a Black Hawk, fly to wherever the PC war is happening, fight alongside US AI vs Russians while zombie hordes close in from the rear — essentially "unlimited supply giant sandbox" Arma 3-feel

---

## Server specs and location

- **Install path:** `C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server`
- **Profile path:** `...\profile_new\` (addons, logs, profile config all here)
- **Game version:** Arma Reforger DS v1.6.0.119
- **Network:** static LAN IP 192.168.0.120, public IP 76.235.218.202, UDP 2001 (game) + 17777 (a2s)

---

## Current Status Summary (2026-05-10)

- ✅ **Server boots cleanly** in ~17s, accepts connections.
- ✅ **99 mods** load without crash (JSON valid, BOM-free).
- ✅ **NATO Helicopter Fleet:** Added AH-64D Apache (6303360DA719E832), CH-47 Chinook (61957C5C6FB7A773), AH-6M Little Bird (6273146ADFE8241D), and UH-1Y Venom (66726C1CF64BDCDC).
- ✅ **High Fidelity Pack Added:** Lighting, Effects, Sounds, DarkEchoes, and HushedWoodland.
- ✅ **Weather Mods Restored:** RealismOverhaulWeather, AtmosphericWeatherMod, and TheFog added back.
- ✅ **QOL Mods Added:** ScenarioReloadMenu, NIGHTVISION, Ambience, and Better Audio.
- ✅ **Vehicle Fleet Expanded:** Added Maxxpro, M113, Hind (Mi-24V), MTLB, T-55, BTR152, ZU23, and BMD-1/2.
- ✅ **Procedural Combat** rolls random battles US/RU/CDF/ChDKZ/NAPA/ION/ZOMBIE.
- ✅ **GM access** works (hold `Y`).
- ✅ **Admin auth** via chat: `#login admin123`.
- ✅ **Attachment Bug Resolved:** Confirmed fixed; weapons spawning with correct attachments.

---

## Known active bugs (unresolved)

### 1. AI has no scopes / weapons have no attachments (THE SMOKING GUN)
- **Technical fingerprint:** Raw log during world preload shows multiple instances of:
  `ENTITY:XXX → GameEntity is missing component RplComponent as required by component SCR_WeaponAttachmentsStorageComponent`
- **Impact:** This template-entity bug breaks attachment storage globally for every weapon. Affected entities are spawned at `<0,0,0>` without the necessary replication component.
- **Suspected cause:** Likely coming from a framework mod (SpaceCore, AUS_CORE, or WCS_Core) that patches inventory/weapon slots incorrectly in v1.6.

### 2. Doors are see-through / bugged geometry
- **Suspected cause:** `BreachableDoors` (`646B350F36C6D3E4`) or `DoorBreaching` (`627D0C6AE5F771FB`) referencing a material (`TransparentMat.emat`) that doesn't exist in 1.6.
- **Status:** These mods are currently **intentionally disabled** in `start_server.ps1` to mitigate the issue.

### 3. PC battle duration is short
- Win condition: one side hits ≤10% manpower → sector resets.
- Hardcoded in PC author's scripts; requires GM intervention or script patching.

---

## Mods physically moved to addons_disabled/ (enforced by launcher)

These mods are moved to `addons_disabled/` by `start_server.ps1` on every launch:

| Mod | GUID | Reason disabled |
|---|---|---|
| DoorBreaching | `627D0C6AE5F771FB` | See-through doors bug |
| BreachableDoors | `646B350F36C6D3E4` | See-through doors bug |
| FoliageCollision | `655C4558B6ED57B2` | VM exception spam in 1.6 |
| EnfusionPersistenceFramework | `5D6EBC81EB1842EF` | Status pending / stability testing |

---

## File locations

| File | Path |
|---|---|
| Server config | `...\serverConfig.json` |
| Active addons | `...\profile_new\addons\` |
| Disabled addons | `...\profile_new\addons_disabled\` |
| Admin config | `...\profile_new\profile\ServerAdminTools_Config.json` |
| Latest logs | `...\profile_new\logs\logs_2026-05-10_16-42-39\` |
| Master state | `...\HANDOFF_CONTEXT.md` |

---

## Key commands

- **Start server:** `.\start_server.ps1`
- **Analyze logs:** `.\analyze_logs.ps1`
- **Check attachment bug:** `Select-String -Path .\console.log -Pattern "RplComponent|WeaponAttachmentsStorage"`

---

## Key mods and GUIDs (Active)

| Mod | GUID | Role |
|---|---|---|
| ProceduralCombat | `67352E1E1F06E599` | Mission director (sector battles) |
| ProceduralCombat-Modern | `69396D5F1FF80524` | Modern faction injection |
| PCFactionZombies | `692176BA1E98A39A` | Adds ZOMBIES to PC faction pool |
| BaconZombies | `622120A5448725E3` | Zombie entities for GM placement |
| ServerAdminTools | `5AAAC70D754245DD` | Admin tools (UUID-whitelisted) |
| RHS Status Quo (Core) | `595F2BF2F44836FB` | RHS base |
| ACE_Core | `60C4CE4888FF4621` | ACE medical/explosives/interactions |
| WCS_Core | `64610AFB74AA9842` | Weapon crafting system |
| RAYZIOPTICSPACK | `628F720BC527C143` | Premium optics |
| SikorskyMH60DAPProject | `60ED3CC6E7E40221` | MH-60 DAP helicopter |

---

## In-game admin credentials

| Field | Value |
|---|---|
| Admin password | `admin123` |
| Chat login | `#login admin123` |
| UUID | `ccb8d5ae-5eb1-4393-8d93-ed43f072adb3` |
| GM access | Hold `Y` in-game after connecting |
| Scenario restart | `#restart` in chat |
