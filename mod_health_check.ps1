#requires -Version 5.1
# Mod-stack health check. Runs on demand or on a schedule.
# Reports anything that warrants operator attention.

param(
    [switch]$Verbose
)

$ServerRoot = 'C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server'
$AddonsPath = Join-Path $ServerRoot 'profile_new\addons'
$ConfigPath = Join-Path $ServerRoot 'serverConfig.json'
$LogsRoot   = Join-Path $ServerRoot 'profile_new\logs'

$report = @{
    declared_mods         = 0
    folders_present       = 0
    folders_missing       = @()
    pak_missing           = @()
    pak_tiny              = @()           # < 1KB suggests broken
    undeclared_orphans    = @()           # folder present, not in mods[], no depper
    undeclared_dep_chains = @{}           # folder present, not in mods[], BUT has deppers
    blacklist_present     = @()           # any blacklisted mod sneaking back
    cache_count           = $null
    loadout_templates     = $null
    game_state_reached    = $false
    crash_dumps_recent    = @()
    vm_exceptions_session = 0
}

# Read declared modlist
$cfg = Get-Content $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json
$declared = @($cfg.game.mods | ForEach-Object { $_.modId })
$report.declared_mods = $declared.Count

# Verify folder presence + pak integrity for every declared mod
foreach ($modId in $declared) {
    $folder = Get-ChildItem $AddonsPath -Directory -Filter "*_$modId" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $folder) {
        $report.folders_missing += $modId
        continue
    }
    $report.folders_present++
    $pak = Get-ChildItem $folder.FullName -Filter 'data.pak' -ErrorAction SilentlyContinue
    if (-not $pak) {
        $folderSize = (Get-ChildItem $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        if ($folderSize -lt 5KB) {
            $fname = $folder.Name
            $report.pak_missing += ($fname + ' (folder ' + $folderSize + 'B - likely broken)')
        }
    } elseif ($pak.Length -lt 1KB) {
        $fname = $folder.Name
        $pkLen = $pak.Length
        $report.pak_tiny += ($fname + ' (pak only ' + $pkLen + 'B)')
    }
}

# Audit undeclared folders for orphan vs depped status
$allFolders = Get-ChildItem $AddonsPath -Directory | ForEach-Object {
    if ($_.Name -match '_([A-F0-9]{16})$') {
        @{ name = $_.Name; modId = $matches[1]; folder = $_.FullName }
    }
}
$undeclared = $allFolders | Where-Object { $_.modId -notin $declared }
foreach ($u in $undeclared) {
    $deppers = @()
    foreach ($d in $declared) {
        $depFolder = $allFolders | Where-Object { $_.modId -eq $d } | Select-Object -First 1
        if (-not $depFolder) { continue }
        $gproj = Get-ChildItem "$($depFolder.folder)\addon.gproj" -ErrorAction SilentlyContinue
        if (-not $gproj) { continue }
        $gp = [System.IO.File]::ReadAllText($gproj.FullName)
        if ($gp -match $u.modId) { $deppers += $d }
    }
    if ($deppers.Count -eq 0) {
        $report.undeclared_orphans += $u.name
    } else {
        $report.undeclared_dep_chains[$u.name] = $deppers
    }
}

# Check blacklist (mods that should NEVER be in addons/)
$blacklist = @(
    @{ id='627D0C6AE5F771FB'; name='DoorBreaching' },
    @{ id='646B350F36C6D3E4'; name='BreachableDoors' },
    @{ id='655C4558B6ED57B2'; name='FoliageCollision' },
    @{ id='61BA4EB5C886D396'; name='WCS_VehicleLock' },
    @{ id='64DCE52D2F882ED2'; name='IPCHigherAISkill' },
    @{ id='66C751946DC58A1A'; name='AllArsenalItemsToPrivate' },
    @{ id='68B0F1527A825B69'; name='IPC_DynamicCombat_Rework' },
    @{ id='68776D13266976ED'; name='ProceduralCombatRHS' }
)
foreach ($b in $blacklist) {
    $bId = $b.id
    $bName = $b.name
    $glob = $AddonsPath + '\*_' + $bId
    if (Test-Path $glob) {
        $report.blacklist_present += ($bName + ' (' + $bId + ') - folder present in addons/, should be purged')
    }
}

# Server runtime health (latest log folder)
$newestLog = Get-ChildItem $LogsRoot -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($newestLog) {
    $scriptLog = Join-Path $newestLog.FullName 'script.log'
    if (Test-Path $scriptLog) {
        $cacheMatch = Select-String -Path $scriptLog -Pattern 'Cached (\d+) items' -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($cacheMatch) { $report.cache_count = [int]$cacheMatch.Matches.Groups[1].Value }
        $tplMatch = Select-String -Path $scriptLog -Pattern 'Loaded (\d+) arsenal loadout templates' -ErrorAction SilentlyContinue | Select-Object -Last 1
        if ($tplMatch) { $report.loadout_templates = [int]$tplMatch.Matches.Groups[1].Value }
        $gameMatch = Select-String -Path $scriptLog -Pattern 'OnGameStateChanged = GAME' -ErrorAction SilentlyContinue
        if ($gameMatch) { $report.game_state_reached = $true }
        $vmCount = (Select-String -Path $scriptLog -Pattern 'Virtual Machine Exception' -ErrorAction SilentlyContinue | Measure-Object).Count
        $report.vm_exceptions_session = $vmCount
    }
}

