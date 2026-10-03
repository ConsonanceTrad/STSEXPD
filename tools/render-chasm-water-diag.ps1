#   render-chasm-water-diag.ps1
#   Diagnostics for "water next to CHASM" in SpsWaterEdgesTilemap.
#
#   Background: the current implementation uses a BLACKLIST of unstitchable
#   terrain and the list contains CHASM, so water next to chasm gets a water
#   edge drawn. The reference SPS uses a WHITELIST
#   (DungeonTileSheet.waterStitcheable) which does NOT contain CHASM, so water
#   next to chasm should be drawn with no edge on that side.
#
#   This script renders the same synthetic map under both rules and puts a RED
#   BOX around every water cell that touches a chasm, so the difference is
#   obvious at a glance.
#
#   W = water   C = chasm   . = plain floor (stitchable)   # = wall

param(
	[string]$AtlasDir = 'core/src/assets/environment/water',
	[string]$Atlas    = 'sps_water_edges_caves.png',
	[string]$OutDir   = 'tools/atlas-meta/water-edges-diag',
	[int]$Scale       = 8
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path

$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$font    = New-Object Drawing.Font('Consolas', 7, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$fontB   = New-Object Drawing.Font('Consolas', 8, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$black   = [Drawing.Brushes]::Black
$labelBg = [Drawing.Brushes]::WhiteSmoke
$floorBr = [Drawing.Brushes]::Gainsboro
$waterBr = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 40, 60, 80))
$chasmBr = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 12, 12, 16))
$redPen  = New-Object Drawing.Pen([Drawing.Color]::Red, 2)

# synthetic map: chasm and water interleaved, covering up/right/down/left neighbours
$rows = @(
	'.C...C.',
	'CWWC.W.',
	'.WWCWW.',
	'CWWWCC.',
	'..C.W..',
	'.CWWWC.',
	'...C...'
)
$h = $rows.Count
$w = $rows[0].Length
$cell = 16 * $Scale
$pad = 20
$titleH = 18

$src = [Drawing.Image]::FromFile((Join-Path (Join-Path $repoRoot $AtlasDir) $Atlas))

function Render-Variant([bool]$chasmUnstitchable, [string]$suffix) {

	$bmpW = [int]($w * $cell + $pad * 2)
	$bmpH = [int]($h * $cell + $pad * 2 + $titleH + 16)
	$bmp = New-Object Drawing.Bitmap($bmpW, $bmpH)
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::White)

	$caption = if ($chasmUnstitchable) { "CURRENT: blacklist, chasm = unstitchable (edge drawn)" } else { "REFERENCE: whitelist, chasm = stitcheable (no edge)" }
	$g.DrawString($caption, $fontB, $black, [single]4, [single]2)

	$weights = @{ up = 1; right = 2; down = 4; left = 8 }

	for ($y = 0; $y -lt $h; $y++) {
		for ($x = 0; $x -lt $w; $x++) {
			$ox = [int]($pad + $x * $cell)
			$oy = [int]($pad + $y * $cell + $titleH)
			$ch = $rows[$y][$x]

			# neighbour terrain letters; off-map counts as chasm
			$up = 'C';    if ($y - 1 -ge 0)  { $up    = $rows[$y-1][$x] }
			$right = 'C'; if ($x + 1 -lt $w) { $right = $rows[$y][$x+1] }
			$down = 'C';  if ($y + 1 -lt $h) { $down  = $rows[$y+1][$x] }
			$left = 'C';  if ($x - 1 -ge 0)  { $left  = $rows[$y][$x-1] }

			if ($ch -eq 'C') {
				$g.FillRectangle($chasmBr, $ox, $oy, $cell, $cell)
			} elseif ($ch -eq 'W') {
				$g.FillRectangle($waterBr, $ox, $oy, $cell, $cell)

				$t = 0
				foreach ($dir in @('up', 'right', 'down', 'left')) {
					$nb = Get-Variable -Name $dir -ValueOnly
					if ($nb -eq 'W') { continue }
					if ($nb -eq 'C' -and -not $chasmUnstitchable) { continue }
					$t += $weights[$dir]
				}

				# frame index == bit weight (15 = water centre, this layer skips it)
				if ($t -ne 15) {
					$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)
					$srcRect = New-Object Drawing.Rectangle([int]($t * 16), 0, 16, 16)
					$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
				}
			} else {
				$g.FillRectangle($floorBr, $ox, $oy, $cell, $cell)
			}

			# RED BOX: water cell that touches a chasm (the disputed ones)
			if ($ch -eq 'W') {
				$touches = $false
				if ($up -eq 'C' -or $right -eq 'C' -or $down -eq 'C' -or $left -eq 'C') { $touches = $true }
				if ($touches) {
					$g.DrawRectangle($redPen, [int]($ox + 1), [int]($oy + 1), [int]($cell - 2), [int]($cell - 2))
				}
			}

			$g.FillRectangle($labelBg, $ox, $oy, 24, 10)
			$g.DrawString("$x,$y", $font, $black, [single]$ox, [single]$oy)
			$g.DrawString($ch, $fontB, $black, [single]($ox + 2), [single]($oy + $cell - 12))
		}
	}

	$out = Join-Path $outFull "chasm_water_$suffix.png"
	$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose(); $bmp.Dispose()
	"  chasm_water_$suffix.png  (${w}x$h)"
}

Render-Variant $true  'current_blacklist'
Render-Variant $false 'reference_whitelist'

$src.Dispose()
''
"output: $OutDir"
