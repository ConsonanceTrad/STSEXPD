# gen-item-atlas-meta.ps1
#   Regenerates tools/atlas-meta/items/**/_atlas.json from the item ID table.
#
#   Input : tools/atlas-meta/items-id-final.csv  (atlas,col,row,w,h,id)
#   Input : tools/atlas-meta/items-aliases.csv   (id,alias)   optional legacy constant names
#   Input : core/src/assets/sprites/items/**.png
#   Output: tools/atlas-meta/items/<atlas path>/_atlas.json
#
#   One CSV row becomes one single-frame entry. The frame rect is measured from the
#   atlas PNG itself (content bounding box clipped to the 16x16 cell), so intra-cell
#   offsets are preserved. The entry "file" keeps the '#' of multi-frame ids;
#   gen-atlas-dict.ps1 folds it to '_' when building the Java identifier.
#
# Usage:
#   .\tools\gen-item-atlas-meta.ps1 -WhatIf     # dry run, no writes
#   .\tools\gen-item-atlas-meta.ps1             # regenerate

param(
	[string]$IdCsv        = 'tools/atlas-meta/items-id-final.csv',
	[string]$AliasCsv     = 'tools/atlas-meta/items-aliases.csv',
	[string]$ItemRoot     = 'core/src/assets/sprites/items',
	[string]$MetaRoot     = 'tools/atlas-meta/items',
	[string]$AssetsPrefix = 'core/src/assets/',
	[string]$JsonAtlasRoot= 'core/src/assets/sprites/items',
	[switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class AtlasBox {
	public static byte[] Load(Bitmap b, out int stride, out int w, out int h) {
		Rectangle r = new Rectangle(0, 0, b.Width, b.Height);
		BitmapData d = b.LockBits(r, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		stride = d.Stride; w = b.Width; h = b.Height;
		byte[] a = new byte[d.Stride * b.Height];
		Marshal.Copy(d.Scan0, a, 0, a.Length);
		b.UnlockBits(d);
		return a;
	}
	public static int[] Rect(byte[] a, int stride, int x0, int y0, int x1, int y1) {
		int mnX = int.MaxValue, mnY = int.MaxValue, mxX = -1, mxY = -1;
		for (int y = y0; y < y1; y++) {
			int row = y * stride;
			for (int x = x0; x < x1; x++) {
				if (a[row + x * 4 + 3] != 0) {
					if (x < mnX) mnX = x;
					if (x > mxX) mxX = x;
					if (y < mnY) mnY = y;
					if (y > mxY) mxY = y;
				}
			}
		}
		if (mxX < 0) return null;
		return new int[] { mnX, mnY, mxX - mnX + 1, mxY - mnY + 1 };
	}
}
'@ -ReferencedAssemblies System.Drawing

# ---- aliases -------------------------------------------------------------
$aliasOf = @{}
if (Test-Path (Join-Path $repoRoot $AliasCsv)) {
	foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $AliasCsv), [Text.Encoding]::UTF8)) {
		$t = $line.Trim()
		if ($t -eq '' -or $t -like 'id,*') { continue }
		$p = $t -split ','
		if ($p.Count -ge 2 -and $p[1].Trim() -ne '') { $aliasOf[$p[0].Trim()] = $p[1].Trim() }
	}
}

# ---- id table ------------------------------------------------------------
$rows = New-Object System.Collections.ArrayList
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $IdCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'atlas,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 6) { continue }
	$id = $p[5].Trim()
	if ($id -eq '' -or $id -eq '-') { continue }
	[void]$rows.Add([pscustomobject]@{
		atlas = $p[0].Trim()
		col   = [int]$p[1]
		row   = [int]$p[2]
		id    = $id
	})
}

# ---- purge old metadata --------------------------------------------------
$oldJsons = @(Get-ChildItem -Recurse -File -Filter '_atlas.json' (Join-Path $repoRoot $MetaRoot))
if (-not $WhatIf) {
	foreach ($j in $oldJsons) { Remove-Item -LiteralPath $j.FullName -Force }
}

# ---- regenerate ----------------------------------------------------------
$written = 0
$entryCount = 0
$emptyCells = New-Object System.Collections.ArrayList
$noAliasWarn = New-Object System.Collections.ArrayList

