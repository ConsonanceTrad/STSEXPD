# SPS: 生成 interfaces/side_toolbar.png —— 左右快捷栏专用格子背景与整栏外框。
# 不再旋转下栏纹理；按定案程序化绘制（色值取自 toolbar.png 单格帧 64,0,22,24）：
#   frame line = #A3A695（亮外框线）、cell fill = #73786C、dark seam = #494D45（描黑，兼格间/外框隔断）
# 帧布局（画布 94x22）：
#   CELL    (0,0,22,22)  格子背景：四边 1px 描黑描边 + 20x20 填充，整体正方形
#   TOPCAP  (22,0,24,1)  上帽：1 行亮框线
#   SIDE    (46,0,24,20) 竖线段：左右各 1px 亮框线（按需裁高拼接）
#   BOTCAP  (70,0,24,1)  下帽：1 行亮框线
# 布局语义：格子描边与外框隔断/格间隔线重叠共享（1px 描黑）；格竖向步进 21（22-1 重叠）。
# 用法：powershell -ExecutionPolicy Bypass -File tools/make-side-toolbar.ps1
param(
	[string]$Source = (Join-Path $PSScriptRoot '..\core\src\assets\interfaces\toolbar.png'),
	[string]$Target = (Join-Path $PSScriptRoot '..\core\src\assets\interfaces\side_toolbar.png')
)

Add-Type -AssemblyName System.Drawing

$src = New-Object System.Drawing.Bitmap((Resolve-Path $Source).Path)
try {
	# 从下栏单格帧取样色值（保持同色系）
	$frameColor = $src.GetPixel(64 + 10, 0)     # 亮外框线 #A3A695
	$fillColor  = $src.GetPixel(64 + 10, 10)    # 格填充   #73786C
	$darkColor  = $src.GetPixel(64 + 10, 23)    # 描黑隔断 #494D45

	$out = New-Object System.Drawing.Bitmap(94, 22)

	# CELL (0,0,22,22)：四边 1px 描黑 + 20x20 填充
	for ($y = 0; $y -lt 22; $y++) {
		for ($x = 0; $x -lt 22; $x++) {
			$edge = ($x -eq 0 -or $x -eq 21 -or $y -eq 0 -or $y -eq 21)
			$out.SetPixel($x, $y, $(if ($edge) { $darkColor } else { $fillColor }))
		}
	}

	# TOPCAP (22,0,24,1)：1 行亮框线
	for ($x = 0; $x -lt 24; $x++) { $out.SetPixel(22 + $x, 0, $frameColor) }

	# SIDE (46,0,24,20)：左右 1px 亮框线，中空填格填充色（被 CELL 覆盖作兜底）
	for ($y = 0; $y -lt 20; $y++) {
		for ($x = 0; $x -lt 24; $x++) {
			$c = if ($x -eq 0 -or $x -eq 23) { $frameColor } else { $fillColor }
			$out.SetPixel(46 + $x, $y, $c)
		}
	}

	# BOTCAP (70,0,24,1)：1 行亮框线
	for ($x = 0; $x -lt 24; $x++) { $out.SetPixel(70 + $x, 0, $frameColor) }

	$out.Save($Target, [System.Drawing.Imaging.ImageFormat]::Png)
	Write-Host ("generated {0} (frame=#{1:X2}{2:X2}{3:X2} fill=#{4:X2}{5:X2}{6:X2} dark=#{7:X2}{8:X2}{9:X2})" -f `
		$Target, $frameColor.R, $frameColor.G, $frameColor.B, `
		$fillColor.R, $fillColor.G, $fillColor.B, $darkColor.R, $darkColor.G, $darkColor.B)
} finally {
	$src.Dispose()
}
