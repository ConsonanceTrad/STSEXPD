# gen-item-sprite-map.ps1
#   Builds  old ItemSpriteSheet constant -> new pd.atlas.items dictionary entry  mapping.
#
#   Matching is by CELL COORDINATE, which is what survives your rework:
#     old constant -> int ordinal -> (x,y) in the original 256x992 items.png
#        -> items/_index.csv semantic (by x,y)
#        -> items-newid-map-en.csv  old_id -> en_id
#        -> pd.atlas.items.<Dict>.<IDENT>
#   Legacy multi-frame constants (ARTIFACT_HORN1..4, SUMMON_ELE_*, ...) come from
#   items-aliases.csv and resolve to the alias emitted in the dictionary.
#
#   Input : core/src/java/pd/sprites/ItemSpriteSheet.java
#           tools/atlas-meta/items/_index.csv
#           tools/atlas-meta/items-newid-map-en.csv
#           tools/atlas-meta/items-aliases.csv
#   Output: tools/atlas-meta/items-sprite-map.csv   (old_const,new_class,new_ident,source,status)

param(
	[string]$Sheet    = 'core/src/java/pd/sprites/ItemSpriteSheet.java',
	[string]$IndexCsv = 'tools/atlas-meta/items/_index.csv',
	[string]$MapCsv   = 'tools/atlas-meta/items-newid-map-en.csv',
	[string]$AliasCsv = 'tools/atlas-meta/items-aliases.csv',
	[string]$OutCsv   = 'tools/atlas-meta/items-sprite-map.csv',
	[int]$Cols        = 16,
	[int]$Cell        = 16
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$utf8 = New-Object Text.UTF8Encoding($false)

function ConvertTo-Camel([string]$name) {
	$parts = [regex]::Split($name, '[^A-Za-z0-9]+') | Where-Object { $_ -ne '' }
	$s = ''
	foreach ($p in $parts) { if ($p.Length -eq 0) { continue }; $s += $p.Substring(0,1).ToUpperInvariant() + $p.Substring(1) }
	if ($s -eq '') { $s = 'Atlas' }
	if ($s -match '^[0-9]') { $s = 'N' + $s }
	return $s
}
function ConvertTo-Identifier([string]$name) {
	$s = [regex]::Replace($name, '[^A-Za-z0-9]+', '_').Trim('_').ToUpperInvariant()
	if ($s -eq '') { $s = 'ENTRY' }
	if ($s -match '^[0-9]') { $s = 'N' + $s }
	return $s
}
function NamePart([string]$id) { $i = $id.IndexOf('/'); if ($i -ge 0) { return $id.Substring($i+1) }; return $id }
function StripSeq([string]$s) { return ($s -replace '#[0-9]+$', '') }
function DictClassFor([string]$atlas) {
	$noExt = $atlas.Substring(0, $atlas.Length - 4)
	# meta path is tools/atlas-meta/items/<atlas>; gen-atlas-dict.ps1 joins from the 2nd segment
	$dirs = @('items') + ($noExt -split '/')
	$nameParts = @($dirs[1..($dirs.Count-1)])
	$classBase = ($nameParts | ForEach-Object { ConvertTo-Camel $_ }) -join ''
	return ($classBase + 'Dict')
}

# ---- 1) (x,y) -> old semantic ---------------------------------------------
$semByCell = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $IndexCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'file,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 6) { continue }
	$key = "$($p[2]),$($p[3])"
	if (-not $semByCell.ContainsKey($key)) { $semByCell[$key] = New-Object System.Collections.ArrayList }
	[void]$semByCell[$key].Add($p[0])
}
Write-Host ("indexed cells: {0}" -f $semByCell.Count)

# ---- 2) old semantic name -> new dict ref ---------------------------------
$refByOldName = @{}
$enNameToClass = @{}
$byStrippedName = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $MapCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'atlas,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 8) { continue }
	$atlas = $p[0]; $en = $p[7].Trim(); $old = $p[5].Trim()
	if ($en -eq '' -or $en -eq '-') { continue }
	$cls = DictClassFor $atlas
	$enName = NamePart $en
	if (-not $enNameToClass.ContainsKey($enName)) { $enNameToClass[$enName] = $cls }
	$full = "$cls." + (ConvertTo-Identifier $enName)
	if (-not $byStrippedName.ContainsKey((StripSeq $enName))) { $byStrippedName[(StripSeq $enName)] = $full }
	if ($old -eq '' -or $old -eq '(skip)') { continue }
	$on = StripSeq (NamePart $old)
	$target = "$cls." + (ConvertTo-Identifier $enName)
	if (-not $refByOldName.ContainsKey($on)) { $refByOldName[$on] = $target }
}
Write-Host ("old names mapped: {0}" -f $refByOldName.Count)

# ---- 3) legacy frame aliases ----------------------------------------------
$aliasTo = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $AliasCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'id,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 2) { continue }
	$aliasTo[(ConvertTo-Identifier $p[1])] = $p[0]
}

