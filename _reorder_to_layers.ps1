$ErrorActionPreference = 'Stop'
$cfgPath = 'serverConfig.json'
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json

# Per MASTER_OBJECTIVE.md "12-layer execution sequence" (Layer 0 -> Layer 11)
# Within each layer the order matters where DAG fixes are documented.

$LAYER_0 = @(  # Engine/utility frameworks (no content)
    '5E389BB9F58B79A6'  # SpaceCore
    '62CCD69DD17E4F2F'  # AKI_Core
    '6276E6E3CC97A22B'  # AUS_CORE
    '64EE818E08AFCF94'  # MFDFramework
    '687CD82F6E41D627'  # AFWCore
    '645F08FA9E7CDEDE'  # AttachmentFramework
    '668B5E64DD9E9041'  # LeesWeaponFramework
    '6632F94B46173164'  # RayziUtils
    '65DACC64CE785B6C'  # GRS-DevFramework
    '5D0551624969C92E'  # ZeliksCharacter
    '686104581D2D722B'  # PR_UTILS
    '631EE12D448D7FCC'  # DarcCore
    '65EC8C419D243264'  # RedactedCore
    '61ECB5EFAA346151'  # TacticalAnimationOverhaulTEST
    '611ABE2F73802440'  # Zagoria89Turrets (framework dep for all Zagoria 89 vehicles)
)

$LAYER_1 = @(  # Realism cores -- RHS Content packs MUST precede RHS_Status_Quo
    '1337C0DE5DABBEEF'  # RHS_Content_01
    'BADC0DEDABBEDA5E'  # RHS_Content_02
    '595F2BF2F44836FB'  # RHS_Status_Quo
    '64610AFB74AA9842'  # WCS_Core
    '68F006D910E7546F'  # WCS_Weapon_Scripts
)

$LAYER_2 = @(  # ACE sub-modules (Dev pair + feature mods)
    '65AD7D0D9941A380'  # ACE Core Dev
    '65AD7C249E4ECDFB'  # ACE Captives Dev
    '60EAEA0389DB3CC2'  # ACE Trenches
    '61226BB18D360BDD'  # ACE Tactical Ladder
    '62F802951CC8A37E'  # ACE Tactical Periscope
    '68EAA4976497C46A'  # ACE Facepaint
)

$LAYER_3 = @(  # WCS content (NATO/RU before Weapons; Clothing_Assets MUST precede Clothing)
    '615806DC6C57AF02'  # WCS_NATO
    '615818DA7C0343FD'  # WCS_RU
    '6602C1EC7E5A4A87'  # WCS_Clothing_Assets
    '6152CB0BD0684837'  # WCS_Clothing
    '61C74A8B647617DA'  # WCS_Attachments
    '62A668F513428630'  # WCS_Scopes
    '631C3C1AEE9C90BC'  # WCS_Sounds
    '629B2BA37EFFD577'  # WCS_Armaments
    '65CF7AE8574E06D2'  # WCS_Weapons
    '612F512CD4CB21D5'  # WCS_Earplugs
    '615CC2D870A39838'  # WCS_Arsenal
    '61D57616CAFBB23D'  # WCS_LoadoutEditor
    '61E42AE6714A3CC2'  # WCS_Armbands
    '69075EC0BD287A6E'  # sTsRHSVanillaArsenal (vanilla arsenal bridge for RHS items)
    '690EE89CA417ECD8'  # sTsWCSVanillaArsenal (vanilla arsenal bridge for WCS items into US/USSR/FIA)
)

$LAYER_4 = @(  # RHS<->WCS attachment bridge -- after both WCS_Weapons and RHS_Status_Quo
    '65F929DF622BAD50'  # WCS_RHS_Weapons
)

$LAYER_5 = @(  # Sway/aiming chain — gproj DAG: RayziUtils(L0)→AimingDeadzone→ADSSway-Core→ADSSway-RHS
    '684608DD7C7E0DFB'  # AimingDeadzone (depped by ADSSway-Core per gproj)
    '648D682E7038491E'  # ADSSway-Core
    '6608FD6F58F3B90A'  # ADSSway-PIPDOF-TEST
    '65735C5643CCC0A6'  # ADSSway-Conf-LOW
    '656B3A0955474CB7'  # ADSSway-RHS
    # BWI 2.8 + BWI bridge moved to L10 per author's "load last" Workshop instruction
)

