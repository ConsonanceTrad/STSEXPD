#   verify-chasm-water.ps1
#   Render the two frames the user pointed at, side by side, for visual check.
#     broken-prefixed atlas (tiles_sewers.png)   : row2 col13 -> xy(13,2) = 28
#     sps-prefixed atlas  (sps_tiles_*_legacy)   : row2 col15 -> xy(15,2) = 30

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
	$font = New-Object Drawing.Font('Consolas', 11, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
	$border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 200, 60, 60), 2)
	for ($i = 0; $i -lt $frames.Count; $i++) {
		$f = $frames[$i]
		$cx = [int]($f % 16)
		$cy = [int][Math]::Floor($f / 16)
		$ox = $pad + $i * ($cell + $pad)
		$g.FillRectangle([Drawing.Brushes]::White, $ox, $pad, $cell, $cell)
		$dst = New-Object Drawing.Rectangle($ox, $pad, $cell, $cell)
		$srcRect = New-Object Drawing.Rectangle(($cx * 16), ($cy * 16), 16, 16)
		$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
		$g.DrawRectangle($border, $ox, $pad, $cell, $cell)
		$g.DrawString("f$f (r$($cy+1)c$($cx+1))", $font, [Drawing.Brushes]::Black, [single]$ox, [single]($pad + $cell + 4))
	}
	$out = Join-Path (Join-Path $repoRoot $OutDir) "chasmwater_$tag.png"
	$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose(); $src.Dispose(); $bmp.Dispose()
	"  chasmwater_$tag.png  frames=$($frames -join ',')"
}

'--- sps-prefixed atlases: expect row2 col15 -> frame 30 ---'
Render-One 'core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png' @(30) 'sps_sewers'
Render-One 'core\src\assets\environment\tiles\sps_tiles_caves_legacy.png'  @(30) 'sps_caves'
Render-One 'core\src\assets\environment\tiles\sps_tiles_prison_legacy.png' @(30) 'sps_prison'

'--- broken-prefixed atlases: expect row2 col13 -> frame 28 ---'
Render-One '_ref\STSEXPD-java\core\src\main\assets\environment\tiles_sewers.png' @(28) 'ref_sewers'
foreach ($t in @('sewers','prison','caves','city','halls')) {
	$p = "core\src\assets\environment\tiles_$t.png"
	Render-One $p @(28) "broken_$t"
}
