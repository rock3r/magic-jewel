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
PATCH_CLASS_TARGET="${JBR_SKIA_PATCH_CLASS_TARGET:-21}"
EXTRA_NATIVE_INCLUDE_DIR="${EXTRA_NATIVE_INCLUDE_DIR:-${NATIVE_OUT_DIR}/abi99/generated}"
ANDROIDX_TRACING_VERSION="${ANDROIDX_TRACING_VERSION:-2.0.0-alpha09}"
ANDROIDX_TRACING_JARS="${ANDROIDX_TRACING_JARS:-}"
ANDROIDX_TRACING_OUT_DIR="${ANDROIDX_TRACING_OUT_DIR:-${OUT_ROOT}/androidx-tracing}"

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

require_native_abi_consistency() {
  local private_abi public_abi native_abi
  private_abi="$(sed -nE 's/.*NATIVE_ABI_VERSION = Integer\.parseInt\("([0-9]+)"\).*/\1/p' \
    "${JBR_ROOT}/src/java.desktop/share/classes/com/jetbrains/desktop/JBRSkia.java")"
  public_abi="$(sed -nE 's/.*NATIVE_ABI_VERSION = Integer\.parseInt\("([0-9]+)"\).*/\1/p' \
    "${JBR_API_ROOT}/src/com/jetbrains/JBRSkia.java")"
  native_abi="$(sed -nE 's/.*NATIVE_ABI_VERSION = ([0-9]+);/\1/p' \
    "${JBR_ROOT}/src/java.desktop/macosx/native/libawt_lwawt/java2d/metal/JBRSkiaInterop.mm")"
  if [[ -z "${private_abi}" || "${private_abi}" != "${public_abi}" || "${private_abi}" != "${native_abi}" ]]; then
    echo "JBR Skia native ABI mismatch: private=${private_abi:-missing} public=${public_abi:-missing} native=${native_abi:-missing}" >&2
    exit 1
  fi
  echo "JBR Skia native ABI: ${private_abi} (private/public/native consistent)"
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

runtime_jars_in_dir() {
  local dir="$1"
  find "${dir}" -type f -name '*.jar' \
    ! -name '*-sources.jar' \
    ! -name '*-javadoc.jar' \
    2>/dev/null | sort
}

resolved_androidx_tracing_jars() {
  if [[ -n "${ANDROIDX_TRACING_JARS}" ]]; then
    # shellcheck disable=SC2086
    printf '%s\n' ${ANDROIDX_TRACING_JARS}
    return
  fi

  local module_cache="${HOME}/.gradle/caches/modules-2/files-2.1"
  local coordinates=(
    "androidx.tracing/tracing-desktop/${ANDROIDX_TRACING_VERSION}"
    "androidx.annotation/annotation-jvm/1.7.0"
    "androidx.collection/collection-jvm/1.5.0"
    "org.jetbrains.kotlinx/kotlinx-coroutines-core-jvm/1.9.0"
  )
  local coordinate
  for coordinate in "${coordinates[@]}"; do
    runtime_jars_in_dir "${module_cache}/${coordinate}" | tail -1
  done
}

require_androidx_tracing_jar_set() {
  if [[ "$#" -lt 4 ]]; then
    echo "Required AndroidX tracing, annotation, collection, and coroutines jars missing; set ANDROIDX_TRACING_JARS or build once to populate Gradle cache" >&2
    exit 1
  fi
}

require_androidx_tracing_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/tracing/Tracer.class$'; then
      return 0
    fi
  done
  echo "Required AndroidX tracing API class androidx/tracing/Tracer.class missing" >&2
  exit 1
}

require_androidx_collection_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/collection/LongObjectMapKt.class$'; then
      return 0
    fi
  done
  echo "Required AndroidX collection API class androidx/collection/LongObjectMapKt.class missing" >&2
  exit 1
}

require_native_abi_consistency

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

    public static <T> T internalService() {
        return null;
    }

    public static final class ServiceNotAvailableException extends RuntimeException {
        public ServiceNotAvailableException(String message) {
            super(message);
        }
    }
}
EOF_STUB

"${JAVA_HOME}/bin/javac" \
  -source "${PATCH_CLASS_TARGET}" \
  -target "${PATCH_CLASS_TARGET}" \
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

echo "== Stage AndroidX tracing classpath jars =="
safe_recreate_dir "${ANDROIDX_TRACING_OUT_DIR}"
tracing_jars=()
while IFS= read -r jar; do
  [[ -n "${jar}" ]] && tracing_jars+=("${jar}")
done < <(resolved_androidx_tracing_jars)
require_androidx_tracing_jar_set "${tracing_jars[@]}"
for jar in "${tracing_jars[@]}"; do
  require_file "${jar}"
done
require_androidx_tracing_api "${tracing_jars[@]}"
require_androidx_collection_api "${tracing_jars[@]}"
for jar in "${tracing_jars[@]}"; do
  cp "${jar}" "${ANDROIDX_TRACING_OUT_DIR}/"
done
echo "AndroidX tracing jars: ${ANDROIDX_TRACING_OUT_DIR}"

