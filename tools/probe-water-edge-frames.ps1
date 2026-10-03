#   probe-water-edge-frames.ps1
#   Precise per-frame probe of a water-edge atlas.
#
#   Prior attempts compared border pixels against a "water colour" threshold and were too
#   noisy. This version asks a much simpler question per pixel: is it transparent/black
#   (background) or not? Then per side it reports how many of the outer ring pixels carry
#   content, plus a 16x16 ASCII map of one frame so the shape is unambiguous.
#
#   Usage:
#     .\tools\probe-water-edge-frames.ps1 -Atlas core/src/assets/environment/water/sps_water_edges_sewers.png
#     .\tools\probe-water-edge-frames.ps1 ... -Ascii 0,1,2,15

param(
	[string]$Atlas = 'core/src/assets/environment/water/sps_water_edges_sewers.png',
	[string]$Ascii = '0,1,2,3,4,8,15'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$path = if ([IO.Path]::IsPathRooted($Atlas)) { $Atlas } else { Join-Path (Get-Location).Path ($Atlas -replace '/', '\') }
$src = [Drawing.Bitmap]::FromFile($path)
$frames = [int]($src.Width / 16)
"atlas: $Atlas   frames: $frames"
''

# background = fully transparent, or pure black (some PNGs store transparency as black)
function Test-Content([Drawing.Color]$c) {
	return ($c.A -gt 8) -and (($c.R + $c.G + $c.B) -gt 24)
}

'frame | up  right down  left | edges (middle-span probe)     | code expects'
'------+---------------------+-------------------------------+-------------'

$bitName = @{ 1 = 'up'; 2 = 'right'; 4 = 'down'; 8 = 'left' }

for ($f = 0; $f -lt $frames; $f++) {
	$ox = $f * 16
	$ring = @{ up = 0; right = 0; down = 0; left = 0 }
	for ($i = 0; $i -lt 16; $i++) {
		if (Test-Content $src.GetPixel($ox + $i, 0))  { $ring.up++ }
		if (Test-Content $src.GetPixel($ox + $i, 15)) { $ring.down++ }
		if (Test-Content $src.GetPixel($ox + 0, $i))  { $ring.left++ }
		if (Test-Content $src.GetPixel($ox + 15, $i)) { $ring.right++ }
	}

	# ignore corners: a real edge covers most of the middle span of that side.
	# pixel 0 and 15 are corner pixels shared with the perpendicular sides.
	$mid = @{ up = 0; right = 0; down = 0; left = 0 }
	for ($i = 4; $i -le 11; $i++) {
		if (Test-Content $src.GetPixel($ox + $i, 0))  { $mid.up++ }
		if (Test-Content $src.GetPixel($ox + $i, 15)) { $mid.down++ }
		if (Test-Content $src.GetPixel($ox + 0, $i))  { $mid.left++ }
		if (Test-Content $src.GetPixel($ox + 15, $i)) { $mid.right++ }
	}

	$real = @()
	foreach ($s in @('up', 'right', 'down', 'left')) { if ($mid[$s] -ge 4) { $real += $s } }

	$expect = @()
	foreach ($b in @(1, 2, 4, 8)) { if (($f -band $b) -ne 0) { $expect += $bitName[$b] } }

	$realTxt = if ($real.Count) { $real -join '+' } else { '(none)' }
	$expTxt = if ($expect.Count) { $expect -join '+' } else { '(none)' }
	$mark = if (($real -join '+') -eq ($expect -join '+')) { '  ' } else { '!=' }
	"{0,5} | {1,3} {2,5} {3,4} {4,5} | {5,-29} | {6,-11} {7}" -f `
		$f, $ring.up, $ring.right, $ring.down, $ring.left, $realTxt, $expTxt, $mark
}

$want = @($Ascii -split ',' | ForEach-Object { [int]$_.Trim() })
''
'=== ASCII maps (X = has content, . = background) ==='
foreach ($f in $want) {
	if ($f -lt 0 -or $f -ge $frames) { continue }
	$ox = $f * 16
	""
	"frame f$f   (atlas x $ox..$($ox+15))"
	for ($y = 0; $y -lt 16; $y++) {
		$row = ''
		for ($x = 0; $x -lt 16; $x++) {
			if (Test-Content $src.GetPixel($ox + $x, $y)) { $row += 'X' } else { $row += '.' }
		}
		"  $row"
	}
}
$src.Dispose()
