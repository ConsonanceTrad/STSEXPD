#   decompile-ref-apks.ps1
#   Decompile every APK under _ref/apk/ into its own folder under _ref/ref/.
#
#   Uses jadx (downloaded to _ref/tools/jadx) with --show-bad-code so methods that fail
#   to decompile still emit a stub, and a bounded thread count so the 55 MB APK does not
#   exhaust memory. Run from the repo root.

param(
	[string]$ApkDir  = '_ref/apk',
	[string]$RefDir  = '_ref/ref',
	[string]$JadxBin = '_ref/tools/jadx/bin/jadx.bat',
	[string]$Heap    = '4g',
	[int]$Threads    = 4
)

$ErrorActionPreference = 'Stop'

# output folder name -> APK file-name pattern (APK names contain Chinese, so match by prefix)
$targets = @(
	[pscustomobject]@{ out = 'decompiled-darkest-0.7.2';     pattern = 'darkest*' },
	[pscustomobject]@{ out = 'decompiled-incredible-1.4.1';  pattern = '*v1.4.1*' },
	[pscustomobject]@{ out = 'decompiled-gunfire-1.1.6';     pattern = '*wsx*' },
	[pscustomobject]@{ out = 'decompiled-bloodborne-1.8.2';  pattern = '*1.8.2*' }
)

if (-not (Test-Path $JadxBin)) { throw "jadx not found: $JadxBin" }

$env:JAVA_OPTS = "-Xmx$Heap"
$log = Join-Path $env:TEMP ('jadx-run-' + (Get-Date -Format 'HHmmss') + '.log')

foreach ($t in $targets) {
	$apk = Get-ChildItem $ApkDir -File -Filter '*.apk' |
		Where-Object { $_.Name -like $t.pattern } |
		Sort-Object Length -Descending |
		Select-Object -First 1
	if (-not $apk) { "SKIP  no apk matching '$($t.pattern)'"; continue }

	$outPath = Join-Path $RefDir $t.out
	$marker = Join-Path $outPath '.jadx-done'
	if (Test-Path $marker) { "SKIP  already done: $($t.out)"; continue }

	"=== $($apk.Name)  ($([math]::Round($apk.Length/1MB,2)) MB) -> $($t.out) ==="
	$sw = [Diagnostics.Stopwatch]::StartNew()
	& $JadxBin -d $outPath --show-bad-code -j $Threads $apk.FullName *>&1 |
		Tee-Object -FilePath $log -Append |
		Select-Object -Last 3 | ForEach-Object { "    $_" }
	$code = $LASTEXITCODE
	$sw.Stop()

	# jadx exits non-zero when some methods fail to decompile; treat "produced sources"
	# as success, since --show-bad-code still emits a stub for those methods
	$srcDir = Join-Path $outPath 'sources'
	$javaCount = 0
	if (Test-Path $srcDir) { $javaCount = @(Get-ChildItem $srcDir -Recurse -File -Filter '*.java').Count }
	if ($javaCount -gt 0) {
		New-Item -ItemType File -Force -Path $marker | Out-Null
		"    OK in $([math]::Round($sw.Elapsed.TotalSeconds,1))s  (exit=$code, $javaCount java files)"
	} else {
		"    FAILED exit=$code after $([math]::Round($sw.Elapsed.TotalSeconds,1))s"
	}
}

"log: $log"
