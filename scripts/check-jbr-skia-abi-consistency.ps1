# Cross-repo JBR/Skia interop ABI consistency check.
# Verifies that the command-stream ABI constants agree across every
# declaration site: public API (jbr-api), private JBR API (share classes),
# each enabled native backend (macOS .mm, Windows .cpp when present), the
# Skiko bridge expectations, the CMP recorder, and the rebuild scripts'
# pinned Skia revision. Exit 0 = consistent; exit 1 = mismatch (printed).
param([string] $Root = 'C:\src\jbr-skia-zero-copy')
$ErrorActionPreference = 'Stop'

function Get-Match([string] $Path, [string] $Pattern, [string] $What) {
    if (-not (Test-Path $Path)) { return $null }
    $m = Select-String -Path $Path -Pattern $Pattern | Select-Object -First 1
    if (-not $m) { throw "$What not found in $Path (pattern: $Pattern)" }
    return $m.Matches[0].Groups[1].Value
}

$sites = @()

# --- private JBR API (share classes) ---
$jbrSkia = Join-Path $Root 'jbr\src\java.desktop\share\classes\com\jetbrains\desktop\JBRSkia.java'
$sites += [pscustomobject]@{ site='jbr-share'; file=$jbrSkia
    abi     = Get-Match $jbrSkia 'ABI_ID\s*=\s*Integer\.parseInt\("(\d+)"\)' 'ABI_ID'
    native  = Get-Match $jbrSkia 'NATIVE_ABI_VERSION\s*=\s*Integer\.parseInt\("(\d+)"\)' 'NATIVE_ABI_VERSION'
    skia    = (Get-Match $jbrSkia 'SKIA_REVISION\s*=\s*"([^"]+)"\s*\+\s*"' 'SKIA_REVISION-a') +
              (Get-Match $jbrSkia 'SKIA_REVISION\s*=\s*"[^"]+"\s*\+\s*"([^"]+)"' 'SKIA_REVISION-b') }

# --- public API (jbr-api mirror) ---
$jbrApi = Join-Path $Root 'jbr-api\src\com\jetbrains\JBRSkia.java'
$sites += [pscustomobject]@{ site='jbr-api'; file=$jbrApi
    abi     = Get-Match $jbrApi 'ABI_ID\s*=\s*Integer\.parseInt\("(\d+)"\)' 'ABI_ID'
    native  = Get-Match $jbrApi 'NATIVE_ABI_VERSION\s*=\s*Integer\.parseInt\("(\d+)"\)' 'NATIVE_ABI_VERSION'
    skia    = (Get-Match $jbrApi 'SKIA_REVISION\s*=\s*"([^"]+)"\s*\+\s*"' 'SKIA_REVISION-a') +
              (Get-Match $jbrApi 'SKIA_REVISION\s*=\s*"[^"]+"\s*\+\s*"([^"]+)"' 'SKIA_REVISION-b') }

# --- native backends (each enabled backend must agree) ---
$mm = Join-Path $Root 'jbr\src\java.desktop\macosx\native\libawt_lwawt\java2d\metal\JBRSkiaInterop.mm'
if (Test-Path $mm) {
    $sites += [pscustomobject]@{ site='native-metal'; file=$mm
        abi    = Get-Match $mm 'ABI_ID\s*=\s*(\d+)' 'ABI_ID'
        native = Get-Match $mm 'NATIVE_ABI_VERSION\s*=\s*(\d+)' 'NATIVE_ABI_VERSION'
        skia   = Get-Match $mm 'BUILD_ID\s*=\s*"skia=([^;]+);' 'BUILD_ID skia token' }
}
$cpp = Join-Path $Root 'jbr\src\java.desktop\windows\native\libjbrskiainterop\JBRSkiaInterop.cpp'
if (Test-Path $cpp) {
    $sites += [pscustomobject]@{ site='native-d3d'; file=$cpp
        abi    = Get-Match $cpp 'ABI_ID\s*=\s*(\d+)' 'ABI_ID'
        native = Get-Match $cpp 'NATIVE_ABI_VERSION\s*=\s*(\d+)' 'NATIVE_ABI_VERSION'
        skia   = Get-Match $cpp 'BUILD_ID\s*=\s*"skia=([^;]+);' 'BUILD_ID skia token' }
}

# --- Skiko bridge expectations ---
$kts = Join-Path $Root 'skiko\skiko\src\awtMain\kotlin\org\jetbrains\skiko\jbr\JbrSkiaInterop.kt'
$sites += [pscustomobject]@{ site='skiko-bridge'; file=$kts
    abi    = Get-Match $kts 'EXPECTED_ABI_ID\s*=\s*(\d+)' 'EXPECTED_ABI_ID'
    native = Get-Match $kts 'EXPECTED_NATIVE_ABI_VERSION\s*=\s*(\d+)' 'EXPECTED_NATIVE_ABI_VERSION'
    skia   = $null }

# --- Skiko layer + CMP recorder command-stream id ---
$layer = Join-Path $Root 'skiko\skiko\src\awtMain\kotlin\org\jetbrains\skiko\jbr\JbrSkiaSwingLayer.kt'
$sites += [pscustomobject]@{ site='skiko-layer'; file=$layer
    abi = Get-Match $layer 'COMMAND_STREAM_ABI_ID\s*=\s*(\d+)' 'COMMAND_STREAM_ABI_ID'
    native = $null; skia = $null }
$rec = Join-Path $Root 'cmp\compose\ui\ui-graphics\src\skikoMain\kotlin\androidx\compose\ui\graphics\JbrSkiaCommandRecorder.skiko.kt'
$sites += [pscustomobject]@{ site='cmp-recorder'; file=$rec
    abi = Get-Match $rec 'COMMAND_STREAM_ABI_ID\s*=\s*(\d+)' 'COMMAND_STREAM_ABI_ID'
    native = $null; skia = $null }

# --- rebuild scripts' pinned Skia revision ---
$rebuild = Join-Path $Root 'magic-jewel\scripts\rebuild-jbr-skia-local-artifacts.sh'
if (Test-Path $rebuild) {
    $sites += [pscustomobject]@{ site='rebuild-macos'; file=$rebuild
        abi = $null; native = $null
        skia = Get-Match $rebuild 'SKIA_REVISION[:=-]+"?\$?\{?SKIA_REVISION[:=-]*([m0-9][^"}\s]*)' 'SKIA_REVISION' }
}
$rebuildWin = Join-Path $Root 'magic-jewel\scripts\rebuild-jbr-skia-local-artifacts-windows.ps1'
if (Test-Path $rebuildWin) {
    $sites += [pscustomobject]@{ site='rebuild-windows'; file=$rebuildWin
        abi = $null; native = $null
        skia = Get-Match $rebuildWin '\$SkiaRevision\s*=\s*''([^'']+)''' 'SkiaRevision' }
}

$sites | Format-Table site, abi, native, skia -AutoSize

$fail = $false
foreach ($field in @('abi','native','skia')) {
    $vals = $sites | Where-Object { $_.$field } | Select-Object -ExpandProperty $field -Unique
    if ($vals.Count -gt 1) {
        Write-Host "MISMATCH on '$field': $($vals -join ' vs ')" -ForegroundColor Red
        $fail = $true
    }
}
if ($fail) { exit 1 }
Write-Host "ABI constants consistent across $($sites.Count) sites." -ForegroundColor Green
exit 0
