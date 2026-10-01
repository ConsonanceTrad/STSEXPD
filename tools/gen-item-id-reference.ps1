# gen-item-id-reference.ps1
#   Build a readable reference for every semantic id in _index.csv so the claim list can be
#   filled by recognizable names. Matching is fuzzy: both sides are normalized (lowercase,
#   strip non-alphanumerics AND the "of" filler) before substring comparison, because the
#   original ids and the message keys do not correspond mechanically.
# Usage:  .\tools\gen-item-id-reference.ps1
# Output: tools/atlas-meta/items-id-reference.csv   (semantic,hint_en,hint_zh,w,h)

param(
	[string]$IndexCsv = 'tools/atlas-meta/items/_index.csv',
	[string]$MsgRoot  = 'core/src/assets/messages/items',
	[string]$OutCsv   = 'tools/atlas-meta/items-id-reference.csv'
)

$ErrorActionPreference = 'Stop'

function Read-Map([string]$path) {
	$m = @{}
	foreach ($line in ([IO.File]::ReadAllText($path, [Text.Encoding]::UTF8) -split "`r?`n")) {
		if ($line -match '^([^=]+)=(.*)$') { $m[$Matches[1].Trim()] = $Matches[2].Trim() }
	}
	return $m
}
$en = Read-Map (Join-Path $MsgRoot 'en/items.properties')
$zh = Read-Map (Join-Path $MsgRoot 'zh/items.properties')

function Norm([string]$s) {
	$s = $s.ToLowerInvariant()
	$s = $s -replace '[\s_\-\.]', ''      # separators
	$s = $s -replace 'of', ''             # filler word
	return $s
}

$enNorm = @{}    # normalized-key-suffix -> full key  (only *.name keys)
foreach ($k in $en.Keys) {
	if ($k -notmatch '\.name$') { continue }
	$tail = ($k -split '\.')[-2]
	$n = Norm $tail
	if (-not $enNorm.ContainsKey($n)) { $enNorm[$n] = $k }
}

$rows = [IO.File]::ReadAllLines((Resolve-Path $IndexCsv).Path, [Text.Encoding]::UTF8) | Select-Object -Skip 1
$seen = @{}
$out = New-Object Text.StringBuilder
[void]$out.AppendLine('semantic,hint_en,hint_zh,w,h')
$hit = 0; $miss = 0
foreach ($r in $rows) {
	if ($r.Trim() -eq '') { continue }
	$p = $r -split ','
	$sem = $p[0]
	if ($seen.ContainsKey($sem)) { continue }
	$seen[$sem] = $true

	$name = ($sem -split '/')[-1]
	$n = Norm $name
	$key = ''
	# exact normalized match only - substring matching produced false positives
	# (e.g. artifacts/horn -> "thorn ammo", artifacts/rose -> "sad ghost")
	if ($enNorm.ContainsKey($n)) { $key = $enNorm[$n] }
	$e = ''; $c = ''
	if ($key -ne '') {
		if ($en.ContainsKey($key)) { $e = $en[$key] }
		$zk = $key
		if ($zh.ContainsKey($zk)) { $c = $zh[$zk] }
	}
	if ($e -ne '' -or $c -ne '') { $hit++ } else { $miss++ }
	$e = $e -replace '"','""'; $c = $c -replace '"','""'
	if ($e -match ',') { $e = '"' + $e + '"' }
	if ($c -match ',') { $c = '"' + $c + '"' }
	[void]$out.AppendLine("$sem,$e,$c,$($p[4]),$($p[5])")
}
[IO.File]::WriteAllText((Join-Path (Get-Location).Path $OutCsv), $out.ToString(), (New-Object Text.UTF8Encoding($false)))
Write-Host "semantic ids: $($seen.Count)   with hint: $hit   no hint: $miss"
Write-Host "written: $OutCsv"