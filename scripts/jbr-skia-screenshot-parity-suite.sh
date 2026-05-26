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
CASE_GROUPS="${CASE_GROUPS:-}"
CASES_WAS_SET="${CASES+x}"
LIST_CASE_GROUPS="${LIST_CASE_GROUPS:-false}"
LIST_CASE_GROUP_COUNTS="${LIST_CASE_GROUP_COUNTS:-false}"
LIST_UNGROUPED_CASES="${LIST_UNGROUPED_CASES:-false}"
CASES="${CASES:-parity-rich parity-button-chrome parity-geometry-clean parity-skew-transform parity-vertices parity-save-layer-filter parity-native-custom-font-text-image parity-native-generic-font-text parity-native-loaded-font-data-text parity-native-resource-font-text parity-native-system-font-text parity-resize-native-generic-font-text parity-resize-native-loaded-font-data-text parity-resize-native-resource-font-text parity-resize-native-system-font-text parity-forced-context-native-custom-font-text-image parity-forced-context-native-generic-font-text parity-forced-context-native-loaded-font-data-text parity-forced-context-native-resource-font-text parity-forced-context-native-system-font-text parity-forced-context-image-refs parity-point-dots parity-path-effect parity-draw-shapes parity-clip-rects parity-clip-path parity-blend-modes parity-gradient-surfaces parity-gradient-paths parity-gradient-shaders parity-gradient-stroke parity-image-filter parity-image-color-matrix-filter parity-color-filter-handle parity-resize-color-filter-handle parity-forced-context-color-filter-handle parity-color-matrix-filter parity-lighting-filter parity-descriptor-eviction parity-image-shader parity-color-shader parity-resize-color-shader parity-forced-context-color-shader parity-noise-shader parity-resize-noise-shader parity-forced-context-noise-shader parity-turbulence-shader parity-resize-turbulence-shader parity-forced-context-turbulence-shader parity-image-shader-color-filter parity-composite-shader parity-composite-noise-shader parity-resize-composite-noise-shader parity-forced-context-composite-noise-shader parity-composite-shader-color-filter parity-linear-gradient-shader-color-filter parity-transformed-shader parity-runtime-effect-pure-color parity-resize-runtime-effect-pure-color parity-forced-context-runtime-effect-pure-color parity-runtime-effect-uniform-only parity-runtime-effect-child-only parity-runtime-effect-shader-source-cache-eviction parity-runtime-effect-shader parity-runtime-effect-shader-color-filter parity-runtime-effect-color-filter parity-runtime-effect-stable-color-filter parity-resize-runtime-effect-stable-color-filter parity-forced-context-runtime-effect-stable-color-filter parity-runtime-effect-color-filter-child parity-runtime-effect-source-cache-eviction parity-graphics-layer parity-graphics-layer-effects parity-graphics-layer-blend-mode parity-graphics-layer-color-filter parity-graphics-layer-color-matrix-filter parity-graphics-layer-blend-color-filter parity-graphics-layer-blend-color-matrix-filter parity-resize-graphics-layer-color-matrix-filter parity-forced-context-graphics-layer-color-matrix-filter parity-resize-graphics-layer-render-effect parity-forced-context-graphics-layer-render-effect parity-graphics-layer-offset-effect parity-graphics-layer-chained-render-effect parity-graphics-layer-render-effect-color-filter parity-graphics-layer-render-effect-blend-mode parity-graphics-layer-render-effect-color-matrix-filter parity-graphics-layer-render-effect-blend-color-filter parity-graphics-layer-render-effect-blend-color-matrix-filter parity-graphics-layer-offset-effect-blend-color-matrix-filter parity-graphics-layer-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-clip parity-graphics-layer-round-clip parity-graphics-layer-path-clip parity-graphics-layer-shadow parity-graphics-layer-round-shadow parity-graphics-layer-path-shadow parity-graphics-layer-modulate-alpha parity-graphics-layer-offscreen parity-graphics-layer-rotationx parity-graphics-layer-rotationy parity-graphics-layer-rotationxy parity-graphics-layer-scale-translate parity-graphics-layer-near-camera parity-graphics-layer-offcenter-pivot}"

