# pack-item-atlas.ps1
#   Row-wise vertical merge: stack each split atlas (top to bottom) into one big items.png,
#   using the full cell width (widest atlas wins). Also emits the row/cell block tables
#   that code uses to locate an icon by semantic name instead of a hard-coded cell index.
#
# Usage:
#   .\tools\pack-item-atlas.ps1            # write items.png + block tables
#   .\tools\pack-item-atlas.ps1 -Check     # report only, do not write
#
# Input : tools/atlas-meta/items-claims.csv   (atlas,col,row,w,h,semantic,status)
# Output: core/src/assets/sprites/items/items.png
#         tools/atlas-meta/items-atlas-rows.csv    row,cellIndexStart,atlas,semanticPrefix
#         tools/atlas-meta/items-atlas-cells.csv   semantic,cell,w,h
#
# Keep this file ASCII-only (PowerShell 5.1 reads BOM-less files as ANSI).

param(
	[string]$ClaimsCsv = 'tools/atlas-meta/items-claims.csv',
	[string]$SplitRoot = 'core/src/assets/sprites/items',
	[string]$OutPng    = 'core/src/assets/sprites/items/items.png',
	[string]$RowsCsv   = 'tools/atlas-meta/items-atlas-rows.csv',
	[string]$CellsCsv  = 'tools/atlas-meta/items-atlas-cells.csv',
	[switch]$Check
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Text;

public class PmPack {
    // returns: 0 OK, 1 nothing to do, 2 error (message out)
    public static int Run(string claimsCsv, string splitRoot, string outPng,
                          string rowsCsv, string cellsCsv, bool check,
                          out string message, out int rowsTotal, out int cellW, out int cellH) {
        message = ""; rowsTotal = 0; cellW = 0; cellH = 0;
        var lines = File.ReadAllLines(claimsCsv);
        if (lines.Length < 2) { message = "claims csv is empty"; return 2; }

        // parse claims
        var cells = new List<string[]>();          // atlas,col,row,w,h,semantic,status
        var atlasOrder = new List<string>();
        var seen = new HashSet<string>();
        for (int i = 1; i < lines.Length; i++) {
            var s = lines[i].Trim();
            if (s.Length == 0) continue;
            var p = s.Split(',');
            if (p.Length < 7) continue;
            cells.Add(p);
            if (!seen.Contains(p[0])) { seen.Add(p[0]); atlasOrder.Add(p[0]); }
        }
        if (cells.Count == 0) { message = "no cells"; return 2; }

        string splitFull = Path.GetFullPath(splitRoot);

        // atlas sizes -> max width is the output width; rows are stacked in atlas order
        var atlasW = new Dictionary<string, int>();
        var atlasH = new Dictionary<string, int>();
        int maxW = 0;
        foreach (var a in atlasOrder) {
            string path = Path.Combine(splitFull, a.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(path)) { message = "missing atlas: " + a; return 2; }
            using (var b = new Bitmap(path)) {
                atlasW[a] = b.Width; atlasH[a] = b.Height;
                if (b.Width > maxW) maxW = b.Width;
            }
        }
        cellW = maxW / 16;
        if (maxW % 16 != 0) { message = "atlas width not multiple of 16: " + maxW; return 2; }

        // row offset per atlas, and total rows
        var rowOffset = new Dictionary<string, int>();
        int off = 0;
        foreach (var a in atlasOrder) {
            rowOffset[a] = off;
            off += atlasH[a] / 16;
        }
        rowsTotal = off;
        cellH = rowsTotal;
        int outW = cellW * 16;
        int outH = rowsTotal * 16;

        // build block tables
        var rows = new StringBuilder();
        rows.AppendLine("row,cellIndexStart,atlas");
        foreach (var a in atlasOrder) {
            int nrows = atlasH[a] / 16;
            for (int r = 0; r < nrows; r++) {
                int finalRow = rowOffset[a] + r;
                rows.AppendLine(finalRow + "," + (finalRow * cellW) + "," + a);
            }
        }

        var cb = new StringBuilder();
        cb.AppendLine("semantic,cell,atlas,col,row,w,h");
        int placed = 0, skipped = 0;
        foreach (var p in cells) {
            string a = p[0], sem = p[5];
            int col = int.Parse(p[1]), row = int.Parse(p[2]);
            int w = int.Parse(p[3]), h = int.Parse(p[4]);
            if (sem.Length == 0) { skipped++; continue; }
            int finalRow = rowOffset[a] + row;
            int cell = finalRow * cellW + col;
            cb.AppendLine(sem + "," + cell + "," + a + "," + col + "," + finalRow + "," + w + "," + h);
            placed++;
        }

        if (check) {
            message = "check only: would pack " + placed + " cells (" + skipped + " unclaimed skipped), "
                    + cellW + "x" + rowsTotal + " cells = " + outW + "x" + outH + " px";
            return 0;
        }

        // draw: copy each 16x16 cell from its atlas into the stacked position
        using (var outp = new Bitmap(outW, outH, PixelFormat.Format32bppArgb)) {
            using (var g = Graphics.FromImage(outp)) { g.Clear(Color.Transparent); }
            // group cells by atlas so each atlas bitmap opens once
            foreach (var a in atlasOrder) {
                string path = Path.Combine(splitFull, a.Replace('/', Path.DirectorySeparatorChar));
                using (var src = new Bitmap(path)) {
                    foreach (var p in cells) {
                        if (p[0] != a) continue;
                        if (p[5].Length == 0 || p[5] == "-") continue;   // unclaimed / skipped: leave transparent
                        int col = int.Parse(p[1]), row = int.Parse(p[2]);
                        int finalRow = rowOffset[a] + row;
                        for (int y = 0; y < 16; y++) {
                            for (int x = 0; x < 16; x++) {
                                int sx = col * 16 + x, sy = row * 16 + y;
                                if (sx >= src.Width || sy >= src.Height) continue;
                                var c = src.GetPixel(sx, sy);
                                if (c.A == 0) continue;
                                outp.SetPixel(col * 16 + x, finalRow * 16 + y, c);
                            }
                        }
                    }
                }
            }
            Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(outPng)));
            // never lose the previous file: keep a backup next to it before overwriting
            if (File.Exists(outPng)) {
                File.Copy(outPng, outPng + ".pack-backup.png", true);
            }
            outp.Save(outPng, ImageFormat.Png);
        }

        File.WriteAllText(rowsCsv, rows.ToString(), new UTF8Encoding(false));
        File.WriteAllText(cellsCsv, cb.ToString(), new UTF8Encoding(false));
        message = "packed " + placed + " cells (" + skipped + " unclaimed skipped) -> "
                + cellW + "x" + rowsTotal + " cells = " + outW + "x" + outH + " px";
        return 0;
    }
}
"@ -ReferencedAssemblies System.Drawing

$message = ''; $rowsTotal = 0; $cw = 0; $ch = 0
$rc = [PmPack]::Run(
	(Resolve-Path $ClaimsCsv).Path,
	(Resolve-Path $SplitRoot).Path,
	(Join-Path (Get-Location).Path $OutPng),
	(Join-Path (Get-Location).Path $RowsCsv),
	(Join-Path (Get-Location).Path $CellsCsv),
	[bool]$Check, [ref]$message, [ref]$rowsTotal, [ref]$cw, [ref]$ch)

Write-Host $message
exit $rc