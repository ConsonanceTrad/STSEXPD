param(
    [string]$LegacyRoot = (Join-Path $PSScriptRoot '..\..\SPS-PD-0.9.8\SPS-PD-0.9.8'),
    [string]$Target = (Join-Path $PSScriptRoot '..\core\src\main\java\com\shatteredpixel\shatteredpixeldungeon\levels\SpsBossLayouts.java')
)

$ErrorActionPreference = 'Stop'

function Read-Layout([string]$FileName, [string]$ArrayName) {
    $sourcePath = Join-Path $LegacyRoot "java\com\hmdzl\spspd\levels\$FileName"
    $source = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $sourcePath))
    $pattern = "private\s+static\s+final\s+int\[\]\s+$ArrayName\s*=\s*\{(?<body>[\s\S]*?)\};"
    $match = [regex]::Match($source, $pattern)
    if (-not $match.Success) { throw "Unable to locate $ArrayName in $sourcePath" }
    return $match.Groups['body'].Value.Trim()
}

$sewers = Read-Layout 'SewerBossLevel.java' 'MAP_S_START'
$prison = Read-Layout 'PrisonBossLevel.java' 'MAP_P_START'
$prison = [regex]::Replace($prison, '\bI\b', 'Terrain.HIGH_GRASS')
$prison = [regex]::Replace($prison, '\bT\b', 'Terrain.INACTIVE_TRAP')
$header = @'
/* Generated from SPS-PD 0.9.8 by tools/import-legacy-boss-layouts.ps1. */
package com.shatteredpixel.shatteredpixeldungeon.levels;

final class SpsBossLayouts {
    private static final int W = Terrain.WALL;
    private static final int D = Terrain.DOOR;
    private static final int B = Terrain.SECRET_DOOR;
    private static final int I = Terrain.GLASS_WALL;
    private static final int O = Terrain.EMPTY;
    private static final int S = Terrain.SIGN;
    private static final int A = Terrain.WATER;
    private static final int T = Terrain.EMPTY_DECO;
    private static final int E = Terrain.ENTRANCE;
    private static final int X = Terrain.LOCKED_EXIT;
    private static final int F = Terrain.EMPTY_SP;
    private static final int C = Terrain.GROUND_A;
    private static final int M = Terrain.WALL_DECO;
    private static final int P = Terrain.PEDESTAL;

'@
$footer = @'

    private SpsBossLayouts() {
    }
}
'@
$java = $header + "    static final int[] SEWERS = {`r`n$sewers`r`n    };`r`n`r`n" +
        "    static final int[] PRISON = {`r`n$prison`r`n    };" + $footer
[IO.File]::WriteAllText($Target, $java, [Text.UTF8Encoding]::new($false))
Write-Output "Imported SPS boss layouts to $Target"