list_case_groups() {
  printf "%s\n" \
    smoke \
    core-drawing \
    native-text \
    descriptor-lifecycle \
    shader-rendering \
    runtime-effect \
    graphics-layer-basic \
    graphics-layer-effects \
    graphics-layer-clip-shadow-transform
}

case_group_cases() {
  case "$1" in
    smoke)
      echo "parity-rich parity-button-chrome parity-geometry-clean"
      ;;
    core-drawing)
      echo "parity-skew-transform parity-vertices parity-save-layer-filter parity-forced-context-image-refs parity-point-dots parity-path-effect parity-draw-shapes parity-clip-rects parity-clip-path parity-blend-modes parity-gradient-surfaces parity-gradient-paths parity-gradient-shaders parity-gradient-stroke parity-image-filter parity-image-color-matrix-filter"
      ;;
    native-text)
      echo "parity-native-custom-font-text-image parity-native-generic-font-text parity-native-loaded-font-data-text parity-native-resource-font-text parity-native-system-font-text parity-resize-native-generic-font-text parity-resize-native-loaded-font-data-text parity-resize-native-resource-font-text parity-resize-native-system-font-text parity-forced-context-native-custom-font-text-image parity-forced-context-native-generic-font-text parity-forced-context-native-loaded-font-data-text parity-forced-context-native-resource-font-text parity-forced-context-native-system-font-text"
      ;;
    descriptor-lifecycle)
      echo "parity-color-filter-handle parity-resize-color-filter-handle parity-forced-context-color-filter-handle parity-color-matrix-filter parity-lighting-filter parity-descriptor-eviction"
      ;;
    shader-rendering)
      echo "parity-image-shader parity-color-shader parity-resize-color-shader parity-forced-context-color-shader parity-noise-shader parity-resize-noise-shader parity-forced-context-noise-shader parity-turbulence-shader parity-resize-turbulence-shader parity-forced-context-turbulence-shader parity-image-shader-color-filter parity-composite-shader parity-composite-noise-shader parity-resize-composite-noise-shader parity-forced-context-composite-noise-shader parity-composite-shader-color-filter parity-linear-gradient-shader-color-filter parity-transformed-shader"
      ;;
    runtime-effect)
      echo "parity-runtime-effect-pure-color parity-resize-runtime-effect-pure-color parity-forced-context-runtime-effect-pure-color parity-runtime-effect-uniform-only parity-runtime-effect-child-only parity-runtime-effect-shader-source-cache-eviction parity-runtime-effect-shader parity-runtime-effect-shader-color-filter parity-runtime-effect-color-filter parity-runtime-effect-stable-color-filter parity-resize-runtime-effect-stable-color-filter parity-forced-context-runtime-effect-stable-color-filter parity-runtime-effect-color-filter-child parity-runtime-effect-source-cache-eviction"
      ;;
    graphics-layer-basic)
      echo "parity-graphics-layer parity-graphics-layer-effects parity-graphics-layer-blend-mode parity-graphics-layer-color-filter parity-graphics-layer-color-matrix-filter parity-graphics-layer-blend-color-filter parity-graphics-layer-blend-color-matrix-filter"
      ;;
    graphics-layer-effects)
      echo "parity-resize-graphics-layer-color-matrix-filter parity-forced-context-graphics-layer-color-matrix-filter parity-resize-graphics-layer-render-effect parity-forced-context-graphics-layer-render-effect parity-graphics-layer-offset-effect parity-graphics-layer-chained-render-effect parity-graphics-layer-render-effect-color-filter parity-graphics-layer-render-effect-blend-mode parity-graphics-layer-render-effect-color-matrix-filter parity-graphics-layer-render-effect-blend-color-filter parity-graphics-layer-render-effect-blend-color-matrix-filter parity-graphics-layer-offset-effect-blend-color-matrix-filter parity-graphics-layer-chained-render-effect-blend-color-matrix-filter parity-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter"
      ;;
    graphics-layer-clip-shadow-transform)
      echo "parity-graphics-layer-clip parity-graphics-layer-round-clip parity-graphics-layer-path-clip parity-graphics-layer-shadow parity-graphics-layer-round-shadow parity-graphics-layer-path-shadow parity-graphics-layer-modulate-alpha parity-graphics-layer-offscreen parity-graphics-layer-rotationx parity-graphics-layer-rotationy parity-graphics-layer-rotationxy parity-graphics-layer-scale-translate parity-graphics-layer-near-camera parity-graphics-layer-offcenter-pivot"
      ;;
    *)
      echo "Unknown CASE_GROUPS entry: $1" >&2
      exit 2
      ;;
  esac
}

