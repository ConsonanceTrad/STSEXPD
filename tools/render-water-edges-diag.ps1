#   render-water-edges-diag.ps1
#   Diagnostics for the SpsWaterEdgesTilemap stitch logic.
#
#   Outputs into tools/atlas-meta/water-edges-diag/:
#     frames_<atlas>.png      the raw atlas scaled up, with frame index + (col,row) under each
#     sim_<atlas>.png         a synthetic water+mixed terrain mapped through the SAME stitch
#                             rule the game uses, so a wrong edge is visible at a glance
#     legend.png              frame index -> stitch bits (+1 up / +2 right / +4 down / +8 left)
#
#   The stitch rule mirrors SpsWaterEdgesTilemap:
#       t = 0
#       if unstitchable(up)    t += 1
#       if unstitchable(right) t += 2
#       if unstitchable(down)  t += 4
#       if unstitchable(left)  t += 8
#       frame = t          (15 = water centre, drawn by the water layer instead)

param(
	[string]$AtlasDir = 'core/src/assets/environment/water',
	[string]$OutDir   = 'tools/atlas-meta/water-edges-diag',
	[int]$Scale       = 6,
	[int]$LabelH      = 12
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path
Add-Type -AssemblyName System.Drawing

$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$font = New-Object Drawing.Font('Consolas', 7, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.Brushes]::Black
$gridPen = New-Object Drawing.Pen([Drawing.Color]::FromArgb(120, 140, 140, 140), 1)
$labelBg = [Drawing.Brushes]::WhiteSmoke
$waterBrush = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 40, 60, 80))

$atlases = @(Get-ChildItem $AtlasDir -File -Filter 'sps_water_edges_*.png' | Sort-Object Name)
"atlases: $($atlases.Count)"

