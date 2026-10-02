# apply-item-sprite-map.ps1
#   Rewrites  ItemSpriteSheet.<CONST>  ->  <XxxDict>.<IDENT>  across core/src/java,
#   using tools/atlas-meta/items-sprite-map.csv, and adds the needed imports.
#
#   UNRESOLVED constants fall back to SpecificPlaceHolderDict.SOMETHING_0 (user decision).
#
# Usage:
#   .\tools\apply-item-sprite-map.ps1 -DryRun     # report only
#   .\tools\apply-item-sprite-map.ps1             # apply

param(
	[string]$MapCsv = 'tools/atlas-meta/items-sprite-map.csv',
	[string]$SrcRoot = 'core/src/java',
	[switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$utf8 = New-Object Text.UTF8Encoding($false)

$map = @{}
$nOk = 0; $nUn = 0
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $MapCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'old_const,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 5) { continue }
	$name = $p[0]
	if ($p[4] -eq 'ok' -and $p[1] -ne '') { $map[$name] = "$($p[1]).$($p[2])"; $nOk++ }
	elseif ($p[4] -eq 'UNRESOLVED') { $map[$name] = 'SpecificPlaceHolderDict.SOMETHING_0'; $nUn++ }
}
# constants that live in ItemSpriteSheet.java but carry no cell (still must resolve)
foreach ($n in @('APK_931','SCROLL_NCOSRANE','SPS_CALL_COCONUT','SPS_JOURNAL_PAGE')) {
	if (-not $map.ContainsKey($n)) { $map[$n] = 'SpecificPlaceHolderDict.SOMETHING_0'; $nUn++ }
}
Write-Host ("map: ok={0} fallback={1}" -f $nOk, $nUn)

$files = @(Get-ChildItem -Recurse -File -Filter '*.java' (Join-Path $repoRoot $SrcRoot))
$changed = 0
$unknown = @{}
foreach ($f in $files) {
	if ($f.Name -eq 'ItemSpriteSheet.java') { continue }
	$text = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8)
	if ($text -notmatch 'ItemSpriteSheet\.') { continue }
	$used = @{}
	$evaluator = {
		param($m)
		$n = $m.Groups[1].Value
		if ($map.ContainsKey($n)) {
			$ref = $map[$n]
			$cls = $ref.Substring(0, $ref.IndexOf('.'))
			$used[$cls] = $true
			return $ref
		}
		$unknown[$n] = $true
		return $m.Value
	}
	$new = [regex]::Replace($text, 'ItemSpriteSheet\.([A-Z][A-Z0-9_]*)(?!\w)', $evaluator)
	if ($new -eq $text) { continue }
	# imports
	$need = @($used.Keys | Sort-Object)
	if ($need.Count -gt 0) {
		$imp = ($need | ForEach-Object { "import pd.atlas.items.$_;" }) -join "`r`n"
		$lines = $new -split "`r?`n"
		$out = New-Object System.Collections.ArrayList
		$inserted = $false
		foreach ($ln in $lines) {
			[void]$out.Add($ln)
			if (-not $inserted -and $ln -match '^package\s') { [void]$out.Add(''); [void]$out.Add($imp); $inserted = $true }
		}
		if (-not $inserted) { [void]$out.Insert(0, $imp) }
		$new = ($out -join "`r`n")
	}
	if (-not $DryRun) { [IO.File]::WriteAllText($f.FullName, $new, $utf8) }
	$changed++
}
Write-Host ("files rewritten: {0}{1}" -f $changed, $(if ($DryRun) { '  (dry run)' } else { '' }))
if ($unknown.Count -gt 0) {
	Write-Host ("unknown constants (left as-is): {0}" -f $unknown.Count) -ForegroundColor Yellow
	$unknown.Keys | Sort-Object | Select-Object -First 30 | ForEach-Object { Write-Host ("  " + $_) }
}
