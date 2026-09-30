param(
	[string]$LegacyPlants = (Join-Path $PSScriptRoot '..\..\SPS-PD-0.9.8\SPS-PD-0.9.8\assets\plants.png'),
	[string]$TargetAtlas = (Join-Path $PSScriptRoot '..\core\src\assets\environment\terrain_features.png')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$LegacyPlants = (Resolve-Path -LiteralPath $LegacyPlants).Path
$TargetAtlas = (Resolve-Path -LiteralPath $TargetAtlas).Path
$targetDirectory = Split-Path -Parent $TargetAtlas
$temporaryAtlas = Join-Path $targetDirectory 'terrain_features.sps-atlas.tmp.png'

$source = [System.Drawing.Bitmap]::FromFile($LegacyPlants)
$current = [System.Drawing.Bitmap]::FromFile($TargetAtlas)
$updated = New-Object System.Drawing.Bitmap 256, 288, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
try {
	for ($y = 0; $y -lt $current.Height; $y++) {
		for ($x = 0; $x -lt $current.Width; $x++) {
			$updated.SetPixel($x, $y, $current.GetPixel($x, $y))
		}
	}
	for ($index = 0; $index -lt 19; $index++) {
		$sourceLeft = $index * 16
		$targetLeft = ($index % 16) * 16
		$targetTop = 256 + [Math]::Floor($index / 16) * 16
		for ($y = 0; $y -lt 16; $y++) {
			for ($x = 0; $x -lt 16; $x++) {
				$updated.SetPixel($targetLeft + $x, $targetTop + $y,
					$source.GetPixel($sourceLeft + $x, $y))
			}
		}
	}
} finally {
	$current.Dispose()
	$source.Dispose()
}

try {
	$updated.Save($temporaryAtlas, [System.Drawing.Imaging.ImageFormat]::Png)
} finally {
	$updated.Dispose()
}
Move-Item -LiteralPath $temporaryAtlas -Destination $TargetAtlas -Force
