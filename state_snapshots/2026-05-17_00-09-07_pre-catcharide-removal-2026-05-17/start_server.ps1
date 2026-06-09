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
# Note: addons_disabled/ pattern abandoned 2026-05-13 — blacklisted mods are purged on each launch
$AnalyzeScript= Join-Path $ServerRoot "analyze_logs.ps1"
$ErrorSummary = Join-Path $ServerRoot "last_session_errors.txt"

# Mods that MUST stay disabled (physically removed from addons\ on each start)
# Folder-presence triggers script execution regardless of serverConfig.json mods[]
# declaration — only physical removal stops them.
# DoorBreaching/BreachableDoors: see-through doors (missing TransparentMat.emat)
# FoliageCollision: VM exception spam
# WCS_VehicleLock: only one player can enter a vehicle
# IPCHigherAISkill: NULL-targetFaction deref in Modded_SCR_CharacterPerceivableComponent
#   crashed the server 2026-05-13 13:34 (replaced by CRX EAI 2026-05-12 but folder lingered)
# AllArsenalItemsToPrivate: mislabeled SGCPvEConflictOverrides — empties all arsenal boxes
# Blacklist disabled entirely 2026-05-13 22:42 per operator decision.
# History: this array used to hold mod folder prefixes the launcher would Remove-Item before
# every boot. The intent was "delete known-bad mods so the engine never compiles their scripts".
# Reality: Steam re-pulls these mods every boot as transitive deps of declared mods (not
# something we control), so the purge-then-repull cycle raced and produced Fragmentizer
# "Can't create output file" errors → "Failed to fetch addon details from workshop API" →
# "Unable to initialize the game". The system was fighting itself.
# New policy: let Steam manage the addons/ folder. If a mod proves harmful at runtime, we
# fix it surgically (find its depper, build a Workbench bridge to break the dep, or accept
# the tail risk). The launcher no longer purges anything.
$DisabledModFolderPrefixes = @()

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "  ARMA REFORGER SERVER LAUNCHER" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# ── Step 1: Analyze previous session logs ─────────────────────────────────────
Write-Host "`n[1/6] Analyzing previous session logs..." -ForegroundColor Yellow
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
Write-Host "`n[2/6] Stopping any running server instances..." -ForegroundColor Yellow
$existing = Get-Process -Name "ArmaReforgerServer" -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Stop-Process -Force
    Write-Host "     Killed $($existing.Count) server process(es). Waiting 3s..." -ForegroundColor Green
    Start-Sleep -Seconds 3
} else {
    Write-Host "     No running server found." -ForegroundColor Gray
}

# ── Step 3: Purge blacklisted mods (delete, do not "disable" — folder presence ─
# triggers script compilation regardless of serverConfig.json mods[] declaration;
# moving to addons_disabled/ leaves the same disk surface untouched. The only
# durable disable is removal. Steam won't re-download anything not in mods[].)
Write-Host "`n[3/6] Purging blacklisted mods..." -ForegroundColor Yellow
$purgedCount = 0
foreach ($prefix in $DisabledModFolderPrefixes) {
    $srcPath = Join-Path $AddonsPath $prefix
    if (Test-Path $srcPath) {
        $purgeOk = $false
        for ($attempt = 1; $attempt -le 3 -and -not $purgeOk; $attempt++) {
            Remove-Item $srcPath -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $srcPath)) {
                $purgeOk = $true
            } elseif ($attempt -lt 3) {
                Start-Sleep -Milliseconds 500
            }
        }

        if ($purgeOk) {
            Write-Host "     Purged: $prefix" -ForegroundColor Yellow
            $purgedCount++
        } else {
            Write-Host "     FAILED to purge: $prefix (folder locked? close ArmaReforgerServer.exe)" -ForegroundColor Red
        }
    }
}
if ($purgedCount -eq 0) {
    Write-Host "     All blacklisted mods already absent from addons." -ForegroundColor Gray
}

# ── Step 4: Validate serverConfig.json ───────────────────────────────────────
Write-Host "`n[4/6] Validating serverConfig.json..." -ForegroundColor Yellow
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
Write-Host "`n[5/6] Starting server..." -ForegroundColor Yellow
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


