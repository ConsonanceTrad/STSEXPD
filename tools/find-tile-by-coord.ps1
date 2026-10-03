#   find-tile-by-coord.ps1
#   Given an (x,y) coordinate, crop that cell out of EVERY atlas under a folder and
#   render them side by side with the atlas name, so the right file can be identified.
#
#   Both interpretations are shown: 1-based (what DungeonTileSheet.xy() consumes) and
#   0-based (plain array indexing).
#
#   Usage: .\tools\find-tile-by-coord.ps1 -X 13 -Y 3

param(
	[string]$Dir = 'core/src/assets/environment/tiles',
	[int]$X = 13,
	[int]$Y = 3,
	[string]$OutDir = 'tools/atlas-meta/tiles-diag',
	[int]$Scale = 6
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path
$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$atlases = @(Get-ChildItem -Recurse -File $Dir -Filter '*.png' | Sort-Object Name)
$cell = 16 * $Scale
$colW = [int]($cell * 2 + 60)

$bmp = New-Object Drawing.Bitmap([int]($colW * 2 + 20), [int]($atlases.Count * ($cell + 14) + 40))
$g = [Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([Drawing.Color]::FromArgb(255, 235, 235, 235))
$font = New-Object Drawing.Font('Consolas', 9, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.Brushes]::Black

$g.DrawString("coord requested: ($X,$Y)", $font, $brush, 6, 4)
$g.DrawString("LEFT = 1-based xy()   RIGHT = 0-based", $font, $brush, 6, 16)

$i = 0
foreach ($a in $atlases) {
	$src = [Drawing.Bitmap]::FromFile($a.FullName)
	$cx = [int]($a.Name.Length * 5.2)
	if ($cx -gt 150) { $cx = 150 }
	$g.DrawString($a.Name, $font, $brush, [single]($colW - 150), [single](30 + $i * ($cell + 14) + 14))

	foreach ($oneBased in @($true, $false)) {
		$fx = if ($oneBased) { ($X - 1) * 16 } else { $X * 16 }
		$fy = if ($oneBased) { ($Y - 1) * 16 } else { $Y * 16 }
		$ox = [int](6 + ($(if ($oneBased) { 0 } else { 1 })) * ($cell + 8))
		$oy = [int](30 + $i * ($cell + 14))
		if ($fx + 16 -le $src.Width -and $fy + 16 -le $src.Height) {
			$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)
			$srcRect = New-Object Drawing.Rectangle($fx, $fy, 16, 16)
			$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
		}
	}
	$src.Dispose()
	$i++
}
$g.Dispose()
$outPng = Join-Path $outFull "coord_${X}_${Y}.png"
$bmp.Save($outPng, [Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"written: $outPng   (atlases: $($atlases.Count))"