$groups = $rows | Group-Object atlas | Sort-Object Name
foreach ($g in $groups) {
	$atlas = $g.Name
	$pngPath = Join-Path $repoRoot (Join-Path $ItemRoot $atlas)
	if (-not (Test-Path $pngPath)) {
		Write-Host ("  SKIP (no png): {0}" -f $atlas) -ForegroundColor Yellow
		continue
	}
	$bmp = [Drawing.Bitmap]::FromFile($pngPath)
	$stride = 0; $bw = 0; $bh = 0
	$buf = [AtlasBox]::Load($bmp, [ref]$stride, [ref]$bw, [ref]$bh)

	$lines = New-Object System.Collections.ArrayList
	$n = 0
	foreach ($r in $g.Group) {
		$x0 = $r.col * 16
		$y0 = $r.row * 16
		$x1 = [Math]::Min($x0 + 16, $bw)
		$y1 = [Math]::Min($y0 + 16, $bh)
		if ($x0 -ge $bw -or $y0 -ge $bh) {
			[void]$emptyCells.Add(("{0}|{1},{2}|{3}" -f $atlas, $r.col, $r.row, $r.id))
			continue
		}
		$rect = [AtlasBox]::Rect($buf, $stride, $x0, $y0, $x1, $y1)
		if ($null -eq $rect) {
			[void]$emptyCells.Add(("{0}|{1},{2}|{3}" -f $atlas, $r.col, $r.row, $r.id))
			continue
		}
		$name = $r.id.Substring($r.id.IndexOf('/') + 1)
		$alias = ''
		if ($aliasOf.ContainsKey($name)) { $alias = $aliasOf[$name] }
		$frame = ("{{ ""x"": {0}, ""y"": {1}, ""w"": {2}, ""h"": {3} }}" -f $rect[0], $rect[1], $rect[2], $rect[3])
		if ($alias -ne '') {
			[void]$lines.Add(("        {{ ""file"": ""{0}"", ""alias"": ""{1}"", ""frames"": [ {2} ] }}" -f $name, $alias, $frame))
		} else {
			[void]$lines.Add(("        {{ ""file"": ""{0}"", ""frames"": [ {2} ] }}" -f $name, $alias, $frame))
		}
		$n++
	}
	$bmp.Dispose()

	$relDir = $atlas.Substring(0, $atlas.Length - 4).Replace('/', '\')
	$metaDir = Join-Path (Join-Path $repoRoot $MetaRoot) $relDir
	$atlasForJson = ($JsonAtlasRoot + '/' + $atlas)
	$outDirForJson = ('tools/atlas-meta/items/' + $atlas.Substring(0, $atlas.Length - 4) + '/work')

	$sb = New-Object Text.StringBuilder
	[void]$sb.AppendLine('{')
	[void]$sb.AppendLine(('    "atlas":  "{0}",' -f $atlasForJson))
	[void]$sb.AppendLine(('    "outDir":  "{0}",' -f $outDirForJson))
	[void]$sb.AppendLine('    "entries":  [')
	for ($i = 0; $i -lt $lines.Count; $i++) {
		$sep = if ($i -lt $lines.Count - 1) { ',' } else { '' }
		[void]$sb.AppendLine($lines[$i] + $sep)
	}
	[void]$sb.AppendLine('    ]')
	[void]$sb.AppendLine('}')

	if (-not $WhatIf) {
		if (-not (Test-Path $metaDir)) { New-Item -ItemType Directory -Force -Path $metaDir | Out-Null }
		[IO.File]::WriteAllText((Join-Path $metaDir '_atlas.json'), $sb.ToString(), $utf8)
	}
	$written++
	$entryCount += $n
	Write-Host ("  {0,-46} {1,4} entries" -f $atlas, $n)
}

# aliases that never got used -> report
foreach ($k in $aliasOf.Keys) {
	$found = $false
	foreach ($r in $rows) { if ($r.id.Substring($r.id.IndexOf('/') + 1) -eq $k) { $found = $true; break } }
	if (-not $found) { [void]$noAliasWarn.Add($k) }
}

Write-Host ''
Write-Host ("gen-item-atlas-meta: {0} metadata files, {1} entries  (WhatIf={2})" -f $written, $entryCount, $WhatIf)
Write-Host ("removed old metadata: {0}" -f $oldJsons.Count)
if ($emptyCells.Count -gt 0) {
	Write-Host ("empty cells (id present but PNG cell is blank): {0}" -f $emptyCells.Count) -ForegroundColor Yellow
	$emptyCells | Select-Object -First 20 | ForEach-Object { Write-Host ("  " + $_) }
}
if ($noAliasWarn.Count -gt 0) {
	Write-Host ("unused alias ids: {0}" -f ($noAliasWarn -join ', ')) -ForegroundColor Yellow
}