echo "== Build native JBR Skia bridge =="
require_dir "${SKIA_ROOT}"
require_dir "${SKIA_OUT}"
mkdir -p "${NATIVE_OUT_DIR}" "${NATIVE_GENERATED_DIR}"
cat > "${NATIVE_GENERATED_DIR}/java_awt_image_AffineTransformOp.h" <<'EOF_AFFINE_HEADER'
#ifndef JAVA_AWT_IMAGE_AFFINETRANSFORMOP_H
#define JAVA_AWT_IMAGE_AFFINETRANSFORMOP_H

#define java_awt_image_AffineTransformOp_TYPE_NEAREST_NEIGHBOR 1L
#define java_awt_image_AffineTransformOp_TYPE_BILINEAR 2L

#endif
EOF_AFFINE_HEADER
cat > "${NATIVE_GENERATED_DIR}/sun_java2d_pipe_hw_AccelSurface.h" <<'EOF_ACCEL_HEADER'
#ifndef SUN_JAVA2D_PIPE_HW_ACCELSURFACE_H
#define SUN_JAVA2D_PIPE_HW_ACCELSURFACE_H

#define sun_java2d_pipe_hw_AccelSurface_UNDEFINED 0L
#define sun_java2d_pipe_hw_AccelSurface_WINDOW 1L
#define sun_java2d_pipe_hw_AccelSurface_TEXTURE 3L
#define sun_java2d_pipe_hw_AccelSurface_FLIP_BACKBUFFER 4L
#define sun_java2d_pipe_hw_AccelSurface_RT_TEXTURE 5L

#endif
EOF_ACCEL_HEADER
cat > "${NATIVE_GENERATED_DIR}/sun_java2d_pipe_BufferedContext.h" <<'EOF_BUFFERED_CONTEXT_HEADER'
#ifndef SUN_JAVA2D_PIPE_BUFFEREDCONTEXT_H
#define SUN_JAVA2D_PIPE_BUFFEREDCONTEXT_H

#define sun_java2d_pipe_BufferedContext_NO_CONTEXT_FLAGS 0L
#define sun_java2d_pipe_BufferedContext_SRC_IS_OPAQUE 1L
#define sun_java2d_pipe_BufferedContext_USE_MASK 2L

#endif
EOF_BUFFERED_CONTEXT_HEADER
cat > "${NATIVE_GENERATED_DIR}/sun_java2d_metal_MTLContext_MTLContextCaps.h" <<'EOF_MTL_CONTEXT_CAPS_HEADER'
#ifndef SUN_JAVA2D_METAL_MTLCONTEXT_MTLCONTEXTCAPS_H
#define SUN_JAVA2D_METAL_MTLCONTEXT_MTLCONTEXTCAPS_H

#define sun_java2d_metal_MTLContext_MTLContextCaps_CAPS_DOUBLEBUFFERED 65536L
#define sun_java2d_metal_MTLContext_MTLContextCaps_CAPS_EXT_LCD_SHADER 131072L
#define sun_java2d_metal_MTLContext_MTLContextCaps_CAPS_EXT_BIOP_SHADER 262144L
#define sun_java2d_metal_MTLContext_MTLContextCaps_CAPS_EXT_GRAD_SHADER 524288L

#endif
EOF_MTL_CONTEXT_CAPS_HEADER
cat > "${NATIVE_GENERATED_DIR}/sun_font_StrikeCache.h" <<'EOF_STRIKE_CACHE_HEADER'
#ifndef SUN_FONT_STRIKECACHE_H
#define SUN_FONT_STRIKECACHE_H

#define sun_font_StrikeCache_PIXEL_FORMAT_UNKNOWN -1L
#define sun_font_StrikeCache_PIXEL_FORMAT_GREYSCALE 1L
#define sun_font_StrikeCache_PIXEL_FORMAT_LCD 3L
#define sun_font_StrikeCache_PIXEL_FORMAT_BGRA 4L

#endif
EOF_STRIKE_CACHE_HEADER
EXTRA_NATIVE_INCLUDE_ARG=""
if [[ -d "${EXTRA_NATIVE_INCLUDE_DIR}" ]]; then
  EXTRA_NATIVE_INCLUDE_ARG="-I${EXTRA_NATIVE_INCLUDE_DIR}"
fi

clang++ -std=c++17 -dynamiclib -arch arm64 -mmacosx-version-min=12.0 -fno-objc-arc -fvisibility=hidden \
  -I"${JAVA_HOME}/include" -I"${JAVA_HOME}/include/darwin" \
  -I"${NATIVE_GENERATED_DIR}" \
  ${EXTRA_NATIVE_INCLUDE_ARG:+"${EXTRA_NATIVE_INCLUDE_ARG}"} \
  -I"${JBR_ROOT}/src/java.desktop/macosx/native/libawt_lwawt/awt" \
  -I"${JBR_ROOT}/src/java.desktop/macosx/native/libawt_lwawt/java2d/metal" \
  -I"${JBR_ROOT}/src/java.desktop/macosx/native/libosxapp" \
  -I"${JBR_ROOT}/src/java.desktop/share/native/libawt/java2d" \
  -I"${JBR_ROOT}/src/java.desktop/share/native/common/awt/debug" \
  -I"${JBR_ROOT}/src/java.desktop/share/native/common/font" \
  -I"${JBR_ROOT}/src/java.base/share/native/libjava" \
  -I"${JBR_ROOT}/src/java.base/unix/native/libjava" \
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
  -Wl,-undefined,dynamic_lookup \
  -o "${NATIVE_LIB}"

echo "Native bridge: ${NATIVE_LIB}"
echo "Done."
