#   verify-chasm-water2.ps1
#   Render frames 28..31 of both atlas families side by side so we can pick the
#   "chasm edge above water" visual.
#     broken family : core/src/assets/environment/tiles/tiles_<region>.png
#     sps family    : core/src/assets/environment/tiles/sps_tiles_<region>_legacy.png

param(
	[string]$OutDir = 'tools/atlas-meta/tiles-diag',
	[int]$Scale = 12
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path

function Render-One([string]$atlas, [int[]]$frames, [string]$tag) {
	$full = Join-Path $repoRoot $atlas
	if (-not (Test-Path $full)) { "  MISSING: $atlas"; return }
	$src = [System.Drawing.Bitmap]::FromFile($full)
	$cell = 16 * $Scale
	$pad = 14
	$labelH = 24
	$w = $frames.Count * ($cell + $pad) + $pad
	$h = $cell + $pad + $labelH
	$bmp = New-Object Drawing.Bitmap($w, $h)
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::FromArgb(255, 245, 245, 250))
	$font = New-Object Drawing.Font('Consolas', 10, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
	$border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 200, 60, 60), 2)
	$cols = [int]($src.Width / 16)
	for ($i = 0; $i -lt $frames.Count; $i++) {
		$f = $frames[$i]
		$cx = [int]($f % $cols)
		$cy = [int][Math]::Floor($f / $cols)
		$ox = $pad + $i * ($cell + $pad)
		$g.FillRectangle([Drawing.Brushes]::White, $ox, $pad, $cell, $cell)
		$dst = New-Object Drawing.Rectangle($ox, $pad, $cell, $cell)
		$srcRect = New-Object Drawing.Rectangle(($cx * 16), ($cy * 16), 16, 16)
		$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
		$g.DrawRectangle($border, $ox, $pad, $cell, $cell)
		$g.DrawString("f$f", $font, [Drawing.Brushes]::Black, [single]$ox, [single]($pad + $cell + 2))
		$g.DrawString("r$($cy+1)c$($cx+1)", (New-Object Drawing.Font('Consolas', 8, [Drawing.GraphicsUnit]::Pixel)), [Drawing.Brushes]::DarkBlue, [single]$ox, [single]($pad + $cell + 13))
	}
	$out = Join-Path (Join-Path $repoRoot $OutDir) "cw2_$tag.png"
	$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose(); $src.Dispose(); $bmp.Dispose()
	"  cw2_$tag.png"
}

'--- sps family, frames 28..31 (row2 col13..16) ---'
Render-One 'core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png' @(28,29,30,31) 'sps_sewers'

'--- broken family, frames 28..31 (row2 col13..16) ---'
Render-One 'core\src\assets\environment\tiles\tiles_sewers.png' @(28,29,30,31) 'broken_sewers'
