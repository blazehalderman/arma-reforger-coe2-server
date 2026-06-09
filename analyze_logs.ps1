param(
    [string]$LogFolder = "",
    [string]$OutputFile = "$PSScriptRoot\last_session_errors.txt"
)

$ServerRoot = "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server"
$LogsRoot   = Join-Path $ServerRoot "profile_new\logs"

if (-not $LogFolder) {
    $LogFolder = (Get-ChildItem $LogsRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
    if (-not $LogFolder) { Write-Error "No log folders found"; exit 1 }
    Write-Host "Using: $LogFolder" -ForegroundColor Cyan
} elseif (-not [System.IO.Path]::IsPathRooted($LogFolder)) {
    $LogFolder = Join-Path $ServerRoot $LogFolder
}

$ErrorLog   = Join-Path $LogFolder "error.log"
$ScriptLog  = Join-Path $LogFolder "script.log"
if (-not (Test-Path $ErrorLog)) { Write-Error "error.log not found in $LogFolder"; exit 1 }

Write-Host "Reading logs..." -ForegroundColor Cyan
$errorLines  = Get-Content $ErrorLog
$scriptLines = if (Test-Path $ScriptLog) { Get-Content $ScriptLog } else { @() }
$allLines = @(($errorLines + $scriptLines) | Sort-Object -Unique)

$errorCount   = ($allLines | Where-Object { $_ -match '\s\(E\):' }).Count
$warnCount    = ($allLines | Where-Object { $_ -match '\s\(W\):' }).Count
$fatalCount   = ($allLines | Where-Object { $_ -match 'FATAL|CRASH' }).Count
$vmExceptions = ($allLines | Where-Object { $_ -match 'Virtual Machine Exception' }).Count

# Group VM exceptions
$vmGroups = @{}
$i = 0
while ($i -lt $allLines.Count) {
    if ($allLines[$i] -match 'Virtual Machine Exception') {
        $block = $allLines[$i..([Math]::Min($i+12, $allLines.Count-1))]
        $cls    = ($block | Where-Object { $_ -match "Class:\s+'(.+)'" }    | Select-Object -First 1) -replace ".*Class:\s+'(.+)'.*",'$1'
        $func   = ($block | Where-Object { $_ -match "Function:\s+'(.+)'" } | Select-Object -First 1) -replace ".*Function:\s+'(.+)'.*",'$1'
        $reason = ($block | Where-Object { $_ -match "Reason:\s+(.+)" }     | Select-Object -First 1) -replace ".*Reason:\s+(.+)",'$1'
        if (-not $cls)    { $cls    = "Unknown" }
        if (-not $func)   { $func   = "Unknown" }
        if (-not $reason) { $reason = "Unknown" }
        $key = "$($reason.Trim()) | $cls.$func"
        $vmGroups[$key] = ($vmGroups[$key] -as [int]) + 1
    }
    $i++
}

# Group script errors (non-VM)
$scriptErrGroups = @{}
foreach ($line in ($allLines | Where-Object { $_ -match '\s\(E\):' -and $_ -notmatch 'Virtual Machine Exception' })) {
    if ($line -match '\s\(E\):\s*(.+)') {
        $msg = $Matches[1].Trim() -replace '\{[0-9A-F]{16}\}','{GUID}' -replace 'ENTITY:[0-9]+','ENTITY:N' -replace '\d+\.\d+','#' -replace '"[^"]{50,}','"<path>'
        $scriptErrGroups[$msg] = ($scriptErrGroups[$msg] -as [int]) + 1
    }
}

# Group RPC errors
$rpcGroups = @{}
foreach ($line in ($allLines | Where-Object { $_ -match 'RpcError' })) {
    if ($line -match "itemType='([^']+)'.*rpc='([^']+)'") {
        $key = "$($Matches[1])::$($Matches[2])"
        $rpcGroups[$key] = ($rpcGroups[$key] -as [int]) + 1
    }
}

# Group top warnings
$warnGroups = @{}
foreach ($line in ($allLines | Where-Object { $_ -match '\s\(W\):' })) {
    if ($line -match '\s\(W\):\s*(.+)') {
        $msg = $Matches[1].Trim() -replace '\{[0-9A-F]{16}\}','{GUID}' -replace 'ENTITY:[0-9]+','ENTITY:N' -replace '\d+\.\d+','#'
        $warnGroups[$msg] = ($warnGroups[$msg] -as [int]) + 1
    }
}

$sep  = "=" * 80
$sep2 = "-" * 80
$ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$session = Split-Path $LogFolder -Leaf
$totalLineCount = @($allLines).Count
$lines = @(
    $sep,
    "  ARMA REFORGER SERVER - LOG ANALYSIS",
    "  Session : $session",
    "  Analyzed: $ts",
    $sep,
    "",
    ("--- SUMMARY " + ("-" * 68)),
    "  Total lines analyzed : $totalLineCount",
    "  FATAL / crash        : $fatalCount",
    "  ERROR entries        : $errorCount",
    "  WARNING entries      : $warnCount",
    "  VM Exceptions        : $vmExceptions",
    ""
)

if ($vmGroups.Count -gt 0) {
    $lines += ("--- VM SCRIPT EXCEPTIONS (grouped) " + ("-" * 45))
    $vmGroups.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        $lines += "  [$($_.Value)x]  $($_.Key)"
    }
    $lines += ""
}

