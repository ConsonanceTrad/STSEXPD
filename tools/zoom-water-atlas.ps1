#   zoom-water-atlas.ps1
#   Blow up every frame of one water-edge atlas so the content is readable,
#   with the frame index printed under each cell.
#
#   Usage: .\tools\zoom-water-atlas.ps1 -Atlas sps_water_edges_sewers.png [-Scale 10]

param(
	[string]$AtlasDir = 'core/src/assets/environment/water',
	[string]$Atlas    = 'sps_water_edges_sewers.png',
	[string]$OutDir   = 'tools/atlas-meta/water-edges-diag',
	[int]$Scale       = 10
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path

$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$src = [Drawing.Image]::FromFile((Join-Path (Join-Path $repoRoot $AtlasDir) $Atlas))
$frames = [int]($src.Width / 16)
$cell = 16 * $Scale
$pad = 10
$labelH = 22

$colsPerRow = 8
$rowsOfImg = [Math]::Ceiling($frames / $colsPerRow)

$bmpW = [int]($colsPerRow * ($cell + $pad) + $pad)
$bmpH = [int]($rowsOfImg * ($cell + $pad + $labelH) + $pad)
$bmp = New-Object Drawing.Bitmap($bmpW, $bmpH)
$g = [Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([Drawing.Color]::FromArgb(255, 245, 245, 250))

$font = New-Object Drawing.Font('Consolas', 10, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
$fontTx = New-Object Drawing.Font('Consolas', 8, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$black = [Drawing.Brushes]::Black
$blue = [Drawing.Brushes]::DarkBlue
$border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 90, 90, 90), 1)

for ($i = 0; $i -lt $frames; $i++) {
	$cx = [int]($i % $colsPerRow)
	$cy = [int][Math]::Floor($i / $colsPerRow)
	$ox = [int]($pad + $cx * ($cell + $pad))
	$oy = [int]($pad + $cy * ($cell + $pad + $labelH))

	# opaque white behind the frame so transparency is visible as white, not black
	$g.FillRectangle([Drawing.Brushes]::White, $ox, $oy, $cell, $cell)
	$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)
	$srcRect = New-Object Drawing.Rectangle([int]($i * 16), 0, 16, 16)
	$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
	$g.DrawRectangle($border, $ox, $oy, $cell, $cell)

	$bits = @()
	if (($i -band 1) -ne 0) { $bits += 'up' }
	if (($i -band 2) -ne 0) { $bits += 'right' }
	if (($i -band 4) -ne 0) { $bits += 'down' }
	if (($i -band 8) -ne 0) { $bits += 'left' }
	$desc = 'none (plain water)'
	if ($bits.Count -gt 0) { $desc = $bits -join '+' }
	if ($i -eq 15) { $desc = 'all 4 (centre, skipped)' }

	$g.DrawString("f$i", $font, $black, [single]$ox, [single]($oy + $cell + 2))
	$g.DrawString($desc, $fontTx, $blue, [single]($ox + 24), [single]($oy + $cell + 4))
}

$out = Join-Path $outFull ("zoom_" + ($Atlas -replace '\.png$', '') + ".png")
$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $src.Dispose(); $bmp.Dispose()
"saved: $out  ($frames frames)"
