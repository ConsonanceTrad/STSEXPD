<#
.SYNOPSIS
    把 assets-src/items 下的单格小图回写到游戏物品图集 items.png。

.DESCRIPTION
    二期美术工作流工具（配套 docs/art-workflow.md）：
      1. 在 assets-src/items/<类别>/ 下用外部软件编辑 16x16 小图（重绘/替换）。
      2. 运行本脚本，小图逐像素回写到 core/src/main/assets/sprites/items/items.png。
      3. 游戏内目验（verifySpsRelease 门禁已退出必跑流程，需要抽查时手动跑）。

    映射来源：assets-src/items/_index.csv（由 art-index/导出工具生成：
    常量名, 类别, 文件, col, row, sliceW, sliceH）。

    安全特性：写前自动备份图集（items.png.pack-backup）；逐像素无重采样；
    尺寸/未知文件名严格校验。-CheckOnly 只报告不写入。

.EXAMPLE
    .\tools\pack-item-icons.ps1              # 回写全部
    .\tools\pack-item-icons.ps1 -CheckOnly   # 只检查差异
    .\tools\pack-item-icons.ps1 -Only BLACKBERRY,MOONBERRY  # 只回写指定图标
#>
param(
    [string]   $SourceDir  = (Join-Path $PSScriptRoot '..\assets-src\items'),
    [string]   $TargetAtlas = (Join-Path $PSScriptRoot '..\core\src\main\assets\sprites\items\items.png'),
    [string[]] $Only = @(),
    [switch]   $CheckOnly
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $SourceDir))  { throw "小图目录不存在: $SourceDir" }
if (-not (Test-Path $TargetAtlas)) { throw "目标图集不存在: $TargetAtlas" }

# ---- 读索引 ----
$indexPath = Join-Path $SourceDir '_index.csv'
if (-not (Test-Path $indexPath)) { throw "缺少索引: $indexPath（应为 constant,category,file,col,row,sliceW,sliceH）" }
$map = @{}
foreach ($line in (Get-Content $indexPath -Encoding UTF8 | Select-Object -Skip 1)) {
    if ($line -notmatch ',') { continue }
    $f = $line -split ','
    if ($f.Count -lt 5) { continue }
    $map[$f[0].Trim()] = @{ Col = [int]$f[3]; Row = [int]$f[4] }
}

function Load-Bytes([string]$path) {
    $bmp = New-Object System.Drawing.Bitmap ((Resolve-Path $path).Path)
    if ($bmp.Width -ne 16 -or $bmp.Height -ne 16) {
        $w = $bmp.Width; $h = $bmp.Height
        $bmp.Dispose()
        throw "尺寸必须为 16x16（$path 为 ${w}x${h}）"
    }
    $rect = New-Object System.Drawing.Rectangle 0,0,16,16
    $d = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $buf = New-Object byte[] ($d.Stride * 16)
    [System.Runtime.InteropServices.Marshal]::Copy($d.Scan0, $buf, 0, $buf.Length)
    $stride = $d.Stride
    $bmp.UnlockBits($d); $bmp.Dispose()
    return @{ Stride = $stride; Bytes = $buf }
}

# ---- 载入目标图集 ----
$atlas = New-Object System.Drawing.Bitmap ((Resolve-Path $TargetAtlas).Path)
$atlasRect = New-Object System.Drawing.Rectangle 0,0,$atlas.Width,$atlas.Height
$atlasData = $atlas.LockBits($atlasRect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$atlasStride = $atlasData.Stride
$changed = 0; $same = 0; $unknown = @(); $errors = @()
$report = @()

foreach ($file in (Get-ChildItem $SourceDir -Recurse -File -Filter *.png | Where-Object { $_.Name -notlike '_*' })) {
    $const = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($Only.Count -gt 0 -and $Only -notcontains $const) { continue }
    if (-not $map.ContainsKey($const)) { $unknown += $const; continue }

    try {
        $src = Load-Bytes $file.FullName
        $col = $map[$const].Col; $row = $map[$const].Row
        $gx = $col * 16; $gy = $row * 16
        if ($gx -lt 0 -or $gx + 16 -gt $atlas.Width -or $gy -lt 0 -or $gy + 16 -gt $atlas.Height) {
            $errors += "$const 格坐标越界 ($col,$row)"; continue
        }
        # 逐行（64 字节 = 16 像素）比较并按需写入
        $diff = $false
        for ($y = 0; $y -lt 16; $y++) {
            $srcOff = $y * $src.Stride
            $dstOff = ($gy + $y) * $atlasStride + $gx * 4
            $tmp = New-Object byte[] 64
            [Array]::Copy($src.Bytes, $srcOff, $tmp, 0, 64)
            $dstStart = [IntPtr]::Add($atlasData.Scan0, $dstOff)
            $cmp = New-Object byte[] 64
            [System.Runtime.InteropServices.Marshal]::Copy($dstStart, $cmp, 0, 64)
            $equal = $true
            for ($k = 0; $k -lt 64; $k++) { if ($tmp[$k] -ne $cmp[$k]) { $equal = $false; break } }
            if (-not $equal) {
                $diff = $true
                if (-not $CheckOnly) { [System.Runtime.InteropServices.Marshal]::Copy($tmp, 0, $dstStart, 64) }
            }
        }
        if ($diff) { $changed++; $report += "$const ($col,$row)" } else { $same++ }
    } catch {
        $errors += "$const : $($_.Exception.Message)"
    }
}

if (-not $CheckOnly) {
    $atlas.UnlockBits($atlasData)
    if ($changed -gt 0) {
        $backup = "$TargetAtlas.pack-backup.png"
        Copy-Item $TargetAtlas $backup -Force
        $tmpPath = "$TargetAtlas.tmp.png"
        $atlas.Save($tmpPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Move-Item $tmpPath $TargetAtlas -Force
        Write-Host "已备份原图集到: $backup"
    }
} else {
    $atlas.UnlockBits($atlasData)
}
$atlas.Dispose()

Write-Host ""
if ($CheckOnly) { Write-Host "[CheckOnly] " -NoNewline }
Write-Host "回写结果：更新 $changed 格、未变 $same 格。"
if ($changed -gt 0) { $report | ForEach-Object { Write-Host "  * $_" } }
if ($unknown.Count -gt 0) {
    Write-Host ""
    Write-Host "以下文件不在 _index.csv 中（新图标需先在 ItemSpriteSheet 中加常量并分配图集空位）："
    $unknown | ForEach-Object { Write-Host "  ? $_" }
}
if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "错误：" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  ! $_" -ForegroundColor Red }
    exit 1
}
exit 0
