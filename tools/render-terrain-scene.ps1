#   render-terrain-scene.ps1
#   Renders a COMPLETE terrain fragment (not isolated tiles) through the same rules the
#   game uses, so layered effects can be judged in context:
#
#     layer 1  terrain    SpsTerrainFrames.visual(t) -> tiles atlas frame
#     layer 2  water      SpsWaterEdgesTilemap rule  -> sps_water_edges_* frame
#     layer 3  chasm      SpsChasmEdgesTilemap rule  -> DungeonTileSheet.stitchChasmTile
#
#   Terrain values (pd.levels.Terrain): CHASM=0 EMPTY=1 GRASS=2 WALL=4 DOOR=5 OPEN_DOOR=6
#   ENTRANCE=7 EXIT=8 EMBERS=9 ... WATER=29 (SpsTerrainFrames maps WATER -> frame 63)
#
#   Usage: .\tools\render-terrain-scene.ps1
#          .\tools\render-terrain-scene.ps1 -Scene 2 -Scale 6

param(
	[string]$TilesAtlas  = 'core/src/assets/environment/tiles/sps_tiles_caves_legacy.png',
	[string]$ChasmAtlas  = 'core/src/assets/environment/tiles/sps_tiles_caves_legacy.png',
	[string]$WaterAtlas  = 'core/src/assets/environment/water/sps_water_edges_caves.png',
	[string]$OutDir      = 'tools/atlas-meta/terrain-diag',
	[int]$Scene          = -1,
	[int]$Scale          = 6
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = (Get-Location).Path
$outFull = Join-Path $repoRoot $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

function Resolve-Atlas([string]$rel) {
	if ([IO.Path]::IsPathRooted($rel)) { return $rel }
	return Join-Path $repoRoot ($rel -replace '/', '\')
}

$tiles = [Drawing.Bitmap]::FromFile((Resolve-Atlas $TilesAtlas))
$chasm = [Drawing.Bitmap]::FromFile((Resolve-Atlas $ChasmAtlas))
$water = [Drawing.Bitmap]::FromFile((Resolve-Atlas $WaterAtlas))

# ---- terrain char -> Terrain constant ----
# NOTE: PowerShell variable names are case-insensitive, so this must not be called $T
# (that would collide with the loop's $t).
$TerrMap = @{}
$TerrMap['W'] = 4; $TerrMap['.'] = 1; $TerrMap['c'] = 0; $TerrMap['~'] = 29
$TerrMap['D'] = 5; $TerrMap['O'] = 6; $TerrMap['*'] = 2; $TerrMap['S'] = 7
$waterBrush = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 40, 60, 80))
$TerrMap['X'] = 8; $TerrMap['e'] = 9

# ---- SpsTerrainFrames.visual(): 0-19 pass through, a few broken-only remaps ----
function TerrainFrame([int]$t) {
	switch ($t) {
		29 { return 63 }   # WATER -> 63 (the actual water tile in the SPS atlas)
		30 { return 2 }    # FURROWED_GRASS -> grass
		default { return $t }
	}
}

# ---- which terrains can a chasm stitch to (DungeonTileSheet.chasmStitcheable) ----
$chasmFloor = @(1, 2, 9, 14)          # EMPTY, GRASS, EMBERS, EMPTY_SP-ish
$chasmWall = @(4, 5, 6, 12)           # WALL, DOOR, OPEN_DOOR, WALL_DECO
$chasmWater = 29

# ---- scenes: a mix of complete terrain, not isolated cases ----
$scenes = @{
	'pond' = @(
		'WWWWWWWWWWWW',
		'W....~~~~...',
		'W...~~~~~~..',
		'W..~~~~~c...',
		'W...~~~~....',
		'W....~~.....',
		'WWWWWWWWWWWW'
	)
	'chasm' = @(
		'WWWWWWWWWWWW',
		'W...ccc.....',
		'W..ccccc....',
		'W.ccccccc...',
		'W..ccccc.D..',
		'W...ccc.....',
		'WWWWWWWWWWWW'
	)
	'mixed' = @(
		'WWWWWWWWWWWW',
		'W~~..cc.....',
		'W~~~.ccc....',
		'W~.~.cccc...',
		'W....cccc.WW',
		'WD....cc....',
		'WWWWWWWWWWWW'
	)
}

