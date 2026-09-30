<#
.SYNOPSIS
    通用图集拆装工具：把静态图集拆散为单格/变体多帧小图（unpack），或把小图回写图集（pack/check）。

.DESCRIPTION
    二期美术工作流核心工具（配置驱动，详见 docs/art-workflow.md）。

    以每张图集旁的 `_atlas.json` 为唯一真相：
      {
        "atlas": "core/src/assets/sprites/items/items.png",
        "outDir": "tools/atlas-meta/items/work",
        "entries": [
          { "file": "artifacts/chalice", "frames": [ {"x":208,"y":240,"w":12,"h":15}, ... ] },
          { "file": "weapons/sword",     "frames": [ {"x":0,"y":112,"w":14,"h":14} ] }
        ]
      }
    规则：
      - 同物品变体族合并为一个多帧文件（frames 多元素，横向排列，外部软件一图看全变体）。
      - 单帧条目 = 独立小图。
      - 小图尺寸 = 各帧 w×h（同族须同尺寸，否则须拆开登记）。
      - 逐像素回写（保住 ARGB 精确值，无重采样）。

.PARAMETER Action
    unpack = 图集 -> 小图（+ 写入 _atlas.json 的镜像 _index.csv）
    pack   = 小图 -> 图集
    check  = 只比对报告（不写）

.EXAMPLE
    .\tools\atlas-tool.ps1 unpack -Config tools\atlas-meta\items\_atlas.json
    .\tools\atlas-tool.ps1 pack   -Config tools\atlas-meta\items\_atlas.json
    .\tools\atlas-tool.ps1 check  -Config tools\atlas-meta\items\_atlas.json
#>
param(
    [Parameter(Mandatory)][ValidateSet('unpack','pack','check')][string]$Action,
    [Parameter(Mandatory)][string]$Config
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $Config)) { throw "配置不存在: $Config" }
$cfg = Get-Content $Config -Encoding UTF8 -Raw | ConvertFrom-Json
$atlasPath = (Resolve-Path $cfg.atlas).Path
if (-not (Test-Path $atlasPath)) { throw "图集不存在: $atlasPath" }
$outDir = (Join-Path (Get-Location).Path $cfg.outDir)

function Load-Atlas([string]$path) {
    $bmp = New-Object System.Drawing.Bitmap $path
    $rect = New-Object System.Drawing.Rectangle 0,0,$bmp.Width,$bmp.Height
    $d = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = New-Object byte[] ($d.Stride * $bmp.Height)
    [System.Runtime.InteropServices.Marshal]::Copy($d.Scan0, $bytes, 0, $bytes.Length)
    return @{ Bmp = $bmp; Data = $d; Stride = $d.Stride; Bytes = $bytes; W = $bmp.Width; H = $bmp.Height }
}

function Row-Equals([byte[]]$a, [int]$aOff, [byte[]]$b, [int]$bOff, [int]$len) {
    for ($i = 0; $i -lt $len; $i++) { if ($a[$aOff + $i] -ne $b[$bOff + $i]) { return $false } }
    return $true
}