if ($scriptErrGroups.Count -gt 0) {
    $lines += ("--- SCRIPT ERRORS non-VM (top 30) " + ("-" * 45))
    $scriptErrGroups.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 30 | ForEach-Object {
        $lines += "  [$($_.Value)x]  $($_.Key)"
    }
    $lines += ""
}

if ($rpcGroups.Count -gt 0) {
    $lines += ("--- RPC ERRORS (grouped) " + ("-" * 55))
    $rpcGroups.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
        $lines += "  [$($_.Value)x]  $($_.Key)"
    }
    $lines += ""
}

if ($warnGroups.Count -gt 0) {
    $lines += ("--- TOP WARNINGS (top 20) " + ("-" * 54))
    $warnGroups.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20 | ForEach-Object {
        $lines += "  [$($_.Value)x]  $($_.Key)"
    }
    $lines += ""
}

# Known issue detection
$known = @()
if (($allLines | Where-Object { $_ -match 'EPF_PersistenceManager.*AddOrUpdateAsync' }).Count -gt 0) {
    $known += "[FreedomFighters] EPF_PersistenceManager NULL ptr in AddOrUpdateAsync - FreedomFighters vehicle persistence bug. Cosmetic, no crash. Unfixable without mod source."
}
if (($allLines | Where-Object { $_ -match "no catalog with that type for faction" }).Count -gt 0) {
    $factions = $allLines | Where-Object { $_ -match "faction '(\w+)'" } | ForEach-Object { if ($_ -match "faction '(\w+)'") { $Matches[1] } } | Select-Object -Unique
    $known += "[MissingCatalog] Factions missing ITEM catalog: [$($factions -join ', ')]. Arsenal empty for these factions. Mod-level fix required."
}
if (($allLines | Where-Object { $_ -match 'TransparentMat\.emat' }).Count -gt 0) {
    $known += "[Doors] TransparentMat.emat missing - caused by BreachableDoors/DoorBreaching. Should be resolved if those mods are disabled."
}
if (($allLines | Where-Object { $_ -match 'Math\.RandomFloat: invalid parameters' }).Count -gt 0) {
    $known += "[PC Scenario] Math.RandomFloat min=max - PC weather/spawn system edge case. Cosmetic."
}
if (($allLines | Where-Object { $_ -match 'RpcError.*SCR_EditorTask' }).Count -gt 0) {
    $known += "[GM Tasks] SCR_EditorTask RPC before channel ready - GM tasks still work in-game. Cosmetic."
}
if ($known.Count -gt 0) {
    $lines += ("--- KNOWN ISSUES DETECTED " + ("-" * 54))
    $i = 1
    foreach ($issue in $known) { $lines += "  [$i] $issue"; $i++ }
    $lines += ""
}

$lines += $sep
$lines += "  Log folder: $LogFolder"
$lines += $sep

$report = $lines -join [Environment]::NewLine
Write-Host $report
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($OutputFile, $report, $utf8NoBom)
Write-Host "`nReport saved: $OutputFile" -ForegroundColor Green

# ── Raw error/warning dump (full lines, unfiltered, in source order) ──────────
$RawOutputFile = [System.IO.Path]::ChangeExtension($OutputFile, $null).TrimEnd('.') + '_raw.txt'
$rawErrorLines  = @($errorLines  | Where-Object { $_ -match '\s\(E\):|\s\(W\):|FATAL|CRASH|Virtual Machine Exception|RpcError' })
$rawScriptLines = @($scriptLines | Where-Object { $_ -match '\s\(E\):|\s\(W\):|FATAL|CRASH|Virtual Machine Exception|RpcError' })

$rawHeader = @(
    $sep,
    "  RAW ERRORS / WARNINGS (full lines, source order)",
    "  Session : $session",
    "  Analyzed: $ts",
    "  error.log entries  : $($rawErrorLines.Count)",
    "  script.log entries : $($rawScriptLines.Count)",
    $sep,
    ""
)
$rawBody = @(
    "===== error.log =====",
    ""
) + $rawErrorLines + @(
    "",
    "===== script.log =====",
    ""
) + $rawScriptLines

[System.IO.File]::WriteAllText($RawOutputFile, (($rawHeader + $rawBody) -join [Environment]::NewLine), $utf8NoBom)
Write-Host "Raw dump saved: $RawOutputFile" -ForegroundColor Green