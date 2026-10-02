# match-item-sprite.ps1
#   For every UNRESOLVED entry of items-sprite-map.csv, find the closest icon in the NEW
#   atlases by image similarity against the ORIGINAL items.png (still 256x992).
#
#   Each icon is reduced to an 8x8 luminance*alpha fingerprint of its content bounding box,
#   so redrawn-but-similar art still matches. Output carries the score so weak matches
#   (below -Threshold) stay flagged for manual review.
#
# Usage:
#   .\tools\match-item-sprite.ps1 -Threshold 0.12

param(
	[string]$MapCsv    = 'tools/atlas-meta/items-sprite-map.csv',
	[string]$OldAtlas  = 'core/src/assets/sprites/items/items.png',
	[string]$MetaRoot  = 'tools/atlas-meta/items',
	[string]$ItemRoot  = 'core/src/assets/sprites/items',
	[double]$Threshold = 0.12,
	[int]$N            = 8
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$utf8 = New-Object Text.UTF8Encoding($false)

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class Sim {
	public static byte[] Load(Bitmap b, out int stride, out int w, out int h) {
		Rectangle r = new Rectangle(0, 0, b.Width, b.Height);
		BitmapData d = b.LockBits(r, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		stride = d.Stride; w = b.Width; h = b.Height;
		byte[] a = new byte[d.Stride * b.Height];
		Marshal.Copy(d.Scan0, a, 0, a.Length);
		b.UnlockBits(d);
		return a;
	}
	public static double[] Fp(byte[] a, int stride, int x0, int y0, int x1, int y1, int n) {
		int mnX = int.MaxValue, mnY = int.MaxValue, mxX = -1, mxY = -1;
		for (int y = y0; y < y1; y++) {
			int row = y * stride;
			for (int x = x0; x < x1; x++) {
				if (a[row + x * 4 + 3] > 8) {
					if (x < mnX) mnX = x;
					if (x > mxX) mxX = x;
					if (y < mnY) mnY = y;
					if (y > mxY) mxY = y;
				}
			}
		}
		double[] f = new double[n * n];
		if (mxX < 0) return null;
		int bw = mxX - mnX + 1, bh = mxY - mnY + 1;
		for (int i = 0; i < n; i++) {
			int sy = mnY + (int)(((i + 0.5) * bh) / n);
			if (sy > mxY) sy = mxY;
			for (int j = 0; j < n; j++) {
				int sx = mnX + (int)(((j + 0.5) * bw) / n);
				if (sx > mxX) sx = mxX;
				int o = sy * stride + sx * 4;
				double al = a[o + 3] / 255.0;
				double lum = (a[o + 0] * 0.114 + a[o + 1] * 0.587 + a[o + 2] * 0.299) / 255.0;
				f[i * n + j] = lum * al;
			}
		}
		return f;
	}
	public static bool Empty(byte[] a, int stride, int x0, int y0, int x1, int y1) {
		for (int y = y0; y < y1; y++) {
			int row = y * stride;
			for (int x = x0; x < x1; x++) { if (a[row + x * 4 + 3] > 8) return false; }
		}
		return true;
	}
	public static double Diff(double[] p, double[] q) {
		double s = 0;
		for (int i = 0; i < p.Length; i++) { double d = p[i] - q[i]; s += d * d; }
		return Math.Sqrt(s / p.Length);
	}
}
'@ -ReferencedAssemblies System.Drawing

# ---- 1) fingerprints of every NEW entry -----------------------------------
$newAtlas = @{}
$entries = New-Object System.Collections.ArrayList
foreach ($j in (Get-ChildItem -Recurse -File -Filter '_atlas.json' (Join-Path $repoRoot $MetaRoot))) {
	$o = Get-Content -Raw -LiteralPath $j.FullName | ConvertFrom-Json
	$rel = ([string]$o.atlas).Replace('core/src/assets/', '').Replace('\','/')
	if (-not $newAtlas.ContainsKey($rel)) {
		$png = Join-Path $repoRoot (Join-Path $ItemRoot ($rel -replace '^sprites/items/',''))
		if (-not (Test-Path $png)) { continue }
		$bmp = [Drawing.Bitmap]::FromFile($png)
		$st = 0; $w = 0; $h = 0
		$buf = [Sim]::Load($bmp, [ref]$st, [ref]$w, [ref]$h)
		$newAtlas[$rel] = @{ buf=$buf; stride=$st; w=$w; h=$h }
		$bmp.Dispose()
	}
	$a = $newAtlas[$rel]
	foreach ($e in $o.entries) {
		$fr = $e.frames[0]
		$id = [string]$e.file
		$fp = [Sim]::Fp($a.buf, $a.stride, [int]$fr.x, [int]$fr.y, [int]$fr.x + [int]$fr.w, [int]$fr.y + [int]$fr.h, $N)
		if ($null -eq $fp) { continue }
		[void]$entries.Add([pscustomobject]@{ ident=$id; atlas=$rel; fp=$fp })
	}
}
Write-Host ("new entries fingerprinted: {0}  atlases: {1}" -f $entries.Count, $newAtlas.Count)

# ---- 2) original items.png ------------------------------------------------
$oldBmp = [Drawing.Bitmap]::FromFile((Join-Path $repoRoot $OldAtlas))
$ost = 0; $ow = 0; $oh = 0
$obuf = [Sim]::Load($oldBmp, [ref]$ost, [ref]$ow, [ref]$oh)
Write-Host ("old atlas: {0}x{1}" -f $ow, $oh)

# ---- 3) match every UNRESOLVED -------------------------------------------
$rows = New-Object System.Collections.ArrayList
$out = New-Object Text.StringBuilder
[void]$out.AppendLine('old_const,cell,new_ident,new_atlas,score,verdict')
$auto = 0; $weak = 0
foreach ($line in [IO.File]::ReadAllLines((Join-Path $repoRoot $MapCsv), [Text.Encoding]::UTF8)) {
	$t = $line.Trim()
	if ($t -eq '' -or $t -like 'old_const,*') { continue }
	$p = $t -split ','
	if ($p.Count -lt 5 -or $p[4] -ne 'UNRESOLVED') { continue }
	$name = $p[0]
	$cell = $p[3]
	if ($cell -notmatch '^cell(\d+)x(\d+)') { continue }
	$x = [int]$Matches[1]; $y = [int]$Matches[2]
	$x1 = [Math]::Min($x + 16, $ow); $y1 = [Math]::Min($y + 16, $oh)
	if ($x -ge $ow -or $y -ge $oh) { continue }
	if ([Sim]::Empty($obuf, $ost, $x, $y, $x1, $y1)) { continue }
	$ofp = [Sim]::Fp($obuf, $ost, $x, $y, $x1, $y1, $N)
	if ($null -eq $ofp) { continue }
	$best = $null; $bestScore = 1e9
	foreach ($e in $entries) {
		$d = [Sim]::Diff($ofp, $e.fp)
		if ($d -lt $bestScore) { $bestScore = $d; $best = $e }
	}
	if ($null -eq $best) { continue }
	$verdict = if ($bestScore -le $Threshold) { $auto++ ; 'auto' } else { $weak++; 'REVIEW' }
	[void]$out.AppendLine("$name,$cell,$($best.ident),$($best.atlas),$([Math]::Round($bestScore,4)),$verdict")
}
[IO.File]::WriteAllText((Join-Path $repoRoot 'tools/atlas-meta/items-similarity.csv'), $out.ToString(), $utf8)
$oldBmp.Dispose()
Write-Host ("auto (score <= {0}) : {1}" -f $Threshold, $auto)
Write-Host ("needs review        : {0}" -f $weak)