# ── Step 6: Spawn standing companion processes ────────────────────────────────
# These run alongside the server for the duration of its lifetime. Claude/operator
# Monitor tools just OBSERVE — they do not run these.
Write-Host "`n[6/6] Spawning standing companion processes..." -ForegroundColor Yellow

# Kill any previous companion-process leftovers via the marker file pattern
$companionPidFile = Join-Path $ServerRoot '.companion_pids'
if (Test-Path $companionPidFile) {
    Get-Content $companionPidFile -ErrorAction SilentlyContinue | ForEach-Object {
        $oldPid = $_ -as [int]
        if ($oldPid) { Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue }
    }
    Remove-Item $companionPidFile -Force -ErrorAction SilentlyContinue
}

# 6a. Snapshot agent — auto-Goldens once server hits stability + prunes obsolete state every 15 min
# Routed through cmd.exe wrapper because Start-Process direct PowerShell -File -Loop -WindowStyle Hidden
# silently dies within seconds on PS 5.1. The .cmd wrapper makes the child genuinely detached.
$snapshotCmd = Join-Path $ServerRoot 'snapshot_agent_loop.cmd'
if (Test-Path $snapshotCmd) {
    $snapProc = Start-Process -FilePath $snapshotCmd -WorkingDirectory $ServerRoot -WindowStyle Hidden -PassThru
    Add-Content -Path $companionPidFile -Value $snapProc.Id
    Write-Host ("     Snapshot agent loop:    PID " + $snapProc.Id + " (via .cmd wrapper)") -ForegroundColor Green
} else {
    Write-Host "     snapshot_agent_loop.cmd missing - skipping." -ForegroundColor DarkYellow
}

# 6b. Mod health check — wait briefly for engine to reach GAME state so runtime checks
# (arsenal cache, loadout templates, GAME state) are valid; then run one-shot.
$healthPs = Join-Path $ServerRoot 'mod_health_check.ps1'
if (Test-Path $healthPs) {
    Write-Host "     Waiting up to 90s for engine GAME state before health check..." -ForegroundColor Cyan
    if ($newLogFolder) {
        $sLogPath = Join-Path $newLogFolder 'script.log'
        $hcDeadline = (Get-Date).AddSeconds(90)
        while ((Get-Date) -lt $hcDeadline) {
            if ((Test-Path $sLogPath) -and (Select-String -Path $sLogPath -Pattern 'OnGameStateChanged = GAME' -ErrorAction SilentlyContinue | Select-Object -First 1)) { break }
            Start-Sleep -Seconds 5
        }
    }
    Write-Host "     Running mod health check..." -ForegroundColor Cyan
    & $healthPs | Out-String | ForEach-Object { Write-Host ('     ' + $_.Trim()) -ForegroundColor DarkGray }
}

# 6c. Print monitor pattern hints for the operator/Claude — these DO NOT run any work,
# they just tail what the server writes. Copy/paste the patterns into a Monitor tool.
Write-Host ""
Write-Host "     Standing observation patterns (paste into Monitor tool):" -ForegroundColor Cyan
Write-Host "       Server density+cache+crash : tail script.log; pattern: 'OnGameStateChanged|VM Exception|FATAL|Recursive call|IPC Groups of Faction|SpawnPoint . Faction affliated|Cached \\d+ items|Mod found:'" -ForegroundColor DarkGray
Write-Host "       Server PEAK alert          : tail script.log; alert when sum(IPC Groups) > 95" -ForegroundColor DarkGray
Write-Host "       Client critical errors     : tail %LOCALAPPDATA%\Arma Reforger\logs\<newest>; pattern: 'VM Exception|FATAL|Recursive call|Cannot create|Game addon|MissionHeader::|RplConnection::ValidationError|prefab .* missing at index|Error when creating entity'  (DO NOT include bare 'Stack trace')" -ForegroundColor DarkGray
Write-Host "       Crash dump watcher         : watch profile_new\crashes\*.dmp + %LOCALAPPDATA%\Arma Reforger\crashes\*.dmp" -ForegroundColor DarkGray

Write-Host ("`n" + "=" * 70) -ForegroundColor Cyan