$LAYER_6 = @(  # Faction packs (content-only)
    '66E9222820080A19'  # DarkGruFactions
    '5F396C4F713595DB'  # Arma2Factions
)

$LAYER_7 = @(  # Apparel/loadouts -- GRS-Patches MUST precede GRS-Apparel
    '657B064AE0E231DF'  # GRS-Patches
    '65157D09F042428A'  # GRS-Apparel
    '618EBC907D93DE97'  # BlackCamoPack
    '66577E328BF1401E'  # DarkGruMPPCamos-GRS
    '606B100247F5C709'  # BaconLoadoutEditor
)

$LAYER_8 = @(  # Vehicle/weapon content packs
    # Aircraft (WCS-themed but content packs)
    '6303360DA719E832'  # WCS_AH-64D
    '6273146ADFE8241D'  # AH-6M_LittleBird
    '628933A0D3A0D700'  # WCS_Mi-24V
    '66726C1CF64BDCDC'  # LeesUH-1YVenom
    '60ED3CC6E7E40221'  # SikorskyMH60DAPProject
    '61957C5C6FB7A773'  # H-47Chinook
    '66DF6C37335B0554'  # AHCFuelSystems (Chinook fuel system dep)
    # Ground vehicles
    '5B383D4CB27E0D54'  # BMP3
    '65171C2883CB81B4'  # BTR152
    '65B60A48AEC31157'  # FMTV
    '618C2492CC62D0D5'  # GsBTR-90
    '68C322898FDCBBEA'  # ZagoriaBMP-2FIX (depped by GsBTR-90)
    '68C510533F2D16C5'  # HorsemansBlackBradley
    '65BB2D0679BCA058'  # Skyhook (depped by Bradley)
    '68C50A99234F97E7'  # Horsemansblackcougar
    '5D5A20A8AE33C21E'  # CougarMRAP (depped by Cougar reskin)
    '5C721177A220B42F'  # JLTV
    '633343E891C1CD38'  # KamAZ5350
    '5E5C154FEE1094BB'  # M113
    '63120AE07E6C0966'  # M2A2
    '684D34D51DC5E22A'  # PRMaxxpro
    '5B02128D896F7DE8'  # STRYKER
    '5E0AB16BEB16D6A4'  # T72A
    '672EECC96D789BAA'  # VT4FRMblackReskin
    '663B2784961621FB'  # VT4-FRM (depped by VT4 reskin)
    '6730D59067916E3D'  # Zagoria89BMP2
    '6734FB8B6716853D'  # Zagoria89BMD1and2
    '67350654558A9C3D'  # Zagoria89MTLB
    '6730FB5A6302F4C7'  # Zagoria89T55
    '617AC5E57EF1D9E3'  # Zagoria89Vehicles
    '62D15D0025AE021B'  # ZSU-23-4
    '5C9AD9EF76F6B5EA'  # ZU23
    # Weapons / projectile content
    '6470FD91F0646126'  # Mk-48MachineGun
    '5ABD0CB57F7E9EB1'  # RISLaserAttachments
    '65D050C86106E5BC'  # Smokes
    '66EE300214703AC9'  # SpectralTracersUnified
    # 2026-05-14 added to fix vehicle-prefab catalog refs
    '5D1880C4AD410C14'  # M1 Abrams (M1A1/M1A2 variants)
    '652CFB1896E2AA24'  # More Vanilla Vehicles (M998/M1025 TAN)
    '67351A1364FBF6FB'  # Zagoria 89 T-34-85
    '6734D4F655E54260'  # Zagoria 89 FV510 Warrior
    '672F40664F706B72'  # Zagoria 89 Leopard 1A5
    '67330E082FB5B3E1'  # Zagoria 89 Chieftain Mk.10
    '672EBE927A8B6D96'  # Zagoria 89 T-80U
)

$LAYER_9 = @(  # AI overlays + sister AI mods + arsenal/rank
    '5F268647F8A1A1F4'  # CRX_EnfusionAI
    '689EDED542F881AF'  # DarcChopper
    '6884BEDB4F582595'  # AIMortarFireSupportSystem
    '66D55C5BEC1BD82F'  # NoRankRequirements
    '64FC36E952FD8E58'  # ArsenalItemsallranks (unlocks all items in arsenal regardless of rank)
    '6846EB65C0A446EE'  # All-In-OneArsenals (cross-faction item availability in arsenal boxes)
)

