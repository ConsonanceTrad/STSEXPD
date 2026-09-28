param(
	[string]$LegacySprite = (Join-Path $PSScriptRoot '..\..\SPS-PD-0.9.8\SPS-PD-0.9.8\assets\orbofzot.png'),
	[string]$TargetSprite = (Join-Path $PSScriptRoot '..\core\src\main\assets\sprites\sps_orbofzot.png')
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $LegacySprite).Path
$targetDirectory = Split-Path -Parent $TargetSprite
if (-not (Test-Path -LiteralPath $targetDirectory)) {
	New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}
Copy-Item -LiteralPath $source -Destination $TargetSprite -Force
