#   pick-chasm-water.ps1
#   Side-by-side contact sheet of the candidate frames from BOTH families, each
#   captioned with atlas + frame + (row,col), so we can pick "chasm above water".

param(
	[string]$OutDir = 'tools/atlas-meta/tiles-diag',
	[int]$Scale = 12
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path

$items = @(
	@{ atlas='core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png'; f=30; note='sps r2c15' },
	@{ atlas='core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png'; f=31; note='sps r2c16' },
	@{ atlas='core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png'; f=46; note='sps r3c15' },
	@{ atlas='core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png'; f=47; note='sps r3c16 TREE?' },
	@{ atlas='core\src\assets\environment\tiles\tiles_sewers.png';            f=28; note='broken r2c13' },
	@{ atlas='_ref\STSEXPD-java\core\src\main\assets\environment\tiles_sewers.png'; f=28; note='ref-sps f28' }
)

$cell = 16 * $Scale
$pad = 14
$labelH = 30
$w = $items.Count * ($cell + $pad) + $pad
$h = $cell + $pad + $labelH

$bmp = New-Object Drawing.Bitmap($w, $h)
$g = [Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([Drawing.Color]::FromArgb(255, 245, 245, 250))

$font = New-Object Drawing.Font('Consolas', 10, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$fontS = New-Object Drawing.Font('Consolas', 8, [Drawing.GraphicsUnit]::Pixel)
$border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 200, 60, 60), 2)

for ($i = 0; $i -lt $items.Count; $i++) {
	$it = $items[$i]
	$full = Join-Path $repoRoot $it.atlas
	if (-not (Test-Path $full)) { continue }
	$src = [System.Drawing.Bitmap]::FromFile($full)
	$cols = [int]($src.Width / 16)
	$f = [int]$it.f
	$cx = $f % $cols
	$cy = [int][Math]::Floor($f / $cols)
	$ox = $pad + $i * ($cell + $pad)
	$g.FillRectangle([Drawing.Brushes]::White, $ox, $pad, $cell, $cell)
	$dst = New-Object Drawing.Rectangle($ox, $pad, $cell, $cell)
	$srcRect = New-Object Drawing.Rectangle(($cx * 16), ($cy * 16), 16, 16)
	$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
	$g.DrawRectangle($border, $ox, $pad, $cell, $cell)
	$g.DrawString("f$f", $font, [Drawing.Brushes]::Black, [single]$ox, [single]($pad + $cell + 2))
	$g.DrawString($it.note, $fontS, [Drawing.Brushes]::DarkBlue, [single]$ox, [single]($pad + $cell + 15))
	$src.Dispose()
}

$out = Join-Path (Join-Path $repoRoot $OutDir) 'pick_chasm_water.png'
$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"saved: $out"
