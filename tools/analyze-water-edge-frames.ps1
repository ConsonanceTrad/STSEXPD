#   analyze-water-edge-frames.ps1
#   For each frame of a water-edge atlas, decide which of the 4 borders carry an
#   edge, by comparing border pixels against the frame's own centre (water) colour.
#
#   Then compare that against what SpsWaterEdgesTilemap believes:
#       frame = +1 up, +2 right, +4 down, +8 left   (a set bit means that side is an edge)
#
#   Usage: .\tools\analyze-water-edge-frames.ps1 [-Atlas core/src/assets/environment/water/sps_water_edges_sewers.png]

param(
	[string]$Atlas = 'core/src/assets/environment/water/sps_water_edges_sewers.png'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$path = Join-Path (Get-Location).Path ($Atlas -replace '/', '\')
$src = [Drawing.Bitmap]::FromFile($path)
$frames = [int]($src.Width / 16)
"atlas: $Atlas   frames: $frames"
''
'frame | detected edges        | code expects          | match'
'------+-----------------------+-----------------------+------'

$bitName = @{ 1 = 'up'; 2 = 'right'; 4 = 'down'; 8 = 'left' }

# water colour reference: centre of frame 0 (the no-edge frame)
$wc = $src.GetPixel(8, 8)
$tol = 10
"water reference RGB: $($wc.R),$($wc.G),$($wc.B)"
''

for ($f = 0; $f -lt $frames; $f++) {
	$ox = $f * 16

	# sample each border: count non-water pixels
	$edges = @()
	foreach ($side in @('up', 'right', 'down', 'left')) {
		$hits = 0
		for ($i = 1; $i -lt 15; $i++) {
			switch ($side) {
				'up'    { $c = $src.GetPixel($ox + $i, 0) }
				'down'  { $c = $src.GetPixel($ox + $i, 15) }
				'left'  { $c = $src.GetPixel($ox + 0, $i) }
				'right' { $c = $src.GetPixel($ox + 15, $i) }
			}
			if (-not ([math]::Abs($c.R - $wc.R) -le $tol -and
					[math]::Abs($c.G - $wc.G) -le $tol -and
					[math]::Abs($c.B - $wc.B) -le $tol)) { $hits++ }
		}
		if ($hits -ge 4) { $edges += $side }
	}

	# what the code would compute for this frame index
	$expect = @()
	foreach ($b in @(1, 2, 4, 8)) { if (($f -band $b) -ne 0) { $expect += $bitName[$b] } }

	$det = ($edges -join '+'); if ($det -eq '') { $det = '(none)' }
	$exp = ($expect -join '+'); if ($exp -eq '') { $exp = '(none)' }
	$ok = if ($det -eq $exp) { 'OK' } else { 'MISMATCH' }
	"{0,5} | {1,-21} | {2,-21} | {3}" -f $f, $det, $exp, $ok
}
$src.Dispose()