# ---- 4) scan constants (two passes: bases first, then values) -------------
$lines = [IO.File]::ReadAllLines((Join-Path $repoRoot $Sheet), [Text.Encoding]::UTF8)
$defs = New-Object System.Collections.ArrayList
$bases = @{}
foreach ($line in $lines) {
	$m = [regex]::Match($line, '^[ \t]*(?:public|private)\s+static\s+final\s+int\s+([A-Z][A-Z0-9_]*)\s*=\s*([^;]+);')
	if (-not $m.Success) { continue }
	$name = $m.Groups[1].Value
	$expr = $m.Groups[2].Value.Trim()
	[void]$defs.Add([pscustomobject]@{ name=$name; expr=$expr })
	foreach ($mm in [regex]::Matches($expr, '([A-Z][A-Z0-9_]*)')) { $bases[$mm.Groups[1].Value] = $true }
}

$vars = @{}
$order = New-Object System.Collections.ArrayList
foreach ($d in $defs) {
	$val = $null
	$mx = [regex]::Match($d.expr, '^xy\(\s*(\d+)\s*,\s*(\d+)\s*\)$')
	if ($mx.Success) {
		$val = ([int]$mx.Groups[1].Value - 1) + $Cols * ([int]$mx.Groups[2].Value - 1)
	} else {
		$mv = [regex]::Match($d.expr, '^([A-Z][A-Z0-9_]*)\s*([+-]\s*[0-9]+)?$')
		if ($mv.Success -and $vars.ContainsKey($mv.Groups[1].Value)) {
			$base = $vars[$mv.Groups[1].Value]
			$delta = 0
			if ($mv.Groups[2].Success) { $delta = [int](($mv.Groups[2].Value) -replace '\s','') }
			$val = $base + $delta
		} elseif ($d.expr -match '^[0-9]+$') {
			$val = [int]$d.expr
		}
	}
	if ($null -ne $val) { $vars[$d.name] = $val; [void]$order.Add($d.name) }
}
Write-Host ("defs={0} vars={1}" -f $defs.Count, $vars.Count)
Write-Host ("order: " + ($order -join ','))
Write-Host ("constants parsed: {0}  (bases skipped: {1})" -f $order.Count, ($order | Where-Object { $bases.ContainsKey($_) }).Count)

# ---- 5) resolve ------------------------------------------------------------
$rows = New-Object System.Collections.ArrayList
$unresolved = New-Object System.Collections.ArrayList
foreach ($c in $order) {
	if ($c -eq 'SIZE') { continue }
	if ($bases.ContainsKey($c)) { continue }
	$v = $vars[$c]
	$x = ($v % $Cols) * $Cell
	$y = [int]([Math]::Floor($v / $Cols)) * $Cell
	$cellKey = "$x,$y"
	$sem = ''
	$target = ''
	if ($semByCell.ContainsKey($cellKey)) {
		foreach ($s in $semByCell[$cellKey]) {
			$on = StripSeq (NamePart $s)
			if ($refByOldName.ContainsKey($on)) { $sem = $s; $target = $refByOldName[$on]; break }
		}
	}
	if ($target -eq '' -and $aliasTo.ContainsKey($c)) {
		$idName = $aliasTo[$c]
		if ($enNameToClass.ContainsKey($idName)) { $target = $enNameToClass[$idName] + '.' + $c; $sem = '(alias)' }
	}
	if ($target -eq '' -and $refByOldName.ContainsKey($c)) {
		$target = $refByOldName[$c]; $sem = '(byname)'
	}
	if ($target -eq '') {
		$try = $c
		if ($try.StartsWith('SPS_')) { $try = $try.Substring(4) }
		elseif ($try.StartsWith('LEGACY_')) { $try = $try.Substring(7) }
		if ($byStrippedName.ContainsKey($try)) { $target = $byStrippedName[$try]; $sem = "(strip:$try)" }
	}
	if ($target -ne '') {
		$sp = $target.LastIndexOf('.')
		[void]$rows.Add([pscustomobject]@{ old=$c; cls=$target.Substring(0,$sp); ident=$target.Substring($sp+1); sem=$sem; status='ok' })
	} else {
		[void]$rows.Add([pscustomobject]@{ old=$c; cls=''; ident=''; sem=("cell" + $cellKey.Replace(',','x')); status='UNRESOLVED' })
		[void]$unresolved.Add("$c  cell=$cellKey ord=$v")
	}
}

$sb = New-Object Text.StringBuilder
[void]$sb.AppendLine('old_const,new_class,new_ident,source,status')
foreach ($r in $rows) { [void]$sb.AppendLine("$($r.old),$($r.cls),$($r.ident),$($r.sem),$($r.status)") }
[IO.File]::WriteAllText((Join-Path $repoRoot $OutCsv), $sb.ToString(), $utf8)

Write-Host ("resolved   : {0}" -f (($rows | Where-Object { $_.status -eq 'ok' }).Count))
Write-Host ("UNRESOLVED : {0}" -f $unresolved.Count)
if ($unresolved.Count -gt 0) { $unresolved | ForEach-Object { Write-Host ("  " + $_) } }
