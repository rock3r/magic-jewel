#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DESKTOP_PATCH=${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}
JBR_API_SHIM=${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}
JBR_SKIA_LIB=${JBR_SKIA_LIB-/tmp/jbr-skia-native/libjbrskiainterop.dylib}
JBR_SKIA_LIBRARY_PATH=${JBR_SKIA_LIBRARY_PATH:-}
JAVA_HOME_FOR_BOOT_LIBRARY_PATH=${JAVA_HOME:-$(/usr/libexec/java_home -v 21)}
SKIKO_VERSION=${SKIKO_VERSION:-0.0.0-SNAPSHOT}
LOCAL_CMP_OUT=${LOCAL_CMP_OUT:-}
JBR_SKIA_RENDER_MODE=${JBR_SKIA_RENDER_MODE:-picture}
JBR_SKIA_NATIVE_TEXT=${JBR_SKIA_NATIVE_TEXT:-false}
MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=${MAGIC_JEWEL_CORRUPT_COMMAND_STREAM:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=${MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION:-false}
MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE=${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING=${MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SOURCE=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SOURCE:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_CHILD_TYPE=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_CHILD_TYPE:-false}
MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=${MAGIC_JEWEL_FORCE_CONTEXT_CHANGE:-false}
MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=${MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE:-false}
SKIKO_EXPECTED_ABI_ID_FOR_TEST=${SKIKO_EXPECTED_ABI_ID_FOR_TEST:-}
SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=${SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST:-}
SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST:-}
SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST:-}
JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=${JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST:-}
JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=${JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST:-}

JBR_ARGS=(
  "--patch-module=java.desktop=${DESKTOP_PATCH}"
  "-Xbootclasspath/a:${JBR_API_SHIM}"
  "--add-exports=java.desktop/com.jetbrains.desktop=ALL-UNNAMED"
  "-Dsun.java2d.skia.interop=true"
)
if [[ -n "${JBR_SKIA_LIB}" ]]; then
  JBR_ARGS+=("-Dsun.java2d.skia.interop.library=${JBR_SKIA_LIB}")
fi
if [[ -n "${JBR_SKIA_LIBRARY_PATH}" ]]; then
  JBR_ARGS+=("-Djava.library.path=${JBR_SKIA_LIBRARY_PATH}")
  JBR_ARGS+=("-Dsun.boot.library.path=${JAVA_HOME_FOR_BOOT_LIBRARY_PATH}/lib:${JBR_SKIA_LIBRARY_PATH}")
fi

case "${JBR_SKIA_RENDER_MODE}" in
  commands)
    JBR_ARGS+=("-Dskiko.jbr.interop.renderCommands=true")
    JBR_ARGS+=("-Dcompose.jbr.skia.command.strict=true")
    if [[ "${JBR_SKIA_NATIVE_TEXT}" == "true" ]]; then
      JBR_ARGS+=("-Dcompose.jbr.skia.command.nativeText=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COMMAND_STREAM}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptCommandStream=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptDescriptorUseForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptDescriptorUseAfterEvictForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectChildUseAfterEvictForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptDescriptorVersionForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptColorFilterHandleTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptColorFilterHandleToPathEffectTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageFilterHandleTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPathEffectHandleTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderHandleTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderChildMissingForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SOURCE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectSourceForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_CHILD_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectChildTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_FORCE_CONTEXT_CHANGE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.forceContextChangeOnceForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE}" == "true" ]]; then
      JBR_ARGS+=("-Dcompose.jbr.skia.command.colorFilterHandles=true")
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
if [[ -n "${SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dskiko.jbr.interop.expectedNativeAbiVersionForTest=${SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST}")
fi
if [[ -n "${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dskiko.jbr.interop.requiredCommandCapabilitiesForTest=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST}")
fi
if [[ -n "${SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dskiko.jbr.interop.requiredCommandCapabilitiesHighForTest=${SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST}")
fi
if [[ -n "${JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dsun.java2d.skia.interop.commandCapabilitiesMaskForTest=${JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST}")
fi
if [[ -n "${JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST}" ]]; then
  JBR_ARGS+=("-Dsun.java2d.skia.interop.commandCapabilitiesHighMaskForTest=${JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST}")
fi

printf -v JOINED_ARGS "%s " "${JBR_ARGS[@]}"
cd "$ROOT"
GRADLE_ARGS=(
  runJbrSkiaInterop
  "-PjbrSkiaInteropJvmArgs=${JOINED_ARGS% }"
  "-PjbrSkiaRenderMode=${JBR_SKIA_RENDER_MODE}"
)
if [[ -n "${LOCAL_CMP_OUT}" ]]; then
  GRADLE_ARGS+=("-PlocalCmpOut=${LOCAL_CMP_OUT}")
fi

SKIKO_VERSION="$SKIKO_VERSION" ./gradlew "${GRADLE_ARGS[@]}"
