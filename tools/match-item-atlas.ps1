# match-item-atlas.ps1
#   Match original items.png cells (tools/atlas-meta/items/_index.csv) against the split
#   item atlases by exact pixel comparison. Only byte-identical cells are reported as filled.
#   Entries that were redrawn / reordered / added are listed as unmatched.
#
# Usage:
#   .\tools\match-item-atlas.ps1
#
# Outputs:
#   tools/atlas-meta/items-match-report.txt    filled listing, grouped per atlas
#   tools/atlas-meta/items-unmatched.txt       entries that could not be matched
#
# NOTE: keep this file ASCII-only. PowerShell 5.1 reads BOM-less files as ANSI, and a
#       mangled param() block silently breaks argument binding.

param(
	[string]$IndexCsv = 'tools/atlas-meta/items/_index.csv',
	[string]$SourcePng = 'core/src/assets/sprites/items/items.png',
	[string]$SplitRoot = 'core/src/assets/sprites/items'
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class PmMatcher {
    public static byte[] Load(Bitmap b, out int stride, out int w, out int h) {
        var rect = new Rectangle(0, 0, b.Width, b.Height);
        var d = b.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        stride = d.Stride; w = b.Width; h = b.Height;
        byte[] all = new byte[stride * b.Height];
        Marshal.Copy(d.Scan0, all, 0, all.Length);
        b.UnlockBits(d);
        return all;
    }
    public static List<int[]> FindAll(byte[] bigAll, int bigStride, int bigW, int bigH,
                                      byte[] srcAll, int srcStride, int tx, int ty, int w, int h) {
        var res = new List<int[]>();
        if (w > bigW || h > bigH) return res;
        int rowBytes = w * 4;
        for (int y = 0; y + h <= bigH; y++) {
            for (int x = 0; x + w <= bigW; x++) {
                int b0 = y * bigStride + x * 4;
                int t0 = ty * srcStride + tx * 4;
                if (bigAll[b0] != srcAll[t0] || bigAll[b0+1] != srcAll[t0+1] ||
                    bigAll[b0+2] != srcAll[t0+2] || bigAll[b0+3] != srcAll[t0+3]) continue;
                bool ok = true;
                for (int yy = 0; yy < h && ok; yy++) {
                    int bi = (y + yy) * bigStride + x * 4;
                    int ti = (ty + yy) * srcStride + tx * 4;
                    for (int xx = 0; xx < rowBytes; xx++) {
                        if (bigAll[bi + xx] != srcAll[ti + xx]) { ok = false; break; }
                    }
                }
                if (ok) res.Add(new int[] { x, y });
            }
        }
        return res;
    }
}
'@ -ReferencedAssemblies System.Drawing

$repoRoot = (Get-Location).Path
$srcBmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $SourcePng).Path)
$srcStride = 0; $srcW = 0; $srcH = 0
$srcAll = [PmMatcher]::Load($srcBmp, [ref]$srcStride, [ref]$srcW, [ref]$srcH)
$srcBmp.Dispose()

$csvPath = (Resolve-Path $IndexCsv).Path
$csvText = [IO.File]::ReadAllText($csvPath, [Text.Encoding]::UTF8)
$lines = [regex]::Split($csvText, "\r?\n")
$entries = New-Object System.Collections.ArrayList
for ($i = 1; $i -lt $lines.Count; $i++) {
	$l = $lines[$i].Trim()
	if ($l -eq '') { continue }
	$p = $l -split ','
	[void]$entries.Add([pscustomobject]@{ File = $p[0]; Frame = [int]$p[1]; X = [int]$p[2]; Y = [int]$p[3]; W = [int]$p[4]; H = [int]$p[5] })
}
Write-Host "index entries: $($entries.Count)"

$splitFull = (Resolve-Path $SplitRoot).Path
$sourceFull = (Resolve-Path $SourcePng).Path
$atlases = @(Get-ChildItem -Recurse -File $splitFull -Filter *.png | Where-Object { $_.FullName -ne $sourceFull } | Sort-Object FullName)
Write-Host "split atlases: $($atlases.Count)"

