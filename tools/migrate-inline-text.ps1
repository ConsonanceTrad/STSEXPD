#   migrate-inline-text.ps1
#   Move Simplified-Chinese text from messages/<purpose>/zh/<purpose>.properties
#   into the Java class that uses it, as an InlineText registration block.
#
#   Input : core/src/assets/messages/<purpose>/zh/<purpose>.properties
#           core/src/java/**/*.java              (class index built from file paths)
#   Output: static { InlineText.of(X.class).t("k", "v") ... } injected at the top of
#           each class body. Existing blocks are replaced when -Force is given.
#
#   Two-phase lookup mirrors pd.messages.Messages:
#       key = cls.getName().replace("pd.","") + "." + k   (lower-cased)
#   So the longest class-name prefix that a properties key starts with wins, and the
#   remainder of the key is the text key.

param(
	[string]$Purpose  = 'items',
	[string]$Messages = 'core/src/assets/messages',
	[string]$JavaRoot = 'core/src/java',
	[switch]$WhatIf,
	[switch]$Force,
	[int]$Limit = 0
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$repoRoot = (Get-Location).Path

function To-JavaLiteral([string]$v) {
	# 1) resolve properties-level escapes first, so the string holds the same characters
	#    I18NBundle would produce (\n -> newline, \t -> tab, \\ -> single backslash)
	$mark = [char]1
	$s = $v -replace '\\r\\n', "`n"
	$s = $s -replace '\\n', "`n"
	$s = $s -replace '\\r', "`r"
	$s = $s -replace '\\t', "`t"
	$s = $s -replace '\\\\', $mark
	$s = $s.Replace($mark, '\')
	# 2) escape for a Java string literal
	$s = $s -replace '\\', '\\\\'
	$s = $s -replace '"', '\"'
	$s = $s -replace "`t", '\t'
	$s = $s -replace "`r", '\r'
	$s = $s -replace "`n", '\n'
	return $s
}

# ---------- 1. class index: lower-cased Messages key prefix -> file ----------
$classIndex = @{}       # lowercased key prefix  ->  [pscustomobject] File, Statement
foreach ($f in (Get-ChildItem -Recurse -File -Filter '*.java' $JavaRoot)) {
	$rel = $f.FullName.Substring((Join-Path $repoRoot $JavaRoot).Length + 1).Replace('\', '/')
	if ($rel -notlike 'pd/*') { continue }
	$fqn = ($rel -replace '\.java$', '') -replace '/', '.'
	$simple = $f.BaseName
	# messages key uses getName().replace("pd.","") -> e.g. items.consum.food.Food
	$prefix = ($fqn -replace '^pd\.', '').ToLowerInvariant()
	$classIndex[$prefix] = [pscustomobject]@{ File = $f.FullName; Simple = $simple; Fqn = $fqn }
}
"class index: $($classIndex.Count) classes"

# ---------- 2. read the zh properties ----------
$propPath = Join-Path $repoRoot (Join-Path $Messages "$Purpose/zh/$Purpose.properties")
if (-not (Test-Path $propPath)) { throw "not found: $propPath" }
# zh properties are UTF-8. (The earlier key-only rewrite used Latin1 deliberately so that
# only ASCII key prefixes changed; here we need the actual Chinese values, so decode UTF-8.)
$raw = [IO.File]::ReadAllText($propPath, (New-Object Text.UTF8Encoding($false)))
$entries = New-Object System.Collections.ArrayList
foreach ($line in ($raw -split "`r?`n")) {
	$t = $line.Trim()
	if ($t -eq '' -or $t.StartsWith('#') -or $t.StartsWith('!')) { continue }
	$eq = $t.IndexOf('=')
	if ($eq -le 0) { continue }
	$k = $t.Substring(0, $eq).Trim()
	$v = $t.Substring($eq + 1)
	[void]$entries.Add([pscustomobject]@{ Key = $k; Value = $v })
}
"properties entries: $($entries.Count)"

# ---------- 3. longest class-prefix match ----------
$byFile = @{}           # file -> ordered list of (textKey, value)
$unmatched = New-Object System.Collections.ArrayList
$matched = 0
foreach ($e in $entries) {
	$lower = $e.Key.ToLowerInvariant()
	# inner-class keys look like aaa$bbb.k. Replacing '$' with '.' keeps the length
	# identical, so substring math on the original key stays aligned.
	$probe = $lower.Replace('$', '.')
	$parts = $probe.Split('.')
	$best = $null
	for ($i = $parts.Length - 1; $i -ge 1; $i--) {
		$cand = ($parts[0..($i - 1)] -join '.')
		if ($classIndex.ContainsKey($cand)) { $best = $cand; break }
	}
	if ($best -eq $null) {
		[void]$unmatched.Add($e.Key)
		continue
	}
	# keep an inner-class '$' marker: the key is aaa$bbb.k, and InlineText concatenates
	# '$bbb.k' without a separator, so the '$' must survive into the generated call
	$textKey = if ($best.Length -lt $e.Key.Length -and $e.Key[$best.Length] -eq '$') {
		$e.Key.Substring($best.Length)
	} else {
		$e.Key.Substring($best.Length + 1)
	}
	$file = $classIndex[$best].File
	if (-not $byFile.ContainsKey($file)) { $byFile[$file] = New-Object System.Collections.ArrayList }
	[void]$byFile[$file].Add([pscustomobject]@{ Key = $textKey; Value = $e.Value })
	$matched++
}
"matched: $matched    unmatched: $($unmatched.Count)"
if ($Limit -gt 0 -and $byFile.Count -gt $Limit) {
	$keep = @($byFile.Keys | Select-Object -First $Limit)
	$tmp = @{}
	foreach ($k in $keep) { $tmp[$k] = $byFile[$k] }
	$byFile = $tmp
	"limited to $($byFile.Count) files"
}

# ---------- 4. inject registration blocks ----------
$written = 0; $skipped = 0; $failed = New-Object System.Collections.ArrayList
foreach ($file in ($byFile.Keys | Sort-Object)) {
	$t = [IO.File]::ReadAllText($file, $utf8)
	$simple = [IO.Path]::GetFileNameWithoutExtension($file)

	# rebuild if a previous block exists
	$t = [regex]::Replace($t, '(?s)\r?\n\t//SPSEXPD: inline Chinese text.*?\r?\n\t\}\r?\n', "`n")
	$t = [regex]::Replace($t, '(?s)\r?\n\tstatic \{\r?\n\t\tInlineText\.of\(.*?\r?\n\t\}\r?\n', "`n")

	if ($t -match 'InlineText\.of\(') { $skipped++; continue }

	$m = [regex]::Match($t, '(?m)^(?:public\s+|final\s+|abstract\s+)*(?:class|enum|interface)\s+([A-Za-z0-9_]+)[^{]*\{')
	if (-not $m.Success) { [void]$failed.Add($file); continue }

	# ensure InlineText is imported (classes inside pd.messages itself need no import)
	if ($t -notmatch '(?m)^import pd\.messages\.InlineText;') {
		$imports = [regex]::Matches($t, '(?m)^import [^;]+;\r?\n')
		if ($imports.Count -gt 0) {
			$last = $imports[$imports.Count - 1]
			$t = $t.Insert($last.Index + $last.Length, "import pd.messages.InlineText;`n")
		} else {
			$pk = [regex]::Match($t, '(?m)^package [^;]+;\r?\n')
			if ($pk.Success) { $t = $t.Insert($pk.Index + $pk.Length, "`nimport pd.messages.InlineText;`n") }
		}
		$m = [regex]::Match($t, '(?m)^(?:public\s+|final\s+|abstract\s+)*(?:class|enum|interface)\s+([A-Za-z0-9_]+)[^{]*\{')
	}

	$sb = New-Object Text.StringBuilder
	[void]$sb.Append("`n`t//SPSEXPD: inline Chinese text (generated from messages/$Purpose/zh)")
	[void]$sb.Append("`n`tstatic {")
	[void]$sb.Append("`n`t`tInlineText.of($simple.class)")
	foreach ($e in $byFile[$file]) {
		$lit = To-JavaLiteral $e.Value
		[void]$sb.Append("`n`t`t`t.t(""$($e.Key)"", ""$lit"")")
	}
	[void]$sb.Append(";")
	[void]$sb.Append("`n`t}`n")

	# enum constants must come first, so insert after the ';' that closes the constant list
	$insertAt = $m.Index + $m.Length
	if ($m.Value -match '\benum\b') {
		$semi = $t.IndexOf(';', $insertAt)
		if ($semi -gt 0) { $insertAt = $semi + 1 }
	}
	$out = $t.Insert($insertAt, $sb.ToString())
	if (-not $WhatIf) { [IO.File]::WriteAllText($file, $out, $utf8) }
	$written++
}
"files written: $written   already-had-block: $skipped   no-class-header: $($failed.Count)  (WhatIf=$WhatIf)"
if ($failed.Count -gt 0) {
	'--- no class header ---'
	$failed | Select-Object -First 10 | ForEach-Object { "  $($_.Replace($repoRoot + '\',''))" }
}
if ($unmatched.Count -gt 0) {
	'--- unmatched key samples ---'
	$unmatched | Select-Object -First 15 | ForEach-Object { "  $_" }
}
