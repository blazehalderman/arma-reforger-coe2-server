<#
.SYNOPSIS
    Restore server configuration from a snapshot taken by snapshot_state.ps1.
.DESCRIPTION
    Lists available snapshots if no -Snapshot argument given.
    Use -Latest to restore the most recent non-golden snapshot.
    Use -LatestGolden to restore the most recent golden snapshot.
    Use -Snapshot <foldername> to restore a specific named snapshot.

    KILLS THE SERVER FIRST (per pak file lock landmine).
.EXAMPLE
    & .\restore_state.ps1                          # list all snapshots
    & .\restore_state.ps1 -LatestGolden            # restore most-recent verified-stable
    & .\restore_state.ps1 -Snapshot "2026-05-13_18-05-00_pre-rank-mods"
.NOTES
    Only restores config FILES. Does NOT restore deleted addon folders — those would need
    Steam re-download via start_server.ps1.
    Operator-mandated 2026-05-13 after the addons-folder-nuke regression cascade.
#>

param(
    [string]$Snapshot,
    [switch]$Latest,
    [switch]$LatestGolden
)

$ServerRoot = "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server"
$SnapRoot = Join-Path $ServerRoot "state_snapshots"

if (-not (Test-Path $SnapRoot)) { Write-Host "No snapshots directory yet. Take one with .\snapshot_state.ps1" -ForegroundColor Yellow; exit 0 }

$snaps = Get-ChildItem $SnapRoot -Directory | Sort-Object LastWriteTime -Descending

if (-not $Snapshot -and -not $Latest -and -not $LatestGolden) {
    Write-Host "Available snapshots (most recent first):" -ForegroundColor Cyan
    $snaps | ForEach-Object {
        $isGold = $_.Name -like "GOLDEN_*"
        $marker = if ($isGold) { "[GOLDEN]" } else { "        " }
        Write-Host "  $marker $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))  $($_.Name)"
    }
    Write-Host "`nUsage: .\restore_state.ps1 -Snapshot <name>  |  -Latest  |  -LatestGolden"
    exit 0
}

$target = $null
if ($Snapshot) {
    $target = $snaps | Where-Object { $_.Name -eq $Snapshot } | Select-Object -First 1
    if (-not $target) { Write-Host "Snapshot not found: $Snapshot" -ForegroundColor Red; exit 1 }
} elseif ($LatestGolden) {
    $target = $snaps | Where-Object { $_.Name -like "GOLDEN_*" } | Select-Object -First 1
    if (-not $target) { Write-Host "No golden snapshots found." -ForegroundColor Red; exit 1 }
} elseif ($Latest) {
    $target = $snaps | Select-Object -First 1
    if (-not $target) { Write-Host "No snapshots found." -ForegroundColor Red; exit 1 }
}

Write-Host "Restoring from: $($target.Name)" -ForegroundColor Yellow

# Kill server first (pak file lock landmine)
$proc = Get-Process -Name ArmaReforgerServer -ErrorAction SilentlyContinue
if ($proc) {
    Write-Host "Killing server PID $($proc.Id)..." -ForegroundColor Yellow
    Stop-Process -Id $proc.Id -Force
    Start-Sleep -Seconds 4
}

# Reverse mapping: snapshot filename -> live path
$mapping = @{
    "serverConfig.json" = "serverConfig.json"
    "start_server.ps1" = "start_server.ps1"
    "IPC_Settings.json" = "profile_new\profile\IPC\IPC_Settings.json"
    "IPC_SoldierList.json" = "profile_new\profile\IPC\IPC_SoldierList.json"
    "LCPConfig.json" = "profile_new\profile\LinearConflictPVEConfig\LCPConfig.json"
    "CRX_EAICharacterConfig.txt" = "profile_new\profile\CRX_EAI\CRX_EAICharacterConfig.txt"
    "CRX_EAIGroupConfig.txt" = "profile_new\profile\CRX_EAI\CRX_EAIGroupConfig.txt"
    "CRX_EAIExperimentalConfig.txt" = "profile_new\profile\CRX_EAI\CRX_EAIExperimentalConfig.txt"
    "dc_coreConfig.json" = "profile_new\profile\DarcMods\dc_coreConfig.json"
    "ServerAdminTools_Config.json" = "profile_new\profile\ServerAdminTools_Config.json"
    "GRS_ATAK_server_config.json" = "profile_new\profile\GRS_ATAK\server_config.json"
}

$restored = 0
foreach ($f in $mapping.Keys) {
    $src = Join-Path $target.FullName $f
    $dst = Join-Path $ServerRoot $mapping[$f]
    if (Test-Path $src) {
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Copy-Item $src $dst -Force
        $restored++
        Write-Host "  RESTORED  $f -> $dst" -ForegroundColor Green
    }
}

Write-Host "`n$restored configs restored. Run .\start_server.ps1 to apply." -ForegroundColor Cyan
$listingFile = Join-Path $target.FullName "addons_listing.txt"
if (Test-Path $listingFile) {
    $expectedAddons = (Get-Content $listingFile).Count
    $currentAddons = (Get-ChildItem (Join-Path $ServerRoot "profile_new\addons") -Directory).Count
    if ($expectedAddons -ne $currentAddons) {
        Write-Host "WARNING: addons folder differs from snapshot (expected $expectedAddons, currently $currentAddons)" -ForegroundColor Yellow
        Write-Host "         Steam will re-download missing mods on next launcher run." -ForegroundColor Yellow
    }
}
