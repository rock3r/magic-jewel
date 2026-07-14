# Windows counterpart of rebuild-jbr-skia-local-artifacts.sh: standalone MSVC
# build of the JBR Skia interop DLL (Direct3D backend) against the pinned
# prebuilt Skia archives, for fast iteration outside the full JBR build.
# The service loads it via -Djbr.skia.interop.library=<path> (see
# JBRSkiaService.loadNativeBridge) or from the JBR image bin directory.
param(
    [string] $Root = 'C:\src\jbr-skia-zero-copy',
    [string] $OutDir = 'C:\tmp\jbr-skia-native'
)
$ErrorActionPreference = 'Stop'
$SkiaRevision = 'm147-64a2414108'

$src = Join-Path $Root 'jbr\src\java.desktop\windows\native\libjbrskiainterop\JBRSkiaInterop.cpp'
$sk = Join-Path $Root "skiko\skiko\dependencies\skia\$SkiaRevision\Skia-$SkiaRevision-windows-Release-x64"
$skOut = Join-Path $sk 'out\Release-windows-x64'
$jdkInclude = Join-Path $Root 'jbr\build\windows-x86_64-server-release\images\jdk\include'
foreach ($p in @($src, $sk, $skOut, $jdkInclude)) {
    if (-not (Test-Path $p)) { throw "missing prerequisite: $p" }
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$vsdevcmd = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat'
$libs = @(
    'skia.lib','skia_ganesh_ext.lib','d3d12allocator.lib','skparagraph.lib',
    'skunicode_icu.lib','skunicode_core.lib','skshaper.lib','skresources.lib',
    'harfbuzz.lib','icu.lib','libpng.lib','libjpeg.lib','libwebp.lib',
    'libwebp_sse41.lib','skcms.lib','zlib.lib','expat.lib','wuffs.lib',
    'bentleyottmann.lib','jsonreader.lib'
) -join ' '
$sysLibs = 'd3d12.lib dxgi.lib d3dcompiler.lib dwrite.lib user32.lib gdi32.lib ole32.lib advapi32.lib shlwapi.lib'

$cmd = @"
call "$vsdevcmd" -arch=x64 -no_logo
cd /d "$OutDir"
cl /nologo /std:c++20 /O2 /MT /GR- /EHs-c- /utf-8 /W3 /LD ^
   /D_HAS_EXCEPTIONS=0 /DWIN32_LEAN_AND_MEAN /DNOMINMAX /D_CRT_SECURE_NO_WARNINGS ^
   /DNDEBUG /DSK_GANESH /DSK_DIRECT3D /DSK_BUILD_FOR_WIN /DSK_GAMMA_SRGB /DSK_GAMMA_APPLY_TO_A8 ^
   /I"$sk" /I"$sk\include" /I"$sk\include\core" /I"$sk\include\gpu" /I"$sk\include\effects" /I"$sk\include\ports" /I"$sk\include\utils" ^
   /I"$jdkInclude" /I"$jdkInclude\win32" ^
   "$src" ^
   /link /LIBPATH:"$skOut" $libs $sysLibs /OUT:jbrskiainterop.dll
"@
$cmdFile = Join-Path $OutDir 'build-jbrskiainterop.cmd'
$cmd | Set-Content -Encoding ascii $cmdFile
& cmd /d /c $cmdFile
if ($LASTEXITCODE -ne 0) { throw "cl failed with $LASTEXITCODE" }
Copy-Item (Join-Path $skOut 'icudtl.dat') $OutDir -ErrorAction SilentlyContinue
$dll = Join-Path $OutDir 'jbrskiainterop.dll'
"built: $dll"
"sha256: $((Get-FileHash $dll -Algorithm SHA256).Hash)"
