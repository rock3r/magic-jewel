#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
WORKSPACE_ROOT="$(cd -- "${SCRIPT_DIR}/../.." >/dev/null && pwd)"

JBR_ROOT="${JBR_ROOT:-${WORKSPACE_ROOT}/jbr}"
JBR_API_ROOT="${JBR_API_ROOT:-${WORKSPACE_ROOT}/jbr-api}"
SKIKO_ROOT="${SKIKO_ROOT:-${WORKSPACE_ROOT}/skiko}"
SKIA_REVISION="${SKIA_REVISION:-m147-64a2414108}"
DEFAULT_SKIA_ROOT="${SKIKO_ROOT}/dependencies/skia/${SKIA_REVISION}/Skia-${SKIA_REVISION}-macos-Release-arm64"
if [[ ! -d "${DEFAULT_SKIA_ROOT}" && -d "${SKIKO_ROOT}/skiko/dependencies/skia/${SKIA_REVISION}/Skia-${SKIA_REVISION}-macos-Release-arm64" ]]; then
  DEFAULT_SKIA_ROOT="${SKIKO_ROOT}/skiko/dependencies/skia/${SKIA_REVISION}/Skia-${SKIA_REVISION}-macos-Release-arm64"
fi
SKIA_ROOT="${SKIA_ROOT:-${DEFAULT_SKIA_ROOT}}"
SKIA_OUT="${SKIA_OUT:-${SKIA_ROOT}/out/Release-macos-arm64}"

OUT_ROOT="${OUT_ROOT:-/tmp/jbr-skia-run}"
DESKTOP_PATCH_DIR="${DESKTOP_PATCH_DIR:-${OUT_ROOT}/desktop}"
STUB_SRC_DIR="${STUB_SRC_DIR:-${OUT_ROOT}/stub-src}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
NATIVE_OUT_DIR="${NATIVE_OUT_DIR:-/tmp/jbr-skia-native}"
NATIVE_GENERATED_DIR="${NATIVE_GENERATED_DIR:-${NATIVE_OUT_DIR}/generated}"
NATIVE_LIB="${NATIVE_LIB:-${NATIVE_OUT_DIR}/libjbrskiainterop.dylib}"
JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}"

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    echo "Required file missing: ${path}" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    echo "Required directory missing: ${path}" >&2
    exit 1
  fi
}

