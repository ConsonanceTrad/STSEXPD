param(
    [string]$LegacyRoot = (Join-Path $PSScriptRoot '..\..\SPS-PD-0.9.8\SPS-PD-0.9.8'),
    [switch]$ListMissing,
    [string]$ReviewedFile = (Join-Path $PSScriptRoot 'sps-reviewed-candidates.txt')
)

$ErrorActionPreference = 'Stop'

$legacySource = Join-Path $LegacyRoot 'java\com\hmdzl\spspd'
$portSource = Join-Path $PSScriptRoot '..\core\src\java\com\shatteredpixel\shatteredpixeldungeon'

if (-not (Test-Path -LiteralPath $legacySource -PathType Container)) {
    throw "Legacy SPS source was not found at $legacySource"
}
if (-not (Test-Path -LiteralPath $portSource -PathType Container)) {
    throw "SPS-SPD source was not found at $portSource"
}

$legacySource = (Resolve-Path -LiteralPath $legacySource).Path
$portSource = (Resolve-Path -LiteralPath $portSource).Path

$portFiles = Get-ChildItem -LiteralPath $portSource -Recurse -File -Filter '*.java'
$portByName = @{}
foreach ($file in $portFiles) {
    $portByName[$file.BaseName.ToLowerInvariant()] = $true
}

$reviewed = @{}
if (Test-Path -LiteralPath $ReviewedFile -PathType Leaf) {
    foreach ($line in Get-Content -LiteralPath $ReviewedFile -Encoding UTF8) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) { continue }
        $separator = $trimmed.IndexOf('|')
        if ($separator -lt 1) {
            throw "Invalid reviewed-candidate entry: $line"
        }
        $path = $trimmed.Substring(0, $separator).Trim()
        $reason = $trimmed.Substring($separator + 1).Trim()
        $reviewed[$path.ToLowerInvariant()] = $reason
    }
}

$rows = foreach ($file in Get-ChildItem -LiteralPath $legacySource -Recurse -File -Filter '*.java') {
    $relative = $file.FullName.Substring($legacySource.Length + 1)
    $relativeTarget = Join-Path $portSource $relative
    $subsystem = ($relative -split '\\')[0]
    $exact = Test-Path -LiteralPath $relativeTarget -PathType Leaf
    $nameMatch = $portByName.ContainsKey($file.BaseName.ToLowerInvariant())
    $reviewedReason = $reviewed[$relative.ToLowerInvariant()]
    [PSCustomObject]@{
        Subsystem = $subsystem
        RelativePath = $relative
        Status = if ($exact) { 'exact-path' } elseif ($nameMatch) { 'name-match' } elseif ($reviewedReason) { 'reviewed-not-required' } else { 'missing-candidate' }
        ReviewReason = $reviewedReason
    }
}

$total = @($rows).Count
$exactCount = @($rows | Where-Object Status -eq 'exact-path').Count
$nameCount = @($rows | Where-Object Status -eq 'name-match').Count
$reviewedCount = @($rows | Where-Object Status -eq 'reviewed-not-required').Count
$missingCount = @($rows | Where-Object Status -eq 'missing-candidate').Count

Write-Output '# SPS-PD source coverage audit'
Write-Output ''
Write-Output "Legacy Java files: $total"
Write-Output "Exact relative-path matches: $exactCount"
Write-Output "Additional case-insensitive class-name matches: $nameCount"
Write-Output "Reviewed candidates not requiring a standalone port: $reviewedCount"
Write-Output "Missing candidates requiring review: $missingCount"
Write-Output ''
Write-Output '| Subsystem | Legacy files | Exact path | Name match | Reviewed | Missing candidate |'
Write-Output '|---|---:|---:|---:|---:|---:|'

foreach ($group in $rows | Group-Object Subsystem | Sort-Object Name) {
    $exact = @($group.Group | Where-Object Status -eq 'exact-path').Count
    $named = @($group.Group | Where-Object Status -eq 'name-match').Count
    $reviewedInGroup = @($group.Group | Where-Object Status -eq 'reviewed-not-required').Count
    $missing = @($group.Group | Where-Object Status -eq 'missing-candidate').Count
    Write-Output "| $($group.Name) | $($group.Count) | $exact | $named | $reviewedInGroup | $missing |"
}

if ($ListMissing) {
    Write-Output ''
    Write-Output '## Missing candidates'
    Write-Output ''
    $rows | Where-Object Status -eq 'missing-candidate' | Sort-Object RelativePath | ForEach-Object {
        Write-Output "- $($_.RelativePath)"
    }

    Write-Output ''
    Write-Output '## Reviewed candidates not requiring a standalone port'
    Write-Output ''
    $rows | Where-Object Status -eq 'reviewed-not-required' | Sort-Object RelativePath | ForEach-Object {
        Write-Output "- $($_.RelativePath): $($_.ReviewReason)"
    }
}
