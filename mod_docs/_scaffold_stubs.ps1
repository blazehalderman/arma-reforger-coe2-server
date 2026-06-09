# Scaffold per-mod doc stubs for every mod declared in serverConfig.json.
# Pulls frontmatter facts from the live config + addons/<guid>/addon.gproj.
# Will NOT overwrite existing docs.
param(
    [string]$ServerRoot = "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server",
    [switch]$Force  # overwrite existing stubs (rarely wanted)
)

$cfgLocal    = Join-Path $ServerRoot 'serverConfig.json'
$cfgDeployed = Join-Path $ServerRoot 'serverconfig-deployed.json'
$addonsDir   = Join-Path $ServerRoot 'profile_new\addons'
$docsDir     = Join-Path $ServerRoot 'mod_docs'

$local    = (Get-Content $cfgLocal    -Raw | ConvertFrom-Json).game.mods
$deployed = (Get-Content $cfgDeployed -Raw | ConvertFrom-Json).game.mods

# Build maps: guid -> { name, version }
$localMap    = @{}
$deployedMap = @{}
foreach ($m in $local)    { $localMap[$m.modId]    = $m }
foreach ($m in $deployed) { $deployedMap[$m.modId] = $m }

# Union of guids
$allGuids = @{}
foreach ($g in $localMap.Keys)    { $allGuids[$g] = $true }
foreach ($g in $deployedMap.Keys) { $allGuids[$g] = $true }

# Read each addons folder's addon.gproj for deps + version manifest
function Get-AddonInfo {
    param([string]$Guid)
    $folder = Get-ChildItem $addonsDir -Directory -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -like "*_$Guid" } | Select-Object -First 1
    if (-not $folder) { return @{ Folder = $null; Deps = @(); Version = '' } }

    $gproj = Join-Path $folder.FullName 'addon.gproj'
    $deps = @()
    if (Test-Path $gproj) {
        $content = Get-Content $gproj -Raw
        # Dependencies { "<GUID>" "<GUID>" ... }
        $match = [regex]::Match($content, 'Dependencies\s*\{([^}]*)\}')
        if ($match.Success) {
            $depGuids = [regex]::Matches($match.Groups[1].Value, '"([0-9A-F]{16})"')
            foreach ($d in $depGuids) { $deps += $d.Groups[1].Value }
        }
    }
    # Version from any *_manifest.json filename
    $manifest = Get-ChildItem $folder.FullName -Filter '*_manifest.json' -ErrorAction SilentlyContinue |
                Select-Object -First 1
    $version = ''
    if ($manifest -and $manifest.Name -match '_(\d+\.\d+\.\d+)_manifest\.json$') { $version = $matches[1] }

    return @{ Folder = $folder.Name; Deps = $deps; Version = $version }
}

# Compute reverse-deps by scanning every gproj for who deps on whom
$revDepMap = @{}
$gprojFiles = Get-ChildItem $addonsDir -Directory -ErrorAction SilentlyContinue |
              ForEach-Object { Join-Path $_.FullName 'addon.gproj' } |
              Where-Object { Test-Path $_ }
foreach ($gp in $gprojFiles) {
    $self = (Split-Path $gp -Parent | Split-Path -Leaf)
    if ($self -notmatch '_([A-F0-9]{16})$') { continue }
    $selfGuid = $matches[1]
    $content  = Get-Content $gp -Raw
    $match    = [regex]::Match($content, 'Dependencies\s*\{([^}]*)\}')
    if ($match.Success) {
        $depGuids = [regex]::Matches($match.Groups[1].Value, '"([0-9A-F]{16})"')
        foreach ($d in $depGuids) {
            $target = $d.Groups[1].Value
            if (-not $revDepMap.ContainsKey($target)) { $revDepMap[$target] = @() }
            $revDepMap[$target] += $selfGuid
        }
    }
}

# Filename sanitizer
function Sanitize-Filename { param([string]$s) return ($s -replace '[\\/:*?"<>|]', '_') -replace '\s+','_' }

