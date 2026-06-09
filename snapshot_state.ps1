<#
.SYNOPSIS
    Snapshots all server-state configuration files before any change.
.DESCRIPTION
    Creates timestamped backups of every editable config in the server.
    Run this BEFORE any change to serverConfig.json, IPC_Settings.json,
    LCPConfig.json, CRX_EAI configs, dc_coreConfig.json, or ServerAdminTools_Config.json.

    Use -Label to name the snapshot (e.g. "pre-arsenal-fix"). Default label is "manual".
    Use -Golden to mark this as a permanent recovery point (won't be auto-cleaned).
.EXAMPLE
    & .\snapshot_state.ps1 -Label "pre-rank-mods"
    & .\snapshot_state.ps1 -Label "verified-stable" -Golden
.NOTES
    All snapshots written under .\state_snapshots\<timestamp>_<label>\
    Golden snapshots written under .\state_snapshots\GOLDEN_<timestamp>_<label>\
    Operator-mandated 2026-05-13 after the addons-folder-nuke regression cascade.
#>

param(
    [string]$Label = "manual",
    [switch]$Golden
)

$ServerRoot = "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server"
$ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$prefix = if ($Golden) { "GOLDEN_" } else { "" }
$snapDir = Join-Path $ServerRoot "state_snapshots\$prefix${ts}_$Label"
New-Item -ItemType Directory -Path $snapDir -Force | Out-Null

# All configs that affect server behavior at boot or runtime
$targets = @(
    @{ src = "serverConfig.json"; dst = "serverConfig.json" }
    @{ src = "start_server.ps1"; dst = "start_server.ps1" }
    @{ src = "profile_new\profile\IPC\IPC_Settings.json"; dst = "IPC_Settings.json" }
    @{ src = "profile_new\profile\IPC\IPC_SoldierList.json"; dst = "IPC_SoldierList.json" }
    @{ src = "profile_new\profile\LinearConflictPVEConfig\LCPConfig.json"; dst = "LCPConfig.json" }
    @{ src = "profile_new\profile\CRX_EAI\CRX_EAICharacterConfig.txt"; dst = "CRX_EAICharacterConfig.txt" }
    @{ src = "profile_new\profile\CRX_EAI\CRX_EAIGroupConfig.txt"; dst = "CRX_EAIGroupConfig.txt" }
    @{ src = "profile_new\profile\CRX_EAI\CRX_EAIExperimentalConfig.txt"; dst = "CRX_EAIExperimentalConfig.txt" }
    @{ src = "profile_new\profile\DarcMods\dc_coreConfig.json"; dst = "dc_coreConfig.json" }
    @{ src = "profile_new\profile\ServerAdminTools_Config.json"; dst = "ServerAdminTools_Config.json" }
    @{ src = "profile_new\profile\GRS_ATAK\server_config.json"; dst = "GRS_ATAK_server_config.json" }
)

$copied = 0
$missing = 0
foreach ($t in $targets) {
    $src = Join-Path $ServerRoot $t.src
    $dst = Join-Path $snapDir $t.dst
    if (Test-Path $src) { Copy-Item $src $dst -Force; $copied++ } else { $missing++ }
}

# Also snapshot the addons folder LISTING (not contents) so we can detect post-hoc deletions
Get-ChildItem (Join-Path $ServerRoot "profile_new\addons") -Directory | Select-Object -ExpandProperty Name | Sort-Object | Set-Content (Join-Path $snapDir "addons_listing.txt") -Encoding UTF8
$addonCount = (Get-ChildItem (Join-Path $ServerRoot "profile_new\addons") -Directory).Count

# Manifest with metadata
$manifest = @{
    timestamp = $ts
    label = $Label
    golden = [bool]$Golden
    copied = $copied
    missing = $missing
    addon_folder_count = $addonCount
    server_pid = (Get-Process -Name ArmaReforgerServer -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Id)
} | ConvertTo-Json
Set-Content (Join-Path $snapDir "manifest.json") $manifest -Encoding UTF8

Write-Host "Snapshot saved: $snapDir" -ForegroundColor Green
Write-Host "  $copied configs copied, $missing missing, $addonCount addon folders listed"
if ($Golden) { Write-Host "  *** GOLDEN: protected from auto-cleanup ***" -ForegroundColor Yellow }
