<#
.SYNOPSIS
    Starts the Arma Reforger Server and manages log capture + error analysis.
.DESCRIPTION
    1. Analyzes the PREVIOUS session's logs and writes a summary to last_session_errors.txt
    2. Kills any existing ArmaReforgerServer.exe process
    3. Removes any door-mod folders that may have been re-downloaded by the engine
    4. Starts the server with the standard config and profile
    5. Monitors the new log folder creation and reports when the server is up
.NOTES
    Always writes serverConfig.json without BOM. Never re-add PC RHS (68776D13266976ED).
    Door mods (BreachableDoors 646B350F36C6D3E4, DoorBreaching 627D0C6AE5F771FB) are
    intentionally disabled - they cause see-through doors via missing TransparentMat.emat.
    BaconLoadoutEditor (606B100247F5C709) is restored in the current play stack.
    FoliageCollision (655C4558B6ED57B2) is intentionally disabled - causes VM exception spam.
#>

$ServerRoot   = "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server"
$ServerExe    = Join-Path $ServerRoot "ArmaReforgerServer.exe"
$ConfigPath   = Join-Path $ServerRoot "serverConfig.json"
$ProfilePath  = Join-Path $ServerRoot "profile_new"
$LogsRoot     = Join-Path $ProfilePath "logs"
$AddonsPath   = Join-Path $ProfilePath "addons"
$DisabledPath = Join-Path $ProfilePath "addons_disabled"
$AnalyzeScript= Join-Path $ServerRoot "analyze_logs.ps1"
$ErrorSummary = Join-Path $ServerRoot "last_session_errors.txt"

# Mods that MUST stay disabled (physically removed from addons\ on each start)
# DoorBreaching/BreachableDoors: see-through doors (missing TransparentMat.emat)
# FoliageCollision: VM exception spam
$DisabledModFolderPrefixes = @(
    'DoorBreaching_627D0C6AE5F771FB',
    'BreachableDoors_646B350F36C6D3E4',
    'FoliageCollision_655C4558B6ED57B2',
    'WCS_VehicleLock_61BA4EB5C886D396'
)

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  ARMA REFORGER SERVER LAUNCHER" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# ── Step 1: Analyze previous session logs ─────────────────────────────────────
Write-Host "`n[1/5] Analyzing previous session logs..." -ForegroundColor Yellow
if (Test-Path $AnalyzeScript) {
    try {
        & $AnalyzeScript -OutputFile $ErrorSummary
        Write-Host "     Log summary saved to: $ErrorSummary" -ForegroundColor Green
    } catch {
        Write-Host "     Log analysis failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "     analyze_logs.ps1 not found, skipping." -ForegroundColor Gray
}

# ── Step 2: Kill existing server process ──────────────────────────────────────
Write-Host "`n[2/5] Stopping any running server instances..." -ForegroundColor Yellow
$existing = Get-Process -Name "ArmaReforgerServer" -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Stop-Process -Force
    Write-Host "     Killed $($existing.Count) server process(es). Waiting 3s..." -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "     No running server found." -ForegroundColor Gray
}

# ── Step 3: Enforce disabled mods (re-downloaded mods get moved back) ─────────
Write-Host "`n[3/5] Enforcing disabled mod list..." -ForegroundColor Yellow
if (-not (Test-Path $DisabledPath)) { New-Item -ItemType Directory -Path $DisabledPath | Out-Null }
$movedCount = 0
foreach ($prefix in $DisabledModFolderPrefixes) {
    $srcPath = Join-Path $AddonsPath $prefix
    $dstPath = Join-Path $DisabledPath $prefix
    if (Test-Path $srcPath) {
        $disabledOk = $false
        for ($attempt = 1; $attempt -le 3 -and -not $disabledOk; $attempt++) {
            if (Test-Path $dstPath) {
                # Already exists in disabled - remove duplicate from addons
                Remove-Item $srcPath -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Move-Item $srcPath $dstPath -ErrorAction SilentlyContinue
            }

            if (-not (Test-Path $srcPath)) {
                $disabledOk = $true
            } elseif ($attempt -lt 3) {
                Start-Sleep -Milliseconds 500
            }
        }

        if ($disabledOk) {
            Write-Host "     Disabled: $prefix" -ForegroundColor Yellow
            $movedCount++
        } else {
            Write-Host "     FAILED to disable: $prefix (still present in addons)" -ForegroundColor Red
        }
    }
}
if ($movedCount -eq 0) {
    Write-Host "     All disabled mods already excluded from addons." -ForegroundColor Gray
}