$written = 0
$skipped = 0
foreach ($guid in $allGuids.Keys) {
    $mod = if ($localMap.ContainsKey($guid)) { $localMap[$guid] } else { $deployedMap[$guid] }
    $name = $mod.name
    $info = Get-AddonInfo -Guid $guid

    $status =
        if (($localMap.ContainsKey($guid)) -and ($deployedMap.ContainsKey($guid))) { 'active' }
        elseif ($deployedMap.ContainsKey($guid)) { 'deployed-only' }
        elseif ($localMap.ContainsKey($guid))    { 'local-only' }
        else { 'unknown' }

    $declaredIn = @()
    if ($localMap.ContainsKey($guid))    { $declaredIn += 'local' }
    if ($deployedMap.ContainsKey($guid)) { $declaredIn += 'deployed' }

    $hardDepsYaml = if ($info.Deps.Count -eq 0) { '[]' } else {
        ($info.Deps | ForEach-Object {
            $depName = if ($localMap.ContainsKey($_)) { $localMap[$_].name } elseif ($deployedMap.ContainsKey($_)) { $deployedMap[$_].name } else { '<not in any config>' }
            "  - `"$_ # $depName`""
        }) -join "`n"
        $hardDepsYaml = "`n$hardDepsYaml"
    }
    if ($info.Deps.Count -gt 0) {
        $hardDepsYaml = "`n" + (($info.Deps | ForEach-Object {
            $depName = if ($localMap.ContainsKey($_)) { $localMap[$_].name } elseif ($deployedMap.ContainsKey($_)) { $deployedMap[$_].name } else { '<not in any config>' }
            "  - `"$_ # $depName`""
        }) -join "`n")
    } else { $hardDepsYaml = ' []' }

    $revDepsYaml = ' []'
    if ($revDepMap.ContainsKey($guid) -and $revDepMap[$guid].Count -gt 0) {
        $revDepsYaml = "`n" + (($revDepMap[$guid] | Sort-Object -Unique | ForEach-Object {
            $rn = if ($localMap.ContainsKey($_)) { $localMap[$_].name } elseif ($deployedMap.ContainsKey($_)) { $deployedMap[$_].name } else { '<undeclared>' }
            "  - `"$_ # $rn`""
        }) -join "`n")
    }

    $declaredYaml = "`n" + (($declaredIn | ForEach-Object { "  - $_" }) -join "`n")

    $filename = Sanitize-Filename -s $name
    $outPath  = Join-Path $docsDir "$filename.md"

    if ((Test-Path $outPath) -and -not $Force) { $skipped++; continue }

    $doc = @"
---
workshop_id: "$guid"
workshop_url: https://reforger.armaplatform.com/workshop/$guid
version: "$($info.Version)"
author: ""
load_order_layer: L?
status: $status
last_verified: 2026-05-16
declared_in:$declaredYaml
hard_deps:$hardDepsYaml
reverse_deps:$revDepsYaml
related_memories: []
folder: "$($info.Folder)"
---

# $name

> **One-line role**: _[needs enrichment — see _ORCHESTRATOR.md for the playbook]_

## 1. Overview

_[stub — to be enriched]_

## 2. Functionality / Features

_[stub]_

## 3. Configuration

_[stub — check `profile_new/profile/$name/` for config files]_

## 4. Operator usage

_[stub]_

## 5. Compatibility & load order

- **Load order layer**: L? _(verify against MASTER_OBJECTIVE.md)_
- **Hard deps**: see frontmatter
- **Reverse deps**: see frontmatter
- **Status**: $status

## 6. Performance impact

_[stub]_

## 7. Known issues / landmines

_[stub — cross-reference CLAUDE.md "Known landmines" table + memory/ folder]_

## 8. Extending / modding

_N/A_

## 9. Changelog / verified state

- **Installed version**: $($info.Version)
- **Folder**: $($info.Folder)
- **Last clean boot**: 2026-05-16 (last golden state)

## 10. References

- [Workshop](https://reforger.armaplatform.com/workshop/$guid)
- [Workshop changelog](https://reforger.armaplatform.com/workshop/$guid/changelog)
"@

    [System.IO.File]::WriteAllText($outPath, $doc, (New-Object System.Text.UTF8Encoding $false))
    $written++
}

Write-Output "Wrote: $written"
Write-Output "Skipped (already exist): $skipped"
Write-Output "Total guids processed: $($allGuids.Count)"
