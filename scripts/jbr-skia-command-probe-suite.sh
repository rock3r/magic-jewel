#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-command-probe-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-8}"
WARMUP_SECONDS="${WARMUP_SECONDS:-2}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
CASES="${CASES:-commands-core-primitives commands-gradient-surfaces commands-gradient-paths commands-popup commands-popup-window commands-menu commands-text-image commands-native-text commands-shader-fallback commands-image-filter-fallback commands-gradient-stroke-fallback commands-color-filter-fallback commands-path-effect-fallback commands-blend-mode-fallback commands-save-layer-filter-fallback commands-invalid-gradient-fallback}"

mkdir -p "${OUT_ROOT}"
SUITE_TSV="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\tfallbacks\tunsupported\tjbr_picture_frames\tjbr_command_frames\tjbr_command_fps\treport\n" > "${SUITE_TSV}"

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
    JBR_SKIA_RENDER_MODE=commands \
    "$@" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" >/tmp/magic-jewel-${name}-command-probe-report.txt

  local report
  report="$(cat /tmp/magic-jewel-${name}-command-probe-report.txt)"
  local status
  status="$(grep -E '^validation_status=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local command_frames
  command_frames="$(grep -E '^jbr_command_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local picture_frames
  picture_frames="$(grep -E '^jbr_picture_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local fallback
  fallback="$(grep -E '^fallback_new_count=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local reasons
  reasons="$(grep -E '^cmp_unsupported_reasons=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local command_fps
  command_fps="$(summary_value "${out_dir}/summary.properties" jbr_command_fps)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${fallback}" "${reasons}" "${picture_frames}" "${command_frames}" "${command_fps}" "${report}" >> "${SUITE_TSV}"
  echo "status=${status} fallback_new_count=${fallback} unsupported=${reasons} jbr_picture_frames=${picture_frames} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

run_named_case() {
  case "$1" in
    commands-core-primitives)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_COMPOSE_TRANSFORM=true \
        MAGIC_JEWEL_COMPOSE_SAVELAYER=true \
        MAGIC_JEWEL_COMPOSE_CLIP=true \
        MAGIC_JEWEL_COMPOSE_CLIP_OUT=true \
        MAGIC_JEWEL_COMPOSE_CLIP_PATH=true \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=true \
        MAGIC_JEWEL_COMPOSE_DRAW_ARC=true \
        MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-gradient-surfaces)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true
      ;;
    commands-gradient-paths)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true
      ;;
    commands-popup)
      run_case "$1" \
        MAGIC_JEWEL_POPUP_STRESS=true \
        EXPECT_MIN_POPUP_FRAMES=5
      ;;
    commands-popup-window)
      run_case "$1" \
        MAGIC_JEWEL_POPUP_WINDOW_STRESS=true \
        EXPECT_MIN_POPUP_FRAMES=5
      ;;
    commands-menu)
      run_case "$1" \
        MAGIC_JEWEL_MENU_STRESS=true \
        EXPECT_MIN_POPUP_FRAMES=5
      ;;
    commands-text-image)
      run_case "$1" \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4
      ;;
    commands-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-image-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=image
      ;;
    commands-gradient-stroke-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=linearGradientPaint
      ;;
    commands-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilter
      ;;
    commands-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=pathEffect
      ;;
    commands-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=blendMode_Plus
      ;;
    commands-save-layer-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=saveLayer
      ;;
    commands-invalid-gradient-fallback)
      run_case "$1" \
        MAGIC_JEWEL_INVALID_SWEEP_GRADIENT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=sweepGradientStops
      ;;
    *)
      echo "Unknown command probe case: $1" >&2
      return 2
      ;;
  esac
}

for case_name in ${CASES}; do
  run_named_case "${case_name}"
done

echo "JBR_SKIA_COMMAND_PROBE_SUITE passed out_root=${OUT_ROOT}"
echo "suite=${SUITE_TSV}"
