#   wrap-npc-windows.ps1
#   Wrap window construction in NPC interact() paths with Game.runOnRenderThread.
#
#   Constructing a Window measures text, which may only happen on the render thread.
#   On the actor thread it throws "Text measured from the actor thread!". This script
#   inserts a small showWindow(Supplier<Window>) helper into the class and rewrites
#   `GameScene.show(<expr>)` into `showWindow(() -> <expr>)`, using real paren matching
#   (not a naive regex) so nested constructor calls stay intact.
#
#   Usage: .\tools\wrap-npc-windows.ps1 -File core/src/java/pd/actors/mobs/npcs/TownNpc.java [-WhatIf]

param(
	[string]$File,
	[switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path
$path = Join-Path $repoRoot ($File -replace '/', '\')

$t = [IO.File]::ReadAllText($path, $utf8)
$orig = $t

# ---- 1. imports + helper ----
if ($t -notmatch 'private static void showWindow') {
	$t = $t -replace '(?m)^import pd\.scenes\.GameScene;',
		("import pd.scenes.GameScene;`r`n" +
		 "import pd.ui.Window;`r`n" +
		 "import render.noosa.Game;`r`n" +
		 "import render.utils.data.Callback;`r`n" +
		 "`r`nimport java.util.function.Supplier;")

	$cm = [regex]::Match($t, '(?m)^(?:public\s+)?class\s+\w+[^{]*\{')
	if (-not $cm.Success) { throw 'no class header' }

	$helper = @"


	//SPSXPD: window construction measures text, which must happen on the render thread.
	//Called from the actor thread it throws "Text measured from the actor thread!", so
	//route every popup through here instead of calling the scene directly.
	private static void showWindow(final Supplier<Window> factory){
		Game.runOnRenderThread(new Callback(){
			@Override public void call(){ __HELPER_SHOW__(factory.get()); }
		});
	}
"@
	$t = $t.Insert($cm.Index + $cm.Length, $helper)
}

# ---- 2. paren-matched rewrite ----
$needle = 'GameScene.show('
$count = 0
$idx = 0
while ($true) {
	$idx = $t.IndexOf($needle, $idx)
	if ($idx -lt 0) { break }

	$open = $idx + $needle.Length           # index just after '('
	$depth = 1
	$i = $open
	while ($i -lt $t.Length -and $depth -gt 0) {
		$c = $t[$i]
		if ($c -eq '(') { $depth++ }
		elseif ($c -eq ')') { $depth-- }
		$i++
	}
	if ($depth -ne 0) { throw "unbalanced parens at offset $idx" }

	$inner = $t.Substring($open, ($i - 1) - $open)
	$repl = "showWindow(() -> $inner)"
	$t = $t.Substring(0, $idx) + $repl + $t.Substring($i)
	$idx = $idx + $repl.Length
	$count++
}

# restore the helper's own call now that user code has been rewritten
$t = $t.Replace('__HELPER_SHOW__(', 'GameScene.show(')

"rewritten calls: $count   (WhatIf=$WhatIf)"

# the helper's own body legitimately still calls GameScene.show
$remain = @([regex]::Matches($t, 'GameScene\.show\(')).Count
"remaining raw GameScene.show( occurrences (expect 1, inside the helper): $remain"

if ($t -ne $orig -and -not $WhatIf) {
	[IO.File]::WriteAllText($path, $t, $utf8)
	"written: $File"
}