$names = if ($Scene -ge 0) {
	@(($scenes.Keys | Sort-Object)[$Scene])
} else {
	@($scenes.Keys | Sort-Object)
}

foreach ($name in $names) {
	if (-not $scenes.ContainsKey($name)) { continue }
	$rows = $scenes[$name]
	$h = $rows.Count
	$w = $rows[0].Length
	$cell = 16 * $Scale
	$pad = 26

	$bmp = New-Object Drawing.Bitmap([int]($w * $cell + $pad * 2), [int]($h * $cell + $pad * 2))
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::FromArgb(255, 20, 20, 24))

	$font = New-Object Drawing.Font('Consolas', 9, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
	$brush = [Drawing.Brushes]::White

	for ($y = 0; $y -lt $h; $y++) {
		for ($x = 0; $x -lt $w; $x++) {
			$ch = [string]$rows[$y][$x]
			$t = $TerrMap[$ch]
			$ox = [int]($pad + $x * $cell)
			$oy = [int]($pad + $y * $cell)
			$dst = New-Object Drawing.Rectangle($ox, $oy, $cell, $cell)

			# ---- layer 1: terrain (water tiles are skipped; the water layer draws them) ----
			if ($t -ne 29) {
				$tf = TerrainFrame $t
				$srcRect = New-Object Drawing.Rectangle([int](($tf % 16) * 16), [int]([int]($tf / 16) * 16), 16, 16)
				$g.DrawImage($tiles, $dst, $srcRect, [Drawing.GraphicsUnit]::Pixel)
			} else {
				# water base: in-game this is the SkinnedBlock water layer. Do NOT use
				# atlas frame 0 here -- frame 0 means "an edge on all four sides"; the
				# frame-15 slot is the one with no edge at all.
				$g.FillRectangle($waterBrush, $dst)

				# ---- layer 2: water edges (SpsWaterEdgesTilemap rule) ----
				# bit set == that neighbour is unstitchable (not water) -> edge on that side
				$wt = 0
				$up = if ($y -gt 0) { $TerrMap[[string]$rows[$y-1][$x]] } else { -1 }
				$rt = if ($x + 1 -lt $w) { $TerrMap[[string]$rows[$y][$x+1]] } else { -1 }
				$dn = if ($y + 1 -lt $h) { $TerrMap[[string]$rows[$y+1][$x]] } else { -1 }
				$lf = if ($x -gt 0) { $TerrMap[[string]$rows[$y][$x-1]] } else { -1 }
				if ($up -ne 29) { $wt += 1 }
				if ($rt -ne 29) { $wt += 2 }
				if ($dn -ne 29) { $wt += 4 }
				if ($lf -ne 29) { $wt += 8 }
				if ($wt -ne 15) {
					$srcRect2 = New-Object Drawing.Rectangle([int]($wt * 16), 0, 16, 16)
					$g.DrawImage($water, $dst, $srcRect2, [Drawing.GraphicsUnit]::Pixel)
				}
			}

			# ---- layer 3: chasm edges (SpsChasmEdgesTilemap rule) ----
			# frames live in the BROKEN atlas (tiles_*.png), coords verified in DungeonTileSheet:
			#   13,3 = 44 邻接地板   14,3 = 45 邻接墙   16,3 = 47 邻接水   1,1 = 0 完整深渊
			if ($t -eq 0 -and $y -gt 0) {
				$above = $TerrMap[[string]$rows[$y-1][$x]]
				if ($above -ne 0) {
					if ($above -eq 29) { $cf = 31 }
					elseif ($chasmWall -contains $above) { $cf = 29 }
					else { $cf = 27 }
					if ($cf -ge 0 -and $cf -lt 256) {
						$srcRect3 = New-Object Drawing.Rectangle([int](($cf % 16) * 16), [int]([int]($cf / 16) * 16), 16, 16)
						$g.DrawImage($chasm, $dst, $srcRect3, [Drawing.GraphicsUnit]::Pixel)
					}
				}
			}

			# coord + terrain label
			$g.DrawString("$x,$y $ch=$t", $font, $brush, [single]($ox + 1), [single]($oy + 1))
		}
	}
	$g.Dispose()
	$outPng = Join-Path $outFull "scene_$name.png"
	$bmp.Save($outPng, [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	"  scene_$name.png   (${w}x$h)"
}
$tiles.Dispose(); $chasm.Dispose(); $water.Dispose()
"output: $OutDir"
