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
CASES="${CASES:-parity-rich parity-geometry-clean parity-native-text parity-runtime-effect-pure-color parity-runtime-effect-uniform-only parity-runtime-effect-child-only parity-graphics-layer-effects}"

mkdir -p "${OUT_ROOT}"
SUITE_TSV="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\tavg_delta\tbad_pixel_ratio\tcompose_bad_pixel_ratio\treport\tdiff\n" > "${SUITE_TSV}"

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

run_case() {
  local name="$1"
  shift
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} =="

  env \
    OUT_DIR="${out_dir}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    "$@" \
    "${PARITY_SCRIPT}"

  local summary="${out_dir}/report/summary.properties"
  local status="passed"
  local avg_delta
  local bad_pixel_ratio
  local compose_bad_pixel_ratio
  avg_delta="$(summary_value "${summary}" screenshot_parity_avgDelta)"
  bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_badPixelRatio)"
  compose_bad_pixel_ratio="$(summary_value "${summary}" screenshot_parity_region_composeCanvas_badPixelRatio)"

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${avg_delta}" "${bad_pixel_ratio}" "${compose_bad_pixel_ratio}" \
    "${out_dir}/report/report.md" "${out_dir}/report/parity-diff.png" >> "${SUITE_TSV}"
  echo "status=${status} avg_delta=${avg_delta} bad_pixel_ratio=${bad_pixel_ratio} compose_bad_pixel_ratio=${compose_bad_pixel_ratio} report=${out_dir}/report/report.md"
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
        MAX_BAD_PIXEL_RATIO=0.07 \
        MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.11 \
        MAX_SWING_ISLAND_BAD_PIXEL_RATIO=0.08 \
        EXPECT_MIN_IMAGE_REFS=0
      ;;
    parity-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=0 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4 \
        MAX_BAD_PIXEL_RATIO=0.05
      ;;
    parity-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true
      ;;
    parity-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true
      ;;
    parity-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true
      ;;
    parity-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true
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
