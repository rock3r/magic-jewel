#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DESKTOP_PATCH=${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}
JBR_API_SHIM=${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}
JBR_SKIA_LIB=${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}
SKIKO_VERSION=${SKIKO_VERSION:-0.0.0-SNAPSHOT}
JBR_SKIA_RENDER_MODE=${JBR_SKIA_RENDER_MODE:-picture}

JBR_ARGS=(
  "--patch-module=java.desktop=${DESKTOP_PATCH}"
  "-Xbootclasspath/a:${JBR_API_SHIM}"
  "--add-exports=java.desktop/com.jetbrains.desktop=ALL-UNNAMED"
  "-Dsun.java2d.skia.interop=true"
  "-Dsun.java2d.skia.interop.library=${JBR_SKIA_LIB}"
)

case "${JBR_SKIA_RENDER_MODE}" in
  commands)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderCommands=true")
    ;;
  diagnostic)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderDiagnostic=true")
    ;;
  *)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderPicture=true")
    ;;
esac

printf -v JOINED_ARGS "%s " "${JBR_ARGS[@]}"
cd "$ROOT"
SKIKO_VERSION="$SKIKO_VERSION" ./gradlew runJbrSkiaInterop \
  -PjbrSkiaInteropJvmArgs="${JOINED_ARGS% }" \
  -PjbrSkiaRenderMode="${JBR_SKIA_RENDER_MODE}"