switch ($Action) {

    'unpack' {
        $atlas = Load-Atlas $atlasPath
        $indexRows = New-Object System.Collections.ArrayList
        $written = 0
        foreach ($entry in $cfg.entries) {
            $frames = @($entry.frames)
            $fw = [int]$frames[0].w; $fh = [int]$frames[0].h
            foreach ($f in $frames) {
                if ([int]$f.w -ne $fw -or [int]$f.h -ne $fh) {
                    throw "同族帧尺寸不一致（$($entry.file)）：$fw x $fh 与 $($f.w) x $($f.h)。请拆成独立条目。"
                }
            }
            $sheetW = $fw * $frames.Count
            $sheet = New-Object System.Drawing.Bitmap $sheetW, $fh, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            for ($i = 0; $i -lt $frames.Count; $i++) {
                $fx = [int]$frames[$i].x; $fy = [int]$frames[$i].y
                if ($fx -lt 0 -or $fx + $fw -gt $atlas.W -or $fy -lt 0 -or $fy + $fh -gt $atlas.H) {
                    throw "帧越界（$($entry.file) 帧$i @ $fx,$fy）"
                }
                for ($y = 0; $y -lt $fh; $y++) {
                    for ($x = 0; $x -lt $fw; $x++) {
                        $off = ($fy + $y) * $atlas.Stride + ($fx + $x) * 4
                        $argb = [BitConverter]::ToInt32($atlas.Bytes, $off)
                        $c = [System.Drawing.Color]::FromArgb(
                            ($argb -shr 24) -band 0xFF, ($argb -shr 16) -band 0xFF,
                            ($argb -shr 8) -band 0xFF, $argb -band 0xFF)
                        $sheet.SetPixel($i * $fw + $x, $y, $c)
                    }
                }
                [void]$indexRows.Add([pscustomobject]@{
                    file = $entry.file; frameIndex = $i; x = $fx; y = $fy; w = $fw; h = $fh
                })
            }
            $target = Join-Path $outDir ($entry.file + '.png')
            New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
            $sheet.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
            $sheet.Dispose()
            $written++
        }
        $atlas.Bmp.UnlockBits($atlas.Data); $atlas.Bmp.Dispose()
        $csv = New-Object System.Text.StringBuilder
        [void]$csv.AppendLine('file,frameIndex,x,y,w,h')
        foreach ($r in $indexRows) { [void]$csv.AppendLine("$($r.file),$($r.frameIndex),$($r.x),$($r.y),$($r.w),$($r.h)") }
        [IO.File]::WriteAllText((Join-Path $outDir '_index.csv'), $csv.ToString(), (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "unpack 完成：$written 个文件（$($indexRows.Count) 帧） -> $($cfg.outDir)"
    }

    { $_ -in 'pack','check' } {
        $atlas = Load-Atlas $atlasPath
        $changed = 0; $same = 0; $missing = @(); $errors = @(); $report = @()
        # 按 file 分组的行（frames 共享同一小图）
        $byFile = @{}
        foreach ($row in (Import-Csv (Join-Path $outDir '_index.csv') -Encoding UTF8)) {
            if (-not $byFile.ContainsKey($row.file)) { $byFile[$row.file] = @() }
            $byFile[$row.file] += $row
        }
        foreach ($file in $byFile.Keys) {
            $imgPath = Join-Path $outDir ($file + '.png')
            if (-not (Test-Path $imgPath)) { $missing += $file; continue }
            $rows = @(@($byFile[$file]) | Sort-Object { [int]$_.frameIndex })
            $r0 = @($rows)[0]
            $fw = [int]$r0.w; $fh = [int]$r0.h
            if ($fw -le 0 -or $fh -le 0) {
                $errors += "$file 索引行异常: w=$($r0.w) h=$($r0.h)"; continue
            }
            $bmp = New-Object System.Drawing.Bitmap $imgPath
            if ($bmp.Width -ne ($fw * $rows.Count) -or $bmp.Height -ne $fh) {
                $gotW = $bmp.Width; $gotH = $bmp.Height; $bmp.Dispose()
                $errors += "$file 尺寸应为 $($fw * $rows.Count)x$fh，实际 ${gotW}x${gotH}"
                continue
            }
            $rect = New-Object System.Drawing.Rectangle 0,0,$bmp.Width,$bmp.Height
            $d = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $srcBytes = New-Object byte[] ($d.Stride * $bmp.Height)
            [System.Runtime.InteropServices.Marshal]::Copy($d.Scan0, $srcBytes, 0, $srcBytes.Length)
            $srcStride = $d.Stride
            foreach ($row in $rows) {
                $i = [int]$row.frameIndex; $fx = [int]$row.x; $fy = [int]$row.y
                $diff = $false
                for ($y = 0; $y -lt $fh; $y++) {
                    $srcOff = $y * $srcStride + $i * $fw * 4
                    $dstOff = ($fy + $y) * $atlas.Stride + $fx * 4
                    if (-not (Row-Equals $srcBytes $srcOff $atlas.Bytes $dstOff ($fw * 4))) {
                        $diff = $true
                        if ($Action -eq 'pack') {
                            [Array]::Copy($srcBytes, $srcOff, $atlas.Bytes, $dstOff, ($fw * 4))
                        }
                    }
                }
                if ($diff) { $changed++; $report += "$file#$i ($fx,$fy) $($fw)x$($fh)" } else { $same++ }
            }
            $bmp.UnlockBits($d); $bmp.Dispose()
        }
        # 把内存副本拷回 Bitmap 显存（否则 GDI+ 保存的是未修改的原像素）
        [System.Runtime.InteropServices.Marshal]::Copy($atlas.Bytes, 0, $atlas.Data.Scan0, $atlas.Bytes.Length)
        $atlas.Bmp.UnlockBits($atlas.Data)
        if ($Action -eq 'pack' -and $changed -gt 0) {
            $backup = "$atlasPath.pack-backup.png"
            Copy-Item $atlasPath $backup -Force
            $tmp = "$atlasPath.tmp.png"
            $atlas.Bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
            $atlas.Bmp.Dispose()   # 释放源文件句柄后再覆盖（GDI+ Bitmap 持锁）
            Move-Item $tmp $atlasPath -Force
            Write-Host "已备份原图集: $backup"
        } else {
            $atlas.Bmp.Dispose()
        }
        Write-Host "$Action 完成：更新 $changed 帧、未变 $same 帧。"
        if ($report.Count -gt 0) { $report | Select-Object -First 20 | ForEach-Object { Write-Host "  * $_" } }
        if ($missing.Count -gt 0) { Write-Host "缺失小图：" -ForegroundColor Yellow; $missing | ForEach-Object { Write-Host "  ? $_" } }
        if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Red }; exit 1 }
    }
}
