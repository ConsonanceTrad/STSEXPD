# render-item-atlas-preview.ps1
#   Render each split atlas at 3x with a 16px cell grid and per-cell "col,row" labels,
#   so the claim list can be filled by looking at pictures instead of guessing ids.
# Usage:  .\tools\render-item-atlas-preview.ps1
# Output: tools/atlas-meta/items-preview/<atlas>.png

param(
	[string]$SplitRoot = 'core/src/assets/sprites/items',
	[string]$ClaimsCsv = 'tools/atlas-meta/items-claims.csv',
	[string]$OutDir    = 'tools/atlas-meta/items-preview',
	[int]$Scale = 3
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# 已认领语义表：atlas|col,row -> semantic
$known = @{}
if (Test-Path $ClaimsCsv) {
	# 可能在编辑器中打开，读取失败时退化为「全部未认领」
	$lines = @()
	try { $lines = [IO.File]::ReadAllLines((Resolve-Path $ClaimsCsv).Path, [Text.Encoding]::UTF8) } catch { Write-Host '  claims csv busy - labels will show grid coords only' }
	for ($i = 1; $i -lt $lines.Count; $i++) {
		$l = $lines[$i].Trim(); if ($l -eq '') { continue }
		$p = $l -split ','
		if ($p.Count -lt 7) { continue }
		if ($p[5] -ne '') { $known["$($p[0])|$(($p[1] -as [int])),$(($p[2] -as [int]))"] = $p[5] }
	}
}

$splitFull = (Resolve-Path $SplitRoot).Path
$outFull = Join-Path (Get-Location).Path $OutDir
if (-not (Test-Path $outFull)) { New-Item -ItemType Directory -Force -Path $outFull | Out-Null }

$cell = 16 * $Scale
$labelH = 12
$font = New-Object Drawing.Font('Consolas', 7)
$fontSmall = New-Object Drawing.Font('Consolas', 6)
$bRed = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 200, 40, 40))
$bBlue = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 30, 90, 200))
$bBlack = New-Object Drawing.SolidBrush([Drawing.Color]::Black)
$bBack = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(255, 240, 240, 240))
$penGrid = New-Object Drawing.Pen([Drawing.Color]::FromArgb(120, 160, 160, 160), 1)

$count = 0
foreach ($a in (Get-ChildItem -Recurse -File $splitFull -Filter *.png | Where-Object { $_.Name -ne 'items.png' } | Sort-Object FullName)) {
	$rel = $a.FullName.Substring($splitFull.Length + 1).Replace('\', '/')
	$src = [Drawing.Bitmap]::FromFile($a.FullName)
	$cols = [int]($src.Width / 16); $rows = [int]($src.Height / 16)

	$W = $cols * $cell; $H = $labelH + $rows * ($cell + $labelH)
	$bmp = New-Object Drawing.Bitmap($W, $H)
	$g = [Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
	$g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
	$g.Clear([Drawing.Color]::White)

	# 顶部列号
	for ($c = 0; $c -lt $cols; $c++) { $g.DrawString("$c", $fontSmall, $bBlack, $c * $cell + 2, 1) }

	for ($r = 0; $r -lt $rows; $r++) {
		$y = $labelH + $r * ($cell + $labelH)
		$g.FillRectangle($bBack, 0, $y, $W, $labelH)
		for ($c = 0; $c -lt $cols; $c++) {
			# 放大贴图
			for ($yy = 0; $yy -lt 16; $yy++) {
				for ($xx = 0; $xx -lt 16; $xx++) {
					$sx = $c * 16 + $xx; $sy = $r * 16 + $yy
					if ($sx -ge $src.Width -or $sy -ge $src.Height) { continue }
					$px = $src.GetPixel($sx, $sy)
					if ($px.A -eq 0) { continue }
					$g.FillRectangle((New-Object Drawing.SolidBrush($px)), $c * $cell + $xx * $Scale, $y + $labelH + $yy * $Scale, $Scale, $Scale)
				}
			}
			# 标签
			$key = "$rel|$c,$r"
			if ($known.ContainsKey($key)) {
				$txt = $known[$key]
				if ($txt.Length -gt 14) { $txt = $txt.Substring(0, 14) }
				$g.DrawString($txt, $fontSmall, $bBlue, $c * $cell + 1, $y + 1)
			} else {
				$g.DrawString("$c,$r", $fontSmall, $bRed, $c * $cell + 1, $y + 1)
			}
		}
		$g.DrawLine($penGrid, 0, $y, $W, $y)
	}
	for ($c = 0; $c -le $cols; $c++) { $g.DrawLine($penGrid, $c * $cell, $labelH, $c * $cell, $H) }

	$g.Dispose()
	$name = $rel.Replace('/', '_') -replace '\.png$', ''
	$bmp.Save((Join-Path $outFull ($name + '.png')), [Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose(); $src.Dispose()
	$count++
}
Write-Host "preview images: $count -> $OutDir"