# ── Step 4: Validate serverConfig.json ───────────────────────────────────────
Write-Host "`n[4/5] Validating serverConfig.json..." -ForegroundColor Yellow
try {
    $rawConfig = [System.IO.File]::ReadAllText($ConfigPath)
    [System.IO.File]::WriteAllText($ConfigPath, $rawConfig, (New-Object System.Text.UTF8Encoding $false))
    $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $modCount = $cfg.game.mods.Count
    $aiLimit  = $cfg.operating.aiLimit
    $scenario = $cfg.game.scenarioId
    $playerCount = $cfg.game.gameProperties.missionHeader.m_iPlayerCount

    # Check none of the always-disabled mods snuck back in
    $badMods = @()
    $found = $cfg.game.mods | Where-Object { $_.modId -in $badMods }
    if ($found) {
        Write-Host "     WARNING: Disabled mods found in config! Removing..." -ForegroundColor Red
        $cfg.game.mods = $cfg.game.mods | Where-Object { $_.modId -notin $badMods }
        $txt = $cfg | ConvertTo-Json -Depth 32
        [System.IO.File]::WriteAllText($ConfigPath, $txt, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "     serverConfig.json auto-corrected." -ForegroundColor Yellow
    }

    Write-Host "     Scenario  : $scenario" -ForegroundColor Green
    Write-Host "     Mods      : $modCount" -ForegroundColor Green
    Write-Host "     aiLimit   : $aiLimit" -ForegroundColor Green
    Write-Host "     m_iPlayerCount: $playerCount" -ForegroundColor Green
} catch {
    Write-Host "     ERROR reading serverConfig.json: $_" -ForegroundColor Red
    Write-Host "     Aborting launch." -ForegroundColor Red
    exit 1
}

# ── Step 5: Start server ──────────────────────────────────────────────────────
Write-Host "`n[5/5] Starting server..." -ForegroundColor Yellow
$serverArgs = @(
    "-config `"$ConfigPath`"",
    "-profile `"$ProfilePath`""
)
$process = Start-Process -FilePath $ServerExe -ArgumentList $serverArgs -WorkingDirectory $ServerRoot -PassThru
Write-Host "     PID: $($process.Id)" -ForegroundColor Green

# Wait for new log folder to appear (server is up when log folder is created)
Write-Host "`n     Waiting for server to initialize (watching for new log folder)..." -ForegroundColor Yellow
$timeout = 120  # seconds
$elapsed = 0
$newLogFolder = $null
# Capture the name of the newest existing log folder before the server creates a new one
$_latestItem = Get-ChildItem $LogsRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
$latestBefore = if ($_latestItem) { $_latestItem.Name } else { $null }
do {
    Start-Sleep -Seconds 2
    $elapsed += 2
    $newest = Get-ChildItem $LogsRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($newest -and ($null -eq $latestBefore -or $newest.Name -gt $latestBefore)) {
        $newLogFolder = $newest.FullName
        break
    }
} while ($elapsed -lt $timeout)

if ($newLogFolder) {
    Write-Host "     New log folder: $(Split-Path $newLogFolder -Leaf)" -ForegroundColor Green
    Write-Host "`n[OK] Server is running. PID $($process.Id)" -ForegroundColor Green
    Write-Host "     Connect: 192.168.0.120:2001 (LAN) | 76.235.218.202:2001 (WAN)" -ForegroundColor Cyan
    Write-Host "     Admin  : #login admin123" -ForegroundColor Cyan
    Write-Host "     GM     : Hold Y in-game" -ForegroundColor Cyan
    Write-Host "`n     Error summary from last session: $ErrorSummary" -ForegroundColor Gray

    # ── AI utilization probe ──────────────────────────────────────────────
    Write-Host "`n[AI] Probing AI activity for 30s..." -ForegroundColor Yellow
    $sLog = Join-Path $newLogFolder 'script.log'
    $eLog = Join-Path $newLogFolder 'error.log'
    $deadline = (Get-Date).AddSeconds(30)
    $aiSpawns = 0; $aiVmEx = 0; $playerSpawns = 0
    while ((Get-Date) -lt $deadline) {
        if (Test-Path $sLog) {
            $sc = Get-Content $sLog -ErrorAction SilentlyContinue
            $aiSpawns     = ($sc | Select-String -Pattern 'AI.*Spawn|SF_ReserveManager.*spawn|SF_ManpowerManager' -SimpleMatch:$false).Count
            $playerSpawns = ($sc | Select-String -Pattern 'OnPlayerSpawned').Count
        }
        if (Test-Path $eLog) {
            $aiVmEx = ((Get-Content $eLog -ErrorAction SilentlyContinue) | Select-String -Pattern 'SCR_AI').Count
        }
        Start-Sleep -Seconds 5
    }
    Write-Host ("     aiLimit (config)         : {0}" -f $cfg.operating.aiLimit) -ForegroundColor Cyan
    Write-Host ("     AI spawn-related events  : {0}" -f $aiSpawns)              -ForegroundColor Cyan
    $vmColor = if ($aiVmEx -gt 0) { 'Yellow' } else { 'Cyan' }
    Write-Host ("     AI VM exceptions         : {0}" -f $aiVmEx) -ForegroundColor $vmColor
    Write-Host ("     Player spawn events      : {0}" -f $playerSpawns)        -ForegroundColor Cyan
    if ($aiSpawns -eq 0) {
        Write-Host "     NOTE: 0 AI events in 30s. Scenario may need a player to join before AI spawn." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "`n     [WARNING] Server log folder not detected within ${timeout}s." -ForegroundColor Red
    Write-Host "     Server process may still be starting. Check PID $($process.Id)." -ForegroundColor Red
}

Write-Host ("`n" + "=" * 70) -ForegroundColor Cyan
