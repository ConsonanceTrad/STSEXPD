#   export-icon-id-table.ps1
#   Extract the authoritative id -> (dict, const, atlas, rect) table from the generated
#   pd/atlas/items/*Dict.java files, and also render a per-atlas contact sheet with the
#   id printed under each icon, so ids can be matched to artwork by eye.
#
#   Usage:
#     .\tools\export-icon-id-table.ps1                       # csv only
#     .\tools\export-icon-id-table.ps1 -Sheets               # csv + contact sheets
#     .\tools\export-icon-id-table.ps1 -Sheets -Scale 4
#
#   Outputs:
#     tools/atlas-meta/items-icon-id-table.csv     id,dict,const,atlas,x,y,w,h
#     tools/atlas-meta/items-id-sheets/<slug>.png  one sheet per atlas

param(
	[string]$DictRoot = 'core/src/java/pd/atlas/items',
	[string]$AssetRoot = 'core/src/assets',
	[string]$OutCsv   = 'tools/atlas-meta/items-icon-id-table.csv',
	[string]$SheetDir = 'tools/atlas-meta/items-id-sheets',
	[switch]$Sheets,
	[int]$Scale       = 4,
	[int]$Cols        = 10,
	[int]$Pad         = 4,
	[int]$LabelH      = 11
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path

# public static final IconEntry NAME = new IconEntry("atlas", new int[]{x, y, w, h}, id);
$rx = [regex]'public static final IconEntry\s+(\w+)\s*=\s*new IconEntry\("([^"]+)",\s*new int\[\]\s*\{\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\}\s*,\s*(\d+)\s*\);'

$rows = New-Object System.Collections.ArrayList
foreach ($f in (Get-ChildItem -File -Filter '*Dict.java' $DictRoot | Sort-Object Name)) {
	$dict = $f.BaseName
	foreach ($line in [IO.File]::ReadAllLines($f.FullName, $utf8)) {
		$m = $rx.Match($line)
		if (-not $m.Success) { continue }
		[void]$rows.Add([pscustomobject]@{
			id    = [int]$m.Groups[7].Value
			dict  = $dict
			const = $m.Groups[1].Value
			atlas = $m.Groups[2].Value
			x     = [int]$m.Groups[3].Value
			y     = [int]$m.Groups[4].Value
			w     = [int]$m.Groups[5].Value
			h     = [int]$m.Groups[6].Value
		})
	}
}

$sorted = $rows | Sort-Object id
"entries: $($sorted.Count)   id range: $(($sorted | Measure-Object id -Minimum).Minimum)..$(($sorted | Measure-Object id -Maximum).Maximum)"

# duplicate id check
$dups = @($sorted | Group-Object id | Where-Object { $_.Count -gt 1 })
if ($dups.Count -gt 0) { "WARNING duplicate ids: $($dups.Count)" }

$sb = New-Object Text.StringBuilder
[void]$sb.AppendLine('id,dict,const,atlas,x,y,w,h')
foreach ($r in $sorted) { [void]$sb.AppendLine("$($r.id),$($r.dict),$($r.const),$($r.atlas),$($r.x),$($r.y),$($r.w),$($r.h)") }
[IO.File]::WriteAllText((Join-Path $repoRoot $OutCsv), $sb.ToString(), $utf8)
"csv written: $OutCsv"

if (-not $Sheets) { return }

# ---------------- contact sheets ----------------
Add-Type -AssemblyName System.Drawing
if (-not (Test-Path (Join-Path $repoRoot $SheetDir))) { New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot $SheetDir) | Out-Null }

$icon = [int](16 * $Scale)
$cellW = [int]($icon + $Pad * 2)
$cellH = [int]($icon + $LabelH + $Pad * 2)
$font = New-Object Drawing.Font('Consolas', 8, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.Brushes]::Black
$bg = [Drawing.Brushes]::White

$byAtlas = $sorted | Group-Object atlas | Sort-Object Name
$made = 0
foreach ($g in $byAtlas) {
	$atlasRel = $g.Name                                     # sprites/items/xxx.png
	$pngPath = Join-Path $repoRoot ((Join-Path $AssetRoot $atlasRel) -replace '/', '\')
	if (-not (Test-Path $pngPath)) { "  MISSING atlas: $atlasRel"; continue }

	$src = [Drawing.Image]::FromFile($pngPath)
	$list = @($g.Group | Sort-Object id)
	$n = $list.Count
	$nCols = [Math]::Min($Cols, [Math]::Max(1, $n))
	$nRows = [int][Math]::Ceiling($n / $nCols)

	$bmpW = [int]($nCols * $cellW)
	$bmpH = [int]($nRows * $cellH)
	$bmp = New-Object Drawing.Bitmap($bmpW, $bmpH)
	$gfx = [Drawing.Graphics]::FromImage($bmp)
	$gfx.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$gfx.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$gfx.Clear([Drawing.Color]::White)

	$i = 0
	foreach ($r in $list) {
		$c = [int]($i % $nCols); $row = [int]($i / $nCols); $i++
		$ox = [int]($c * $cellW + $Pad)
		$oy = [int]($row * $cellH + $Pad)
		$dst = New-Object Drawing.Rectangle($ox, $oy, $icon, $icon)
		$srcRect = New-Object Drawing.Rectangle([int]$r.x, [int]$r.y, [int]$r.w, [int]$r.h)
		try { $gfx.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel) } catch { }
		# id label centered under the icon
		$label = "$($r.id)"
		$sz = $gfx.MeasureString($label, $font)
		$cellLeft = [int]($c * $cellW)
		$lx = [single]($ox + ($icon - $sz.Width) / 2)
		if ($lx -lt $cellLeft) { $lx = [single]$cellLeft }
		$gfx.DrawString($label, $font, $brush, $lx, [single]($oy + $icon))
	}
	$gfx.Dispose()
	$src.Dispose()

	$slug = ($atlasRel -replace '^sprites/items/', '') -replace '\.png$', '' -replace '/', '__'
	$outPng = Join-Path (Join-Path $repoRoot $SheetDir) "$slug.png"
	$bmp.Save($outPng, [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	$made++
	"  $slug.png   ($n entries)"
}
"sheets: $made"