# Crash dumps newer than current process start
$proc = Get-Process -Name ArmaReforgerServer -ErrorAction SilentlyContinue
if ($proc) {
    $dumpDir = Join-Path $ServerRoot 'profile_new\crashes'
    if (Test-Path $dumpDir) {
        $report.crash_dumps_recent = @(Get-ChildItem $dumpDir -Filter '*.dmp' -ErrorAction SilentlyContinue |
                                       Where-Object { $_.LastWriteTime -gt $proc.StartTime } |
                                       ForEach-Object { $_.Name })
    }
}

# Render report
Write-Host ""
Write-Host "================ MOD HEALTH CHECK ================" -ForegroundColor Cyan
Write-Host ""
$declCount = $report.declared_mods
$presCount = $report.folders_present
Write-Host ("Declared mods:           $declCount")
Write-Host ("Folders present:         $presCount of $declCount")
$missCount = $report.folders_missing.Count
if ($missCount -gt 0) {
    Write-Host ("MISSING FOLDERS ($missCount):") -ForegroundColor Red
    $report.folders_missing | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "All declared mod folders present." -ForegroundColor Green
}

if ($report.pak_missing.Count -gt 0) {
    Write-Host ""
    Write-Host ("BROKEN MODS (pak missing or tiny):") -ForegroundColor Red
    $report.pak_missing + $report.pak_tiny | ForEach-Object { Write-Host "  $_" }
}

if ($report.blacklist_present.Count -gt 0) {
    Write-Host ""
    Write-Host "BLACKLISTED MOD IN ADDONS/ (should be purged):" -ForegroundColor Red
    $report.blacklist_present | ForEach-Object { Write-Host "  $_" }
}

$orphCount = $report.undeclared_orphans.Count
if ($orphCount -gt 0) {
    Write-Host ""
    $hdr = 'UNDECLARED ORPHAN FOLDERS (' + $orphCount + ' folders, no depper, safe to purge):'
    Write-Host $hdr -ForegroundColor Yellow
    $report.undeclared_orphans | ForEach-Object { Write-Host ('  ' + $_) }
}

$depCount = $report.undeclared_dep_chains.Count
if ($depCount -gt 0 -and $Verbose) {
    Write-Host ""
    $hdr = 'UNDECLARED FOLDERS WITH DEPPERS (' + $depCount + ' folders, leave alone):'
    Write-Host $hdr -ForegroundColor Gray
    $report.undeclared_dep_chains.GetEnumerator() | ForEach-Object {
        Write-Host ('  ' + $_.Key + ' <- ' + ($_.Value -join ','))
    }
}

Write-Host ""
Write-Host "--- RUNTIME ---"
$cacheStatus = if ($report.cache_count -ge 600) {'OK'} elseif ($report.cache_count) {'LOW'} else {'unknown'}
$cacheCount = $report.cache_count
Write-Host ("Arsenal cache:           $cacheCount items ($cacheStatus)")
$tplCount = $report.loadout_templates
Write-Host ("Loadout templates:       $tplCount")
$gameStateText = if ($report.game_state_reached) {'YES'} else {'NO'}
$gameStateColor = if ($report.game_state_reached) {'Green'} else {'Red'}
Write-Host ("Game state reached:      $gameStateText") -ForegroundColor $gameStateColor
$vmCount = $report.vm_exceptions_session
$vmColor = if ($vmCount -le 5) {'Green'} else {'Red'}
Write-Host ("VM exceptions (session): $vmCount") -ForegroundColor $vmColor

if ($proc) {
    $age = [int](New-TimeSpan -Start $proc.StartTime -End (Get-Date)).TotalMinutes
    $procId = $proc.Id
    $ramMb = [int]($proc.WorkingSet64/1MB)
    Write-Host ("Server process:          PID $procId | uptime ${age}m | RAM ${ramMb}MB")
} else {
    Write-Host "Server process:          NOT RUNNING" -ForegroundColor Red
}

if ($report.crash_dumps_recent.Count -gt 0) {
    Write-Host ""
    Write-Host "RECENT CRASH DUMPS (post process-start):" -ForegroundColor Red
    $report.crash_dumps_recent | ForEach-Object { Write-Host "  $_" }
}

Write-Host ""
$exitCode = 0
if ($report.folders_missing.Count -gt 0 -or $report.pak_missing.Count -gt 0 -or $report.blacklist_present.Count -gt 0 -or -not $report.game_state_reached -or $report.cache_count -lt 600) {
    Write-Host "STATUS: ATTENTION REQUIRED" -ForegroundColor Red
    $exitCode = 1
} else {
    Write-Host "STATUS: HEALTHY" -ForegroundColor Green
}
Write-Host ""
exit $exitCode