if [[ "${LIST_CASE_GROUPS}" == "true" ]]; then
  list_case_groups
  exit 0
fi

if [[ "${LIST_CASE_GROUP_COUNTS}" == "true" ]]; then
  for group in $(list_case_groups); do
    printf "%s\t%s\n" "${group}" "$(case_group_cases "${group}" | wc -w | tr -d ' ')"
  done
  exit 0
fi

case_in_words() {
  local needle="$1"
  shift
  local word
  for word in "$@"; do
    if [[ "${word}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

group_case_union() {
  local seen=()
  local group
  local name
  for group in $(list_case_groups); do
    for name in $(case_group_cases "${group}"); do
      if (( ${#seen[@]} == 0 )) || ! case_in_words "${name}" "${seen[@]}"; then
        seen+=("${name}")
        printf "%s\n" "${name}"
      fi
    done
  done
}

list_ungrouped_cases() {
  local grouped_cases
  grouped_cases="$(group_case_union)"
  local name
  for name in ${CASES}; do
    if ! case_in_words "${name}" ${grouped_cases}; then
      printf "%s\n" "${name}"
    fi
  done
}

if [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  CASES=""
  for group in ${CASE_GROUPS}; do
    CASES="${CASES} $(case_group_cases "${group}")"
  done
  CASES="${CASES# }"
fi

if [[ -n "${CASES_FROM:-}" || -n "${CASES_UNTIL:-}" ]]; then
  filtered=""
  include=false
  started=false
  ended=false
  [[ -z "${CASES_FROM:-}" ]] && include=true
  for case_name in ${CASES}; do
    if [[ -n "${CASES_FROM:-}" && "${case_name}" == "${CASES_FROM}" ]]; then
      include=true
      started=true
    fi
    if [[ "${include}" == "true" ]]; then
      filtered="${filtered} ${case_name}"
    fi
    if [[ -n "${CASES_UNTIL:-}" && "${case_name}" == "${CASES_UNTIL}" ]]; then
      ended=true
      break
    fi
  done
  if [[ -n "${CASES_FROM:-}" && "${started}" != "true" ]]; then
    echo "Unknown CASES_FROM: ${CASES_FROM}" >&2
    exit 2
  fi
  if [[ -n "${CASES_UNTIL:-}" && "${ended}" != "true" ]]; then
    echo "Unknown CASES_UNTIL: ${CASES_UNTIL}" >&2
    exit 2
  fi
  CASES="${filtered# }"
fi

if [[ "${LIST_CASES:-false}" == "true" ]]; then
  for case_name in ${CASES}; do
    echo "${case_name}"
  done
  exit 0
fi

if [[ "${LIST_UNGROUPED_CASES}" == "true" ]]; then
  list_ungrouped_cases
  exit 0
fi

if [[ "${LIST_CASE_COUNT:-false}" == "true" ]]; then
  count=0
  for case_name in ${CASES}; do
    count=$((count + 1))
  done
  echo "${count}"
  exit 0
fi

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
    parity-skew-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TEXT=false \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_COMPOSE_IMAGE=false \
        MAGIC_JEWEL_COMPOSE_SKEW_TRANSFORM=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_COMPOSE_BOTTOM_SWATCHES_BAD_PIXEL_RATIO=0.005
      ;;
    parity-vertices)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11
      ;;
    parity-save-layer-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11
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
    parity-resize-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
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
    parity-forced-context-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
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
        EXPECT_MIN_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
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
    parity-draw-shapes)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=true \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=true \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.10 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.07
      ;;
    parity-clip-rects)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CLIP=true \
        MAGIC_JEWEL_COMPOSE_CLIP_OUT=true \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.08
      ;;
    parity-clip-path)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CLIP_PATH=true \
        MIN_CLIP_PATH_PROBE_RIGHT_CYAN=3000 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.08 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.05
      ;;
    parity-blend-modes)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-gradient-surfaces)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-gradient-paths)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-gradient-shaders)
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
        MAGIC_JEWEL_COMPOSE_GRADIENT_SHADERS=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.08
      ;;
    parity-gradient-stroke)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.08 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.05
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.06
      ;;
    parity-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-resize-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.06
      ;;
    parity-forced-context-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.06
      ;;
    parity-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.06
      ;;
    parity-lighting-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=false \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=false \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=false \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=false \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=false \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.06
      ;;
    parity-descriptor-eviction)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_DESCRIPTOR_EVICTION=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1024 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1024 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_EVICTS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1024 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1024 \
        EXPECT_MIN_JBR_SHADER_HANDLE_EVICTS=1
      ;;
    parity-image-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TEXT=false \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        MIN_IMAGE_SHADER_PROBE_RIGHT_DARK=900 \
        EXPECT_MIN_IMAGE_REFS=1 \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_COMPOSE_SHADER_IMAGE_BAD_PIXEL_RATIO=0.07
      ;;
    parity-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_IMAGE_BAD_PIXEL_RATIO=0.05
      ;;
    parity-composite-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TEXT=false \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.09
      ;;
    parity-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.09
      ;;
    parity-resize-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.09
      ;;
    parity-forced-context-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.09
      ;;
    parity-composite-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO=0.07
      ;;
    parity-linear-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_SHADER_LINEAR_BAD_PIXEL_RATIO=0.05
      ;;
    parity-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.09
      ;;
    parity-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-resize-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03
      ;;
    parity-forced-context-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-runtime-effect-shader-source-cache-eviction)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        JBR_SKIA_RUNTIME_EFFECT_CACHE_LIMIT_FOR_TEST=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 \
        EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=shader
      ;;
    parity-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-runtime-effect-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-resize-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03
      ;;
    parity-forced-context-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        MAX_BAD_PIXEL_RATIO=0.06
      ;;
    parity-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    parity-runtime-effect-source-cache-eviction)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        JBR_SKIA_RUNTIME_EFFECT_CACHE_LIMIT_FOR_TEST=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 \
        EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=colorFilter
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1
      ;;
    parity-graphics-layer)
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
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-blend-mode)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-color-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-color-matrix-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-blend-color-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-blend-color-matrix-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-resize-graphics-layer-color-matrix-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-forced-context-graphics-layer-color-matrix-filter)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-resize-graphics-layer-render-effect)
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
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-forced-context-graphics-layer-render-effect)
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
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=false \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_HEADER_BUTTONS_BAD_PIXEL_RATIO=0.03 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-offset-effect)
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-chained-render-effect)
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        MAX_BAD_PIXEL_RATIO=0.10 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.13 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.16
      ;;
    parity-graphics-layer-clip)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP=true \
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-round-clip)
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
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
      ;;
    parity-graphics-layer-path-clip)
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
        MAX_BAD_PIXEL_RATIO=0.09 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.12 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.09
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
    parity-graphics-layer-modulate-alpha)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_MODULATE_ALPHA=true \
        MAX_BAD_PIXEL_RATIO=0.08 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.13
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
    parity-graphics-layer-scale-translate)
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
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SCALE_TRANSLATE=true \
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
