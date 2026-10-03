#   find-chasm-water-frame.ps1
#   Look through every frame of the project's SPS legacy tiles atlas for the
#   "chasm edge above water" visual and print the frames whose bottom half is
#   water-like (blue-ish) while the top half has the dark chasm lip.
#
#   Usage: .\tools\find-chasm-water-frame.ps1 -Atlas core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png

param(
	[string]$Atlas = 'core\src\assets\environment\tiles\sps_tiles_sewers_legacy.png',
	[string]$OutDir = 'tools/atlas-meta/tiles-diag',
	[int]$Scale = 10
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path

$full = Join-Path $repoRoot $Atlas
$src = [System.Drawing.Bitmap]::FromFile($full)
$cols = [int]($src.Width / 16)
$rowsCount = [int]($src.Height / 16)
$total = $cols * $rowsCount
"atlas: $Atlas  ${cols}x${rowsCount} = $total frames"

# sample each frame: is the lower part bluish (water) and upper part dark (chasm lip)?
$report = @()
for ($f = 0; $f -lt $total; $f++) {
	$gx = ($f % $cols) * 16
	$gy = [int][Math]::Floor($f / $cols) * 16
	$topDark = 0; $bottomBlue = 0; $opaque = 0
	for ($y = 0; $y -lt 16; $y++) {
		for ($x = 0; $x -lt 16; $x++) {
			$c = $src.GetPixel($gx + $x, $gy + $y)
			if ($c.A -lt 32) { continue }
			$opaque++
			$lum = ($c.R * 0.299 + $c.G * 0.587 + $c.B * 0.114)
			if ($y -lt 6 -and $lum -lt 90) { $topDark++ }
			if ($y -ge 10 -and $c.B -gt $c.R + 15) { $bottomBlue++ }
		}
	}
	$report += [pscustomobject]@{ f = $f; fx = ($f % $cols); fy = [int][Math]::Floor($f / $cols); opaque = $opaque; topDark = $topDark; bottomBlue = $bottomBlue }
}

'--- frames whose bottom reads as water AND top has a dark lip ---'
$cands = @($report | Where-Object { $_.bottomBlue -ge 20 -and $_.topDark -ge 10 })
if ($cands.Count -eq 0) {
	'  (none matched; showing all non-empty frames instead)'
	$cands = @($report | Where-Object { $_.opaque -ge 30 })
}
foreach ($r in $cands) {
	"  f$($r.f)  col=$($r.fx) row=$($r.fy)  opaque=$($r.opaque) topDark=$($r.topDark) bottomBlue=$($r.bottomBlue)"
}

# render the candidates large enough to judge
if ($cands.Count -gt 0) {
	$cell = 16 * $Scale
	$pad = 12
	$labelH = 22
	$w = $cands.Count * ($cell + $pad) + $pad
	$h = $cell + $pad + $labelH
	$bmp = New-Object Drawing.Bitmap($w, $h)
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::FromArgb(255, 245, 245, 250))
	$font = New-Object Drawing.Font('Consolas', 11, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
	$border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 90, 90, 90), 1)
	for ($i = 0; $i -lt $cands.Count; $i++) {
		$m = $cands[$i]
		$cx = [int]$m.fx
		$cy = [int]$m.fy
		$ox = $pad + $i * ($cell + $pad)
		$g.FillRectangle([Drawing.Brushes]::White, $ox, $pad, $cell, $cell)
		$dst = New-Object Drawing.Rectangle($ox, $pad, $cell, $cell)
		$srcRect = New-Object Drawing.Rectangle(($cx * 16), ($cy * 16), 16, 16)
		$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
		$g.DrawRectangle($border, $ox, $pad, $cell, $cell)
		$g.DrawString("f$($m.f)", $font, [Drawing.Brushes]::Black, [single]$ox, [single]($pad + $cell + 2))
	}
	$out = Join-Path (Join-Path $repoRoot $OutDir) ('candidates_' + (Split-Path $Atlas -Leaf))
	$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose(); $bmp.Dispose()
	"saved: $out"
}

$src.Dispose()
