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
MAGIC_JEWEL_CORRUPT_TEXT_FONT_SIZE=${MAGIC_JEWEL_CORRUPT_TEXT_FONT_SIZE:-false}
MAGIC_JEWEL_CORRUPT_TEXT_FONT_WEIGHT=${MAGIC_JEWEL_CORRUPT_TEXT_FONT_WEIGHT:-false}
MAGIC_JEWEL_CORRUPT_TEXT_FONT_WIDTH=${MAGIC_JEWEL_CORRUPT_TEXT_FONT_WIDTH:-false}
MAGIC_JEWEL_CORRUPT_TEXT_FONT_SLANT=${MAGIC_JEWEL_CORRUPT_TEXT_FONT_SLANT:-false}
MAGIC_JEWEL_CORRUPT_TEXT_FONT_FAMILY_COUNT=${MAGIC_JEWEL_CORRUPT_TEXT_FONT_FAMILY_COUNT:-false}
MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SIZE=${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SIZE:-false}
MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WEIGHT=${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WEIGHT:-false}
MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WIDTH=${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WIDTH:-false}
MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SLANT=${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SLANT:-false}
MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_FAMILY_COUNT=${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_FAMILY_COUNT:-false}
MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_WIDTH=${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_WIDTH:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=${MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=${MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_TYPE=${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_TYPE:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_VERSION=${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_VERSION:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_RECORD_LENGTH=${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_RECORD_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_LIGHTING_FILTER_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_LIGHTING_FILTER_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_TINT_COLOR_FILTER_DESCRIPTOR_BLEND_MODE=${MAGIC_JEWEL_CORRUPT_TINT_COLOR_FILTER_DESCRIPTOR_BLEND_MODE:-false}
MAGIC_JEWEL_CORRUPT_COLOR_MATRIX_FILTER_DESCRIPTOR_PAYLOAD=${MAGIC_JEWEL_CORRUPT_COLOR_MATRIX_FILTER_DESCRIPTOR_PAYLOAD:-false}
MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA=${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA:-false}
MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA=${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA:-false}
MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE=${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE:-false}
MAGIC_JEWEL_CORRUPT_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA=${MAGIC_JEWEL_CORRUPT_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA:-false}
MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_RADIUS=${MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_RADIUS:-false}
MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_NEGATIVE_RADIUS=${MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_NEGATIVE_RADIUS:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ADVANCE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ADVANCE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ZERO_ADVANCE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ZERO_ADVANCE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PHASE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PHASE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PHASE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PHASE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_STYLE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_STYLE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_FILL_TYPE=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_FILL_TYPE:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_DATA_LENGTH=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_DATA_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PATH_DATA_LENGTH=${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PATH_DATA_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_CHAIN_PATH_EFFECT_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_CHAIN_PATH_EFFECT_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_TYPE=${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_TYPE:-false}
MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT=${MAGIC_JEWEL_CORRUPT_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_LENGTH=${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE=${MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE:-false}
MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE:-false}
MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER:-false}
MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS=${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS:-false}
MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE:-false}
MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER:-false}
MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_COLOR_COUNT=${MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_COLOR_COUNT:-false}
MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=${MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_WIDTH=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_WIDTH:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_WIDTH=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_WIDTH:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_HEIGHT=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_HEIGHT:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_HEIGHT=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_HEIGHT:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_X=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_X:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_Y=${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_Y:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_KIND=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_KIND:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_FREQUENCY=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_FREQUENCY:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_OCTAVES=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_OCTAVES:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_ZERO_OCTAVES=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_ZERO_OCTAVES:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_SIZE=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_SIZE:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_HEIGHT=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_HEIGHT:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_SIZE=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_SIZE:-false}
MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_HEIGHT=${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_HEIGHT:-false}
MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION=${MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION:-false}
MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE=${MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE:-false}
MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=${MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE:-false}
MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING=${MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SOURCE_HASH=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SOURCE_HASH:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SKSL_LENGTH=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SKSL_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_FLOAT_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_FLOAT_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_UNIFORM_FLOAT_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_UNIFORM_FLOAT_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_UNIFORM_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_UNIFORM_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_UNIFORM_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_UNIFORM_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SKSL_LENGTH=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SKSL_LENGTH:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_FLOAT_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_FLOAT_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_UNIFORM_FLOAT_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_UNIFORM_FLOAT_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_UNIFORM_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_UNIFORM_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_UNIFORM_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_UNIFORM_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_CHILD_COUNT:-false}
MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_CHILD_COUNT=${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_CHILD_COUNT:-false}
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
    if [[ "${MAGIC_JEWEL_CORRUPT_TEXT_FONT_SIZE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTextFontSizeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TEXT_FONT_WEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTextFontWeightForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TEXT_FONT_WIDTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTextFontWidthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TEXT_FONT_SLANT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTextFontSlantForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TEXT_FONT_FAMILY_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTextFontFamilyCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SIZE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptParagraphFontSizeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptParagraphFontWeightForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WIDTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptParagraphFontWidthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SLANT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptParagraphFontSlantForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_FAMILY_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptParagraphFontFamilyCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_WIDTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptLinearGradientStrokeWidthForTesting=true")
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
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectChildMissingForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectDescriptorTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_VERSION}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectDescriptorVersionForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_RECORD_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptEffectDescriptorRecordLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_LIGHTING_FILTER_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptLightingFilterDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TINT_COLOR_FILTER_DESCRIPTOR_BLEND_MODE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTintColorFilterDescriptorBlendModeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COLOR_MATRIX_FILTER_DESCRIPTOR_PAYLOAD}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptColorMatrixFilterDescriptorPayloadForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptBlurImageFilterDescriptorSigmaForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptBlurImageFilterDescriptorNegativeSigmaForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptBlurImageFilterDescriptorTileModeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptOffsetImageFilterDescriptorDeltaForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_RADIUS}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptCornerPathEffectDescriptorRadiusForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_NEGATIVE_RADIUS}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptCornerPathEffectDescriptorNegativeRadiusForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ADVANCE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorAdvanceForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ZERO_ADVANCE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorZeroAdvanceForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PHASE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorPhaseForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PHASE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorNegativePhaseForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_STYLE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorStyleForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_FILL_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorFillTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_DATA_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorPathDataLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PATH_DATA_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptStampedPathEffectDescriptorNegativePathDataLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_CHAIN_PATH_EFFECT_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptChainPathEffectDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_TYPE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderDescriptorTypeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptColorShaderDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderColorFilterDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptTransformedShaderDescriptorPayloadCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptShaderDescriptorRecordLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptCompositeShaderDescriptorBlendModeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptLinearGradientShaderDescriptorTileModeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptLinearGradientShaderDescriptorStopOrderForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRadialGradientShaderDescriptorRadiusForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRadialGradientShaderDescriptorTileModeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRadialGradientShaderDescriptorStopOrderForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_COLOR_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptSweepGradientShaderDescriptorColorCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptSweepGradientShaderDescriptorStopOrderForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_WIDTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorWidthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_WIDTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorMaxWidthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_HEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorHeightForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_HEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorMaxHeightForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_X}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorTileModeXForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_Y}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptImageShaderDescriptorTileModeYForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_KIND}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderKindForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_FREQUENCY}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderFrequencyForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_OCTAVES}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderOctavesForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_ZERO_OCTAVES}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderZeroOctavesForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_SIZE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderTileSizeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_HEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderTileHeightForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_SIZE}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderNegativeTileSizeForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_HEIGHT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptPerlinNoiseShaderNegativeTileHeightForTesting=true")
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
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SOURCE_HASH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderSourceHashForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SKSL_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterSkslLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_FLOAT_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterUniformFloatCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_UNIFORM_FLOAT_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNegativeUniformFloatCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNegativeChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_UNIFORM_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNamedUniformCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_UNIFORM_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNegativeNamedUniformCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNamedChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectColorFilterNegativeNamedChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SKSL_LENGTH}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderSkslLengthForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_FLOAT_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderUniformFloatCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_UNIFORM_FLOAT_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNegativeUniformFloatCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNegativeChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_UNIFORM_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNamedUniformCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_UNIFORM_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNegativeNamedUniformCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNamedChildCountForTesting=true")
    fi
    if [[ "${MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_CHILD_COUNT}" == "true" ]]; then
      JBR_ARGS+=("-Dskiko.jbr.interop.corruptRuntimeEffectShaderNegativeNamedChildCountForTesting=true")
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
