#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DESKTOP_PATCH=${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}
JBR_API_SHIM=${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}
JBR_SKIA_LIB=${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}
SKIKO_VERSION=${SKIKO_VERSION:-0.0.0-SNAPSHOT}

JBR_ARGS=(
  "--patch-module=java.desktop=${DESKTOP_PATCH}"
  "-Xbootclasspath/a:${JBR_API_SHIM}"
  "--add-exports=java.desktop/com.jetbrains.desktop=ALL-UNNAMED"
  "-Dsun.java2d.skia.interop=true"
  "-Dsun.java2d.skia.interop.library=${JBR_SKIA_LIB}"
)

printf -v JOINED_ARGS "%s " "${JBR_ARGS[@]}"
cd "$ROOT"
SKIKO_VERSION="$SKIKO_VERSION" ./gradlew runJbrSkiaInterop -PjbrSkiaInteropJvmArgs="${JOINED_ARGS% }"