$LAYER_10 = @(  # GM / admin / QoL / audio-visual overlays
    '5964E0B3BB7410CE'  # Game Master Enhanced
    '666947D8218E3B3F'  # GMTrenches
    '5AAAC70D754245DD'  # ServerAdminTools
    '631B695913C7781F'  # RealismOverhaulSounds
    '631CC0C323562CC7'  # RealismOverhaulLighting
    '631D61C22E30D845'  # RealismOverhaulEffects
    '64AB5D83872CCF87'  # RealismOverhaulWeather
    '59A30ACC02650E71'  # NIGHTVISION
    '5C9758250C8C56F1'  # BonActionAnimations
    '6174A376E06661BF'  # BrutalVoices
    '66FAF6113997388F'  # MoreBrutalVoices
    '5F340B3613F49010'  # DarkerNights
    '6528C95796EBEDE0'  # EnvironmentalAmbienceMod
    '660896EB172D4B7F'  # ImprovedBloodEffectDeluxe
    '62FCEB51DF8527B6'  # ImprovedBloodEffect
    '5D550926D43F1409'  # TacticalFlava
    '5965550F24A0C152'  # WhereAmI
    '62F364B35E9B51B0'  # Wirecutters2
    '661B062B26BDB12F'  # CatchaRide
    # Sway overrides — moved here from L5 per BWI 2.8 author's explicit "load last" Workshop note
    '5A7B79D8A910A4D1'  # BetterWeaponImmersion 2.8
    '663A654A6BB0AEA4'  # BWI-ADSsway-RHS-TAOcompat
)

$LAYER_11 = @(  # Scenario controllers — LAST
    '5ED61DC0AFE17E8E'  # Kex Scenario Core
    '60926835F4A7B0CA'  # COE2
)

$layerOrder = @($LAYER_0 + $LAYER_1 + $LAYER_2 + $LAYER_3 + $LAYER_4 + $LAYER_5 + $LAYER_6 + $LAYER_7 + $LAYER_8 + $LAYER_9 + $LAYER_10 + $LAYER_11 | ForEach-Object { $_.ToUpper() })

$declaredByGuid = @{}
foreach ($m in $cfg.game.mods) { $declaredByGuid[$m.modId.ToUpper()] = $m }

$newMods = @()
$placed = @{}
foreach ($g in $layerOrder) {
    if ($declaredByGuid.ContainsKey($g)) {
        $newMods += $declaredByGuid[$g]
        $placed[$g] = $true
    }
}
foreach ($g in $declaredByGuid.Keys) {
    if (-not $placed.ContainsKey($g)) {
        Write-Host ('  WARN uncategorized -> appending at end: ' + $declaredByGuid[$g].name + ' [' + $g + ']')
        $newMods += $declaredByGuid[$g]
    }
}

if ($newMods.Count -ne $cfg.game.mods.Count) {
    Write-Host "FAIL: count mismatch. Original=$($cfg.game.mods.Count), New=$($newMods.Count)."
    exit 1
}

$cfg.game.mods = @($newMods)
$json = $cfg | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText((Resolve-Path $cfgPath).Path, $json, (New-Object System.Text.UTF8Encoding $false))

# Show distribution
$distribution = @(
    @{N='L0 frameworks';V=$LAYER_0}
    @{N='L1 realism cores';V=$LAYER_1}
    @{N='L2 ACE sub';V=$LAYER_2}
    @{N='L3 WCS content';V=$LAYER_3}
    @{N='L4 RHS-WCS bridge';V=$LAYER_4}
    @{N='L5 sway/aiming';V=$LAYER_5}
    @{N='L6 factions';V=$LAYER_6}
    @{N='L7 apparel/loadouts';V=$LAYER_7}
    @{N='L8 vehicle/weapon';V=$LAYER_8}
    @{N='L9 AI overlays';V=$LAYER_9}
    @{N='L10 GM/admin/QoL';V=$LAYER_10}
    @{N='L11 scenarios';V=$LAYER_11}
)
"=== Layer distribution (declared mods only) ==="
$totalPlaced = 0
foreach ($d in $distribution) {
    $present = @($d.V | Where-Object { $declaredByGuid.ContainsKey($_.ToUpper()) }).Count
    "  $($d.N): $present"
    $totalPlaced += $present
}
"  Total placed: $totalPlaced (config has $($cfg.game.mods.Count))"
