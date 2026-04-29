#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DESKTOP_PATCH=${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}
JBR_API_SHIM=${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}
JBR_SKIA_LIB=${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}
SKIKO_VERSION=${SKIKO_VERSION:-0.0.0-SNAPSHOT}
JBR_SKIA_RENDER_MODE=${JBR_SKIA_RENDER_MODE:-picture}
MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=${MAGIC_JEWEL_CORRUPT_COMMAND_STREAM:-false}
SKIKO_EXPECTED_ABI_ID_FOR_TEST=${SKIKO_EXPECTED_ABI_ID_FOR_TEST:-}
SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST:-}

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
    JBR_ARGS+=("-Dcompose.jbr.skia.command.strict=true")
    if [[ "${MAGIC_JEWEL_CORRUPT_COMMAND_STREAM}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptCommandStream=true")
    fi
    ;;
  diagnostic)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderDiagnostic=true")
    ;;
  *)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderPicture=true")
    ;;
esac

if [[ -n "${SKIKO_EXPECTED_ABI_ID_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dskiko.jbr.interop.expectedAbiIdForTest=${SKIKO_EXPECTED_ABI_ID_FOR_TEST}")
fi
if [[ -n "${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dskiko.jbr.interop.requiredCommandCapabilitiesForTest=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST}")
fi

printf -v JOINED_ARGS "%s " "${JBR_ARGS[@]}"
cd "$ROOT"
SKIKO_VERSION="$SKIKO_VERSION" ./gradlew runJbrSkiaInterop \
  -PjbrSkiaInteropJvmArgs="${JOINED_ARGS% }" \
  -PjbrSkiaRenderMode="${JBR_SKIA_RENDER_MODE}"
