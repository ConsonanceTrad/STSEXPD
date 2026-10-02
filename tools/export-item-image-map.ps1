#   export-item-image-map.ps1
#   Build a full item -> icon mapping table for manual review/backfill.
#
#   Every class under pd/items that declares an `image =` assignment is listed, together
#   with the icon it currently points at (resolved to the dictionary id), so that:
#     - already-mapped items can be spot-checked for wrong/misaligned icons
#     - placeholder items can be filled in by typing the target id into `new_id`
#
#   status:
#     filled       image = <Some>Dict.<CONST>          (current_id resolved from the table)
#     placeholder  image = SpecificPlaceHolderDict.SOMETHING_0
#     no-image     the class has no `image =` of its own (inherits from its parent)
#
#   Output: tools/atlas-meta/items-image-map.csv
#     class,cn_name,status,current_const,current_id,current_atlas,extends,package,file,new_id

param(
	[string]$ItemRoot = 'core/src/java/pd/items',
	[string]$IdTable  = 'tools/atlas-meta/items-icon-id-table.csv',
	[string]$OutCsv   = 'tools/atlas-meta/items-image-map.csv'
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path

# ---- id lookup: dict.const -> row ----
$ids = @{}
foreach ($r in (Import-Csv (Join-Path $repoRoot $IdTable))) {
	$k = "$($r.dict).$($r.const)"
	$ids[$k] = $r
}
"id table rows: $($ids.Count)"

# ---- alias map: dict.alias -> dict.target (multi-frame aliases)
#      e.g. public static final IconEntry ARTIFACT_HORN1 = HORN_OF_PLENTY_0; ----
$rxAlias = [regex]'public static final IconEntry\s+(\w+)\s*=\s*(\w+)\s*;'
$alias = @{}
foreach ($f in (Get-ChildItem -File -Filter '*Dict.java' 'core/src/java/pd/atlas/items')) {
	$dict = $f.BaseName
	foreach ($line in [IO.File]::ReadAllLines($f.FullName, $utf8)) {
		$m = $rxAlias.Match($line)
		if ($m.Success) { $alias["$dict.$($m.Groups[1].Value)"] = "$dict.$($m.Groups[2].Value)" }
	}
}
"alias rows: $($alias.Count)"

# ---- walk item classes ----
$rxImage = [regex]'image\s*=\s*(?:([A-Za-z0-9_]+)\.)?([A-Za-z0-9_]+)\s*;'
$rxName = [regex]'\.t\("name",\s*"((?:[^"\\]|\\.)*)"\)'
$rxExt = [regex]'(?:class|enum)\s+(\w+)\s+extends\s+([A-Za-z0-9_.]+)'
$rxPkg = [regex]'(?m)^package\s+([^;]+);'

$rows = New-Object System.Collections.ArrayList
foreach ($f in (Get-ChildItem -Recurse -File -Filter '*.java' $ItemRoot | Sort-Object FullName)) {
	$t = [IO.File]::ReadAllText($f.FullName, $utf8)
	$cls = $f.BaseName
	$rel = $f.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
	$pkg = $rxPkg.Match($t).Groups[1].Value.Trim()

	# class-level (not inner) `image = ...` — take the first assignment
	$curConst = ''; $curId = ''; $curAtlas = ''; $status = 'no-image'
	$m = $rxImage.Match($t)
	if ($m.Success) {
		$owner = $m.Groups[1].Value       # may be empty for `image = SOMETHING_0`
		$name = $m.Groups[2].Value
		if ($owner -and $owner -like '*PlaceHolder*') {
			$curConst = "$owner.$name"; $status = 'placeholder'
		} elseif ($owner -eq 'SpecificPlaceHolderDict') {
			$curConst = "$owner.$name"; $status = 'placeholder'
		} elseif ($owner) {
			$key = "$owner.$name"
			$curConst = $key
			# follow alias chains (e.g. ARTIFACT_HORN1 -> HORN_OF_PLENTY_0)
			$resolved = $key
			$guard = 0
			while (-not $ids.ContainsKey($resolved) -and $alias.ContainsKey($resolved) -and $guard -lt 8) {
				$resolved = $alias[$resolved]
				$guard++
			}
			if ($resolved -ne $key) { $curConst = "$key -> $resolved" }
			if ($ids.ContainsKey($resolved)) {
				$curId = $ids[$resolved].id; $curAtlas = $ids[$resolved].atlas; $status = 'filled'
			} else { $status = 'unknown-const' }
		} else {
			# bare name, e.g. image = SOMETHING_0
			$curConst = $name; $status = 'placeholder'
		}
	}

	$cn = ''
	$mn = $rxName.Match($t)
	if ($mn.Success) { $cn = $mn.Groups[1].Value }

	$ext = ''
	$me = $rxExt.Match($t)
	if ($me.Success) { $ext = ($me.Groups[2].Value -split '\.')[-1] }

	[void]$rows.Add([pscustomobject]@{
		class = $cls; cn_name = $cn; status = $status
		current_const = $curConst; current_id = $curId; current_atlas = $curAtlas
		extends = $ext; package = $pkg; file = $rel; new_id = ''
	})
}

$by = $rows | Group-Object status | Sort-Object Name
"classes: $($rows.Count)"
$by | ForEach-Object { "  {0,-14} {1}" -f $_.Name, $_.Count }

$sb = New-Object Text.StringBuilder
[void]$sb.AppendLine('class,cn_name,status,current_const,current_id,current_atlas,extends,package,file,new_id')
foreach ($r in ($rows | Sort-Object package, class)) {
	[void]$sb.AppendLine("$($r.class),$($r.cn_name),$($r.status),$($r.current_const),$($r.current_id),$($r.current_atlas),$($r.extends),$($r.package),$($r.file),$($r.new_id)")
}
[IO.File]::WriteAllText((Join-Path $repoRoot $OutCsv), $sb.ToString(), $utf8)
"csv written: $OutCsv"
