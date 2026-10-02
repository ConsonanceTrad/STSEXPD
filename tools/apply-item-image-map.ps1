#   apply-item-image-map.ps1
#   Apply the hand-reviewed id backfill in tools/atlas-meta/items-image-map.csv to the
#   item classes: for every row with a `new_id`, rewrite (or insert) the class's
#   `image = <Dict>.<CONST>;` assignment to point at the dictionary entry with that id.
#
#   Handles three cases:
#     - the class already assigns `image`      -> that assignment is replaced
#     - the class assigns nothing (inherits)   -> an assignment is inserted at class top
#     - nothing to do (no new_id)              -> file untouched
#
#   Idempotent: running twice yields the same files.
#
#   Usage:
#     .\tools\apply-item-image-map.ps1 -WhatIf
#     .\tools\apply-item-image-map.ps1

param(
	[string]$MapCsv  = 'tools/atlas-meta/items-image-map.csv',
	[string]$IdTable = 'tools/atlas-meta/items-icon-id-table.csv',
	[switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path

# ---- id -> Dict.CONST ----
$byId = @{}
foreach ($r in (Import-Csv (Join-Path $repoRoot $IdTable))) {
	$byId[[int]$r.id] = $r
}
"id table: $($byId.Count) entries"

# ---- class -> superclass map, used to skip non-Item helper classes ----
$extendsOf = @{}
foreach ($f in (Get-ChildItem -Recurse -File -Filter '*.java' 'core/src/java/pd/items')) {
	$txt = [IO.File]::ReadAllText($f.FullName, $utf8)
	$m = [regex]::Match($txt, '(?:class|enum)\s+' + [regex]::Escape($f.BaseName) + '\s+extends\s+([A-Za-z0-9_.]+)')
	if ($m.Success) { $extendsOf[$f.BaseName] = ($m.Groups[1].Value -split '\.')[-1] }
}
function Test-IsItem([string]$cls) {
	$seen = @{}
	$c = $cls
	while ($c -and -not $seen.ContainsKey($c)) {
		$seen[$c] = $true
		if ($c -eq 'Item') { return $true }
		if (-not $extendsOf.ContainsKey($c)) { return $false }
		$c = $extendsOf[$c]
	}
	return $false
}

$rows = @(Import-Csv (Join-Path $repoRoot $MapCsv) | Where-Object { -not [string]::IsNullOrWhiteSpace($_.new_id) })
"rows with new_id: $($rows.Count)"

$rxImage = [regex]'(?<![\w.])image\s*=\s*[^;]+;'
$targets = New-Object System.Collections.ArrayList

foreach ($r in $rows) {
	$id = [int]$r.new_id
	if (-not $byId.ContainsKey($id)) { "  SKIP $($r.class): id $id not in table"; continue }
	$e = $byId[$id]
	$dict = $e.dict
	$const = $e.const
	$assign = "image = $dict.$const;"

	$file = Join-Path $repoRoot ($r.file -replace '/', '\')
	if (-not (Test-Path $file)) { "  SKIP $($r.class): file missing $($r.file)"; continue }

	# only classes inside pd.items get rewritten
	if ($r.file -notlike 'core/src/java/pd/items/*') { "  SKIP $($r.class): outside pd/items"; continue }
	# ...and only real Item subclasses (helper classes like CursedWand have no `image`)
	if (-not (Test-IsItem $r.class)) { "  SKIP $($r.class): not an Item subclass"; continue }

	$t = [IO.File]::ReadAllText($file, $utf8)
	$orig = $t

	# 1) replace the first `image = ...;`
	$m = $rxImage.Match($t)
	if ($m.Success) {
		$t = $t.Remove($m.Index, $m.Length).Insert($m.Index, $assign)
	} else {
		# 2) no assignment yet: insert an instance initializer block after the class brace,
		#    because a bare `image = ...;` is not a valid class-body statement
		$cm = [regex]::Match($t, '(?m)^(?:public\s+|final\s+|abstract\s+)*(?:class|enum)\s+\w+[^{]*\{')
		if (-not $cm.Success) { "  SKIP $($r.class): no class header"; continue }
		$t = $t.Insert($cm.Index + $cm.Length, "`n`t{`n`t`t$assign`n`t}")
	}

	# 3) ensure the dictionary is imported (same-package dictionaries need none)
	if ($t -notmatch ("(?m)^import pd\.atlas\.items\." + [regex]::Escape($dict) + ";")) {
		$imports = [regex]::Matches($t, '(?m)^import [^;]+;\r?\n')
		$imp = "import pd.atlas.items.$dict;`n"
		if ($imports.Count -gt 0) {
			$last = $imports[$imports.Count - 1]
			$t = $t.Insert($last.Index + $last.Length, $imp)
		} else {
			$pk = [regex]::Match($t, '(?m)^package [^;]+;\r?\n')
			if ($pk.Success) { $t = $t.Insert($pk.Index + $pk.Length, "`n$imp") }
		}
	}

	if ($t -ne $orig) {
		[void]$targets.Add([pscustomobject]@{ file = $file; cls = $r.class; id = $id; dict = "$dict.$const" })
		if (-not $WhatIf) { [IO.File]::WriteAllText($file, $t, $utf8) }
	}
}

"files changed: $($targets.Count)  (WhatIf=$WhatIf)"
''
'=== 前 15 个 ==='
$targets | Select-Object -First 15 | ForEach-Object { "  {0,-24} id={1,-5} {2}" -f $_.cls, $_.id, $_.dict }
''
'=== 按字典分组（前 15）==='
$targets | Group-Object { ($_.dict -split '\.')[0] } | Sort-Object { -$_.Count } | Select-Object -First 15 | ForEach-Object { "  {0,-46} {1}" -f $_.Name, $_.Count }
