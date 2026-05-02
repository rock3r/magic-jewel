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
CASES="${CASES:-parity-rich parity-geometry-clean parity-native-text parity-point-dots parity-path-effect parity-image-filter parity-image-color-matrix-filter parity-image-shader-color-filter parity-composite-shader-color-filter parity-linear-gradient-shader-color-filter parity-runtime-effect-pure-color parity-runtime-effect-uniform-only parity-runtime-effect-child-only parity-runtime-effect-shader parity-runtime-effect-shader-color-filter parity-runtime-effect-color-filter parity-runtime-effect-color-filter-child parity-graphics-layer-effects parity-graphics-layer-render-effect-color-filter parity-graphics-layer-render-effect-blend-mode parity-graphics-layer-render-effect-color-matrix-filter parity-graphics-layer-render-effect-blend-color-filter parity-graphics-layer-render-effect-blend-color-matrix-filter parity-graphics-layer-offset-effect-blend-color-matrix-filter parity-graphics-layer-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-shadow parity-graphics-layer-round-shadow parity-graphics-layer-path-shadow parity-graphics-layer-offscreen parity-graphics-layer-rotationx parity-graphics-layer-rotationy parity-graphics-layer-rotationxy parity-graphics-layer-near-camera parity-graphics-layer-offcenter-pivot}"

mkdir -p "${OUT_ROOT}"
SUITE_TSV="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\tavg_delta\tbad_pixel_ratio\tcompose_bad_pixel_ratio\tcompose_purple_rect_bad_pixel_ratio\tcompose_top_progress_bad_pixel_ratio\tcompose_bottom_swatches_bad_pixel_ratio\tcompose_shader_image_bad_pixel_ratio\tcompose_shader_composite_bad_pixel_ratio\tcompose_shader_linear_bad_pixel_ratio\treport\tdiff\n" > "${SUITE_TSV}"

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
  local bad_pixel_ratio
  local compose_bad_pixel_ratio
  local compose_purple_rect_bad_pixel_ratio
  local compose_top_progress_bad_pixel_ratio
  local compose_bottom_swatches_bad_pixel_ratio
  local compose_shader_image_bad_pixel_ratio
  local compose_shader_composite_bad_pixel_ratio
  local compose_shader_linear_bad_pixel_ratio
  avg_delta="$(summary_value "${summary}" screenshot_parity_avgDelta)"
  bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_badPixelRatio)"
  compose_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeCanvas_badPixelRatio)"
  compose_purple_rect_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composePurpleRect_badPixelRatio)"
  compose_top_progress_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeTopProgress_badPixelRatio)"
  compose_bottom_swatches_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeBottomSwatches_badPixelRatio)"
  compose_shader_image_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderImage_badPixelRatio)"
  compose_shader_composite_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderComposite_badPixelRatio)"
  compose_shader_linear_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeShaderLinear_badPixelRatio)"

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${avg_delta}" "${bad_pixel_ratio}" "${compose_bad_pixel_ratio}" \
    "${compose_purple_rect_bad_pixel_ratio}" "${compose_top_progress_bad_pixel_ratio}" "${compose_bottom_swatches_bad_pixel_ratio}" \
    "${compose_shader_image_bad_pixel_ratio}" "${compose_shader_composite_bad_pixel_ratio}" "${compose_shader_linear_bad_pixel_ratio}" \
    "${out_dir}/report/report.md" "${out_dir}/report/parity-diff.png" >> "${SUITE_TSV}"
  echo "status=${status} avg_delta=${avg_delta} bad_pixel_ratio=${bad_pixel_ratio} compose_bad_pixel_ratio=${compose_bad_pixel_ratio} compose_bottom_swatches_bad_pixel_ratio=${compose_bottom_swatches_bad_pixel_ratio} compose_shader_image_bad_pixel_ratio=${compose_shader_image_bad_pixel_ratio} compose_shader_composite_bad_pixel_ratio=${compose_shader_composite_bad_pixel_ratio} compose_shader_linear_bad_pixel_ratio=${compose_shader_linear_bad_pixel_ratio} report=${out_dir}/report/report.md"
  if [ "${status}" != "passed" ]; then
    return 1
  fi
}

run_named_case() {
  case "$1" in
    parity-rich)
      run_case "$1"
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
    parity-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4 \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10
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
