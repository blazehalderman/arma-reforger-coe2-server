# LIVE-ACTION TEST CASES — 12-Layer Runtime Health Checklist

> **STATUS 2026-05-16: HISTORICAL.** Stack pivoted to COE2 Eden + iter3 deployed adds (117 mods). See CLAUDE.md and golden_state_2026_05_16_v5 memory for current state.
>
> **STATUS 2026-05-14: PARTIALLY STALE.** Test cases below were authored for the IPC/PVE-Remixed stack. The 12-layer scheme is still canonical (refined per [research](MASTER_OBJECTIVE.md#layer-table-2026-05-14-revision)) but several test cases reference IPC group counts, LCP autoAddObjective behavior, and PVE Remixed-specific quirks that no longer apply. **For the current COE2 stack**: walk the same layers (frameworks → realism → WCS → bridges → factions → apparel → vehicles → AI overlays → scenario), but observe COE2-specific runtime markers instead (Kex Scenario Core init, COE2 faction picker UI, GM-spawned helis/mortars).

> Operator runs server + client on same box. Connect to `127.0.0.1:2001`, `#login admin123`, then walk the layers top-to-bottom. A failure at layer N invalidates layers >N.

---

### Layer 0 — Engine/utility frameworks (SpaceCore, AKI_Core, AUS_CORE, MFDFramework, AFWCore, AttachmentFramework, RayziUtils, GRS-DevFramework, ZeliksCharacter)
*Why silent fail*: Frameworks expose APIs only — no in-world content. A missing framework manifests as a downstream layer failing to register.
*Live-Action Test*: **No direct test.** Validated transitively — if Layer 1 entities appear correctly, Layer 0 loaded. If `error.log` shows `Compiling .* failed` or `Module: <X> failed to load classes` at boot, suspect Layer 0.
*Pass*: Layer 1 test passes.
*Fail*: Cascade of "class not found" errors on Layer 1+ spawn attempts.

### Layer 1 — Realism cores (ACE_Core, RHS_Content_01/02, RHS_Status_Quo, WCS_Core, WCS_Weapon_Scripts)
*Why silent fail*: RHS prefabs not registering means unit/weapon spawns fall back to engine defaults — visually plausible, structurally broken (no RHS ballistics, no ACE medical hooks).
*Live-Action Test*: Hold `Y` → Game Master → Place Entity → search "M4" and "AK74". Spawn one of each near you and pick them up.
*Pass*: `RHS_M4A1_*` and `RHS_AK74M_*` (or similar `RHS_`-prefixed) entities appear, spawn with correct RHS textures, and ACE Medical menu opens with Ctrl+Shift+H on yourself.
*Fail*: Only vanilla `M16A2`/`AKM` options appear; OR spawned weapon is invisible/pink-checker; OR no ACE menu opens.

### Layer 2 — ACE sub-modules (Hitzones, Explosives, MagRepack, Carrying, Captives, Compass, etc.)
*Why silent fail*: ACE_Core loads but sub-modules silently no-op — basic medical works but bandage/morphine/tourniquet actions are missing from the interaction wheel.
*Live-Action Test*: Self-inflict damage (jump from 4m, or have GM-spawned AI shoot you in the leg). Open ACE Medical menu (Ctrl+Shift+H) → select the wounded limb → apply Bandage.
*Pass*: Bandage option visible, applies, bleeding stops, blood loss timer pauses. MagRepack option appears in interaction wheel when holding a partially-empty mag.
*Fail*: Medical menu shows only "Examine Patient" with no treatment verbs; OR no MagRepack entry exists on partial mags.

### Layer 3 — WCS content (NATO, RU, Clothing, Attachments, Scopes, Sounds, Armaments, Weapons, Earplugs, LoadoutEditor)
*Why silent fail*: WCS_Core loads but content sub-mods don't register their catalogs — arsenal shows ACE/RHS gear only, no WCS uniforms, no WCS optic catalog.
*Live-Action Test*: Walk to an arsenal crate (spawn one via GM if needed: Place Entity → "Arsenal"). Open it → Clothing tab → filter by "WCS" or scroll for chest rigs/plate carriers labeled `WCS_`.
*Pass*: WCS-prefixed uniforms, plate carriers, helmets visible and equipable. Optics tab shows WCS scopes (e.g. `WCS_ELCAN`, `WCS_ACOG`).
*Fail*: Clothing tab shows only vanilla BDU/CDF uniforms; OR WCS items appear but equip leaves character in default fatigues.

### Layer 4 — RHS↔WCS attachment bridge (WCS_RHS_Weapons `65F929DF622BAD50`)
*Why silent fail*: Without the bridge, RHS weapons have empty attachment slots even though WCS_Attachments is loaded.
*Live-Action Test*: Open arsenal → pick an RHS weapon (`RHS_M4A1` or `RHS_AK74M`) → look at the attachment slot panel on the right.
*Pass*: Optic / grip / suppressor / muzzle slots are populated with WCS attachments; mount one and confirm it shows on the weapon model in 3rd-person.
*Fail*: Slots show "no compatible attachments" / empty / red placeholder; OR attachment mounts in arsenal but vanishes when you exit and re-spawn.

### Layer 5 — Sway/aiming chain (ADSSway-Core, ADSSway-RHS, BetterWeaponImmersion 2.8, BWI-ADSsway-RHS-TAOcompat, AimingDeadzone)
*Why silent fail*: IK collisions from layered animation overrides cause floating hands, weapon clipping through chest, or sway on rails freeze.
*Live-Action Test*: Equip any RHS rifle. Aim down sights (right-click hold). Move mouse slowly inside the deadzone, then push past it.
*Pass*: Hands and weapon move smoothly; sway is breath-modulated; ADS reticle drifts naturally; weapon model attached cleanly to hands in 3rd-person.
*Fail*: Hands floating off-body / detached from weapon; weapon clipping through torso; rigid no-sway "T-pose" aim; mouse movement causes camera but not weapon to track.

### Layer 6 — Faction packs (DarkGruFactions, 3DRSMODERNRUSSIANSFACTION, Arma2Factions, PMCFaction)
*Why silent fail*: Faction registers as enum but unit prefabs missing — entity browser shows the faction but spawning a unit yields invisible/T-posed character. Note: IPC will not allocate these factions (per Faction Reality Check), so test via GM only.
*Live-Action Test*: Hold `Y` → Game Master → Place Entity → filter by Faction dropdown. Look for `DarkGru`, `3DRS`, `PMC` entries. Spawn one rifleman from each.
*Pass*: Faction-specific units appear in dropdown, spawn with correct faction-themed uniforms (e.g. DarkGru wearing black/operator kit), animate and respond to AI commands.
*Fail*: Faction missing from dropdown; OR units spawn invisible / in default underwear / T-posed.

### Layer 7 — Apparel/loadouts (GRS-Apparel, GRS-Patches, BlackCamoPack)
*Why silent fail*: Apparel mods register clothing prefabs but textures/materials fail to stream — character equips item, model shows naked or magenta-checkered.
*Live-Action Test*: At arsenal → Clothing tab → search "GRS" or scroll to chest rigs/patches/black-camo variants. Equip a GRS plate carrier and a BlackCamo uniform.
*Pass*: Items visible in arsenal preview, equip cleanly, render with correct textures in 3rd-person mirror view (TAB to inspect self).
*Fail*: Items missing from arsenal entirely; OR equip succeeds but 3rd-person shows magenta/missing-texture; OR character reverts to default uniform on respawn.

### Layer 8 — Vehicle/weapon content packs (BMP3, T72A, M113, BTR152, BigChungus packs, Smokes, SpectralTracersUnified)
*Why silent fail*: Vehicle prefabs register but physics/turret/seat configs broken — vehicle spawns static, can't be entered, or driver seat ejects.
*Live-Action Test*: Hold `Y` → GM → Place Entity → search "BMP3" and "T72A". Spawn one of each. Walk up, press `V` to enter driver seat, drive 50m, swap to gunner.
*Pass*: Vehicle spawns intact with textures, enterable, drivable, turret rotates, gunner can fire main gun.
*Fail*: Vehicle missing from browser; OR spawns as wreck / floating geometry; OR `V` does nothing; OR vehicle has no driver seat / immediately ejects you.

### Layer 9 — AI overlays (IPCAutonomousCaptureAI, CRX_EnfusionAI, FSTacticalAISpawnManager, ConflictNoBaseAILimit)
*Why silent fail*: AI spawns as dumb sentries with no group cohesion; IPC fails to allocate to objectives; CRX behavioral marks (flanking, fireteam splits) absent.
*Live-Action Test*: Wait 3 minutes after scenario start. In admin chat type `#groups` (or check `script.log` for `IPC.*group.*allocated`). Then spawn near an unheld objective, watch for 60s.
*Pass*: 30+ active IPC groups counted; within 60s a defender group spawns at the unheld objective; observed AI splits into 2-man elements and uses cover (CRX EAI behavior).
*Fail*: Group count stuck at 0–5 after 3 min; OR no objective defenders ever spawn; OR AI bunches in conga line and walks straight at you ignoring cover.

### Layer 10 — GM / admin / QoL / audio-visual overlays (GameMasterEnhanced, ServerAdminTools, RealismOverhaul {Sounds,Lighting,Effects,Weather}, NIGHTVISION, BonActionAnimations)
*Why silent fail*: Admin tools fail to bind to operator UID — `#login` rejected; OR GM hotkey unbound; OR night vision toggle does nothing.
*Live-Action Test*: Type `#login admin123` in chat. Then hold `Y` to open Game Master Enhanced. Equip NVGs (spawn via arsenal) and press `N` after dusk (or set time to 22:00 via GM).
*Pass*: `#login` returns admin promote confirmation; GM panel opens with extended GME tabs (trenches, FX); NVGs toggle on/off, scene goes green-tinted with grain.
*Fail*: `#login` returns "invalid password" or no response; OR `Y` does nothing; OR NVG `N` keypress no-ops.

### Layer 11 — Scenario controllers (LinearConflictPVE → PVEConflictwithRHSandWCS bridge → ConflictPVERemixedVanilla2.0 — active scenario)
*Why silent fail*: Scenario loads but objective system inert — no LCP markers on map, no auto-objective spawning, players idle with nothing to do.
*Live-Action Test*: Open map (`M`). Verify LCP objective markers (numbered capture points) visible. Travel 500m+ in any direction from current objective on foot or vehicle, then re-open map after 30–60s.
*Pass*: 3+ LCP objective markers on map at scenario start; after 500m move, a NEW objective auto-spawns within `autoAddObjectiveDistance: 500` radius and appears as a new marker.
*Fail*: Map shows no objective markers; OR markers exist but never refresh / no new ones spawn after travel; OR moving 500m triggers no IPC defender allocation at the new point (also implicates Layer 9).

---
**Order of operations**: Run Layer 1 → 11 sequentially. First failing layer = stop, diagnose, do not proceed. A pass at Layer 11 with all upstream layers green = full-stack runtime health confirmed.
