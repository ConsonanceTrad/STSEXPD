#   render-tiles-sheet.ps1
#   Render a terrain tiles atlas scaled up with the frame index printed inside each cell,
#   so tile constants (DungeonTileSheet.CHASM etc.) can be matched against real artwork.
#
#   Usage: .\tools\render-tiles-sheet.ps1 -Atlas core/src/assets/environment/tiles/tiles_sewers.png
#          .\tools\render-tiles-sheet.ps1 -Atlas ... -Start 16 -End 48

param(
	[string]$Atlas = 'core/src/assets/environment/tiles/tiles_sewers.png',
	[string]$OutDir = 'tools/atlas-meta/tiles-diag',
	[int]$Start = 0,
	[int]$End = -1,
	[int]$Scale = 3
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path
$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$path = if ([IO.Path]::IsPathRooted($Atlas)) { $Atlas } else { Join-Path $repoRoot ($Atlas -replace '/', '\') }
$src = [Drawing.Bitmap]::FromFile($path)
$cols = [int]($src.Width / 16)
$rows = [int]($src.Height / 16)
$total = $cols * $rows
if ($End -lt 0 -or $End -ge $total) { $End = $total - 1 }
"atlas: $Atlas   ${cols}x${rows} = $total frames   rendering $Start..$End"

$cell = 16 * $Scale
$pad = 20
$font = New-Object Drawing.Font('Consolas', 8, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.Brushes]::Black
$labelBg = [Drawing.Brushes]::WhiteSmoke
$hlPen = New-Object Drawing.Pen([Drawing.Color]::FromArgb(255, 220, 30, 30), 2)

$count = $End - $Start + 1
$nCols = [int][Math]::Min(16, $count)
$nRows = [int][Math]::Ceiling($count / $nCols)
$bmp = New-Object Drawing.Bitmap([int]($nCols * ($cell + $pad) + 8), [int]($nRows * ($cell + $pad) + 8))
$g = [Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
$g.Clear([Drawing.Color]::FromArgb(255, 240, 240, 240))

$i = 0
for ($f = $Start; $f -le $End; $f++) {
	$fx = ($f % $cols) * 16
	$fy = [int]($f / $cols) * 16
	$cx = [int](4 + ($i % $nCols) * ($cell + $pad))
	$cy = [int](4 + [int]($i / $nCols) * ($cell + $pad))
	$dst = New-Object Drawing.Rectangle($cx, $cy, $cell, $cell)
	$srcRect = New-Object Drawing.Rectangle($fx, $fy, 16, 16)
	$g.DrawImage($src, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
	# checkered backing so transparent tiles are visible
	$g.FillRectangle($labelBg, $cx, [int]($cy + $cell), [int]$cell, 10)
	$g.DrawString("$f", $font, $brush, [single]$cx, [single]($cy + $cell))
	$i++
}
$g.Dispose(); $src.Dispose()
$name = [IO.Path]::GetFileNameWithoutExtension($path)
$outPng = Join-Path $outFull "$name`_f$Start-$End.png"
$bmp.Save($outPng, [Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"written: $outPng"
