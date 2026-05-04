#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-screenshot-parity-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-6}"
WARMUP_SECONDS="${WARMUP_SECONDS:-1}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
PARITY_SCRIPT="${PARITY_SCRIPT:-${SCRIPT_DIR}/jbr-skia-screenshot-parity.sh}"
CASES="${CASES:-parity-rich parity-button-chrome parity-geometry-clean parity-native-custom-font-text-image parity-native-generic-font-text parity-native-loaded-font-data-text parity-native-resource-font-text parity-native-system-font-text parity-resize-native-generic-font-text parity-resize-native-loaded-font-data-text parity-resize-native-resource-font-text parity-forced-context-native-custom-font-text-image parity-forced-context-native-generic-font-text parity-forced-context-native-loaded-font-data-text parity-forced-context-native-resource-font-text parity-forced-context-image-refs parity-point-dots parity-path-effect parity-image-filter parity-image-color-matrix-filter parity-color-shader parity-resize-color-shader parity-forced-context-color-shader parity-noise-shader parity-resize-noise-shader parity-forced-context-noise-shader parity-turbulence-shader parity-resize-turbulence-shader parity-forced-context-turbulence-shader parity-image-shader-color-filter parity-composite-shader-color-filter parity-linear-gradient-shader-color-filter parity-transformed-shader parity-runtime-effect-pure-color parity-runtime-effect-uniform-only parity-runtime-effect-child-only parity-runtime-effect-shader parity-runtime-effect-shader-color-filter parity-runtime-effect-color-filter parity-runtime-effect-color-filter-child parity-graphics-layer-effects parity-graphics-layer-render-effect-color-filter parity-graphics-layer-render-effect-blend-mode parity-graphics-layer-render-effect-color-matrix-filter parity-graphics-layer-render-effect-blend-color-filter parity-graphics-layer-render-effect-blend-color-matrix-filter parity-graphics-layer-offset-effect-blend-color-matrix-filter parity-graphics-layer-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-shadow parity-graphics-layer-round-shadow parity-graphics-layer-path-shadow parity-graphics-layer-offscreen parity-graphics-layer-rotationx parity-graphics-layer-rotationy parity-graphics-layer-rotationxy parity-graphics-layer-near-camera parity-graphics-layer-offcenter-pivot}"

mkdir -p "${OUT_ROOT}"
SUITE_TSV="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\tfallbacks\tjbr_picture_frames\tjbr_command_frames\tavg_delta\tbad_pixel_ratio\theader_buttons_bad_pixel_ratio\tcompose_bad_pixel_ratio\tcompose_bottom_labels_bad_pixel_ratio\tcompose_paragraph_probes_bad_pixel_ratio\tcompose_purple_rect_bad_pixel_ratio\tcompose_top_progress_bad_pixel_ratio\tcompose_bottom_swatches_bad_pixel_ratio\tcompose_shader_color_bad_pixel_ratio\tcompose_shader_image_bad_pixel_ratio\tcompose_shader_composite_bad_pixel_ratio\tcompose_shader_linear_bad_pixel_ratio\tcompose_shader_noise_bad_pixel_ratio\tcompose_shader_turbulence_bad_pixel_ratio\treport\tdiff\n" > "${SUITE_TSV}"

summary_value() {
  local file="$1"
  local key="$2"
  if [ ! -f "${file}" ]; then
    echo "missing"
    return
  fi
  local value
  value="$(grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2- || true)"
  if [ -z "${value}" ]; then
    echo "missing"
  else
    echo "${value}"
  fi
}

