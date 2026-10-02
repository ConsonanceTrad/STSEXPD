# render-dict-preview.ps1
#   Renders every entry of the item dictionaries (i.e. every rect in
#   tools/atlas-meta/items/**/_atlas.json) into one contact-sheet PNG, so the
#   dictionary coordinates can be eyeballed without launching the game.
#
#   Each cell shows the icon cropped straight out of its atlas at the rect the
#   dictionary declares. Misaligned or empty cells are immediately visible.
#
# Usage:
#   .\tools\render-dict-preview.ps1
#   .\tools\render-dict-preview.ps1 -Scale 4

param(
	[string]$MetaRoot = 'tools/atlas-meta/items',
	[string]$ItemRoot = 'core/src/assets/sprites/items',
	[string]$Out      = 'tools/atlas-meta/items-dict-preview.png',
	[int]$Scale       = 3,
	[int]$Cell        = 18,
	[int]$Cols        = 24
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
Add-Type -AssemblyName System.Drawing

# ---- collect entries ------------------------------------------------------
$entries = New-Object System.Collections.ArrayList
foreach ($j in (Get-ChildItem -Recurse -File -Filter '_atlas.json' (Join-Path $repoRoot $MetaRoot) | Sort-Object FullName)) {
	$o = Get-Content -Raw -LiteralPath $j.FullName | ConvertFrom-Json
	$rel = ([string]$o.atlas).Replace('core/src/assets/', '').Replace('\','/')
	$png = Join-Path $repoRoot (Join-Path $ItemRoot ($rel -replace '^sprites/items/',''))
	if (-not (Test-Path $png)) { continue }
	foreach ($e in $o.entries) {
		$f = $e.frames[0]
		[void]$entries.Add([pscustomobject]@{
			atlas = $png; name = [string]$e.file
			x = [int]$f.x; y = [int]$f.y; w = [int]$f.w; h = [int]$f.h
		})
	}
}
Write-Host ("entries: {0}" -f $entries.Count)

# ---- layout ---------------------------------------------------------------
$cw = $Cell * $Scale
$rows = [int][Math]::Ceiling($entries.Count / $Cols)
$W = $Cols * $cw
$H = $rows * $cw
$sheet = New-Object Drawing.Bitmap($W, $H, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [Drawing.Graphics]::FromImage($sheet)
$g.Clear([Drawing.Color]::FromArgb(255, 32, 32, 40))

$cache = @{}
$i = 0
foreach ($e in $entries) {
	$c = $i % $Cols
	$r = [int][Math]::Floor($i / $Cols)
	$i++
	if (-not $cache.ContainsKey($e.atlas)) { $cache[$e.atlas] = [Drawing.Bitmap]::FromFile($e.atlas) }
	$src = $cache[$e.atlas]
	$sx = [Math]::Max(0, [Math]::Min($e.x, $src.Width - 1))
	$sy = [Math]::Max(0, [Math]::Min($e.y, $src.Height - 1))
	$sw = [Math]::Max(1, [Math]::Min($e.w, $src.Width - $sx))
	$sh = [Math]::Max(1, [Math]::Min($e.h, $src.Height - $sy))
	$dst = New-Object Drawing.Rectangle(($c * $cw), ($r * $cw), ($sw * $Scale), ($sh * $Scale))
	$g.DrawImage($src, $dst, (New-Object Drawing.Rectangle($sx, $sy, $sw, $sh)), [Drawing.GraphicsUnit]::Pixel)
	# cell border
	$g.DrawRectangle([Drawing.Pens]::DimGray, ($c * $cw), ($r * $cw), ($cw - 1), ($cw - 1))
}
$g.Dispose()
foreach ($b in $cache.Values) { $b.Dispose() }
$outPath = Join-Path $repoRoot $Out
$sheet.Save($outPath, [Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()
Write-Host ("wrote {0}x{1} -> {2}" -f $W, $H, $Out)