safe_recreate_dir() {
  local path="$1"
  case "${path}" in
    /tmp/jbr-skia-run/*|/tmp/jbr-skia-native/*|/private/tmp/jbr-skia-run/*|/private/tmp/jbr-skia-native/*)
      rm -rf "${path}"
      mkdir -p "${path}"
      ;;
    *)
      echo "Refusing to recreate non-temporary output directory: ${path}" >&2
      exit 1
      ;;
  esac
}

echo "== Build public JBR API shim =="
(
  cd "${JBR_API_ROOT}"
  bash tools/build.sh dev "" out >/tmp/jbr-api-build.log
)
require_file "${JBR_API_ROOT}/out/jbr-api-SNAPSHOT.jar"
cp "${JBR_API_ROOT}/out/jbr-api-SNAPSHOT.jar" "${JBR_API_SHIM}"
echo "JBR API shim: ${JBR_API_SHIM}"

echo "== Compile patched java.desktop classes =="
safe_recreate_dir "${DESKTOP_PATCH_DIR}"
mkdir -p "${STUB_SRC_DIR}/com/jetbrains/exported" "${NATIVE_GENERATED_DIR}"
cat > "${STUB_SRC_DIR}/com/jetbrains/exported/JBRApi.java" <<'EOF_STUB'
package com.jetbrains.exported;

public final class JBRApi {
    private JBRApi() {
    }

    public @interface Service {
    }

    public @interface Provides {
        String value();
    }

    public @interface Provided {
        String value();
    }

    public static final class ServiceNotAvailableException extends RuntimeException {
        public ServiceNotAvailableException(String message) {
            super(message);
        }
    }
}
EOF_STUB

javac \
  --add-exports java.desktop/sun.java2d=ALL-UNNAMED \
  --add-exports java.desktop/sun.java2d.metal=ALL-UNNAMED \
  --add-exports java.desktop/sun.java2d.pipe.hw=ALL-UNNAMED \
  -cp "${JBR_API_SHIM}:${STUB_SRC_DIR}" \
  -h "${NATIVE_GENERATED_DIR}" \
  -d "${DESKTOP_PATCH_DIR}" \
  "${JBR_ROOT}/src/java.desktop/share/classes/com/jetbrains/desktop/JBRSkia.java" \
  "${JBR_ROOT}/src/java.desktop/macosx/classes/com/jetbrains/desktop/JBRSkiaService.java"

find "${DESKTOP_PATCH_DIR}/com/jetbrains/exported" -type f -print -delete 2>/dev/null || true
find "${DESKTOP_PATCH_DIR}/com/jetbrains/exported" -type d -empty -delete 2>/dev/null || true
echo "java.desktop patch: ${DESKTOP_PATCH_DIR}"

echo "== Build native JBR Skia bridge =="
require_dir "${SKIA_ROOT}"
require_dir "${SKIA_OUT}"
mkdir -p "${NATIVE_OUT_DIR}" "${NATIVE_GENERATED_DIR}"

clang++ -std=c++17 -dynamiclib -arch arm64 -mmacosx-version-min=12.0 -fobjc-arc -fvisibility=hidden \
  -I"${JAVA_HOME}/include" -I"${JAVA_HOME}/include/darwin" \
  -I"${NATIVE_GENERATED_DIR}" \
  -I"${JBR_ROOT}/src/java.desktop/macosx/native/libawt_lwawt/java2d/metal" \
  -I"${JBR_ROOT}/src/java.desktop/share/native/libawt/java2d" \
  -I"${JBR_ROOT}/src/java.desktop/share/native/common/awt/debug" \
  -I"${JBR_ROOT}/src/java.base/share/native/libjava" \
  -I"${SKIA_ROOT}" -I"${SKIA_ROOT}/include" -I"${SKIA_ROOT}/include/core" -I"${SKIA_ROOT}/include/config" \
  -I"${SKIA_ROOT}/include/effects" -I"${SKIA_ROOT}/include/gpu" -I"${SKIA_ROOT}/include/private" -I"${SKIA_ROOT}/include/utils" \
  -I"${SKIA_ROOT}/modules/skparagraph/include" -I"${SKIA_ROOT}/modules/skunicode/include" \
  -I"${SKIA_ROOT}/src" -I"${SKIA_ROOT}/out/Release-macos-arm64/gen" \
  "${JBR_ROOT}/src/java.desktop/macosx/native/libawt_lwawt/java2d/metal/JBRSkiaInterop.mm" \
  "${SKIA_OUT}/libskia.a" "${SKIA_OUT}/libskparagraph.a" "${SKIA_OUT}/libskunicode_icu.a" "${SKIA_OUT}/libskunicode_core.a" \
  "${SKIA_OUT}/libskshaper.a" "${SKIA_OUT}/libskresources.a" "${SKIA_OUT}/libskia_ganesh_ext.a" "${SKIA_OUT}/libharfbuzz.a" \
  "${SKIA_OUT}/libicu.a" "${SKIA_OUT}/libpng.a" "${SKIA_OUT}/libjpeg.a" "${SKIA_OUT}/libwebp.a" "${SKIA_OUT}/libskcms.a" \
  "${SKIA_OUT}/libzlib.a" "${SKIA_OUT}/libexpat.a" "${SKIA_OUT}/libwuffs.a" \
  -framework Metal -framework Foundation -framework CoreText -framework CoreFoundation -framework CoreGraphics \
  -framework QuartzCore -framework ImageIO -framework UniformTypeIdentifiers -framework AppKit -lz -lc++ \
  -o "${NATIVE_LIB}"

echo "Native bridge: ${NATIVE_LIB}"
echo "Done."
