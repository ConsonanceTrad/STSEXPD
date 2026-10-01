# list-item-atlas-cells.ps1
#   Emit an editable "claim list" for every icon cell of the split item atlases.
#   Already-claimed cells are listed too so historical misplacements can be corrected.
# Usage:  .\tools\list-item-atlas-cells.ps1
# Output: tools/atlas-meta/items-claims.csv   (atlas,col,row,w,h,semantic,status)
# Keep this file ASCII-only (PowerShell 5.1 reads BOM-less files as ANSI).

param(
	[string]$IndexCsv = 'tools/atlas-meta/items/_index.csv',
	[string]$SourcePng = 'core/src/assets/sprites/items/items.png',
	[string]$SplitRoot = 'core/src/assets/sprites/items',
	[string]$OutCsv = 'tools/atlas-meta/items-claims.csv'
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

    static bool MatchAt(Img big, Img tpl, int tx, int ty, int x, int y, int w, int h) {
        for (int yy = 0; yy < h; yy++) {
            int bi = (y + yy) * big.stride + x * 4;
            int ti = (ty + yy) * tpl.stride + tx * 4;
            for (int xx = 0; xx < w * 4; xx++) if (big.px[bi + xx] != tpl.px[ti + xx]) return false;
        }
        return true;
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

    public static string Run(string indexCsv, string sourcePng, string splitRoot, string outCsv,
                             out int matched, out int unclaimed, out int atlases) {
        matched = 0; unclaimed = 0; atlases = 0;
        Img src;
        using (var b = new Bitmap(sourcePng)) { src = Grab(b); }

        var entries = new List<int[]>();
        var names = new List<string>();
        foreach (var line in File.ReadAllLines(indexCsv)) {
            var s = line.Trim();
            if (s.Length == 0 || s.StartsWith("file")) continue;
            var p = s.Split(',');
            entries.Add(new int[] { int.Parse(p[2]), int.Parse(p[3]), int.Parse(p[4]), int.Parse(p[5]) });
            names.Add(p[0] + "#" + p[1]);
        }

        var sb = new StringBuilder();
        sb.AppendLine("atlas,col,row,w,h,semantic,status");

        var files = new List<string>(Directory.GetFiles(splitRoot, "*.png", SearchOption.AllDirectories));
        files.Sort(StringComparer.Ordinal);
        string srcFull = Path.GetFullPath(sourcePng);
        string splitFull = Path.GetFullPath(splitRoot);

        foreach (var f in files) {
            if (Path.GetFullPath(f).Equals(srcFull, StringComparison.OrdinalIgnoreCase)) continue;
            atlases++;
            string rel = f.Substring(splitFull.Length + 1).Replace('\\', '/');
            Img big;
            using (var b = new Bitmap(f)) { big = Grab(b); }

            var claimed = new Dictionary<string, string>();
            for (int i = 0; i < entries.Count; i++) {
                var e = entries[i];
                if (e[2] > big.w || e[3] > big.h) continue;
                bool done = false;
                for (int y = 0; y + e[3] <= big.h && !done; y++) {
                    for (int x = 0; x + e[2] <= big.w; x++) {
                        if (!MatchAt(big, src, e[0], e[1], x, y, e[2], e[3])) continue;
                        string k = x + "," + y + "," + e[2] + "," + e[3];
                        if (!claimed.ContainsKey(k)) claimed[k] = names[i];
                        done = true;
                        break;
                    }
                }
            }

            var cellSem = new Dictionary<string, string>();
            foreach (var kv in claimed) {
                var p = kv.Key.Split(',');
                int bx = int.Parse(p[0]), by = int.Parse(p[1]), bw = int.Parse(p[2]), bh = int.Parse(p[3]);
                int c0 = bx / 16, r0 = by / 16, c1 = (bx + bw - 1) / 16, r1 = (by + bh - 1) / 16;
                for (int rr = r0; rr <= r1; rr++)
                    for (int cc = c0; cc <= c1; cc++)
                        cellSem[cc + "," + rr] = kv.Value + "," + bw + "," + bh;
            }

            int rows = big.h / 16, cols = big.w / 16;
            for (int r = 0; r < rows; r++) {
                for (int c = 0; c < cols; c++) {
                    string ck = c + "," + r;
                    string cs;
                    if (cellSem.TryGetValue(ck, out cs)) {
                        var parts = cs.Split(',');
                        sb.AppendLine(rel + "," + c + "," + r + "," + parts[1] + "," + parts[2] + "," + parts[0] + ",matched");
                        matched++;
                        continue;
                    }
                    int x0 = c * 16, y0 = r * 16;
                    if (!Opaque(big, x0, y0, x0 + 16, y0 + 16)) continue;
                    var bb = BBox(big, x0, y0, x0 + 16, y0 + 16);
                    sb.AppendLine(rel + "," + c + "," + r + "," + (bb[2] - bb[0] + 1) + "," + (bb[3] - bb[1] + 1) + ",,unclaimed");
                    unclaimed++;
                }
            }
        }

        File.WriteAllText(outCsv, sb.ToString(), new UTF8Encoding(false));
        return outCsv;
    }
}
"@ -ReferencedAssemblies System.Drawing

$matched = 0; $unclaimed = 0; $atlases = 0
[PmList]::Run(
	(Resolve-Path $IndexCsv).Path,
	(Resolve-Path $SourcePng).Path,
	(Resolve-Path $SplitRoot).Path,
	(Join-Path (Get-Location).Path $OutCsv),
	[ref]$matched, [ref]$unclaimed, [ref]$atlases) | Out-Null

Write-Host "atlases   : $atlases"
Write-Host "matched   : $matched"
Write-Host "unclaimed : $unclaimed"