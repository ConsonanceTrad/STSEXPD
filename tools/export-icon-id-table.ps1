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
	[int]$LabelH      = 30
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

$font = New-Object Drawing.Font('Consolas', 8, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.Brushes]::Black
$gridPen = New-Object Drawing.Pen([Drawing.Color]::FromArgb(80, 170, 170, 170), 1)
$labelBg = [Drawing.Brushes]::WhiteSmoke

$byAtlas = $sorted | Group-Object atlas | Sort-Object Name
$made = 0
foreach ($g in $byAtlas) {
	$atlasRel = $g.Name                                     # sprites/items/xxx.png
	$pngPath = Join-Path $repoRoot ((Join-Path $AssetRoot $atlasRel) -replace '/', '\')
	if (-not (Test-Path $pngPath)) { "  MISSING atlas: $atlasRel"; continue }

	$src = [Drawing.Image]::FromFile($pngPath)
	$srcW = [int]$src.Width
	$srcH = [int]$src.Height
	$list = @($g.Group | Sort-Object { [int]$_.id })

	# ORIGINAL LAYOUT PRESERVED: the atlas scaled up as-is, with a label strip added on top.
	$sheetW = [int]($srcW * $Scale)
	$sheetH = [int]([int]($srcH * $Scale) + $LabelH)
	$bmp = New-Object Drawing.Bitmap($sheetW, $sheetH)
	$gfx = [Drawing.Graphics]::FromImage($bmp)
	$gfx.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$gfx.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$gfx.Clear([Drawing.Color]::White)
	$gfx.FillRectangle($labelBg, 0, 0, $sheetW, $LabelH)
	# atlas drawn at its own coordinates, shifted down by the strip height
	$gfx.DrawImage($src, 0, $LabelH, $sheetW, [int]($srcH * $Scale))

	# 16px cell grid over the atlas area, to make rect edges readable
	for ($gx = 16; $gx -lt $srcW; $gx += 16) {
		$px = [int]($gx * $Scale)
		$gfx.DrawLine($gridPen, $px, $LabelH, $px, [int]($sheetH - 1))
	}
	for ($gy = 16; $gy -lt $srcH; $gy += 16) {
		$py = [int]([int]$LabelH + $gy * $Scale)
		$gfx.DrawLine($gridPen, 0, $py, [int]($sheetW - 1), $py)
	}

	# id printed in the top strip, aligned above its icon's left edge;
	# entries sharing a column stack downward so nothing is hidden
	$perCol = @{}
	foreach ($r in $list) {
		$colX = [int]([int]$r.x * $Scale)
		$line = 0
		if ($perCol.ContainsKey($colX)) { $line = $perCol[$colX] }
		$perCol[$colX] = $line + 1
		$ly = [int]($line * 9)
		if (($ly + 9) -gt $LabelH) { $ly = [Math]::Max(0, $LabelH - 9) }
		$gfx.DrawString("$($r.id)", $font, $brush, [single]$colX, [single]$ly)
	}
	$gfx.Dispose()
	$src.Dispose()

	$slug = ($atlasRel -replace '^sprites/items/', '') -replace '\.png$', '' -replace '/', '__'
	$bmp.Save((Join-Path (Join-Path $repoRoot $SheetDir) "$slug.png"), [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	$made++
	"  $slug.png   ($($list.Count) entries, ${srcW}x${srcH})"
}
"sheets: $made"