run_case() {
  local name="$1"
  shift
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} =="

  local status="passed"
  env \
    OUT_DIR="${out_dir}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    "$@" \
    "${PARITY_SCRIPT}" || status="failed"

  local summary="${out_dir}/report/summary.properties"
  local avg_delta
  local fallback_count
  local jbr_picture_frames
  local jbr_command_frames
  local bad_pixel_ratio
  local header_buttons_bad_pixel_ratio
  local compose_bad_pixel_ratio
  local compose_bottom_labels_bad_pixel_ratio
  local compose_paragraph_probes_bad_pixel_ratio
  local compose_purple_rect_bad_pixel_ratio
  local compose_top_progress_bad_pixel_ratio
  local compose_bottom_swatches_bad_pixel_ratio
  local compose_shader_color_bad_pixel_ratio
  local compose_shader_image_bad_pixel_ratio
  local compose_shader_composite_bad_pixel_ratio
  local compose_shader_linear_bad_pixel_ratio
  local compose_shader_noise_bad_pixel_ratio
  local compose_shader_turbulence_bad_pixel_ratio
  avg_delta="$(summary_value "${summary}" screenshot_parity_avgDelta)"
  bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_badPixelRatio)"
  header_buttons_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_headerButtons_badPixelRatio)"
  compose_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeCanvas_badPixelRatio)"
  compose_bottom_labels_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeBottomLabels_badPixelRatio)"
  compose_paragraph_probes_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeParagraphProbes_badPixelRatio)"
  compose_purple_rect_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composePurpleRect_badPixelRatio)"
  compose_top_progress_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeTopProgress_badPixelRatio)"
  compose_bottom_swatches_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeBottomSwatches_badPixelRatio)"
  compose_shader_color_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderColor_badPixelRatio)"
  compose_shader_image_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderImage_badPixelRatio)"
  compose_shader_composite_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderComposite_badPixelRatio)"
  compose_shader_linear_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderLinear_badPixelRatio)"
  compose_shader_noise_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderNoise_badPixelRatio)"
  compose_shader_turbulence_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderTurbulence_badPixelRatio)"
  fallback_count="$(summary_value "${summary}" fallback_new_count)"
  jbr_picture_frames="$(summary_value "${summary}" jbr_picture_frames)"
  jbr_command_frames="$(summary_value "${summary}" jbr_command_frames)"

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${fallback_count}" "${jbr_picture_frames}" "${jbr_command_frames}" \
    "${avg_delta}" "${bad_pixel_ratio}" "${header_buttons_bad_pixel_ratio}" "${compose_bad_pixel_ratio}" \
    "${compose_bottom_labels_bad_pixel_ratio}" "${compose_paragraph_probes_bad_pixel_ratio}" \
    "${compose_purple_rect_bad_pixel_ratio}" "${compose_top_progress_bad_pixel_ratio}" "${compose_bottom_swatches_bad_pixel_ratio}" \
    "${compose_shader_color_bad_pixel_ratio}" "${compose_shader_image_bad_pixel_ratio}" "${compose_shader_composite_bad_pixel_ratio}" "${compose_shader_linear_bad_pixel_ratio}" \
    "${compose_shader_noise_bad_pixel_ratio}" "${compose_shader_turbulence_bad_pixel_ratio}" \
    "${out_dir}/report/report.md" "${out_dir}/report/parity-diff.png" >> "${SUITE_TSV}"
  echo "status=${status} fallback_new_count=${fallback_count} jbr_picture_frames=${jbr_picture_frames} jbr_command_frames=${jbr_command_frames} avg_delta=${avg_delta} bad_pixel_ratio=${bad_pixel_ratio} header_buttons_bad_pixel_ratio=${header_buttons_bad_pixel_ratio} compose_bad_pixel_ratio=${compose_bad_pixel_ratio} compose_bottom_labels_bad_pixel_ratio=${compose_bottom_labels_bad_pixel_ratio} compose_paragraph_probes_bad_pixel_ratio=${compose_paragraph_probes_bad_pixel_ratio} compose_bottom_swatches_bad_pixel_ratio=${compose_bottom_swatches_bad_pixel_ratio} compose_shader_color_bad_pixel_ratio=${compose_shader_color_bad_pixel_ratio} compose_shader_image_bad_pixel_ratio=${compose_shader_image_bad_pixel_ratio} compose_shader_composite_bad_pixel_ratio=${compose_shader_composite_bad_pixel_ratio} compose_shader_linear_bad_pixel_ratio=${compose_shader_linear_bad_pixel_ratio} compose_shader_noise_bad_pixel_ratio=${compose_shader_noise_bad_pixel_ratio} compose_shader_turbulence_bad_pixel_ratio=${compose_shader_turbulence_bad_pixel_ratio} report=${out_dir}/report/report.md"
  if [ "${status}" != "passed" ]; then
    return 1
  fi
}