# ---------------- A. atlas frames with id + coords ----------------
foreach ($a in $atlases) {
	$src = [Drawing.Image]::FromFile($a.FullName)
	$frames = [int]($src.Width / 16)
	$cell = 16 * $Scale
	$bmp = New-Object Drawing.Bitmap([int]($frames * ($cell + 8)), [int]($cell + $LabelH + 8))
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::White)
	for ($i = 0; $i -lt $frames; $i++) {
		$ox = [int](4 + $i * ($cell + 8))
		$oy = 4
		$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)
		$srcRect = New-Object Drawing.Rectangle([int]($i * 16), 0, 16, 16)
		$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
		# NOTE: no grid line drawn over the tile itself -- an overlay rectangle would
		# look like an edge and make the frame content unreadable.
		$txt = "f$i"
		$g.FillRectangle($labelBg, $ox, [int]($oy + $cell), 22, 10)
		$g.DrawString($txt, $font, $brush, [single]$ox, [single]($oy + $cell))
	}
	$g.Dispose(); $src.Dispose()
	$name = ($a.BaseName -replace '^sps_water_edges_', '')
	$bmp.Save((Join-Path $outFull "frames_$name.png"), [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	"  frames_$name.png  ($frames frames)"
}

# ---------------- B. simulated terrain ----------------
# w = water, . = plain floor (stitchable), # = wall/solid (unstitchable), C = chasm
# every cell is water -> we only need to know which neighbours are unstitchable
$maps = @{
	'edges_straight' = @(
		'#####',
		'#www#',
		'#www#',
		'#####'
	)
	'edges_corner'   = @(
		'####.',
		'#www.',
		'#www.',
		'.....'
	)
	'edges_mixed'    = @(
		'..#..',
		'.ww#.',
		'#ww#.',
		'..w..'
	)
	'edges_island'   = @(
		'.....',
		'.www.',
		'.w.w.',
		'.www.',
		'.....'
	)
	'edges_chasm'    = @(
		'..C..',
		'.wwC.',
		'Cww..',
		'..w.C'
	)
}

foreach ($key in ($maps.Keys | Sort-Object)) {
	$rows = $maps[$key]
	$h = $rows.Count
	$w = $rows[0].Length
	$cell = 16 * $Scale
	$pad = 18
	$bmp = New-Object Drawing.Bitmap([int]($w * $cell + $pad * 2), [int]($h * $cell + $pad * 2 + 14))
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::White)

	# base layer (scale up the first atlas so plain water is visible under the edges)
	$base = [Drawing.Image]::FromFile((Join-Path (Join-Path $repoRoot $AtlasDir) 'sps_water_edges_halls.png'))

	for ($y = 0; $y -lt $h; $y++) {
		for ($x = 0; $x -lt $w; $x++) {
			$ox = [int]($pad + $x * $cell)
			$oy = [int]($pad + $y * $cell)
			$ch = $rows[$y][$x]
			if ($ch -eq 'w') {
				# opaque water base so the edge overlay reads correctly
				$g.FillRectangle($waterBrush, $ox, $oy, $cell, $cell)
				# stitch bits, same rule as SpsWaterEdgesTilemap
				$t = 0
				if (($y - 1 -lt 0) -or ($rows[$y-1][$x] -ne 'w')) { $t += 1 }
				if (($x + 1 -ge $w) -or ($rows[$y][$x+1] -ne 'w')) { $t += 2 }
				if (($y + 1 -ge $h) -or ($rows[$y+1][$x] -ne 'w')) { $t += 4 }
				if (($x - 1 -lt 0) -or ($rows[$y][$x-1] -ne 'w')) { $t += 8 }
				$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)
				$srcRect = New-Object Drawing.Rectangle([int]($t * 16), 0, 16, 16)
				$g.DrawImage($base, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
			}
			# coord label only -- a grid overlay would read as a drawn edge
			$label = "$x,$y"
			$g.FillRectangle($labelBg, $ox, $oy, 24, 10)
			$g.DrawString($label, $font, $brush, [single]$ox, [single]$oy)
			# terrain char under the cell
			$g.DrawString($ch, $font, $brush, [single]($ox + 2), [single]($oy + $cell - 10))
		}
	}
	$g.Dispose(); $base.Dispose()
	$bmp.Save((Join-Path $outFull "sim_$key.png"), [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	"  sim_$key.png  (${w}x$h)"
}

# ---------------- C. legend ----------------
$legend = @(
	@('f0',  'water, but all 4 sides stitchable'),
	@('f1',  '+1 up is solid/chasm'),
	@('f2',  '+2 right is solid/chasm'),
	@('f3',  '+1+2 up+right'),
	@('f4',  '+4 down is solid/chasm'),
	@('f5',  '+1+4 up+down'),
	@('f6',  '+2+4 right+down'),
	@('f7',  '+1+2+4 up+right+down'),
	@('f8',  '+8 left is solid/chasm'),
	@('f9',  '+1+8 up+left'),
	@('f10', '+2+8 right+left'),
	@('f11', '+1+2+8 up+right+left'),
	@('f12', '+4+8 down+left'),
	@('f13', '+1+4+8 up+down+left'),
	@('f14', '+2+4+8 right+down+left'),
	@('f15', 'water CENTRE, skipped by this layer')
)
$bmp = New-Object Drawing.Bitmap([int](420), [int](18 * $legend.Count + 8))
$g = [Drawing.Graphics]::FromImage($bmp)
$g.Clear([Drawing.Color]::White)
$g.DrawString('frame  meaning  (+1 up / +2 right / +4 down / +8 left)', $font, $brush, [single]4, [single]2)
$i = 0
foreach ($row in $legend) {
	$y = [int](14 + $i * 18)
	$g.DrawString($row[0], $font, $brush, [single]4, [single]$y)
	$g.DrawString($row[1], $font, $brush, [single]40, [single]$y)
	$i++
}
$g.Dispose()
$bmp.Save((Join-Path $outFull 'legend.png'), [Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
'  legend.png'

''
"output: $OutDir"
