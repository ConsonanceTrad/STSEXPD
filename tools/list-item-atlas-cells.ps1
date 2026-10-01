# list-item-atlas-cells.ps1
#   Emit an editable "claim list" for every icon cell of the split item atlases.
#   Matching is POSITION-INSENSITIVE: each cell's content bounding box is compared against
#   the original cells so an icon merely moved inside its cell still matches.
#   User decisions recorded in items-overrides.csv take precedence, and cells marked
#   clear/skip are emitted with semantic "-" so packing leaves them transparent.
# Usage:  .\tools\list-item-atlas-cells.ps1
# Output: tools/atlas-meta/items-claims.csv   (atlas,col,row,w,h,semantic,status)
# Keep this file ASCII-only (PowerShell 5.1 reads BOM-less files as ANSI).

param(
	[string]$IndexCsv     = 'tools/atlas-meta/items/_index.csv',
	[string]$SourcePng    = 'core/src/assets/sprites/items/items.png',
	[string]$SplitRoot    = 'core/src/assets/sprites/items',
	[string]$OutCsv       = 'tools/atlas-meta/items-claims.csv',
	[string]$ExcludeFile  = 'tools/atlas-meta/items-exclude.txt',
	[string]$OverrideFile = 'tools/atlas-meta/items-overrides.csv'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

public class PmList {
    class Img { public byte[] px; public int stride, w, h; }

    static Img Grab(Bitmap b) {
        var r = new Rectangle(0, 0, b.Width, b.Height);
        var d = b.LockBits(r, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        var im = new Img();
        im.stride = d.Stride; im.w = b.Width; im.h = b.Height;
        im.px = new byte[d.Stride * b.Height];
        Marshal.Copy(d.Scan0, im.px, 0, im.px.Length);
        b.UnlockBits(d);
        return im;
    }

    static string Hash(Img im, int x, int y, int w, int h) {
        ulong hash = 14695981039346656037UL;
        for (int yy = 0; yy < h; yy++) {
            int i = (y + yy) * im.stride + x * 4;
            for (int xx = 0; xx < w * 4; xx++) { hash ^= im.px[i + xx]; hash *= 1099511628211UL; }
        }
        return hash.ToString("X16");
    }

    static bool Opaque(Img im, int x0, int y0, int x1, int y1) {
        for (int y = y0; y < y1; y++) {
            int row = y * im.stride;
            for (int x = x0; x < x1; x++) if (im.px[row + x * 4 + 3] != 0) return true;
        }
        return false;
    }

    static int[] BBox(Img im, int x0, int y0, int x1, int y1) {
        int minX = int.MaxValue, minY = int.MaxValue, maxX = -1, maxY = -1;
        for (int y = y0; y < y1; y++) {
            int row = y * im.stride;
            for (int x = x0; x < x1; x++) if (im.px[row + x * 4 + 3] != 0) {
                if (x < minX) minX = x; if (x > maxX) maxX = x;
                if (y < minY) minY = y; if (y > maxY) maxY = y;
            }
        }
        if (maxX < 0) return null;
        return new int[] { minX, minY, maxX, maxY };
    }

    public static void Run(string indexCsv, string sourcePng, string splitRoot, string outCsv,
                           string[] exclude, string[] ovKeys, string[] ovVals,
                           out int matched, out int unclaimed, out int skipped, out int atlases) {
        matched = 0; unclaimed = 0; skipped = 0; atlases = 0;
        Img src;
        using (var b = new Bitmap(sourcePng)) { src = Grab(b); }

        var byContent = new Dictionary<string, string>();
        foreach (var line in File.ReadAllLines(indexCsv)) {
            var s = line.Trim();
            if (s.Length == 0 || s.StartsWith("file")) continue;
            var p = s.Split(',');
            int x = int.Parse(p[2]), y = int.Parse(p[3]), w = int.Parse(p[4]), h = int.Parse(p[5]);
            string k = w + "x" + h + ":" + Hash(src, x, y, w, h);
            if (!byContent.ContainsKey(k)) byContent[k] = p[0] + "#" + p[1];
        }

        var skipSet = new HashSet<string>(exclude);
        var ovr = new Dictionary<string, string>();
        for (int i = 0; i < ovKeys.Length; i++) ovr[ovKeys[i]] = ovVals[i];

        var sb = new StringBuilder();
        sb.AppendLine("atlas,col,row,w,h,semantic,status");

        var files = new List<string>(Directory.GetFiles(splitRoot, "*.png", SearchOption.AllDirectories));
        files.Sort(StringComparer.Ordinal);
        string srcFull = Path.GetFullPath(sourcePng);
        string splitFull = Path.GetFullPath(splitRoot);

        foreach (var f in files) {
            if (Path.GetFullPath(f).Equals(srcFull, StringComparison.OrdinalIgnoreCase)) continue;
            string rel = f.Substring(splitFull.Length + 1).Replace('\\', '/');
            if (skipSet.Contains(rel)) continue;
            atlases++;

            Img big;
            using (var b = new Bitmap(f)) { big = Grab(b); }

            int rows = big.h / 16, cols = big.w / 16;
            for (int r = 0; r < rows; r++) {
                for (int c = 0; c < cols; c++) {
                    int x0 = c * 16, y0 = r * 16;
                    if (!Opaque(big, x0, y0, x0 + 16, y0 + 16)) continue;
                    var bb = BBox(big, x0, y0, x0 + 16, y0 + 16);
                    int w = bb[2] - bb[0] + 1, h = bb[3] - bb[1] + 1;

                    string sem = null;
                    string ov;
                    if (ovr.TryGetValue(rel + "|" + c + "," + r, out ov)) {
                        int bar = ov.IndexOf('|');
                        string act = ov.Substring(bar + 1);
                        string val = ov.Substring(0, bar);
                        sem = (act == "set") ? val : "-";
                    } else {
                        string auto;
                        if (byContent.TryGetValue(w + "x" + h + ":" + Hash(big, bb[0], bb[1], w, h), out auto)) sem = auto;
                    }

                    string head = rel + "," + c + "," + r + "," + w + "," + h + ",";
                    if (sem == null) {
                        sb.AppendLine(head + ",unclaimed"); unclaimed++;
                    } else if (sem == "-") {
                        sb.AppendLine(head + "-,skipped"); skipped++;
                    } else {
                        sb.AppendLine(head + sem + ",matched"); matched++;
                    }
                }
            }
        }

        File.WriteAllText(outCsv, sb.ToString(), new UTF8Encoding(false));
    }
}
"@ -ReferencedAssemblies System.Drawing

function Read-List([string]$path, [switch]$SkipComments) {
	$r = @()
	if (Test-Path $path) {
		foreach ($l in ([IO.File]::ReadAllLines((Resolve-Path $path).Path, [Text.Encoding]::UTF8))) {
			$s = $l.Trim()
			if ($s -eq '') { continue }
			if ($SkipComments -and $s.StartsWith('#')) { continue }
			$r += $s
		}
	}
	return $r
}

$exclude = Read-List $ExcludeFile -SkipComments
$ovKeys = @(); $ovVals = @()
$ovLines = Read-List $OverrideFile -SkipComments | Select-Object -Skip 1
foreach ($l in $ovLines) {
	$q = $l -split ','
	if ($q.Count -lt 5) { continue }
	$ovKeys += "$($q[0])|$($q[1]),$($q[2])"
	$ovVals += "$($q[3])|$($q[4])"
}
Write-Host "excluded : $($exclude.Count)   overrides: $($ovKeys.Count)"

$m = 0; $u = 0; $s = 0; $a = 0
[PmList]::Run(
	(Resolve-Path $IndexCsv).Path,
	(Resolve-Path $SourcePng).Path,
	(Resolve-Path $SplitRoot).Path,
	(Join-Path (Get-Location).Path $OutCsv),
	[string[]]$exclude, [string[]]$ovKeys, [string[]]$ovVals,
	[ref]$m, [ref]$u, [ref]$s, [ref]$a)

Write-Host "atlases   : $a"
Write-Host "matched   : $m"
Write-Host "unclaimed : $u"
Write-Host "skipped   : $s"