run_named_case() {
  case "$1" in
    parity-rich)
      run_case "$1"
      ;;
    parity-button-chrome)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=false \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=false \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=false \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=false \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=false \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=false \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_SWING_ISLAND=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.02 \
        MAX_SWING_ISLAND_BAD_PIXEL_RATIO=0.06 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.07
      ;;
    parity-geometry-clean)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TEXT=false \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_SWING_ISLAND=false \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_SWING_ISLAND_BAD_PIXEL_RATIO=0.09 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_PURPLE_RECT_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_TOP_PROGRESS_BAD_PIXEL_RATIO=0.11 \
        MAX_COMPOSE_BOTTOM_SWATCHES_BAD_PIXEL_RATIO=0.005 \
        EXPECT_MIN_IMAGE_REFS=0
      ;;
    parity-native-custom-font-text-image|parity-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.17 \
        MAX_COMPOSE_PARAGRAPH_PROBES_BAD_PIXEL_RATIO=0.19
      ;;
    parity-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18 \
        MAX_COMPOSE_PARAGRAPH_PROBES_BAD_PIXEL_RATIO=0.20
      ;;
    parity-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=3 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=3 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-resize-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18 \
        MAX_COMPOSE_PARAGRAPH_PROBES_BAD_PIXEL_RATIO=0.20
      ;;
    parity-resize-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-resize-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-forced-context-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18 \
        MAX_COMPOSE_PARAGRAPH_PROBES_BAD_PIXEL_RATIO=0.20
      ;;
    parity-forced-context-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-forced-context-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.18
      ;;
    parity-forced-context-native-custom-font-text-image|parity-forced-context-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_BOTTOM_LABELS_BAD_PIXEL_RATIO=0.17 \
        MAX_COMPOSE_PARAGRAPH_PROBES_BAD_PIXEL_RATIO=0.19
      ;;
    parity-forced-context-image-refs)
      run_case "$1" \
        MAGIC_JEWEL_IMAGE_CACHE_CHURN=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MAX_IMAGE_CACHE_CLEARS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    parity-point-dots)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true
      ;;
    parity-path-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10
      ;;
    parity-image-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-image-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COLOR_BAD_PIXEL_RATIO=0.04
      ;;
    parity-resize-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_SHADER_COLOR_BAD_PIXEL_RATIO=0.05
      ;;
    parity-forced-context-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COLOR_BAD_PIXEL_RATIO=0.04
      ;;
    parity-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_NOISE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-resize-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_SHADER_NOISE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-forced-context-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_NOISE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_TURBULENCE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-resize-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_SHADER_TURBULENCE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-forced-context-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_TURBULENCE_BAD_PIXEL_RATIO=0.08
      ;;
    parity-image-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_IMAGE_BAD_PIXEL_RATIO=0.05
      ;;
    parity-composite-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.07
      ;;
    parity-linear-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_LINEAR_BAD_PIXEL_RATIO=0.05
      ;;
    parity-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.09
      ;;
    parity-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true
      ;;
    parity-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true
      ;;
    parity-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true
      ;;
    parity-runtime-effect-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true
      ;;
    parity-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true
      ;;
    parity-graphics-layer-effects)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true
      ;;
    parity-graphics-layer-render-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-render-effect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-render-effect-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-render-effect-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-offset-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.13 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-graphics-layer-round-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-path-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-offscreen)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSCREEN=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-graphics-layer-rotationx)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-rotationy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-rotationxy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-near-camera)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAX_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.13 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.10
      ;;
    parity-graphics-layer-offcenter-pivot)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true \
        MAX_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.13 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.10
      ;;
    *)
      echo "Unknown screenshot parity case: $1" >&2
      return 2
      ;;
  esac
}

for case_name in ${CASES}; do
  run_named_case "${case_name}"
done

echo "JBR_SKIA_SCREENSHOT_PARITY_SUITE passed out_root=${OUT_ROOT}"
echo "suite=${SUITE_TSV}"
