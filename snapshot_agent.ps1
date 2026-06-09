#requires -Version 5.1
# Standing snapshot-and-cleanup agent for the Arma Reforger dedicated server.
# Run modes:
#   .\snapshot_agent.ps1                     # one-shot pass (for Task Scheduler)
#   .\snapshot_agent.ps1 -Loop               # foreground long-running monitor
#   .\snapshot_agent.ps1 -Loop -LoopIntervalMin 5
param(
    [int]$LoopIntervalMin = 15,
    [switch]$Loop
)

$ServerRoot = 'C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server'
$LogsRoot   = Join-Path $ServerRoot 'profile_new\logs'
$SnapDir    = Join-Path $ServerRoot 'state_snapshots'
$AgentLog   = Join-Path $ServerRoot 'snapshot_agent.log'
$SnapshotPs = Join-Path $ServerRoot 'snapshot_state.ps1'

# Tunable retention policy
$STABILITY_THRESHOLD_MIN     = 20
$STABILITY_MAX_VM_5MIN       = 0
$STABILITY_MIN_ARSENAL_CACHE = 608   # floor; current stack (2026-05-17) caches ~6689
$NON_GOLDEN_RETENTION_HOURS  = 24
$GOLDEN_RETENTION_COUNT      = 10
$GOLDEN_COOLDOWN_HOURS       = 2

$CONFIG_WHITELIST = @(
    'serverConfig.json',
    'serverConfig.pre-restoration-2026-05-10.json'
)

function Write-AgentLog {
    param([string]$msg)
    $ts = Get-Date -Format 's'
    $line = '[' + $ts + '] ' + $msg
    Add-Content -Path $AgentLog -Value $line -Encoding UTF8
    Write-Host $line
}

function Test-ServerStable {
    $proc = Get-Process -Name ArmaReforgerServer -ErrorAction SilentlyContinue
    if (-not $proc) { return @{ stable=$false; reason='no server process' } }

    $ageMin = [int](New-TimeSpan -Start $proc.StartTime -End (Get-Date)).TotalMinutes
    if ($ageMin -lt $STABILITY_THRESHOLD_MIN) {
        return @{ stable=$false; reason=('process only ' + $ageMin + 'm old (need ' + $STABILITY_THRESHOLD_MIN + ')') }
    }

    $newestLog = Get-ChildItem $LogsRoot -Directory -ErrorAction SilentlyContinue |
                 Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $newestLog) { return @{ stable=$false; reason='no log folder' } }

    $scriptLog = Join-Path $newestLog.FullName 'script.log'
    $cacheLine = Select-String -Path $scriptLog -Pattern 'GunBuilderUI_ServerInit \| Cached (\d+) items' -ErrorAction SilentlyContinue | Select-Object -Last 1
    if (-not $cacheLine) { return @{ stable=$false; reason='no cache event yet' } }
    $cache = [int]$cacheLine.Matches.Groups[1].Value
    if ($cache -lt $STABILITY_MIN_ARSENAL_CACHE) { return @{ stable=$false; reason=('cache=' + $cache + ' (expected >=' + $STABILITY_MIN_ARSENAL_CACHE + ')') } }

    $cutoff = (Get-Date).AddMinutes(-5)
    $vmExc = Select-String -Path $scriptLog -Pattern 'Virtual Machine Exception' -ErrorAction SilentlyContinue
    $recentVMCount = 0
    foreach ($v in $vmExc) {
        if ($v.Line -match '^(\d{2}):(\d{2}):(\d{2})') {
            $logTime = Get-Date -Hour $matches[1] -Minute $matches[2] -Second $matches[3]
            if ($logTime -gt $cutoff) { $recentVMCount++ }
        }
    }
    if ($recentVMCount -gt $STABILITY_MAX_VM_5MIN) {
        return @{ stable=$false; reason=($recentVMCount.ToString() + ' VM exceptions in last 5 min') }
    }

    $dumpDir = Join-Path $ServerRoot 'profile_new\crashes'
    if (Test-Path $dumpDir) {
        $fresh = Get-ChildItem $dumpDir -Filter '*.dmp' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $proc.StartTime }
        if ($fresh) { return @{ stable=$false; reason=($fresh.Count.ToString() + ' crash dump(s) since process start') } }
    }

    return @{ stable=$true; reason=('age=' + $ageMin + 'm cache=' + $cache + ' vm5min=' + $recentVMCount) }
}

function Test-GoldenCooldown {
    $lastGolden = Get-ChildItem $SnapDir -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -like 'GOLDEN_*' } |
                  Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $lastGolden) { return $true }
    $sinceHours = (New-TimeSpan -Start $lastGolden.LastWriteTime -End (Get-Date)).TotalHours
    return $sinceHours -ge $GOLDEN_COOLDOWN_HOURS
}

function Invoke-AgentPass {
    Write-AgentLog '-- pass start --'

    $check = Test-ServerStable
    Write-AgentLog ('stability: ' + $check.reason)
    if ($check.stable -and (Test-GoldenCooldown)) {
        $label = 'auto-golden-' + (Get-Date -Format 'HHmm')
        Write-AgentLog ('taking Golden snapshot: ' + $label)
        & $SnapshotPs -Label $label -Golden | Out-Null
    } elseif ($check.stable) {
        Write-AgentLog 'stable but within Golden cooldown - skip'
    }

    $cutoff = (Get-Date).AddHours(-$NON_GOLDEN_RETENTION_HOURS)
    $oldNonGolden = Get-ChildItem $SnapDir -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -notlike 'GOLDEN_*' -and $_.LastWriteTime -lt $cutoff }
    foreach ($o in $oldNonGolden) {
        $ageH = [int]((Get-Date) - $o.LastWriteTime).TotalHours
        Write-AgentLog ('pruning old non-Golden: ' + $o.Name + ' (age ' + $ageH + 'h)')
        Remove-Item $o.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

    $allGolden = Get-ChildItem $SnapDir -Directory -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -like 'GOLDEN_*' } |
                 Sort-Object LastWriteTime -Descending
    if ($allGolden.Count -gt $GOLDEN_RETENTION_COUNT) {
        $extras = $allGolden | Select-Object -Skip $GOLDEN_RETENTION_COUNT
        foreach ($g in $extras) {
            Write-AgentLog ('pruning excess Golden: ' + $g.Name)
            Remove-Item $g.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $obsoleteConfigs = Get-ChildItem $ServerRoot -Filter 'serverConfig*.json' -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -notin $CONFIG_WHITELIST }
    foreach ($c in $obsoleteConfigs) {
        $kb = [int]($c.Length / 1KB)
        Write-AgentLog ('pruning obsolete config backup: ' + $c.Name + ' (' + $kb + 'KB)')
        Remove-Item $c.FullName -Force -ErrorAction SilentlyContinue
    }
    $brokenBackups = Get-ChildItem $ServerRoot -Filter 'serverConfig.broken-*.json' -ErrorAction SilentlyContinue
    foreach ($b in $brokenBackups) {
        Write-AgentLog ('pruning broken-* backup: ' + $b.Name)
        Remove-Item $b.FullName -Force -ErrorAction SilentlyContinue
    }

    Write-AgentLog '-- pass end --'
}

do {
    Invoke-AgentPass
    if ($Loop) {
        Write-AgentLog ('sleep ' + $LoopIntervalMin + ' min')
        Start-Sleep -Seconds ($LoopIntervalMin * 60)
    }
} while ($Loop)
