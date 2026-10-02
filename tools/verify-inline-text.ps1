#   verify-inline-text.ps1
#   Compare every inlined Chinese string against the zh properties entry it replaced.
#
#   Both sides are unescaped to real characters before comparing, so the check is
#   independent of how the text was stored. Reports:
#     OK        - identical
#     DIFF      - both present but different
#     NO_PROP   - inlined entry has no matching properties key (expected for the 13
#                 keys whose class no longer exists, or for hand-added text)
#     NO_INLINE - properties key not inlined (should only be the known leftovers)

param(
	[string]$JavaRoot = 'core/src/java',
	[string]$Messages = 'core/src/assets/messages',
	[string]$Purpose  = 'items',
	[int]$ShowDiffs   = 20
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).Path
$utf8 = New-Object Text.UTF8Encoding($false)

function From-Escaped([string]$s) {
	$sb = New-Object Text.StringBuilder
	$i = 0
	while ($i -lt $s.Length) {
		$c = $s[$i]
		if ($c -eq '\' -and ($i + 1) -lt $s.Length) {
			$n = $s[$i + 1]; $i += 2
			switch ($n) {
				'n' { [void]$sb.Append("`n") }
				'r' { [void]$sb.Append("`r") }
				't' { [void]$sb.Append("`t") }
				'\' { [void]$sb.Append('\') }
				'"' { [void]$sb.Append('"') }
				default { [void]$sb.Append($n) }
			}
		} else {
			[void]$sb.Append($c); $i++
		}
	}
	return $sb.ToString()
}

# ---- properties index ----
$propPath = Join-Path $repoRoot (Join-Path $Messages "$Purpose/zh/$Purpose.properties")
$props = @{}
foreach ($line in ([IO.File]::ReadAllText($propPath, $utf8) -split "`r?`n")) {
	$t = $line.Trim()
	if ($t -eq '' -or $t.StartsWith('#') -or $t.StartsWith('!')) { continue }
	$eq = $t.IndexOf('=')
	if ($eq -le 0) { continue }
	$props[$t.Substring(0, $eq).Trim()] = From-Escaped $t.Substring($eq + 1)
}
"properties entries: $($props.Count)"

# ---- walk injected classes ----
$ok = 0; $diff = New-Object System.Collections.ArrayList; $noProp = New-Object System.Collections.ArrayList
$seen = @{}
foreach ($f in (Get-ChildItem -Recurse -File -Filter '*.java' $JavaRoot)) {
	$t = [IO.File]::ReadAllText($f.FullName, $utf8)
	if ($t -notmatch 'InlineText\.of\(') { continue }
	$rel = $f.FullName.Substring((Join-Path $repoRoot $JavaRoot).Length + 1).Replace('\', '/')
	if ($rel -notlike 'pd/*') { continue }
	$fqn = ($rel -replace '\.java$', '') -replace '/', '.'
	$prefix = ($fqn -replace '^pd\.', '').ToLowerInvariant()

	$ofM = [regex]::Match($t, 'InlineText\.of\(([A-Za-z0-9_]+)\.class\)')
	if (-not $ofM.Success) { continue }
	foreach ($m in [regex]::Matches($t, '\.t\("((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\)')) {
		$k = $m.Groups[1].Value
		$v = From-Escaped $m.Groups[2].Value
		# inner-class keys arrive as "$inner.dialogue_1" and concatenate WITHOUT a dot,
		# mirroring InlineText.Builder.t()
		$full = if ($k.StartsWith('$')) { $prefix + $k } else { "$prefix.$k" }
		$seen[$full] = $true
		if (-not $props.ContainsKey($full)) {
			[void]$noProp.Add($full)
		} elseif ($props[$full] -eq $v) {
			$ok++
		} else {
			[void]$diff.Add([pscustomobject]@{ Key = $full; Inline = $v; Prop = $props[$full] })
		}
	}
}
$notInlined = @($props.Keys | Where-Object { -not $seen.ContainsKey($_) })

"inline entries checked : $($ok + $diff.Count + $noProp.Count)"
"  identical            : $ok"
"  DIFFERENT            : $($diff.Count)"
"  no matching property : $($noProp.Count)"
"properties not inlined : $($notInlined.Count)"
''
if ($diff.Count -gt 0) {
	"--- first $ShowDiffs diffs ---"
	$diff | Select-Object -First $ShowDiffs | ForEach-Object {
		"  [$($_.Key)]"
		"     inline: $($_.Inline -replace "`n", '\n')"
		"     prop  : $($_.Prop   -replace "`n", '\n')"
	}
}
if ($noProp.Count -gt 0) {
	"--- inlined but no property ($($noProp.Count)) ---"
	$noProp | Select-Object -First 15 | ForEach-Object { "  $_" }
}
if ($notInlined.Count -gt 0) {
	"--- property but not inlined ($($notInlined.Count)) ---"
	$notInlined | Select-Object -First 15 | ForEach-Object { "  $_" }
}