$placed = @{}
$perAtlas = New-Object System.Collections.ArrayList

foreach ($a in $atlases) {
	$rel = $a.FullName.Substring($splitFull.Length + 1).Replace('\', '/')
	$bmp = [System.Drawing.Bitmap]::FromFile($a.FullName)
	$bStride = 0; $bW = 0; $bH = 0
	$bAll = [PmMatcher]::Load($bmp, [ref]$bStride, [ref]$bW, [ref]$bH)
	$bmp.Dispose()

	$taken = @{}
	$filledHere = 0
	foreach ($e in $entries) {
		$n = "$($e.File)#$($e.Frame)"
		if ($placed.ContainsKey($n)) { continue }
		if ($e.W -gt $bW -or $e.H -gt $bH) { continue }
		$hits = [PmMatcher]::FindAll($bAll, $bStride, $bW, $bH, $srcAll, $srcStride, $e.X, $e.Y, $e.W, $e.H)
		foreach ($hit in $hits) {
			$k = "$($hit[0]),$($hit[1]),$($e.W),$($e.H)"
			if ($taken.ContainsKey($k)) { continue }
			$taken[$k] = $n
			$placed[$n] = [pscustomobject]@{ Atlas = $rel; X = $hit[0]; Y = $hit[1]; W = $e.W; H = $e.H }
			$filledHere++
			break
		}
	}
	[void]$perAtlas.Add([pscustomobject]@{ Atlas = $rel; W = $bW; H = $bH; Filled = $filledHere })
}

Write-Host ''
Write-Host '=== per atlas ==='
$perAtlas | ForEach-Object { Write-Host ("  {0,-52} {1,4}x{2,-4}  filled {3,3}" -f $_.Atlas, $_.W, $_.H, $_.Filled) }
Write-Host ("  TOTAL placed: {0} / {1}" -f $placed.Count, $entries.Count)

$sb = New-Object Text.StringBuilder
$sb.AppendLine('# matched cells (exact pixel match)') | Out-Null
foreach ($g in ($placed.Keys | Group-Object { $placed[$_].Atlas } | Sort-Object Name)) {
	$sb.AppendLine('') | Out-Null
	$sb.AppendLine("## $($g.Name)") | Out-Null
	foreach ($n in ($g.Group | Sort-Object { $placed[$_].Y }, { $placed[$_].X })) {
		$v = $placed[$n]
		$sb.AppendLine(("  ({0},{1}) {2}x{3}  {4}" -f $v.X, $v.Y, $v.W, $v.H, $n)) | Out-Null
	}
}
[IO.File]::WriteAllText((Join-Path $repoRoot 'tools/atlas-meta/items-match-report.txt'), $sb.ToString(), (New-Object Text.UTF8Encoding($false)))

$miss = New-Object System.Collections.ArrayList
foreach ($e in $entries) {
	if (-not $placed.ContainsKey("$($e.File)#$($e.Frame)")) { [void]$miss.Add($e) }
}
$sb2 = New-Object Text.StringBuilder
$sb2.AppendLine("# unmatched entries ($($miss.Count)) - redrawn / reordered / added") | Out-Null
foreach ($e in ($miss | Sort-Object File, Frame)) {
	$sb2.AppendLine(("  {0}#{1}  {2}x{3}  (was {4},{5})" -f $e.File, $e.Frame, $e.W, $e.H, $e.X, $e.Y)) | Out-Null
}
[IO.File]::WriteAllText((Join-Path $repoRoot 'tools/atlas-meta/items-unmatched.txt'), $sb2.ToString(), (New-Object Text.UTF8Encoding($false)))

Write-Host "report: tools/atlas-meta/items-match-report.txt"
Write-Host "unmatched: tools/atlas-meta/items-unmatched.txt ($($miss.Count))"
