#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
source "${SCRIPT_DIR}/jbr-skia-daily-validation-guard.sh"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-command-probe-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-8}"
WARMUP_SECONDS="${WARMUP_SECONDS:-2}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
CASE_GROUPS="${CASE_GROUPS:-}"
CASES_WAS_SET="${CASES+x}"
CASES_FROM="${CASES_FROM:-}"
CASES_UNTIL="${CASES_UNTIL:-}"
LIST_CASE_GROUPS="${LIST_CASE_GROUPS:-false}"
LIST_CASE_GROUP_COUNTS="${LIST_CASE_GROUP_COUNTS:-false}"
LIST_CASES="${LIST_CASES:-false}"
LIST_CASE_COUNT="${LIST_CASE_COUNT:-false}"
LIST_UNGROUPED_CASES="${LIST_UNGROUPED_CASES:-false}"
EARLY_DEFAULT_BROAD_VALIDATION_GUARDED=false
if [[ "${LIST_CASE_GROUPS}" != "true" && "${LIST_CASE_GROUP_COUNTS}" != "true" && "${LIST_CASES}" != "true" && "${LIST_CASE_COUNT}" != "true" && "${LIST_UNGROUPED_CASES}" != "true" && -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" && -z "${CASES_FROM}" && -z "${CASES_UNTIL}" ]]; then
  jbr_skia_daily_broad_validation_guard "command-probe suite (default launch)"
  EARLY_DEFAULT_BROAD_VALIDATION_GUARDED=true
fi
if [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  CASES="__CASE_GROUPS_SELECTED__"
fi
CASES="${CASES:-commands-live-animation commands-invalid-command-stream-flags-fallback commands-invalid-command-record-flags-fallback commands-invalid-command-coordinate-space-fallback commands-invalid-command-paint-format-fallback commands-invalid-command-payload-length-fallback commands-invalid-command-payload-truncated-fallback commands-invalid-command-payload-extra-fallback commands-invalid-command-record-length-fallback commands-native-bridge-load-library commands-core-primitives commands-point-lines commands-point-dots commands-concat-transform commands-skew-transform commands-gradient-surfaces commands-gradient-paths commands-linear-gradient-path-stroke-fallback commands-radial-gradient-path-stroke-fallback commands-sweep-gradient-path-stroke-fallback commands-popup commands-popup-window commands-menu commands-text-image commands-native-custom-font-text-image commands-native-generic-font-text commands-native-loaded-font-data-text commands-native-resource-font-text commands-native-system-font-text commands-resize-native-generic-font-text commands-resize-native-loaded-font-data-text commands-resize-native-resource-font-text commands-resize-native-system-font-text commands-forced-context-native-custom-font-text-image commands-forced-context-native-generic-font-text commands-forced-context-native-loaded-font-data-text commands-forced-context-native-resource-font-text commands-forced-context-native-system-font-text commands-forced-context-dynamic-images commands-image-path-effect-fallback commands-image-shader commands-raw-image-shader-fallback commands-color-shader commands-descriptor-stroke-shader-fallback commands-gradient-shaders commands-noise-shader commands-turbulence-shader commands-raw-linear-gradient-shader-fallback commands-raw-radial-gradient-shader-fallback commands-raw-sweep-gradient-shader-fallback commands-raw-conical-gradient-shader-fallback commands-raw-noise-shader-fallback commands-raw-turbulence-shader-fallback commands-image-shader-color-filter commands-composite-shader commands-composite-noise-shader commands-composite-shader-color-filter commands-resize-composite-shader-color-filter commands-forced-context-composite-shader-color-filter commands-transformed-shader commands-resize-transformed-shader commands-forced-context-transformed-shader commands-runtime-effect-shader commands-resize-runtime-effect-shader commands-forced-context-runtime-effect-shader commands-raw-runtime-effect-shader-fallback commands-runtime-effect-shader-color-filter commands-resize-runtime-effect-shader-color-filter commands-forced-context-runtime-effect-shader-color-filter commands-linear-gradient-shader-color-filter commands-resize-linear-gradient-shader-color-filter commands-forced-context-linear-gradient-shader-color-filter commands-radial-gradient-shader-color-filter commands-resize-radial-gradient-shader-color-filter commands-forced-context-radial-gradient-shader-color-filter commands-sweep-gradient-shader-color-filter commands-resize-sweep-gradient-shader-color-filter commands-forced-context-sweep-gradient-shader-color-filter commands-runtime-effect-pure-color commands-resize-runtime-effect-pure-color commands-forced-context-runtime-effect-pure-color commands-runtime-effect-uniform-only commands-resize-runtime-effect-uniform-only commands-forced-context-runtime-effect-uniform-only commands-runtime-effect-child-only commands-resize-runtime-effect-child-only commands-forced-context-runtime-effect-child-only commands-runtime-effect-shader-source-cache-eviction commands-runtime-effect-invalid-uniform-schema-fallback commands-runtime-effect-invalid-child-schema-fallback commands-runtime-effect-invalid-nested-child-fallback commands-runtime-effect-color-filter commands-resize-runtime-effect-color-filter commands-forced-context-runtime-effect-color-filter commands-runtime-effect-stable-color-filter commands-resize-runtime-effect-stable-color-filter commands-forced-context-runtime-effect-stable-color-filter commands-raw-runtime-effect-color-filter-fallback commands-runtime-effect-color-filter-child commands-resize-runtime-effect-color-filter-child commands-forced-context-runtime-effect-color-filter-child commands-runtime-effect-source-cache-eviction commands-runtime-effect-color-filter-invalid-uniform-schema-fallback commands-runtime-effect-color-filter-invalid-child-schema-fallback commands-runtime-effect-color-filter-invalid-nested-child-fallback commands-runtime-effect-color-filter-compile-fallback commands-runtime-effect-color-filter-build-fallback commands-runtime-effect-color-filter-child-type-fallback commands-runtime-effect-compile-fallback commands-runtime-effect-build-fallback commands-runtime-effect-child-type-fallback commands-invalid-descriptor-use-fallback commands-invalid-shader-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback commands-invalid-path-effect-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-missing-fallback commands-offset-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback commands-shader-color-filter-effect-child-missing-fallback commands-invalid-shader-descriptor-type-fallback commands-invalid-descriptor-version-fallback commands-shader-wrong-effect-type-fallback commands-transformed-shader-child-wrong-effect-type-fallback commands-composite-shader-child-wrong-effect-type-fallback commands-composite-shader-src-child-wrong-effect-type-fallback commands-runtime-effect-shader-child-wrong-effect-type-fallback commands-transformed-shader-child-missing-fallback commands-composite-shader-child-missing-fallback commands-composite-shader-src-child-missing-fallback commands-shader-color-filter-shader-child-missing-fallback commands-color-filter-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-path-effect-wrong-type-fallback commands-color-filter-path-effect-wrong-type-fallback commands-shader-color-filter-wrong-effect-type-fallback commands-image-filter-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback commands-chain-path-effect-child-wrong-effect-type-fallback commands-gradient-stroke commands-image-filter commands-image-color-matrix-filter commands-image-raw-table-color-filter-fallback commands-raw-blend-color-filter-fallback commands-raw-table-color-filter-fallback commands-color-filter commands-color-filter-blend-mode commands-color-filter-handle commands-color-matrix-filter commands-color-matrix-filter-nonfinite-fallback commands-lighting-filter commands-descriptor-eviction commands-resize-descriptor-redefine commands-forced-context-descriptor-redefine commands-resize-shader-descriptor-redefine commands-forced-context-shader-descriptor-redefine commands-resize-color-shader-descriptor-redefine commands-forced-context-color-shader-descriptor-redefine commands-resize-noise-shader-descriptor-redefine commands-forced-context-noise-shader-descriptor-redefine commands-resize-turbulence-shader-descriptor-redefine commands-forced-context-turbulence-shader-descriptor-redefine commands-resize-composite-noise-shader-descriptor-redefine commands-forced-context-composite-noise-shader-descriptor-redefine commands-path-effect commands-path-effect-color-filter-fallback commands-raw-discrete-path-effect-fallback commands-vertices commands-blend-mode commands-graphics-layer commands-graphics-layer-modulate-alpha commands-graphics-layer-offscreen commands-graphics-layer-clip commands-graphics-layer-round-clip commands-graphics-layer-path-clip commands-graphics-layer-blend-mode commands-resize-graphics-layer-blend-mode commands-forced-context-graphics-layer-blend-mode commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-resize-graphics-layer-color-matrix-filter commands-forced-context-graphics-layer-color-matrix-filter commands-graphics-layer-raw-color-filter-fallback commands-graphics-layer-render-effect commands-resize-graphics-layer-render-effect commands-forced-context-graphics-layer-render-effect commands-graphics-layer-raw-image-filter-effect-fallback commands-graphics-layer-offset-effect commands-resize-graphics-layer-offset-effect commands-forced-context-graphics-layer-offset-effect commands-graphics-layer-chained-render-effect commands-resize-graphics-layer-chained-render-effect commands-forced-context-graphics-layer-chained-render-effect commands-graphics-layer-render-effect-color-filter commands-resize-graphics-layer-render-effect-color-filter commands-forced-context-graphics-layer-render-effect-color-filter commands-graphics-layer-render-effect-blend-mode commands-resize-graphics-layer-render-effect-blend-mode commands-forced-context-graphics-layer-render-effect-blend-mode commands-graphics-layer-render-effect-color-matrix-filter commands-resize-graphics-layer-render-effect-color-matrix-filter commands-forced-context-graphics-layer-render-effect-color-matrix-filter commands-graphics-layer-render-effect-blend-color-filter commands-resize-graphics-layer-render-effect-blend-color-filter commands-forced-context-graphics-layer-render-effect-blend-color-filter commands-graphics-layer-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-render-effect-blend-color-matrix-filter commands-graphics-layer-offset-effect-blend-color-matrix-filter commands-resize-graphics-layer-offset-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-offset-effect-blend-color-matrix-filter commands-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-graphics-layer-shadow commands-graphics-layer-invalid-shadow-elevation-fallback commands-graphics-layer-round-shadow commands-graphics-layer-path-shadow commands-graphics-layer-rotationx commands-graphics-layer-rotationy commands-graphics-layer-rotationxy commands-resize-graphics-layer-rotationxy commands-forced-context-graphics-layer-rotationxy commands-graphics-layer-scale-translate commands-resize-graphics-layer-scale-translate commands-forced-context-graphics-layer-scale-translate commands-graphics-layer-near-camera commands-resize-graphics-layer-near-camera commands-forced-context-graphics-layer-near-camera commands-graphics-layer-offcenter-pivot commands-resize-graphics-layer-offcenter-pivot commands-forced-context-graphics-layer-offcenter-pivot commands-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter commands-save-layer-filter commands-save-layer-raw-color-filter-fallback commands-opaque-shader-fallback commands-composite-opaque-shader-fallback commands-picture-shader-fallback commands-invalid-gradient-fallback}"
if [[ -z "${CASES_WAS_SET}" ]]; then
  CASES="${CASES/commands-graphics-layer-modulate-alpha commands-graphics-layer-offscreen/commands-graphics-layer-modulate-alpha commands-resize-graphics-layer-modulate-alpha commands-forced-context-graphics-layer-modulate-alpha commands-graphics-layer-offscreen}"
  CASES="${CASES/commands-graphics-layer-offscreen commands-graphics-layer-clip/commands-graphics-layer-offscreen commands-resize-graphics-layer-offscreen commands-forced-context-graphics-layer-offscreen commands-graphics-layer-clip}"
  CASES="${CASES/commands-graphics-layer-clip commands-graphics-layer-round-clip/commands-graphics-layer-clip commands-resize-graphics-layer-clip commands-forced-context-graphics-layer-clip commands-graphics-layer-round-clip}"
  CASES="${CASES/commands-graphics-layer-round-clip commands-graphics-layer-path-clip/commands-graphics-layer-round-clip commands-resize-graphics-layer-round-clip commands-forced-context-graphics-layer-round-clip commands-graphics-layer-path-clip}"
  CASES="${CASES/commands-graphics-layer-path-clip commands-graphics-layer-blend-mode/commands-graphics-layer-path-clip commands-resize-graphics-layer-path-clip commands-forced-context-graphics-layer-path-clip commands-graphics-layer-blend-mode}"
fi
list_case_groups() {
  printf "%s\n" \
    smoke \
    surface-transform-ui \
    gradient-path-stroke-fallbacks \
    gradient-path-structure-invalid \
    gradient-stop-invalid \
    gradient-geometry-invalid \
    gradient-color-count-invalid \
    gradient-stroke-width-invalid \
    gradient-round-rect-radius-invalid \
    gradient-stroke-round-rect-radius-invalid \
    image-shader-invalid \
    shader-rendering \
    shader-composition-runtime \
    core-effects \
    graphics-layer-extras \
    save-layer-shader-fallbacks \
    stream-invalid \
    primitive-invalid \
    path-invalid \
    effect-descriptor-invalid \
    shader-descriptor-invalid \
    gradient-invalid \
    gradient-path-invalid \
    runtime-effect-invalid \
    descriptor-handles-invalid \
    shader-ref-invalid \
    image-handles-invalid \
    save-layer-invalid \
    color-filters \
    descriptor-lifecycle \
    fill-rect-color-filter-invalid \
    native-text \
    native-text-invalid \
    blend-mode-invalid \
    graphics-layer-invalid \
    graphics-layer
}

case_group_cases() {
  case "$1" in
    smoke)
      echo "commands-live-animation commands-core-primitives commands-color-shader commands-color-filter-handle commands-color-matrix-filter commands-graphics-layer"
      ;;
    surface-transform-ui)
      echo "commands-native-bridge-load-library commands-point-lines commands-resize-point-lines commands-forced-context-point-lines commands-point-dots commands-resize-point-dots commands-forced-context-point-dots commands-concat-transform commands-resize-concat-transform commands-forced-context-concat-transform commands-skew-transform commands-resize-skew-transform commands-forced-context-skew-transform commands-gradient-surfaces commands-resize-gradient-surfaces commands-forced-context-gradient-surfaces commands-linear-gradient-blend-mode commands-resize-linear-gradient-blend-mode commands-forced-context-linear-gradient-blend-mode commands-radial-gradient-stroke-blend-mode commands-resize-radial-gradient-stroke-blend-mode commands-forced-context-radial-gradient-stroke-blend-mode commands-sweep-gradient-round-rect-blend-mode commands-resize-sweep-gradient-round-rect-blend-mode commands-forced-context-sweep-gradient-round-rect-blend-mode commands-gradient-paths commands-resize-gradient-paths commands-forced-context-gradient-paths commands-linear-gradient-path-blend-mode commands-resize-linear-gradient-path-blend-mode commands-forced-context-linear-gradient-path-blend-mode commands-popup commands-popup-window commands-menu commands-text-image"
      ;;
    gradient-path-stroke-fallbacks)
      echo "commands-linear-gradient-path-stroke-fallback commands-radial-gradient-path-stroke-fallback commands-sweep-gradient-path-stroke-fallback"
      ;;
    gradient-path-structure-invalid)
      echo "commands-linear-gradient-path-invalid-fallback commands-radial-gradient-path-invalid-fallback commands-sweep-gradient-path-invalid-fallback"
      ;;
    gradient-stop-invalid)
      echo "commands-linear-gradient-invalid-stops-fallback commands-linear-gradient-invalid-points-fallback commands-radial-gradient-invalid-stops-fallback commands-invalid-gradient-fallback"
      ;;
    gradient-geometry-invalid)
      echo "commands-linear-gradient-invalid-points-fallback commands-radial-gradient-invalid-geometry-fallback commands-sweep-gradient-invalid-geometry-fallback"
      ;;
    gradient-color-count-invalid)
      echo "commands-linear-gradient-invalid-color-count-fallback commands-radial-gradient-invalid-color-count-fallback commands-sweep-gradient-invalid-color-count-fallback"
      ;;
    gradient-stroke-width-invalid)
      echo "commands-linear-gradient-invalid-stroke-width-public-fallback commands-radial-gradient-invalid-stroke-width-public-fallback commands-sweep-gradient-invalid-stroke-width-public-fallback"
      ;;
    gradient-round-rect-radius-invalid)
      echo "commands-linear-gradient-round-rect-invalid-radius-fallback commands-radial-gradient-round-rect-invalid-radius-fallback commands-sweep-gradient-round-rect-invalid-radius-fallback"
      ;;
    gradient-stroke-round-rect-radius-invalid)
      echo "commands-linear-gradient-stroke-round-rect-invalid-radius-fallback commands-radial-gradient-stroke-round-rect-invalid-radius-fallback commands-sweep-gradient-stroke-round-rect-invalid-radius-fallback"
      ;;
    image-shader-invalid)
      echo "commands-image-shader-invalid-image-fallback"
      ;;
    shader-rendering)
      echo "commands-forced-context-dynamic-images commands-image-blend-mode commands-resize-image-blend-mode commands-forced-context-image-blend-mode commands-image-path-effect-fallback commands-image-shader commands-resize-image-shader commands-forced-context-image-shader commands-image-shader-blend-mode commands-resize-image-shader-blend-mode commands-forced-context-image-shader-blend-mode commands-image-shader-invalid-image-fallback commands-raw-image-shader-fallback commands-resize-color-shader commands-forced-context-color-shader commands-color-shader-blend-mode commands-resize-color-shader-blend-mode commands-forced-context-color-shader-blend-mode commands-descriptor-stroke-shader-fallback commands-gradient-shaders commands-resize-gradient-shaders commands-forced-context-gradient-shaders commands-noise-shader commands-resize-noise-shader commands-forced-context-noise-shader commands-turbulence-shader commands-resize-turbulence-shader commands-forced-context-turbulence-shader commands-raw-linear-gradient-shader-fallback commands-raw-radial-gradient-shader-fallback commands-raw-sweep-gradient-shader-fallback commands-raw-conical-gradient-shader-fallback commands-raw-noise-shader-fallback commands-raw-turbulence-shader-fallback"
      ;;
    shader-composition-runtime)
      echo "commands-image-shader-color-filter commands-resize-image-shader-color-filter commands-forced-context-image-shader-color-filter commands-composite-shader commands-resize-composite-shader commands-forced-context-composite-shader commands-resize-composite-shader-descriptor-redefine commands-forced-context-composite-shader-descriptor-redefine commands-composite-noise-shader commands-resize-composite-noise-shader commands-forced-context-composite-noise-shader commands-composite-shader-color-filter commands-resize-composite-shader-color-filter commands-forced-context-composite-shader-color-filter commands-transformed-shader commands-resize-transformed-shader commands-forced-context-transformed-shader commands-runtime-effect-shader commands-resize-runtime-effect-shader commands-forced-context-runtime-effect-shader commands-raw-runtime-effect-shader-fallback commands-runtime-effect-shader-color-filter commands-resize-runtime-effect-shader-color-filter commands-forced-context-runtime-effect-shader-color-filter commands-linear-gradient-shader-color-filter commands-resize-linear-gradient-shader-color-filter commands-forced-context-linear-gradient-shader-color-filter commands-radial-gradient-shader-color-filter commands-resize-radial-gradient-shader-color-filter commands-forced-context-radial-gradient-shader-color-filter commands-sweep-gradient-shader-color-filter commands-resize-sweep-gradient-shader-color-filter commands-forced-context-sweep-gradient-shader-color-filter commands-runtime-effect-pure-color commands-resize-runtime-effect-pure-color commands-forced-context-runtime-effect-pure-color commands-runtime-effect-uniform-only commands-resize-runtime-effect-uniform-only commands-forced-context-runtime-effect-uniform-only commands-runtime-effect-child-only commands-resize-runtime-effect-child-only commands-forced-context-runtime-effect-child-only commands-runtime-effect-shader-source-cache-eviction commands-runtime-effect-color-filter commands-resize-runtime-effect-color-filter commands-forced-context-runtime-effect-color-filter commands-runtime-effect-stable-color-filter commands-resize-runtime-effect-stable-color-filter commands-forced-context-runtime-effect-stable-color-filter commands-raw-runtime-effect-color-filter-fallback commands-runtime-effect-color-filter-child commands-resize-runtime-effect-color-filter-child commands-forced-context-runtime-effect-color-filter-child commands-runtime-effect-source-cache-eviction"
      ;;
    core-effects)
      echo "commands-gradient-stroke commands-resize-gradient-stroke commands-forced-context-gradient-stroke commands-image-filter commands-resize-image-filter commands-forced-context-image-filter commands-path-effect commands-resize-path-effect commands-forced-context-path-effect commands-path-effect-color-filter-fallback commands-raw-discrete-path-effect-fallback commands-vertices commands-resize-vertices commands-forced-context-vertices commands-vertices-raw-color-filter-fallback commands-blend-mode commands-resize-blend-mode commands-forced-context-blend-mode"
      ;;
    graphics-layer-extras)
      echo "commands-resize-graphics-layer commands-forced-context-graphics-layer commands-resize-graphics-layer-modulate-alpha commands-forced-context-graphics-layer-modulate-alpha commands-resize-graphics-layer-offscreen commands-forced-context-graphics-layer-offscreen commands-resize-graphics-layer-clip commands-forced-context-graphics-layer-clip commands-resize-graphics-layer-round-clip commands-forced-context-graphics-layer-round-clip commands-resize-graphics-layer-path-clip commands-forced-context-graphics-layer-path-clip commands-resize-graphics-layer-blend-mode commands-forced-context-graphics-layer-blend-mode commands-resize-graphics-layer-shadow commands-forced-context-graphics-layer-shadow commands-resize-graphics-layer-round-shadow commands-forced-context-graphics-layer-round-shadow commands-resize-graphics-layer-path-shadow commands-forced-context-graphics-layer-path-shadow commands-resize-graphics-layer-rotationx commands-forced-context-graphics-layer-rotationx commands-resize-graphics-layer-rotationy commands-forced-context-graphics-layer-rotationy commands-resize-graphics-layer-rotationxy commands-forced-context-graphics-layer-rotationxy commands-resize-graphics-layer-scale-translate commands-forced-context-graphics-layer-scale-translate commands-resize-graphics-layer-near-camera commands-forced-context-graphics-layer-near-camera commands-resize-graphics-layer-offcenter-pivot commands-forced-context-graphics-layer-offcenter-pivot commands-resize-graphics-layer-color-filter commands-forced-context-graphics-layer-color-filter commands-resize-graphics-layer-color-matrix-filter commands-forced-context-graphics-layer-color-matrix-filter commands-resize-graphics-layer-blend-color-filter commands-forced-context-graphics-layer-blend-color-filter commands-resize-graphics-layer-blend-color-matrix-filter commands-forced-context-graphics-layer-blend-color-matrix-filter commands-graphics-layer-raw-color-filter-fallback commands-graphics-layer-raw-table-color-filter-fallback commands-graphics-layer-unsupported-child-fallback commands-resize-graphics-layer-render-effect commands-forced-context-graphics-layer-render-effect commands-graphics-layer-raw-image-filter-effect-fallback commands-resize-graphics-layer-offset-effect commands-forced-context-graphics-layer-offset-effect commands-resize-graphics-layer-chained-render-effect commands-forced-context-graphics-layer-chained-render-effect commands-resize-graphics-layer-render-effect-color-filter commands-forced-context-graphics-layer-render-effect-color-filter commands-resize-graphics-layer-render-effect-blend-mode commands-forced-context-graphics-layer-render-effect-blend-mode commands-graphics-layer-render-effect-color-filter commands-graphics-layer-render-effect-blend-mode commands-graphics-layer-render-effect-color-matrix-filter commands-resize-graphics-layer-render-effect-color-matrix-filter commands-forced-context-graphics-layer-render-effect-color-matrix-filter commands-graphics-layer-render-effect-blend-color-filter commands-resize-graphics-layer-render-effect-blend-color-filter commands-forced-context-graphics-layer-render-effect-blend-color-filter commands-graphics-layer-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-render-effect-blend-color-matrix-filter commands-graphics-layer-offset-effect-blend-color-matrix-filter commands-resize-graphics-layer-offset-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-offset-effect-blend-color-matrix-filter commands-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-resize-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-forced-context-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter"
      ;;
    save-layer-shader-fallbacks)
      echo "commands-save-layer-filter commands-resize-save-layer-filter commands-forced-context-save-layer-filter commands-save-layer-color-matrix-filter commands-resize-save-layer-color-matrix-filter commands-forced-context-save-layer-color-matrix-filter commands-save-layer-blend-mode commands-resize-save-layer-blend-mode commands-forced-context-save-layer-blend-mode commands-save-layer-blend-color-filter commands-resize-save-layer-blend-color-filter commands-forced-context-save-layer-blend-color-filter commands-save-layer-raw-color-filter-fallback commands-save-layer-raw-table-color-filter-fallback commands-opaque-shader-fallback commands-composite-opaque-shader-fallback commands-picture-shader-fallback commands-invalid-gradient-fallback"
      ;;
    stream-invalid)
      echo "commands-invalid-command-stream-flags-fallback commands-invalid-command-record-flags-fallback commands-invalid-command-coordinate-space-fallback commands-invalid-command-paint-format-fallback commands-invalid-command-payload-length-fallback commands-invalid-command-payload-truncated-fallback commands-invalid-command-payload-extra-fallback commands-invalid-command-record-length-fallback"
      ;;
    primitive-invalid)
      echo "commands-invalid-stroke-cap-fallback commands-invalid-blend-layer-bounds-fallback commands-invalid-concat-transform-fallback commands-invalid-transform-record-flags-fallback commands-invalid-clip-operation-fallback commands-invalid-point-dots-fallback commands-invalid-draw-points-point-count-fallback commands-invalid-draw-points-max-point-count-fallback commands-invalid-draw-points-record-length-fallback commands-invalid-draw-vertices-vertex-count-fallback commands-invalid-draw-vertices-max-vertex-count-fallback commands-invalid-draw-vertices-record-length-fallback commands-invalid-draw-vertices-vertex-mode-fallback commands-invalid-draw-vertices-blend-mode-fallback commands-invalid-draw-vertices-index-count-fallback commands-invalid-draw-vertices-max-index-count-fallback"
      ;;
    path-invalid)
      echo "commands-clip-path-invalid-fallback commands-draw-path-invalid-fallback commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback commands-invalid-draw-path-path-effect-verb-fallback commands-invalid-stroke-line-dash-path-effect-interval-count-fallback commands-invalid-stroke-rect-dash-path-effect-interval-count-fallback commands-invalid-stroke-rect-dash-path-effect-width-fallback commands-invalid-stroke-rect-dash-path-effect-height-fallback commands-invalid-stroke-round-rect-dash-path-effect-interval-count-fallback commands-invalid-stroke-round-rect-dash-path-effect-right-fallback commands-invalid-stroke-round-rect-dash-path-effect-bottom-fallback commands-invalid-stroke-round-rect-dash-path-effect-radius-x-fallback commands-invalid-stroke-round-rect-dash-path-effect-radius-y-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-width-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-cap-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-join-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-miter-fallback commands-invalid-stroke-round-rect-dash-path-effect-phase-fallback commands-invalid-stroke-round-rect-dash-path-effect-interval-fallback commands-invalid-stroke-path-dash-path-effect-verb-fallback commands-invalid-stroke-path-dash-path-effect-interval-count-fallback commands-invalid-stroke-path-dash-path-effect-interval-fallback commands-invalid-draw-shadow-path-verb-fallback"
      ;;
    effect-descriptor-invalid)
      echo "commands-invalid-effect-descriptor-type-fallback commands-invalid-effect-descriptor-version-fallback commands-invalid-effect-descriptor-record-flags-fallback commands-invalid-effect-descriptor-payload-count-fallback commands-invalid-effect-descriptor-record-length-fallback commands-invalid-lighting-filter-descriptor-payload-count-fallback commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-sigma-fallback commands-invalid-blur-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-corner-path-effect-descriptor-negative-radius-fallback commands-invalid-stamped-path-effect-descriptor-advance-fallback commands-invalid-stamped-path-effect-descriptor-zero-advance-fallback commands-invalid-stamped-path-effect-descriptor-phase-fallback commands-invalid-stamped-path-effect-descriptor-negative-phase-fallback commands-invalid-stamped-path-effect-descriptor-style-fallback commands-invalid-stamped-path-effect-descriptor-fill-type-fallback commands-invalid-stamped-path-effect-descriptor-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-negative-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-path-verb-fallback commands-invalid-chain-path-effect-descriptor-payload-count-fallback"
      ;;
    shader-descriptor-invalid)
      echo "commands-invalid-shader-descriptor-type-fallback commands-invalid-shader-descriptor-record-flags-fallback commands-invalid-shader-descriptor-payload-count-fallback commands-invalid-color-shader-descriptor-payload-count-fallback commands-invalid-shader-color-filter-descriptor-payload-count-fallback commands-invalid-shader-descriptor-record-length-fallback commands-invalid-shader-descriptor-version-fallback commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-composite-shader-descriptor-blend-mode-fallback commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback commands-invalid-radial-gradient-shader-descriptor-radius-fallback commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback commands-invalid-image-shader-descriptor-width-fallback commands-invalid-image-shader-descriptor-max-width-fallback commands-invalid-image-shader-descriptor-height-fallback commands-invalid-image-shader-descriptor-max-height-fallback commands-invalid-image-shader-descriptor-tile-mode-x-fallback commands-invalid-image-shader-descriptor-tile-mode-y-fallback commands-invalid-perlin-noise-shader-kind-fallback commands-invalid-perlin-noise-shader-frequency-fallback commands-invalid-perlin-noise-shader-octaves-fallback commands-invalid-perlin-noise-shader-zero-octaves-fallback commands-invalid-perlin-noise-shader-tile-size-fallback commands-invalid-perlin-noise-shader-tile-height-fallback commands-invalid-perlin-noise-shader-negative-tile-size-fallback commands-invalid-perlin-noise-shader-negative-tile-height-fallback"
      ;;
    shader-ref-invalid)
      echo "commands-invalid-fill-rect-shader-ref-horizontal-bounds-fallback commands-invalid-fill-rect-shader-ref-vertical-bounds-fallback commands-invalid-fill-rect-shader-ref-alpha-fallback"
      ;;
    gradient-invalid)
      printf "%s\n" \
        commands-linear-gradient-invalid-stops-fallback \
        commands-linear-gradient-invalid-points-fallback \
        commands-radial-gradient-invalid-geometry-fallback \
        commands-sweep-gradient-invalid-geometry-fallback \
        commands-radial-gradient-invalid-stops-fallback \
        commands-invalid-gradient-fallback \
        commands-linear-gradient-invalid-color-count-fallback \
        commands-radial-gradient-invalid-color-count-fallback \
        commands-sweep-gradient-invalid-color-count-fallback \
        commands-linear-gradient-invalid-stroke-width-public-fallback \
        commands-radial-gradient-invalid-stroke-width-public-fallback \
        commands-sweep-gradient-invalid-stroke-width-public-fallback \
        commands-linear-gradient-round-rect-invalid-radius-fallback \
        commands-radial-gradient-round-rect-invalid-radius-fallback \
        commands-sweep-gradient-round-rect-invalid-radius-fallback \
        commands-linear-gradient-stroke-round-rect-invalid-radius-fallback \
        commands-radial-gradient-stroke-round-rect-invalid-radius-fallback \
        commands-sweep-gradient-stroke-round-rect-invalid-radius-fallback \
        commands-linear-gradient-path-invalid-fallback \
        commands-radial-gradient-path-invalid-fallback \
        commands-sweep-gradient-path-invalid-fallback \
        commands-invalid-linear-gradient-stroke-width-fallback \
        commands-invalid-linear-gradient-round-rect-stroke-width-fallback \
        commands-invalid-radial-gradient-stroke-width-fallback \
        commands-invalid-radial-gradient-round-rect-stroke-width-fallback \
        commands-invalid-sweep-gradient-stroke-width-fallback \
        commands-invalid-sweep-gradient-round-rect-stroke-width-fallback \
        commands-invalid-linear-gradient-tile-mode-fallback \
        commands-invalid-linear-gradient-round-rect-tile-mode-fallback \
        commands-invalid-linear-gradient-stroke-tile-mode-fallback \
        commands-invalid-linear-gradient-round-rect-stroke-tile-mode-fallback \
        commands-invalid-linear-gradient-color-count-fallback \
        commands-invalid-linear-gradient-round-rect-color-count-fallback \
        commands-invalid-linear-gradient-stroke-color-count-fallback \
        commands-invalid-linear-gradient-round-rect-stroke-color-count-fallback \
        commands-invalid-linear-gradient-stop-order-fallback \
        commands-invalid-linear-gradient-round-rect-stop-order-fallback \
        commands-invalid-linear-gradient-stroke-stop-order-fallback \
        commands-invalid-linear-gradient-round-rect-stroke-stop-order-fallback \
        commands-invalid-linear-gradient-path-tile-mode-fallback \
        commands-invalid-linear-gradient-path-color-count-fallback \
        commands-invalid-linear-gradient-path-stop-order-fallback \
        commands-invalid-linear-gradient-path-fill-type-fallback \
        commands-invalid-linear-gradient-path-data-length-fallback \
        commands-invalid-linear-gradient-path-verb-fallback \
        commands-invalid-radial-gradient-path-radius-fallback \
        commands-invalid-radial-gradient-path-tile-mode-fallback \
        commands-invalid-radial-gradient-path-color-count-fallback \
        commands-invalid-radial-gradient-path-stop-order-fallback \
        commands-invalid-radial-gradient-path-fill-type-fallback \
        commands-invalid-radial-gradient-path-data-length-fallback \
        commands-invalid-radial-gradient-path-verb-fallback \
        commands-invalid-sweep-gradient-path-color-count-fallback \
        commands-invalid-sweep-gradient-path-stop-order-fallback \
        commands-invalid-sweep-gradient-path-fill-type-fallback \
        commands-invalid-sweep-gradient-path-data-length-fallback \
        commands-invalid-sweep-gradient-path-verb-fallback \
        commands-invalid-sweep-gradient-color-count-fallback \
        commands-invalid-sweep-gradient-round-rect-color-count-fallback \
        commands-invalid-sweep-gradient-stroke-color-count-fallback \
        commands-invalid-sweep-gradient-round-rect-stroke-color-count-fallback \
        commands-invalid-sweep-gradient-stop-order-fallback \
        commands-invalid-sweep-gradient-round-rect-stop-order-fallback \
        commands-invalid-sweep-gradient-stroke-stop-order-fallback \
        commands-invalid-sweep-gradient-round-rect-stroke-stop-order-fallback \
        commands-invalid-radial-gradient-radius-fallback \
        commands-invalid-radial-gradient-round-rect-radius-fallback \
        commands-invalid-radial-gradient-stroke-radius-fallback \
        commands-invalid-radial-gradient-round-rect-stroke-radius-fallback \
        commands-invalid-radial-gradient-tile-mode-fallback \
        commands-invalid-radial-gradient-round-rect-tile-mode-fallback \
        commands-invalid-radial-gradient-stroke-tile-mode-fallback \
        commands-invalid-radial-gradient-round-rect-stroke-tile-mode-fallback \
        commands-invalid-radial-gradient-color-count-fallback \
        commands-invalid-radial-gradient-round-rect-color-count-fallback \
        commands-invalid-radial-gradient-stroke-color-count-fallback \
        commands-invalid-radial-gradient-round-rect-stroke-color-count-fallback \
        commands-invalid-radial-gradient-stop-order-fallback \
        commands-invalid-radial-gradient-round-rect-stop-order-fallback \
        commands-invalid-radial-gradient-stroke-stop-order-fallback \
        commands-invalid-radial-gradient-round-rect-stroke-stop-order-fallback
      ;;
    gradient-path-invalid)
      echo "commands-linear-gradient-path-invalid-fallback commands-radial-gradient-path-invalid-fallback commands-sweep-gradient-path-invalid-fallback commands-invalid-linear-gradient-path-tile-mode-fallback commands-invalid-linear-gradient-path-color-count-fallback commands-invalid-linear-gradient-path-stop-order-fallback commands-invalid-linear-gradient-path-fill-type-fallback commands-invalid-linear-gradient-path-data-length-fallback commands-invalid-linear-gradient-path-verb-fallback commands-invalid-radial-gradient-path-radius-fallback commands-invalid-radial-gradient-path-tile-mode-fallback commands-invalid-radial-gradient-path-color-count-fallback commands-invalid-radial-gradient-path-stop-order-fallback commands-invalid-radial-gradient-path-fill-type-fallback commands-invalid-radial-gradient-path-data-length-fallback commands-invalid-radial-gradient-path-verb-fallback commands-invalid-sweep-gradient-path-color-count-fallback commands-invalid-sweep-gradient-path-stop-order-fallback commands-invalid-sweep-gradient-path-fill-type-fallback commands-invalid-sweep-gradient-path-data-length-fallback commands-invalid-sweep-gradient-path-verb-fallback"
      ;;
    runtime-effect-invalid)
      echo "commands-runtime-effect-shader-source-hash-fallback commands-runtime-effect-shader-source-code-fallback commands-runtime-effect-shader-sksl-length-fallback commands-runtime-effect-shader-uniform-float-count-fallback commands-runtime-effect-shader-negative-uniform-float-count-fallback commands-runtime-effect-shader-child-count-fallback commands-runtime-effect-shader-negative-child-count-fallback commands-runtime-effect-shader-named-uniform-count-fallback commands-runtime-effect-shader-negative-named-uniform-count-fallback commands-runtime-effect-shader-named-child-count-fallback commands-runtime-effect-shader-negative-named-child-count-fallback commands-runtime-effect-shader-uniform-name-fallback commands-runtime-effect-shader-uniform-schema-float-count-fallback commands-runtime-effect-shader-uniform-schema-float-offset-fallback commands-runtime-effect-shader-uniform-schema-float-range-fallback commands-runtime-effect-shader-uniform-schema-name-length-fallback commands-runtime-effect-shader-uniform-schema-max-name-length-fallback commands-runtime-effect-shader-uniform-schema-name-range-fallback commands-runtime-effect-shader-child-name-fallback commands-runtime-effect-shader-child-schema-name-length-fallback commands-runtime-effect-shader-child-schema-max-name-length-fallback commands-runtime-effect-shader-child-schema-name-range-fallback commands-runtime-effect-shader-child-index-fallback commands-runtime-effect-shader-negative-child-index-fallback commands-runtime-effect-shader-duplicate-child-index-fallback commands-runtime-effect-color-filter-source-hash-fallback commands-runtime-effect-color-filter-source-code-fallback commands-runtime-effect-color-filter-sksl-length-fallback commands-runtime-effect-color-filter-uniform-float-count-fallback commands-runtime-effect-color-filter-negative-uniform-float-count-fallback commands-runtime-effect-color-filter-child-count-fallback commands-runtime-effect-color-filter-negative-child-count-fallback commands-runtime-effect-color-filter-named-uniform-count-fallback commands-runtime-effect-color-filter-negative-named-uniform-count-fallback commands-runtime-effect-color-filter-named-child-count-fallback commands-runtime-effect-color-filter-negative-named-child-count-fallback commands-runtime-effect-color-filter-uniform-name-fallback commands-runtime-effect-color-filter-uniform-schema-float-count-fallback commands-runtime-effect-color-filter-uniform-schema-float-offset-fallback commands-runtime-effect-color-filter-uniform-schema-float-range-fallback commands-runtime-effect-color-filter-uniform-schema-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-max-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-name-range-fallback commands-runtime-effect-color-filter-child-name-fallback commands-runtime-effect-color-filter-child-schema-name-length-fallback commands-runtime-effect-color-filter-child-schema-max-name-length-fallback commands-runtime-effect-color-filter-child-schema-name-range-fallback commands-runtime-effect-color-filter-child-index-fallback commands-runtime-effect-color-filter-negative-child-index-fallback commands-runtime-effect-color-filter-duplicate-child-index-fallback commands-runtime-effect-invalid-uniform-schema-fallback commands-runtime-effect-invalid-child-schema-fallback commands-runtime-effect-invalid-nested-child-fallback commands-runtime-effect-color-filter-invalid-uniform-schema-fallback commands-runtime-effect-color-filter-invalid-child-schema-fallback commands-runtime-effect-color-filter-invalid-nested-child-fallback commands-runtime-effect-color-filter-compile-fallback commands-runtime-effect-color-filter-build-fallback commands-runtime-effect-color-filter-child-type-fallback commands-runtime-effect-compile-fallback commands-runtime-effect-build-fallback commands-runtime-effect-child-type-fallback"
      ;;
    descriptor-handles-invalid)
      echo "commands-invalid-descriptor-use-fallback commands-invalid-shader-descriptor-use-fallback commands-invalid-path-effect-descriptor-use-fallback commands-invalid-save-layer-color-filter-use-fallback commands-invalid-save-layer-blend-color-filter-use-fallback commands-invalid-save-layer-image-filter-use-fallback commands-invalid-descriptor-use-after-evict-fallback commands-invalid-shader-evict-record-flags-fallback commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-color-filter-evict-record-flags-fallback commands-invalid-path-effect-descriptor-use-after-evict-fallback commands-invalid-save-layer-color-filter-use-after-evict-fallback commands-invalid-save-layer-blend-color-filter-use-after-evict-fallback commands-invalid-save-layer-image-filter-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback commands-composite-shader-child-use-after-evict-fallback commands-composite-shader-src-child-use-after-evict-fallback commands-shader-color-filter-shader-child-use-after-evict-fallback commands-runtime-effect-shader-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-use-after-evict-fallback commands-shader-color-filter-effect-child-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback commands-invalid-blur-effect-child-use-after-evict-fallback commands-invalid-path-effect-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-missing-fallback commands-blur-image-filter-child-missing-fallback commands-offset-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback commands-shader-color-filter-effect-child-missing-fallback commands-shader-wrong-effect-type-fallback commands-transformed-shader-child-wrong-effect-type-fallback commands-composite-shader-child-wrong-effect-type-fallback commands-composite-shader-src-child-wrong-effect-type-fallback commands-runtime-effect-shader-child-wrong-effect-type-fallback commands-transformed-shader-child-missing-fallback commands-composite-shader-child-missing-fallback commands-composite-shader-src-child-missing-fallback commands-shader-color-filter-shader-child-missing-fallback commands-color-filter-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-path-effect-wrong-type-fallback commands-color-filter-path-effect-wrong-type-fallback commands-shader-color-filter-wrong-effect-type-fallback commands-image-filter-wrong-effect-type-fallback commands-path-effect-wrong-effect-type-fallback commands-blur-image-filter-child-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback commands-chain-path-effect-child-wrong-effect-type-fallback"
      ;;
    image-handles-invalid)
      echo "commands-invalid-image-define-record-flags-fallback commands-invalid-image-cache-clear-record-flags-fallback commands-invalid-image-evict-record-flags-fallback commands-invalid-image-define-width-fallback commands-invalid-image-define-max-width-fallback commands-invalid-image-define-height-fallback commands-invalid-image-define-max-height-fallback commands-invalid-image-define-pixel-count-fallback commands-invalid-image-use-fallback commands-invalid-image-use-after-evict-fallback commands-invalid-image-ref-width-fallback commands-invalid-image-ref-height-fallback commands-invalid-image-ref-alpha-fallback commands-invalid-image-ref-filter-quality-fallback commands-invalid-image-color-filter-use-fallback commands-invalid-image-color-filter-use-after-evict-fallback commands-invalid-image-color-filter-ref-width-fallback commands-invalid-image-color-filter-ref-height-fallback commands-invalid-image-color-filter-ref-alpha-fallback commands-invalid-image-color-filter-ref-filter-quality-fallback commands-invalid-image-color-filter-blend-mode-fallback commands-invalid-image-color-filter-ref-use-fallback commands-invalid-image-color-filter-ref-use-after-evict-fallback commands-invalid-image-color-filter-descriptor-ref-width-fallback commands-invalid-image-color-filter-descriptor-ref-height-fallback commands-invalid-image-color-filter-descriptor-ref-alpha-fallback commands-invalid-image-color-filter-descriptor-ref-filter-quality-fallback"
      ;;
    save-layer-invalid)
      echo "commands-invalid-save-layer-alpha-fallback commands-invalid-save-layer-record-flags-fallback commands-invalid-save-layer-color-filter-record-flags-fallback commands-invalid-save-layer-blend-mode-record-flags-fallback commands-invalid-save-layer-blend-color-filter-record-flags-fallback commands-invalid-save-layer-record-length-fallback commands-invalid-save-layer-color-filter-record-length-fallback commands-invalid-save-layer-blend-mode-record-length-fallback commands-invalid-save-layer-blend-color-filter-record-length-fallback commands-invalid-save-layer-color-filter-ref-record-flags-fallback commands-invalid-save-layer-blend-color-filter-ref-record-flags-fallback commands-invalid-save-layer-image-filter-ref-record-flags-fallback commands-invalid-save-layer-color-filter-ref-record-length-fallback commands-invalid-save-layer-blend-color-filter-ref-record-length-fallback commands-invalid-save-layer-image-filter-ref-record-length-fallback commands-invalid-save-layer-color-filter-width-fallback commands-invalid-save-layer-color-filter-height-fallback commands-invalid-save-layer-color-filter-alpha-fallback commands-invalid-save-layer-blend-mode-width-fallback commands-invalid-save-layer-blend-mode-height-fallback commands-invalid-save-layer-blend-mode-alpha-fallback commands-invalid-save-layer-blend-color-filter-width-fallback commands-invalid-save-layer-blend-color-filter-height-fallback commands-invalid-save-layer-blend-color-filter-alpha-fallback commands-invalid-save-layer-color-filter-blend-mode-fallback commands-invalid-save-layer-blend-mode-fallback commands-invalid-save-layer-blend-color-filter-blend-mode-fallback commands-invalid-save-layer-image-filter-alpha-fallback commands-invalid-save-layer-image-filter-width-fallback commands-invalid-save-layer-image-filter-height-fallback commands-invalid-save-layer-color-filter-ref-width-fallback commands-invalid-save-layer-color-filter-ref-height-fallback commands-invalid-save-layer-color-filter-ref-alpha-fallback commands-invalid-save-layer-blend-color-filter-ref-width-fallback commands-invalid-save-layer-blend-color-filter-ref-height-fallback commands-invalid-save-layer-blend-color-filter-ref-alpha-fallback commands-invalid-save-layer-blend-color-filter-ref-blend-mode-fallback"
      ;;
    color-filters)
      echo "commands-image-color-matrix-filter commands-resize-image-color-matrix-filter commands-forced-context-image-color-matrix-filter commands-image-raw-table-color-filter-fallback commands-raw-blend-color-filter-fallback commands-raw-table-color-filter-fallback commands-color-filter commands-resize-color-filter commands-forced-context-color-filter commands-color-filter-blend-mode commands-resize-color-filter-blend-mode commands-forced-context-color-filter-blend-mode commands-color-filter-handle commands-resize-color-filter-handle commands-forced-context-color-filter-handle commands-color-matrix-filter commands-resize-color-matrix-filter commands-forced-context-color-matrix-filter commands-lighting-filter commands-resize-lighting-filter commands-forced-context-lighting-filter commands-graphics-layer-color-filter commands-resize-graphics-layer-color-filter commands-forced-context-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-graphics-layer-blend-color-filter commands-resize-graphics-layer-blend-color-filter commands-forced-context-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter commands-resize-graphics-layer-blend-color-matrix-filter commands-forced-context-graphics-layer-blend-color-matrix-filter commands-save-layer-filter commands-resize-save-layer-filter commands-forced-context-save-layer-filter commands-save-layer-color-matrix-filter commands-resize-save-layer-color-matrix-filter commands-forced-context-save-layer-color-matrix-filter"
      ;;
    descriptor-lifecycle)
      echo "commands-descriptor-eviction commands-resize-descriptor-redefine commands-forced-context-descriptor-redefine commands-resize-shader-descriptor-redefine commands-forced-context-shader-descriptor-redefine commands-resize-color-shader-descriptor-redefine commands-forced-context-color-shader-descriptor-redefine commands-resize-noise-shader-descriptor-redefine commands-forced-context-noise-shader-descriptor-redefine commands-resize-turbulence-shader-descriptor-redefine commands-forced-context-turbulence-shader-descriptor-redefine commands-resize-composite-shader-descriptor-redefine commands-forced-context-composite-shader-descriptor-redefine commands-resize-composite-noise-shader-descriptor-redefine commands-forced-context-composite-noise-shader-descriptor-redefine commands-resize-composite-shader-color-filter commands-forced-context-composite-shader-color-filter commands-resize-transformed-shader commands-forced-context-transformed-shader commands-runtime-effect-stable-color-filter commands-resize-runtime-effect-shader commands-forced-context-runtime-effect-shader commands-resize-runtime-effect-shader-color-filter commands-forced-context-runtime-effect-shader-color-filter commands-resize-linear-gradient-shader-color-filter commands-forced-context-linear-gradient-shader-color-filter commands-resize-radial-gradient-shader-color-filter commands-forced-context-radial-gradient-shader-color-filter commands-resize-runtime-effect-pure-color commands-forced-context-runtime-effect-pure-color commands-resize-runtime-effect-uniform-only commands-forced-context-runtime-effect-uniform-only commands-resize-runtime-effect-child-only commands-forced-context-runtime-effect-child-only commands-resize-runtime-effect-color-filter commands-forced-context-runtime-effect-color-filter commands-resize-runtime-effect-color-filter-child commands-forced-context-runtime-effect-color-filter-child commands-resize-runtime-effect-stable-color-filter commands-forced-context-runtime-effect-stable-color-filter commands-resize-image-filter commands-forced-context-image-filter commands-resize-image-color-matrix-filter commands-forced-context-image-color-matrix-filter commands-resize-color-filter commands-forced-context-color-filter commands-resize-color-filter-blend-mode commands-forced-context-color-filter-blend-mode commands-resize-color-matrix-filter commands-forced-context-color-matrix-filter commands-resize-lighting-filter commands-forced-context-lighting-filter commands-resize-path-effect commands-forced-context-path-effect commands-resize-graphics-layer-blend-color-matrix-filter commands-forced-context-graphics-layer-blend-color-matrix-filter commands-resize-save-layer-color-matrix-filter commands-forced-context-save-layer-color-matrix-filter commands-runtime-effect-shader-source-cache-eviction commands-runtime-effect-source-cache-eviction"
      ;;
    fill-rect-color-filter-invalid)
      echo "commands-color-matrix-filter-nonfinite-fallback commands-invalid-fill-rect-color-filter-blend-mode-fallback commands-invalid-fill-rect-color-filter-width-fallback commands-invalid-fill-rect-color-filter-height-fallback commands-invalid-fill-rect-color-filter-ref-width-fallback commands-invalid-fill-rect-color-filter-ref-height-fallback"
      ;;
    native-text)
      echo "commands-native-custom-font-text-image commands-native-generic-font-text commands-native-loaded-font-data-text commands-native-resource-font-text commands-native-system-font-text commands-resize-native-generic-font-text commands-resize-native-loaded-font-data-text commands-resize-native-resource-font-text commands-resize-native-system-font-text commands-forced-context-native-custom-font-text-image commands-forced-context-native-generic-font-text commands-forced-context-native-loaded-font-data-text commands-forced-context-native-resource-font-text commands-forced-context-native-system-font-text"
      ;;
    native-text-invalid)
      echo "commands-invalid-text-font-size-fallback commands-invalid-text-font-weight-fallback commands-invalid-text-font-width-fallback commands-invalid-text-font-slant-fallback commands-invalid-text-font-family-count-fallback commands-invalid-paragraph-font-size-fallback commands-invalid-paragraph-font-weight-fallback commands-invalid-paragraph-font-width-fallback commands-invalid-paragraph-font-slant-fallback commands-invalid-paragraph-font-family-count-fallback commands-invalid-font-data-record-flags-fallback"
      ;;
    blend-mode-invalid)
      echo "commands-vertices-invalid-blend-mode-fallback commands-invalid-fill-rect-blend-mode-width-fallback commands-invalid-fill-rect-blend-mode-height-fallback"
      ;;
    graphics-layer-invalid)
      echo "commands-graphics-layer-invalid-size-width-fallback commands-graphics-layer-invalid-size-height-fallback commands-graphics-layer-invalid-alpha-fallback commands-graphics-layer-invalid-scale-x-fallback commands-graphics-layer-invalid-scale-y-fallback commands-graphics-layer-invalid-rotation-z-fallback commands-graphics-layer-invalid-translation-x-fallback commands-graphics-layer-invalid-translation-y-fallback commands-graphics-layer-invalid-rotation-x-fallback commands-graphics-layer-invalid-rotation-y-fallback commands-graphics-layer-invalid-camera-distance-fallback commands-graphics-layer-invalid-shadow-elevation-fallback commands-graphics-layer-invalid-shadow-path-fallback commands-graphics-layer-invalid-blend-mode-fallback commands-graphics-layer-unrecorded-fallback"
      ;;
    graphics-layer)
      echo "commands-graphics-layer commands-graphics-layer-modulate-alpha commands-graphics-layer-offscreen commands-graphics-layer-clip commands-graphics-layer-round-clip commands-graphics-layer-path-clip commands-graphics-layer-blend-mode commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-graphics-layer-render-effect commands-graphics-layer-offset-effect commands-graphics-layer-chained-render-effect commands-graphics-layer-shadow commands-graphics-layer-invalid-shadow-elevation-fallback commands-graphics-layer-round-shadow commands-graphics-layer-path-shadow commands-graphics-layer-rotationx commands-graphics-layer-rotationy commands-graphics-layer-rotationxy commands-graphics-layer-scale-translate commands-graphics-layer-near-camera commands-graphics-layer-offcenter-pivot"
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

replace_default_case_segment() {
  local needle="$1"
  local replacement="$2"
  CASES="$(
    CASES_TEXT="${CASES}" \
      CASES_NEEDLE="${needle}" \
      CASES_REPLACEMENT="${replacement}" \
      perl -e '
        my $cases = $ENV{"CASES_TEXT"};
        my $needle = $ENV{"CASES_NEEDLE"};
        my $replacement = $ENV{"CASES_REPLACEMENT"};
        $cases =~ s/\Q$needle\E/$replacement/;
        print $cases;
      '
  )"
}

if [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  CASES=""
  for group in ${CASE_GROUPS}; do
    CASES="${CASES} $(case_group_cases "${group}")"
  done
  CASES="${CASES# }"
fi
if [[ -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" ]]; then
  replace_default_case_segment "commands-native-bridge-load-library commands-core-primitives" "commands-native-bridge-load-library commands-invalid-stroke-cap-fallback commands-invalid-blend-layer-bounds-fallback commands-invalid-concat-transform-fallback commands-invalid-transform-record-flags-fallback commands-invalid-clip-operation-fallback commands-core-primitives"
  replace_default_case_segment "commands-concat-transform commands-skew-transform" "commands-concat-transform commands-resize-concat-transform commands-forced-context-concat-transform commands-skew-transform commands-resize-skew-transform commands-forced-context-skew-transform"
  replace_default_case_segment "commands-point-lines commands-point-dots" "commands-point-lines commands-resize-point-lines commands-forced-context-point-lines commands-invalid-point-dots-fallback commands-invalid-draw-points-point-count-fallback commands-invalid-draw-points-max-point-count-fallback commands-invalid-draw-points-record-length-fallback commands-point-dots commands-resize-point-dots commands-forced-context-point-dots"
  replace_default_case_segment "commands-vertices commands-blend-mode" "commands-vertices commands-resize-vertices commands-forced-context-vertices commands-vertices-raw-color-filter-fallback commands-vertices-invalid-blend-mode-fallback commands-invalid-draw-vertices-vertex-count-fallback commands-invalid-draw-vertices-max-vertex-count-fallback commands-invalid-draw-vertices-record-length-fallback commands-invalid-draw-vertices-vertex-mode-fallback commands-invalid-draw-vertices-blend-mode-fallback commands-invalid-draw-vertices-index-count-fallback commands-invalid-draw-vertices-max-index-count-fallback commands-blend-mode commands-resize-blend-mode commands-forced-context-blend-mode"
  replace_default_case_segment "commands-core-primitives commands-point-lines" "commands-core-primitives commands-invalid-image-define-record-flags-fallback commands-invalid-image-cache-clear-record-flags-fallback commands-invalid-image-evict-record-flags-fallback commands-invalid-image-define-width-fallback commands-invalid-image-define-max-width-fallback commands-invalid-image-define-height-fallback commands-invalid-image-define-max-height-fallback commands-invalid-image-define-pixel-count-fallback commands-invalid-image-use-fallback commands-invalid-image-use-after-evict-fallback commands-invalid-image-ref-width-fallback commands-invalid-image-ref-height-fallback commands-invalid-image-ref-alpha-fallback commands-invalid-image-ref-filter-quality-fallback commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback commands-invalid-draw-path-path-effect-verb-fallback commands-invalid-stroke-line-dash-path-effect-interval-count-fallback commands-invalid-stroke-rect-dash-path-effect-interval-count-fallback commands-invalid-stroke-rect-dash-path-effect-width-fallback commands-invalid-stroke-rect-dash-path-effect-height-fallback commands-invalid-stroke-round-rect-dash-path-effect-interval-count-fallback commands-invalid-stroke-round-rect-dash-path-effect-right-fallback commands-invalid-stroke-round-rect-dash-path-effect-bottom-fallback commands-invalid-stroke-round-rect-dash-path-effect-radius-x-fallback commands-invalid-stroke-round-rect-dash-path-effect-radius-y-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-width-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-cap-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-join-fallback commands-invalid-stroke-round-rect-dash-path-effect-stroke-miter-fallback commands-invalid-stroke-round-rect-dash-path-effect-phase-fallback commands-invalid-stroke-round-rect-dash-path-effect-interval-fallback commands-invalid-stroke-path-dash-path-effect-verb-fallback commands-invalid-stroke-path-dash-path-effect-interval-count-fallback commands-invalid-stroke-path-dash-path-effect-interval-fallback commands-invalid-draw-shadow-path-verb-fallback commands-point-lines"
  replace_default_case_segment "commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback" "commands-clip-path-invalid-fallback commands-draw-path-invalid-fallback commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback"
  replace_default_case_segment "commands-native-generic-font-text commands-native-loaded-font-data-text" "commands-native-generic-font-text commands-invalid-text-font-size-fallback commands-invalid-text-font-weight-fallback commands-invalid-text-font-width-fallback commands-invalid-text-font-slant-fallback commands-invalid-text-font-family-count-fallback commands-invalid-paragraph-font-size-fallback commands-invalid-paragraph-font-weight-fallback commands-invalid-paragraph-font-width-fallback commands-invalid-paragraph-font-slant-fallback commands-invalid-paragraph-font-family-count-fallback commands-invalid-font-data-record-flags-fallback commands-native-loaded-font-data-text"
  replace_default_case_segment "commands-gradient-stroke commands-image-filter" "commands-gradient-stroke commands-invalid-linear-gradient-stroke-width-fallback commands-invalid-linear-gradient-round-rect-stroke-width-fallback commands-invalid-radial-gradient-stroke-width-fallback commands-invalid-radial-gradient-round-rect-stroke-width-fallback commands-invalid-sweep-gradient-stroke-width-fallback commands-invalid-sweep-gradient-round-rect-stroke-width-fallback commands-invalid-linear-gradient-tile-mode-fallback commands-invalid-linear-gradient-round-rect-tile-mode-fallback commands-invalid-linear-gradient-stroke-tile-mode-fallback commands-invalid-linear-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-linear-gradient-color-count-fallback commands-invalid-linear-gradient-round-rect-color-count-fallback commands-invalid-linear-gradient-stroke-color-count-fallback commands-invalid-linear-gradient-round-rect-stroke-color-count-fallback commands-invalid-linear-gradient-stop-order-fallback commands-invalid-linear-gradient-round-rect-stop-order-fallback commands-invalid-linear-gradient-stroke-stop-order-fallback commands-invalid-linear-gradient-round-rect-stroke-stop-order-fallback commands-invalid-linear-gradient-path-tile-mode-fallback commands-invalid-linear-gradient-path-color-count-fallback commands-invalid-linear-gradient-path-stop-order-fallback commands-invalid-linear-gradient-path-fill-type-fallback commands-invalid-linear-gradient-path-data-length-fallback commands-invalid-linear-gradient-path-verb-fallback commands-invalid-radial-gradient-path-radius-fallback commands-invalid-radial-gradient-path-tile-mode-fallback commands-invalid-radial-gradient-path-color-count-fallback commands-invalid-radial-gradient-path-stop-order-fallback commands-invalid-radial-gradient-path-fill-type-fallback commands-invalid-radial-gradient-path-data-length-fallback commands-invalid-radial-gradient-path-verb-fallback commands-invalid-sweep-gradient-path-color-count-fallback commands-invalid-sweep-gradient-path-stop-order-fallback commands-invalid-sweep-gradient-path-fill-type-fallback commands-invalid-sweep-gradient-path-data-length-fallback commands-invalid-sweep-gradient-path-verb-fallback commands-invalid-sweep-gradient-color-count-fallback commands-invalid-sweep-gradient-round-rect-color-count-fallback commands-invalid-sweep-gradient-stroke-color-count-fallback commands-invalid-sweep-gradient-round-rect-stroke-color-count-fallback commands-invalid-sweep-gradient-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stop-order-fallback commands-invalid-sweep-gradient-stroke-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stroke-stop-order-fallback commands-invalid-radial-gradient-radius-fallback commands-invalid-radial-gradient-round-rect-radius-fallback commands-invalid-radial-gradient-stroke-radius-fallback commands-invalid-radial-gradient-round-rect-stroke-radius-fallback commands-invalid-radial-gradient-tile-mode-fallback commands-invalid-radial-gradient-round-rect-tile-mode-fallback commands-invalid-radial-gradient-stroke-tile-mode-fallback commands-invalid-radial-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-radial-gradient-color-count-fallback commands-invalid-radial-gradient-round-rect-color-count-fallback commands-invalid-radial-gradient-stroke-color-count-fallback commands-invalid-radial-gradient-round-rect-stroke-color-count-fallback commands-invalid-radial-gradient-stop-order-fallback commands-invalid-radial-gradient-round-rect-stop-order-fallback commands-invalid-radial-gradient-stroke-stop-order-fallback commands-invalid-radial-gradient-round-rect-stroke-stop-order-fallback commands-image-filter"
  replace_default_case_segment "commands-gradient-stroke commands-invalid-linear-gradient-stroke-width-fallback" "commands-gradient-stroke commands-linear-gradient-invalid-stops-fallback commands-linear-gradient-invalid-points-fallback commands-radial-gradient-invalid-stops-fallback commands-invalid-linear-gradient-stroke-width-fallback"
  replace_default_case_segment "commands-gradient-stroke commands-linear-gradient-invalid-stops-fallback" "commands-gradient-stroke commands-resize-gradient-stroke commands-forced-context-gradient-stroke commands-linear-gradient-invalid-stops-fallback"
  replace_default_case_segment "commands-radial-gradient-invalid-stops-fallback commands-invalid-linear-gradient-stroke-width-fallback" "commands-radial-gradient-invalid-stops-fallback commands-radial-gradient-invalid-geometry-fallback commands-sweep-gradient-invalid-geometry-fallback commands-linear-gradient-invalid-color-count-fallback commands-radial-gradient-invalid-color-count-fallback commands-sweep-gradient-invalid-color-count-fallback commands-invalid-linear-gradient-stroke-width-fallback"
  replace_default_case_segment "commands-sweep-gradient-invalid-color-count-fallback commands-invalid-linear-gradient-stroke-width-fallback" "commands-sweep-gradient-invalid-color-count-fallback commands-linear-gradient-invalid-stroke-width-public-fallback commands-radial-gradient-invalid-stroke-width-public-fallback commands-sweep-gradient-invalid-stroke-width-public-fallback commands-linear-gradient-round-rect-invalid-radius-fallback commands-radial-gradient-round-rect-invalid-radius-fallback commands-sweep-gradient-round-rect-invalid-radius-fallback commands-linear-gradient-stroke-round-rect-invalid-radius-fallback commands-radial-gradient-stroke-round-rect-invalid-radius-fallback commands-sweep-gradient-stroke-round-rect-invalid-radius-fallback commands-invalid-linear-gradient-stroke-width-fallback"
  replace_default_case_segment "commands-gradient-surfaces commands-gradient-paths" "commands-gradient-surfaces commands-linear-gradient-blend-mode commands-gradient-paths"
  replace_default_case_segment "commands-gradient-surfaces commands-linear-gradient-blend-mode" "commands-gradient-surfaces commands-resize-gradient-surfaces commands-forced-context-gradient-surfaces commands-linear-gradient-blend-mode"
  replace_default_case_segment "commands-linear-gradient-blend-mode commands-radial-gradient-stroke-blend-mode" "commands-linear-gradient-blend-mode commands-resize-linear-gradient-blend-mode commands-forced-context-linear-gradient-blend-mode commands-radial-gradient-stroke-blend-mode"
  replace_default_case_segment "commands-radial-gradient-stroke-blend-mode commands-sweep-gradient-round-rect-blend-mode" "commands-radial-gradient-stroke-blend-mode commands-resize-radial-gradient-stroke-blend-mode commands-forced-context-radial-gradient-stroke-blend-mode commands-sweep-gradient-round-rect-blend-mode"
  replace_default_case_segment "commands-sweep-gradient-round-rect-blend-mode commands-gradient-paths" "commands-sweep-gradient-round-rect-blend-mode commands-resize-sweep-gradient-round-rect-blend-mode commands-forced-context-sweep-gradient-round-rect-blend-mode commands-gradient-paths"
  replace_default_case_segment "commands-gradient-paths commands-linear-gradient-path-blend-mode" "commands-gradient-paths commands-resize-gradient-paths commands-forced-context-gradient-paths commands-linear-gradient-path-blend-mode"
  replace_default_case_segment "commands-linear-gradient-blend-mode commands-gradient-paths" "commands-linear-gradient-blend-mode commands-radial-gradient-stroke-blend-mode commands-sweep-gradient-round-rect-blend-mode commands-gradient-paths"
  replace_default_case_segment "commands-gradient-paths commands-linear-gradient-path-stroke-fallback" "commands-gradient-paths commands-linear-gradient-path-blend-mode commands-linear-gradient-path-invalid-fallback commands-radial-gradient-path-invalid-fallback commands-sweep-gradient-path-invalid-fallback commands-linear-gradient-path-stroke-fallback"
  replace_default_case_segment "commands-linear-gradient-path-blend-mode commands-linear-gradient-path-invalid-fallback" "commands-linear-gradient-path-blend-mode commands-resize-linear-gradient-path-blend-mode commands-forced-context-linear-gradient-path-blend-mode commands-linear-gradient-path-invalid-fallback"
  replace_default_case_segment "commands-image-shader commands-raw-image-shader-fallback" "commands-image-shader commands-resize-image-shader commands-forced-context-image-shader commands-image-shader-blend-mode commands-resize-image-shader-blend-mode commands-forced-context-image-shader-blend-mode commands-image-shader-invalid-image-fallback commands-raw-image-shader-fallback"
  replace_default_case_segment "commands-image-path-effect-fallback commands-image-shader" "commands-image-blend-mode commands-image-path-effect-fallback commands-image-shader"
  replace_default_case_segment "commands-image-blend-mode commands-image-path-effect-fallback" "commands-image-blend-mode commands-resize-image-blend-mode commands-forced-context-image-blend-mode commands-image-path-effect-fallback"
  replace_default_case_segment "commands-color-shader commands-descriptor-stroke-shader-fallback" "commands-color-shader commands-resize-color-shader commands-forced-context-color-shader commands-color-shader-blend-mode commands-resize-color-shader-blend-mode commands-forced-context-color-shader-blend-mode commands-descriptor-stroke-shader-fallback"
  replace_default_case_segment "commands-gradient-shaders commands-noise-shader" "commands-gradient-shaders commands-resize-gradient-shaders commands-forced-context-gradient-shaders commands-noise-shader"
  replace_default_case_segment "commands-noise-shader commands-turbulence-shader" "commands-noise-shader commands-resize-noise-shader commands-forced-context-noise-shader commands-turbulence-shader commands-resize-turbulence-shader commands-forced-context-turbulence-shader"
  replace_default_case_segment "commands-image-shader-color-filter commands-composite-shader" "commands-image-shader-color-filter commands-resize-image-shader-color-filter commands-forced-context-image-shader-color-filter commands-composite-shader"
  replace_default_case_segment "commands-composite-shader commands-composite-noise-shader" "commands-composite-shader commands-resize-composite-shader commands-forced-context-composite-shader commands-resize-composite-shader-descriptor-redefine commands-forced-context-composite-shader-descriptor-redefine commands-composite-noise-shader commands-resize-composite-noise-shader commands-forced-context-composite-noise-shader"
  replace_default_case_segment "commands-image-filter commands-image-color-matrix-filter" "commands-image-filter commands-resize-image-filter commands-forced-context-image-filter commands-invalid-image-color-filter-use-fallback commands-invalid-image-color-filter-use-after-evict-fallback commands-invalid-image-color-filter-ref-width-fallback commands-invalid-image-color-filter-ref-height-fallback commands-invalid-image-color-filter-ref-alpha-fallback commands-invalid-image-color-filter-ref-filter-quality-fallback commands-invalid-image-color-filter-blend-mode-fallback commands-invalid-image-color-filter-ref-use-fallback commands-invalid-image-color-filter-ref-use-after-evict-fallback commands-invalid-image-color-filter-descriptor-ref-width-fallback commands-invalid-image-color-filter-descriptor-ref-height-fallback commands-invalid-image-color-filter-descriptor-ref-alpha-fallback commands-invalid-image-color-filter-descriptor-ref-filter-quality-fallback commands-image-color-matrix-filter commands-resize-image-color-matrix-filter commands-forced-context-image-color-matrix-filter"
  replace_default_case_segment "commands-raw-blend-color-filter-fallback commands-raw-table-color-filter-fallback commands-color-filter" "commands-raw-blend-color-filter-fallback commands-raw-table-color-filter-fallback commands-invalid-fill-rect-color-filter-blend-mode-fallback commands-invalid-fill-rect-color-filter-width-fallback commands-invalid-fill-rect-color-filter-height-fallback commands-invalid-fill-rect-color-filter-ref-width-fallback commands-invalid-fill-rect-color-filter-ref-height-fallback commands-color-filter"
  replace_default_case_segment "commands-color-filter commands-color-filter-blend-mode" "commands-color-filter commands-resize-color-filter commands-forced-context-color-filter commands-color-filter-blend-mode"
  replace_default_case_segment "commands-color-filter-blend-mode commands-color-filter-handle" "commands-color-filter-blend-mode commands-resize-color-filter-blend-mode commands-forced-context-color-filter-blend-mode commands-color-filter-handle"
  replace_default_case_segment "commands-color-filter-handle commands-color-matrix-filter" "commands-color-filter-handle commands-resize-color-filter-handle commands-forced-context-color-filter-handle commands-color-matrix-filter"
  replace_default_case_segment "commands-color-matrix-filter commands-color-matrix-filter-nonfinite-fallback" "commands-color-matrix-filter commands-resize-color-matrix-filter commands-forced-context-color-matrix-filter commands-color-matrix-filter-nonfinite-fallback"
  replace_default_case_segment "commands-lighting-filter commands-descriptor-eviction" "commands-lighting-filter commands-resize-lighting-filter commands-forced-context-lighting-filter commands-descriptor-eviction"
  replace_default_case_segment "commands-blend-mode commands-graphics-layer" "commands-blend-mode commands-invalid-fill-rect-blend-mode-width-fallback commands-invalid-fill-rect-blend-mode-height-fallback commands-graphics-layer"
  replace_default_case_segment "commands-graphics-layer commands-graphics-layer-modulate-alpha" "commands-graphics-layer commands-graphics-layer-invalid-alpha-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer commands-graphics-layer-invalid-alpha-fallback" "commands-graphics-layer commands-graphics-layer-invalid-size-width-fallback commands-graphics-layer-invalid-size-height-fallback commands-graphics-layer-invalid-alpha-fallback"
  replace_default_case_segment "commands-graphics-layer commands-graphics-layer-invalid-size-width-fallback" "commands-graphics-layer commands-resize-graphics-layer commands-forced-context-graphics-layer commands-graphics-layer-invalid-size-width-fallback"
  replace_default_case_segment "commands-graphics-layer-blend-mode commands-graphics-layer-color-filter" "commands-graphics-layer-blend-mode commands-graphics-layer-invalid-blend-mode-fallback commands-graphics-layer-color-filter"
  replace_default_case_segment "commands-graphics-layer-invalid-blend-mode-fallback commands-graphics-layer-color-filter" "commands-graphics-layer-invalid-blend-mode-fallback commands-graphics-layer-unrecorded-fallback commands-graphics-layer-color-filter"
  replace_default_case_segment "commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter" "commands-graphics-layer-color-filter commands-resize-graphics-layer-color-filter commands-forced-context-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter"
  replace_default_case_segment "commands-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter" "commands-graphics-layer-blend-color-filter commands-resize-graphics-layer-blend-color-filter commands-forced-context-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter commands-resize-graphics-layer-blend-color-matrix-filter commands-forced-context-graphics-layer-blend-color-matrix-filter"
  replace_default_case_segment "commands-graphics-layer-invalid-alpha-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-alpha-fallback commands-graphics-layer-invalid-scale-x-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-scale-x-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-scale-x-fallback commands-graphics-layer-invalid-scale-y-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-scale-y-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-scale-y-fallback commands-graphics-layer-invalid-rotation-z-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-rotation-z-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-rotation-z-fallback commands-graphics-layer-invalid-translation-x-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-translation-x-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-translation-x-fallback commands-graphics-layer-invalid-translation-y-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-translation-y-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-translation-y-fallback commands-graphics-layer-invalid-rotation-x-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-invalid-rotation-x-fallback commands-graphics-layer-modulate-alpha" "commands-graphics-layer-invalid-rotation-x-fallback commands-graphics-layer-invalid-rotation-y-fallback commands-graphics-layer-modulate-alpha"
  replace_default_case_segment "commands-graphics-layer-near-camera commands-resize-graphics-layer-near-camera commands-forced-context-graphics-layer-near-camera commands-graphics-layer-offcenter-pivot" "commands-graphics-layer-near-camera commands-resize-graphics-layer-near-camera commands-forced-context-graphics-layer-near-camera commands-graphics-layer-invalid-camera-distance-fallback commands-graphics-layer-offcenter-pivot"
  replace_default_case_segment "commands-graphics-layer-shadow commands-graphics-layer-invalid-shadow-elevation-fallback" "commands-graphics-layer-shadow commands-resize-graphics-layer-shadow commands-forced-context-graphics-layer-shadow commands-graphics-layer-invalid-shadow-elevation-fallback"
  replace_default_case_segment "commands-graphics-layer-invalid-shadow-elevation-fallback commands-graphics-layer-round-shadow" "commands-graphics-layer-invalid-shadow-elevation-fallback commands-graphics-layer-invalid-shadow-path-fallback commands-graphics-layer-round-shadow"
  replace_default_case_segment "commands-graphics-layer-round-shadow commands-graphics-layer-path-shadow" "commands-graphics-layer-round-shadow commands-resize-graphics-layer-round-shadow commands-forced-context-graphics-layer-round-shadow commands-graphics-layer-path-shadow"
  replace_default_case_segment "commands-graphics-layer-path-shadow commands-graphics-layer-rotationx" "commands-graphics-layer-path-shadow commands-resize-graphics-layer-path-shadow commands-forced-context-graphics-layer-path-shadow commands-graphics-layer-rotationx"
  replace_default_case_segment "commands-graphics-layer-rotationx commands-graphics-layer-rotationy" "commands-graphics-layer-rotationx commands-resize-graphics-layer-rotationx commands-forced-context-graphics-layer-rotationx commands-graphics-layer-rotationy"
  replace_default_case_segment "commands-graphics-layer-rotationy commands-graphics-layer-rotationxy" "commands-graphics-layer-rotationy commands-resize-graphics-layer-rotationy commands-forced-context-graphics-layer-rotationy commands-graphics-layer-rotationxy"
  replace_default_case_segment "commands-graphics-layer-raw-color-filter-fallback commands-graphics-layer-render-effect" "commands-graphics-layer-raw-color-filter-fallback commands-graphics-layer-raw-table-color-filter-fallback commands-graphics-layer-unsupported-child-fallback commands-graphics-layer-render-effect"
  replace_default_case_segment "commands-save-layer-filter commands-save-layer-raw-color-filter-fallback" "commands-save-layer-filter commands-resize-save-layer-filter commands-forced-context-save-layer-filter commands-save-layer-color-matrix-filter commands-resize-save-layer-color-matrix-filter commands-forced-context-save-layer-color-matrix-filter commands-save-layer-blend-mode commands-resize-save-layer-blend-mode commands-forced-context-save-layer-blend-mode commands-save-layer-blend-color-filter commands-resize-save-layer-blend-color-filter commands-forced-context-save-layer-blend-color-filter commands-invalid-save-layer-alpha-fallback commands-invalid-save-layer-record-flags-fallback commands-invalid-save-layer-color-filter-record-flags-fallback commands-invalid-save-layer-blend-mode-record-flags-fallback commands-invalid-save-layer-blend-color-filter-record-flags-fallback commands-invalid-save-layer-record-length-fallback commands-invalid-save-layer-color-filter-record-length-fallback commands-invalid-save-layer-blend-mode-record-length-fallback commands-invalid-save-layer-blend-color-filter-record-length-fallback commands-invalid-save-layer-color-filter-ref-record-flags-fallback commands-invalid-save-layer-blend-color-filter-ref-record-flags-fallback commands-invalid-save-layer-image-filter-ref-record-flags-fallback commands-invalid-save-layer-color-filter-ref-record-length-fallback commands-invalid-save-layer-blend-color-filter-ref-record-length-fallback commands-invalid-save-layer-image-filter-ref-record-length-fallback commands-invalid-save-layer-color-filter-width-fallback commands-invalid-save-layer-color-filter-height-fallback commands-invalid-save-layer-color-filter-alpha-fallback commands-invalid-save-layer-blend-mode-width-fallback commands-invalid-save-layer-blend-mode-height-fallback commands-invalid-save-layer-blend-mode-alpha-fallback commands-invalid-save-layer-blend-color-filter-width-fallback commands-invalid-save-layer-blend-color-filter-height-fallback commands-invalid-save-layer-blend-color-filter-alpha-fallback commands-invalid-save-layer-color-filter-blend-mode-fallback commands-invalid-save-layer-blend-mode-fallback commands-invalid-save-layer-blend-color-filter-blend-mode-fallback commands-invalid-save-layer-image-filter-alpha-fallback commands-invalid-save-layer-image-filter-width-fallback commands-invalid-save-layer-image-filter-height-fallback commands-invalid-save-layer-color-filter-ref-width-fallback commands-invalid-save-layer-color-filter-ref-height-fallback commands-invalid-save-layer-color-filter-ref-alpha-fallback commands-invalid-save-layer-blend-color-filter-ref-width-fallback commands-invalid-save-layer-blend-color-filter-ref-height-fallback commands-invalid-save-layer-blend-color-filter-ref-alpha-fallback commands-invalid-save-layer-blend-color-filter-ref-blend-mode-fallback commands-save-layer-raw-color-filter-fallback"
  replace_default_case_segment "commands-save-layer-raw-color-filter-fallback commands-opaque-shader-fallback" "commands-save-layer-raw-color-filter-fallback commands-save-layer-raw-table-color-filter-fallback commands-opaque-shader-fallback"
  replace_default_case_segment "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback" "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-color-filter-evict-record-flags-fallback commands-invalid-path-effect-descriptor-use-after-evict-fallback commands-invalid-save-layer-color-filter-use-fallback commands-invalid-save-layer-blend-color-filter-use-fallback commands-invalid-save-layer-image-filter-use-fallback commands-invalid-save-layer-color-filter-use-after-evict-fallback commands-invalid-save-layer-blend-color-filter-use-after-evict-fallback commands-invalid-save-layer-image-filter-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback commands-composite-shader-child-use-after-evict-fallback commands-composite-shader-src-child-use-after-evict-fallback commands-shader-color-filter-shader-child-use-after-evict-fallback commands-runtime-effect-shader-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-use-after-evict-fallback commands-shader-color-filter-effect-child-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback commands-invalid-blur-effect-child-use-after-evict-fallback"
  replace_default_case_segment "commands-shader-color-filter-effect-child-missing-fallback commands-invalid-shader-descriptor-type-fallback" "commands-shader-color-filter-effect-child-missing-fallback commands-invalid-effect-descriptor-type-fallback commands-invalid-effect-descriptor-version-fallback commands-invalid-effect-descriptor-record-flags-fallback commands-invalid-effect-descriptor-payload-count-fallback commands-invalid-effect-descriptor-record-length-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-effect-descriptor-record-length-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-effect-descriptor-record-length-fallback commands-invalid-lighting-filter-descriptor-payload-count-fallback commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-sigma-fallback commands-invalid-blur-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-shader-descriptor-type-fallback" "commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-corner-path-effect-descriptor-negative-radius-fallback commands-invalid-stamped-path-effect-descriptor-advance-fallback commands-invalid-stamped-path-effect-descriptor-zero-advance-fallback commands-invalid-stamped-path-effect-descriptor-phase-fallback commands-invalid-stamped-path-effect-descriptor-negative-phase-fallback commands-invalid-stamped-path-effect-descriptor-style-fallback commands-invalid-stamped-path-effect-descriptor-fill-type-fallback commands-invalid-stamped-path-effect-descriptor-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-negative-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-path-verb-fallback commands-invalid-chain-path-effect-descriptor-payload-count-fallback commands-invalid-shader-descriptor-type-fallback"
  replace_default_case_segment "commands-path-effect commands-path-effect-color-filter-fallback" "commands-path-effect commands-resize-path-effect commands-forced-context-path-effect commands-path-effect-color-filter-fallback"
  replace_default_case_segment "commands-invalid-shader-descriptor-type-fallback commands-invalid-descriptor-version-fallback" "commands-invalid-shader-descriptor-type-fallback commands-invalid-shader-descriptor-record-flags-fallback commands-invalid-shader-descriptor-payload-count-fallback commands-invalid-color-shader-descriptor-payload-count-fallback commands-invalid-shader-color-filter-descriptor-payload-count-fallback commands-invalid-shader-descriptor-record-length-fallback commands-invalid-descriptor-version-fallback"
  replace_default_case_segment "commands-invalid-shader-descriptor-record-length-fallback commands-invalid-descriptor-version-fallback" "commands-invalid-shader-descriptor-record-length-fallback commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-descriptor-version-fallback"
  replace_default_case_segment "commands-invalid-descriptor-version-fallback commands-shader-wrong-effect-type-fallback" "commands-invalid-shader-descriptor-version-fallback commands-shader-wrong-effect-type-fallback"
  replace_default_case_segment "commands-invalid-shader-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback" "commands-invalid-shader-descriptor-use-fallback commands-invalid-fill-rect-shader-ref-horizontal-bounds-fallback commands-invalid-fill-rect-shader-ref-vertical-bounds-fallback commands-invalid-fill-rect-shader-ref-alpha-fallback commands-invalid-path-effect-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback commands-invalid-shader-evict-record-flags-fallback"
  replace_default_case_segment "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback" "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-color-filter-evict-record-flags-fallback commands-invalid-path-effect-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback"
  replace_default_case_segment "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback" "commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback commands-composite-shader-child-use-after-evict-fallback commands-composite-shader-src-child-use-after-evict-fallback commands-shader-color-filter-shader-child-use-after-evict-fallback commands-runtime-effect-shader-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-use-after-evict-fallback commands-shader-color-filter-effect-child-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback"
  replace_default_case_segment "commands-offset-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback" "commands-offset-image-filter-child-missing-fallback commands-blur-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback"
  replace_default_case_segment "commands-runtime-effect-invalid-uniform-schema-fallback" "commands-runtime-effect-shader-source-hash-fallback commands-runtime-effect-shader-source-code-fallback commands-runtime-effect-shader-sksl-length-fallback commands-runtime-effect-shader-uniform-float-count-fallback commands-runtime-effect-shader-negative-uniform-float-count-fallback commands-runtime-effect-shader-child-count-fallback commands-runtime-effect-shader-negative-child-count-fallback commands-runtime-effect-shader-named-uniform-count-fallback commands-runtime-effect-shader-negative-named-uniform-count-fallback commands-runtime-effect-shader-named-child-count-fallback commands-runtime-effect-shader-negative-named-child-count-fallback commands-runtime-effect-shader-uniform-name-fallback commands-runtime-effect-shader-uniform-schema-float-count-fallback commands-runtime-effect-shader-uniform-schema-float-offset-fallback commands-runtime-effect-shader-uniform-schema-float-range-fallback commands-runtime-effect-shader-uniform-schema-name-length-fallback commands-runtime-effect-shader-uniform-schema-max-name-length-fallback commands-runtime-effect-shader-uniform-schema-name-range-fallback commands-runtime-effect-shader-child-name-fallback commands-runtime-effect-shader-child-schema-name-length-fallback commands-runtime-effect-shader-child-schema-max-name-length-fallback commands-runtime-effect-shader-child-schema-name-range-fallback commands-runtime-effect-shader-child-index-fallback commands-runtime-effect-shader-negative-child-index-fallback commands-runtime-effect-shader-duplicate-child-index-fallback commands-runtime-effect-color-filter-source-hash-fallback commands-runtime-effect-color-filter-source-code-fallback commands-runtime-effect-color-filter-sksl-length-fallback commands-runtime-effect-color-filter-uniform-float-count-fallback commands-runtime-effect-color-filter-negative-uniform-float-count-fallback commands-runtime-effect-color-filter-child-count-fallback commands-runtime-effect-color-filter-negative-child-count-fallback commands-runtime-effect-color-filter-named-uniform-count-fallback commands-runtime-effect-color-filter-negative-named-uniform-count-fallback commands-runtime-effect-color-filter-named-child-count-fallback commands-runtime-effect-color-filter-negative-named-child-count-fallback commands-runtime-effect-color-filter-uniform-name-fallback commands-runtime-effect-color-filter-uniform-schema-float-count-fallback commands-runtime-effect-color-filter-uniform-schema-float-offset-fallback commands-runtime-effect-color-filter-uniform-schema-float-range-fallback commands-runtime-effect-color-filter-uniform-schema-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-max-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-name-range-fallback commands-runtime-effect-color-filter-child-name-fallback commands-runtime-effect-color-filter-child-schema-name-length-fallback commands-runtime-effect-color-filter-child-schema-max-name-length-fallback commands-runtime-effect-color-filter-child-schema-name-range-fallback commands-runtime-effect-color-filter-child-index-fallback commands-runtime-effect-color-filter-negative-child-index-fallback commands-runtime-effect-color-filter-duplicate-child-index-fallback commands-runtime-effect-invalid-uniform-schema-fallback"
  replace_default_case_segment "commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-descriptor-version-fallback" "commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-composite-shader-descriptor-blend-mode-fallback commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback commands-invalid-radial-gradient-shader-descriptor-radius-fallback commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback commands-invalid-image-shader-descriptor-width-fallback commands-invalid-image-shader-descriptor-max-width-fallback commands-invalid-image-shader-descriptor-height-fallback commands-invalid-image-shader-descriptor-max-height-fallback commands-invalid-image-shader-descriptor-tile-mode-x-fallback commands-invalid-image-shader-descriptor-tile-mode-y-fallback commands-invalid-perlin-noise-shader-kind-fallback commands-invalid-perlin-noise-shader-frequency-fallback commands-invalid-perlin-noise-shader-octaves-fallback commands-invalid-perlin-noise-shader-zero-octaves-fallback commands-invalid-perlin-noise-shader-tile-size-fallback commands-invalid-perlin-noise-shader-tile-height-fallback commands-invalid-perlin-noise-shader-negative-tile-size-fallback commands-invalid-perlin-noise-shader-negative-tile-height-fallback commands-invalid-descriptor-version-fallback"
  replace_default_case_segment "commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-shader-descriptor-version-fallback" "commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-composite-shader-descriptor-blend-mode-fallback commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback commands-invalid-radial-gradient-shader-descriptor-radius-fallback commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback commands-invalid-image-shader-descriptor-width-fallback commands-invalid-image-shader-descriptor-max-width-fallback commands-invalid-image-shader-descriptor-height-fallback commands-invalid-image-shader-descriptor-max-height-fallback commands-invalid-image-shader-descriptor-tile-mode-x-fallback commands-invalid-image-shader-descriptor-tile-mode-y-fallback commands-invalid-perlin-noise-shader-kind-fallback commands-invalid-perlin-noise-shader-frequency-fallback commands-invalid-perlin-noise-shader-octaves-fallback commands-invalid-perlin-noise-shader-zero-octaves-fallback commands-invalid-perlin-noise-shader-tile-size-fallback commands-invalid-perlin-noise-shader-tile-height-fallback commands-invalid-perlin-noise-shader-negative-tile-size-fallback commands-invalid-perlin-noise-shader-negative-tile-height-fallback commands-invalid-shader-descriptor-version-fallback"
  replace_default_case_segment "commands-image-filter-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback" "commands-image-filter-wrong-effect-type-fallback commands-path-effect-wrong-effect-type-fallback commands-blur-image-filter-child-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback"
fi

filter_case_range() {
  local started="false"
  local ended="false"
  local filtered=""
  local name
  for name in ${CASES}; do
    if [[ -z "${CASES_FROM}" || "${name}" == "${CASES_FROM}" ]]; then
      started="true"
    fi
    if [[ "${started}" == "true" ]]; then
      filtered="${filtered} ${name}"
    fi
    if [[ -n "${CASES_UNTIL}" && "${name}" == "${CASES_UNTIL}" && "${started}" == "true" ]]; then
      ended="true"
      break
    fi
  done
  if [[ -n "${CASES_FROM}" && "${started}" != "true" ]]; then
    echo "Unknown CASES_FROM: ${CASES_FROM}" >&2
    exit 2
  fi
  if [[ -n "${CASES_UNTIL}" && "${ended}" != "true" ]]; then
    echo "Unknown CASES_UNTIL: ${CASES_UNTIL}" >&2
    exit 2
  fi
  CASES="${filtered# }"
}

if [[ -n "${CASES_FROM}" || -n "${CASES_UNTIL}" ]]; then
  filter_case_range
fi

if [[ "${LIST_CASES}" == "true" ]]; then
  printf "%s\n" ${CASES}
  exit 0
fi

if [[ "${LIST_CASE_COUNT}" == "true" ]]; then
  echo "${CASES}" | wc -w | tr -d ' '
  exit 0
fi

if [[ "${LIST_UNGROUPED_CASES}" == "true" ]]; then
  list_ungrouped_cases
  exit 0
fi

selection_reason="exact"
if [[ -n "${CASES_FROM}" || -n "${CASES_UNTIL}" ]]; then
  selection_reason="range"
elif [[ -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" ]]; then
  selection_reason="default"
elif [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  selection_reason="case-groups"
fi
if [[ "${EARLY_DEFAULT_BROAD_VALIDATION_GUARDED}" != "true" ]]; then
  jbr_skia_daily_broad_validation_guard_for_selection \
    "command-probe suite" \
    "$(echo "${CASES}" | wc -w | tr -d ' ')" \
    "${selection_reason}"
fi

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
    commands-live-animation)
      run_case "$1" \
        SKIKO_FORCE_TINY_FULL_SCENE_ONCE_FOR_TEST=true \
        EXPECT_MIN_APP_NEW_FRAMES=5 \
        EXPECT_MIN_TINY_FULL_SCENE_INJECTIONS=1
      ;;
    commands-invalid-command-stream-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_STREAM_FLAGS_CORRUPTED"
      ;;
    commands-invalid-command-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-command-coordinate-space-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_COORDINATE_SPACE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_COORDINATE_SPACE_CORRUPTED"
      ;;
    commands-invalid-command-paint-format-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_PAINT_FORMAT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_PAINT_FORMAT_CORRUPTED"
      ;;
    commands-invalid-command-payload-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_PAYLOAD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_PAYLOAD_LENGTH_CORRUPTED mode=negative"
      ;;
    commands-invalid-command-payload-truncated-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_PAYLOAD_TRUNCATED=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_PAYLOAD_LENGTH_CORRUPTED mode=truncated"
      ;;
    commands-invalid-command-payload-extra-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_PAYLOAD_EXTRA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_PAYLOAD_LENGTH_CORRUPTED mode=extra"
      ;;
    commands-invalid-command-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_COMMAND_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMMAND_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-invalid-stroke-cap-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_STROKE_CAP=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_CAP_CORRUPTED"
      ;;
    commands-invalid-blend-layer-bounds-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_INVALID_BLEND_LAYER_BOUNDS=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-invalid-concat-transform-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_INVALID_CONCAT_TRANSFORM=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-invalid-transform-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_TRANSFORM_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TRANSFORM_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-clip-operation-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CLIP=true \
        MAGIC_JEWEL_CORRUPT_CLIP_OPERATION=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_CLIP_OPERATION_CORRUPTED"
      ;;
    commands-invalid-point-dots-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_INVALID_POINT_DOTS=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-invalid-draw-points-point-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true \
        MAGIC_JEWEL_CORRUPT_DRAW_POINTS_POINT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_POINTS_POINT_COUNT_CORRUPTED"
      ;;
    commands-invalid-draw-points-max-point-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true \
        MAGIC_JEWEL_CORRUPT_DRAW_POINTS_MAX_POINT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_POINTS_MAX_POINT_COUNT_CORRUPTED"
      ;;
    commands-invalid-draw-points-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true \
        MAGIC_JEWEL_CORRUPT_DRAW_POINTS_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_POINTS_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-native-bridge-load-library)
      run_case "$1" \
        JBR_SKIA_LIB= \
        JBR_SKIA_LIBRARY_PATH=/tmp/jbr-skia-native \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
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
    commands-invalid-image-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_CORRUPTED op=16"
      ;;
    commands-invalid-image-define-pixel-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_PIXEL_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_PIXEL_COUNT_CORRUPTED op=15"
      ;;
    commands-invalid-image-define-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-image-define-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_WIDTH_CORRUPTED op=15"
      ;;
    commands-invalid-image-define-max-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_MAX_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_MAX_WIDTH_CORRUPTED op=15"
      ;;
    commands-invalid-image-define-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_HEIGHT_CORRUPTED op=15"
      ;;
    commands-invalid-image-define-max-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_DEFINE_MAX_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_DEFINE_MAX_HEIGHT_CORRUPTED op=15"
      ;;
    commands-invalid-image-cache-clear-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_IMAGE_CACHE_CHURN=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_CACHE_CLEAR_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_ALLOW_RECOVERY=true \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_CACHE_CLEAR_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-image-evict-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_IMAGE_CACHE_CHURN=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_EVICT_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_ALLOW_RECOVERY=true \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_EVICT_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-image-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_AFTER_EVICT_CORRUPTED op=16"
      ;;
    commands-invalid-image-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_WIDTH_CORRUPTED op=16"
      ;;
    commands-invalid-image-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_HEIGHT_CORRUPTED op=16"
      ;;
    commands-invalid-image-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_ALPHA_CORRUPTED op=16"
      ;;
    commands-invalid-image-ref-filter-quality-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_REF_FILTER_QUALITY=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_FILTER_QUALITY_CORRUPTED op=16"
      ;;
    commands-invalid-image-color-filter-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_AFTER_EVICT_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_WIDTH_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_HEIGHT_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_ALPHA_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-ref-filter-quality-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_FILTER_QUALITY=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_FILTER_QUALITY_CORRUPTED op=45"
      ;;
    commands-invalid-image-color-filter-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_COLOR_FILTER_BLEND_MODE_CORRUPTED"
      ;;
    commands-invalid-image-color-filter-ref-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_CORRUPTED op=53"
      ;;
    commands-invalid-image-color-filter-ref-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_REF_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_USE_AFTER_EVICT_CORRUPTED op=53"
      ;;
    commands-invalid-image-color-filter-descriptor-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_DESCRIPTOR_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_WIDTH_CORRUPTED op=53"
      ;;
    commands-invalid-image-color-filter-descriptor-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_DESCRIPTOR_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_HEIGHT_CORRUPTED op=53"
      ;;
    commands-invalid-image-color-filter-descriptor-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_DESCRIPTOR_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_ALPHA_CORRUPTED op=53"
      ;;
    commands-invalid-image-color-filter-descriptor-ref-filter-quality-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_COLOR_FILTER_DESCRIPTOR_REF_FILTER_QUALITY=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_REF_FILTER_QUALITY_CORRUPTED op=53"
      ;;
    commands-invalid-clip-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CLIP_PATH=true \
        MAGIC_JEWEL_CORRUPT_CLIP_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_CLIP_PATH_VERB_CORRUPTED"
      ;;
    commands-clip-path-invalid-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CLIP_PATH=true \
        MAGIC_JEWEL_COMPOSE_INVALID_CLIP_PATH=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-draw-path-invalid-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=true \
        MAGIC_JEWEL_COMPOSE_INVALID_DRAW_PATH=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-invalid-draw-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_DRAW_PATH=true \
        MAGIC_JEWEL_CORRUPT_DRAW_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_PATH_VERB_CORRUPTED"
      ;;
    commands-invalid-draw-path-path-effect-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_DRAW_PATH_PATH_EFFECT_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_PATH_PATH_EFFECT_VERB_CORRUPTED"
      ;;
    commands-invalid-stroke-line-dash-path-effect-interval-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_LINE_DASH_PATH_EFFECT_INTERVAL_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_LINE_DASH_PATH_EFFECT_INTERVAL_COUNT_CORRUPTED"
      ;;
    commands-invalid-stroke-rect-dash-path-effect-interval-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_RECT_DASH_PATH_EFFECT_INTERVAL_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_RECT_DASH_PATH_EFFECT_INTERVAL_COUNT_CORRUPTED"
      ;;
    commands-invalid-stroke-rect-dash-path-effect-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_RECT_DASH_PATH_EFFECT_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_RECT_DASH_PATH_EFFECT_WIDTH_CORRUPTED"
      ;;
    commands-invalid-stroke-rect-dash-path-effect-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_RECT_DASH_PATH_EFFECT_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_RECT_DASH_PATH_EFFECT_HEIGHT_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-interval-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_INTERVAL_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_INTERVAL_COUNT_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-right-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RIGHT_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-bottom-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_BOTTOM=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_BOTTOM_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-radius-x-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RADIUS_X=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RADIUS_X_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-radius-y-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RADIUS_Y=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_RADIUS_Y_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-stroke-cap-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_CAP=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_CAP_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-stroke-join-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_JOIN=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_JOIN_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-stroke-miter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_MITER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_STROKE_MITER_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-phase-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_PHASE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_PHASE_CORRUPTED"
      ;;
    commands-invalid-stroke-round-rect-dash-path-effect-interval-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_ROUND_RECT_DASH_PATH_EFFECT_INTERVAL=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_ROUND_RECT_DASH_PATH_EFFECT_INTERVAL_CORRUPTED"
      ;;
    commands-invalid-stroke-path-dash-path-effect-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_PATH_DASH_PATH_EFFECT_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_PATH_DASH_PATH_EFFECT_VERB_CORRUPTED"
      ;;
    commands-invalid-stroke-path-dash-path-effect-interval-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_PATH_DASH_PATH_EFFECT_INTERVAL_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_PATH_DASH_PATH_EFFECT_INTERVAL_COUNT_CORRUPTED"
      ;;
    commands-invalid-stroke-path-dash-path-effect-interval-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_PATH_DASH_PATH_EFFECT_INTERVAL=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_PATH_DASH_PATH_EFFECT_INTERVAL_CORRUPTED"
      ;;
    commands-invalid-draw-shadow-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_CORRUPT_DRAW_SHADOW_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_SHADOW_PATH_VERB_CORRUPTED"
      ;;
    commands-concat-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CONCAT_TRANSFORM=true
      ;;
    commands-resize-concat-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CONCAT_TRANSFORM=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-concat-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_CONCAT_TRANSFORM=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-skew-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SKEW_TRANSFORM=true
      ;;
    commands-resize-skew-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SKEW_TRANSFORM=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-skew-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SKEW_TRANSFORM=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-point-lines)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_LINES=true
      ;;
    commands-resize-point-lines)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_LINES=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-point-lines)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_LINES=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-point-dots)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true
      ;;
    commands-resize-point-dots)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-point-dots)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
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
    commands-resize-gradient-surfaces)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-gradient-surfaces)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-linear-gradient-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_BLEND_MODE=true
      ;;
    commands-resize-linear-gradient-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-linear-gradient-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-radial-gradient-stroke-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_STROKE_BLEND_MODE=true
      ;;
    commands-resize-radial-gradient-stroke-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_STROKE_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-radial-gradient-stroke-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_STROKE_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-sweep-gradient-round-rect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT_BLEND_MODE=true
      ;;
    commands-resize-sweep-gradient-round-rect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-sweep-gradient-round-rect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-linear-gradient-invalid-stops-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_STOPS=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-linear-gradient-invalid-points-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_POINTS=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-radial-gradient-invalid-stops-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_STOPS=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-radial-gradient-invalid-geometry-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_GEOMETRY=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
        commands-linear-gradient-invalid-color-count-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_COLOR_COUNT=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-radial-gradient-invalid-color-count-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_COLOR_COUNT=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-sweep-gradient-invalid-color-count-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_SWEEP_GRADIENT_COLOR_COUNT=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-sweep-gradient-invalid-geometry-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_COMPOSE_INVALID_SWEEP_GRADIENT_GEOMETRY=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
        commands-linear-gradient-invalid-stroke-width-public-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_STROKE_WIDTH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-radial-gradient-invalid-stroke-width-public-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_STROKE_WIDTH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-sweep-gradient-invalid-stroke-width-public-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_INVALID_SWEEP_GRADIENT_STROKE_WIDTH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-linear-gradient-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-radial-gradient-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-sweep-gradient-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_SWEEP_GRADIENT_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-linear-gradient-stroke-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_LINEAR_GRADIENT_STROKE_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-radial-gradient-stroke-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_RADIAL_GRADIENT_STROKE_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-sweep-gradient-stroke-round-rect-invalid-radius-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
            MAGIC_JEWEL_COMPOSE_INVALID_SWEEP_GRADIENT_STROKE_ROUND_RECT_RADIUS=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-gradient-paths)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true
      ;;
    commands-resize-gradient-paths)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-gradient-paths)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-linear-gradient-path-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH_BLEND_MODE=true
      ;;
    commands-resize-linear-gradient-path-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-linear-gradient-path-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
        commands-linear-gradient-path-invalid-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
            MAGIC_JEWEL_COMPOSE_INVALID_GRADIENT_PATH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-radial-gradient-path-invalid-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
            MAGIC_JEWEL_COMPOSE_INVALID_GRADIENT_PATH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-sweep-gradient-path-invalid-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
            MAGIC_JEWEL_COMPOSE_INVALID_GRADIENT_PATH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-linear-gradient-path-stroke-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_GRADIENT_PATH_STROKE=true
      ;;
    commands-radial-gradient-path-stroke-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_GRADIENT_PATH_STROKE=true
      ;;
    commands-sweep-gradient-path-stroke-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_COMPOSE_GRADIENT_PATH_STROKE=true
      ;;
    commands-popup)
      run_case "$1" \
        MAGIC_JEWEL_POPUP_STRESS=true \
        EXPECT_MIN_POPUP_FRAMES=5
      ;;
    commands-popup-window)
      run_case "$1" \
        MAGIC_JEWEL_POPUP_WINDOW_STRESS=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
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
    commands-native-custom-font-text-image|commands-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1
      ;;
    commands-invalid-text-font-size-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_TEXT_FONT_SIZE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TEXT_FONT_SIZE_CORRUPTED"
      ;;
    commands-invalid-text-font-weight-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_TEXT_FONT_WEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TEXT_FONT_WEIGHT_CORRUPTED"
      ;;
    commands-invalid-text-font-width-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_TEXT_FONT_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TEXT_FONT_WIDTH_CORRUPTED"
      ;;
    commands-invalid-text-font-slant-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_TEXT_FONT_SLANT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TEXT_FONT_SLANT_CORRUPTED"
      ;;
    commands-invalid-text-font-family-count-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_TEXT_FONT_FAMILY_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TEXT_FONT_FAMILY_COUNT_CORRUPTED"
      ;;
    commands-invalid-paragraph-font-size-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SIZE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PARAGRAPH_FONT_SIZE_CORRUPTED"
      ;;
    commands-invalid-paragraph-font-weight-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PARAGRAPH_FONT_WEIGHT_CORRUPTED"
      ;;
    commands-invalid-paragraph-font-width-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PARAGRAPH_FONT_WIDTH_CORRUPTED"
      ;;
    commands-invalid-paragraph-font-slant-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_SLANT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PARAGRAPH_FONT_SLANT_CORRUPTED"
      ;;
    commands-invalid-paragraph-font-family-count-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_CORRUPT_PARAGRAPH_FONT_FAMILY_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PARAGRAPH_FONT_FAMILY_COUNT_CORRUPTED"
      ;;
    commands-invalid-font-data-record-flags-fallback)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_CORRUPT_FONT_DATA_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_ALLOW_RECOVERY=true \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_FONT_DATA_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1
      ;;
    commands-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1
      ;;
    commands-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1
      ;;
    commands-resize-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-resize-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-resize-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-resize-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-generic-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_GENERIC_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=3 \
        EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MAX_JBR_FONT_DATA_DEFINES=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-system-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_SYSTEM_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-custom-font-text-image|commands-forced-context-native-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_UNSUPPORTED_TEXT=true \
        MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-dynamic-images)
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
    commands-image-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_BLEND_MODE=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-resize-image-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-image-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-image-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-resize-image-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-image-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-image-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_BLEND_MODE=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-resize-image-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-image-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-image-shader-invalid-image-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        MAGIC_JEWEL_COMPOSE_INVALID_IMAGE_SHADER_IMAGE=true
      ;;
    commands-image-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_PATH_EFFECT=true
      ;;
    commands-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-resize-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-forced-context-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-color-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER_BLEND_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-resize-color-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-forced-context-color-shader-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-gradient-shaders)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRADIENT_SHADERS=true
      ;;
    commands-resize-gradient-shaders)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRADIENT_SHADERS=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-gradient-shaders)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRADIENT_SHADERS=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-image-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-image-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-image-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-composite-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3
      ;;
    commands-resize-composite-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-forced-context-composite-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-resize-composite-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-forced-context-composite-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3
      ;;
    commands-resize-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
    commands-forced-context-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
    commands-composite-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-composite-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=8 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=12 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-composite-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=8 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=12 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-resize-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-forced-context-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-raw-runtime-effect-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_SHADER=true
      ;;
    commands-runtime-effect-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-runtime-effect-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-runtime-effect-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-linear-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-linear-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-linear-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-sweep-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-radial-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_SHADER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-radial-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-radial-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-sweep-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-sweep-gradient-shader-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-resize-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-forced-context-runtime-effect-pure-color)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-resize-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-forced-context-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3
      ;;
    commands-resize-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-forced-context-runtime-effect-child-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=9
      ;;
    commands-runtime-effect-shader-source-cache-eviction)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        JBR_SKIA_RUNTIME_EFFECT_CACHE_LIMIT_FOR_TEST=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 \
        EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=shader
      ;;
    commands-runtime-effect-shader-source-hash-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SOURCE_HASH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_SOURCE_HASH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-source-code-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SOURCE_CODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_SOURCE_CODE_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-source-hash-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SOURCE_HASH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_SOURCE_HASH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-name-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_NAME=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_NAME_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-float-offset-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_OFFSET=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_OFFSET_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-float-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_FLOAT_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-max-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_MAX_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_MAX_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-schema-name-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_NAME_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_SCHEMA_NAME_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-name-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_NAME=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_NAME_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-schema-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-schema-max-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_MAX_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_MAX_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-schema-name-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_NAME_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_SCHEMA_NAME_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_INDEX_CORRUPTED"
      ;;
    commands-runtime-effect-shader-negative-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_INDEX_CORRUPTED"
      ;;
    commands-runtime-effect-shader-duplicate-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_DUPLICATE_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_DUPLICATE_CHILD_INDEX_CORRUPTED"
      ;;
    commands-runtime-effect-shader-sksl-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_SKSL_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_SKSL_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-shader-uniform-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_UNIFORM_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_UNIFORM_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-negative-uniform-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_UNIFORM_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NEGATIVE_UNIFORM_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-negative-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NEGATIVE_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-named-uniform-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_UNIFORM_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NAMED_UNIFORM_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-negative-named-uniform-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_UNIFORM_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_UNIFORM_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-named-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NAMED_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NAMED_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-shader-negative-named-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_SHADER_NEGATIVE_NAMED_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-sksl-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SKSL_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_SKSL_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-source-code-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_SOURCE_CODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_SOURCE_CODE_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-negative-uniform-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_UNIFORM_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_UNIFORM_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-negative-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-named-uniform-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_UNIFORM_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NAMED_UNIFORM_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-negative-named-uniform-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_UNIFORM_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_UNIFORM_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-named-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NAMED_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NAMED_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-negative-named-child-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_CHILD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_NAMED_CHILD_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-name-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_NAME=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_NAME_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-float-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_COUNT_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-float-offset-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_OFFSET=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_OFFSET_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-float-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_FLOAT_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-max-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_MAX_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_MAX_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-uniform-schema-name-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_NAME_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_UNIFORM_SCHEMA_NAME_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-name-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_NAME=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_NAME_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-schema-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-schema-max-name-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_MAX_NAME_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_MAX_NAME_LENGTH_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-schema-name-range-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_NAME_RANGE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_SCHEMA_NAME_RANGE_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_CHILD_INDEX_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-negative-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_NEGATIVE_CHILD_INDEX_CORRUPTED"
      ;;
    commands-runtime-effect-color-filter-duplicate-child-index-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_COLOR_FILTER_DUPLICATE_CHILD_INDEX=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RUNTIME_EFFECT_COLOR_FILTER_DUPLICATE_CHILD_INDEX_CORRUPTED"
      ;;
        commands-runtime-effect-invalid-uniform-schema-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_INVALID_UNIFORM_SCHEMA=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-runtime-effect-invalid-child-schema-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_INVALID_CHILD_SCHEMA=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-runtime-effect-invalid-nested-child-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_INVALID_NESTED_CHILD=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-resize-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-forced-context-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-runtime-effect-stable-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-raw-runtime-effect-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_COLOR_FILTER=true
      ;;
    commands-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-resize-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-forced-context-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-runtime-effect-source-cache-eviction)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_STABLE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        JBR_SKIA_RUNTIME_EFFECT_CACHE_LIMIT_FOR_TEST=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 \
        EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=colorFilter
      ;;
        commands-runtime-effect-color-filter-invalid-uniform-schema-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_UNIFORM_SCHEMA=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-runtime-effect-color-filter-invalid-child-schema-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_CHILD_SCHEMA=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-runtime-effect-color-filter-invalid-nested-child-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
            MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_NESTED_CHILD=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-runtime-effect-color-filter-compile-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SOURCE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-compile-failed
      ;;
    commands-runtime-effect-color-filter-build-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_BAD_CHILD=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed \
        EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=child-count
      ;;
    commands-runtime-effect-color-filter-child-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_CHILD_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed \
        EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=positional-child-type
      ;;
    commands-runtime-effect-compile-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_SOURCE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-compile-failed
      ;;
    commands-runtime-effect-build-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_BAD_CHILD=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed \
        EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=missing-child
      ;;
    commands-runtime-effect-child-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RUNTIME_EFFECT_CHILD_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=runtime-effect-build-failed \
        EXPECT_RUNTIME_EFFECT_BUILD_FAILURE_STAGE=child-type
      ;;
    commands-invalid-descriptor-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=47"
      ;;
    commands-invalid-shader-descriptor-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=58"
      ;;
    commands-invalid-fill-rect-shader-ref-horizontal-bounds-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_SHADER_REF_HORIZONTAL_BOUNDS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_SHADER_REF_HORIZONTAL_BOUNDS_CORRUPTED
      ;;
    commands-invalid-fill-rect-shader-ref-vertical-bounds-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_SHADER_REF_VERTICAL_BOUNDS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_SHADER_REF_VERTICAL_BOUNDS_CORRUPTED
      ;;
    commands-invalid-fill-rect-shader-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_SHADER_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_SHADER_REF_ALPHA_CORRUPTED
      ;;
    commands-invalid-path-effect-descriptor-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=62"
      ;;
    commands-invalid-descriptor-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=58"
      ;;
    commands-invalid-shader-evict-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        MAGIC_JEWEL_CORRUPT_SHADER_EVICT_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_EVICT_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-color-filter-descriptor-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=47"
      ;;
    commands-invalid-color-filter-evict-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_EVICT_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_EVICT_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-path-effect-descriptor-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=62"
      ;;
    commands-transformed-shader-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_USE_AFTER_EVICT_CORRUPTED target=transformedShaderChild"
      ;;
    commands-composite-shader-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_USE_AFTER_EVICT_CORRUPTED target=compositeShaderDstChild"
      ;;
    commands-composite-shader-src-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_SRC_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_USE_AFTER_EVICT_CORRUPTED target=compositeShaderSrcChild"
      ;;
    commands-shader-color-filter-shader-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_USE_AFTER_EVICT_CORRUPTED target=shaderColorFilterShaderChild"
      ;;
    commands-runtime-effect-shader-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_USE_AFTER_EVICT_CORRUPTED target=runtimeEffectShaderChild"
      ;;
    commands-runtime-effect-color-filter-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_USE_AFTER_EVICT_CORRUPTED target=runtimeEffectColorFilterChild"
      ;;
    commands-shader-color-filter-effect-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_USE_AFTER_EVICT_CORRUPTED target=shaderColorFilterEffectChild"
      ;;
    commands-invalid-effect-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_USE_AFTER_EVICT_CORRUPTED target=offsetImageFilterChild"
      ;;
    commands-invalid-blur-effect-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_USE_AFTER_EVICT_CORRUPTED target=blurImageFilterChild"
      ;;
    commands-invalid-path-effect-child-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_USE_AFTER_EVICT_CORRUPTED target=chainPathEffectChild"
      ;;
    commands-runtime-effect-color-filter-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_MISSING_CORRUPTED target=runtimeEffectColorFilterChild"
      ;;
    commands-offset-image-filter-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_MISSING_CORRUPTED target=offsetImageFilterChild"
      ;;
    commands-blur-image-filter-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_MISSING_CORRUPTED target=blurImageFilterChild"
      ;;
    commands-chain-path-effect-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_MISSING_CORRUPTED target=chainPathEffectChild"
      ;;
    commands-shader-color-filter-effect-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_CHILD_MISSING_CORRUPTED target=shaderColorFilterEffectChild"
      ;;
    commands-invalid-effect-descriptor-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_DESCRIPTOR_TYPE_CORRUPTED"
      ;;
    commands-invalid-effect-descriptor-version-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_VERSION=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_DESCRIPTOR_VERSION_CORRUPTED"
      ;;
    commands-invalid-effect-descriptor-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_DESCRIPTOR_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-effect-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-effect-descriptor-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_EFFECT_DESCRIPTOR_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_EFFECT_DESCRIPTOR_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-invalid-lighting-filter-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        MAGIC_JEWEL_CORRUPT_LIGHTING_FILTER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LIGHTING_FILTER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-tint-color-filter-descriptor-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_TINT_COLOR_FILTER_DESCRIPTOR_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TINT_COLOR_FILTER_DESCRIPTOR_BLEND_MODE_CORRUPTED"
      ;;
    commands-invalid-color-matrix-filter-descriptor-payload-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_COLOR_MATRIX_FILTER_DESCRIPTOR_PAYLOAD=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_MATRIX_FILTER_DESCRIPTOR_PAYLOAD_CORRUPTED"
      ;;
    commands-invalid-blur-image-filter-descriptor-sigma-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA_CORRUPTED"
      ;;
    commands-invalid-blur-with-input-image-filter-descriptor-sigma-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_SIGMA_CORRUPTED"
      ;;
    commands-invalid-blur-image-filter-descriptor-negative-sigma-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA_CORRUPTED"
      ;;
    commands-invalid-blur-with-input-image-filter-descriptor-negative-sigma-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_NEGATIVE_SIGMA_CORRUPTED"
      ;;
    commands-invalid-blur-image-filter-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_BLUR_IMAGE_FILTER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-offset-image-filter-descriptor-delta-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA_CORRUPTED"
      ;;
    commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_OFFSET_IMAGE_FILTER_DESCRIPTOR_DELTA_CORRUPTED"
      ;;
    commands-invalid-corner-path-effect-descriptor-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_CORNER_PATH_EFFECT_DESCRIPTOR_RADIUS_CORRUPTED"
      ;;
    commands-invalid-corner-path-effect-descriptor-negative-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_CORNER_PATH_EFFECT_DESCRIPTOR_NEGATIVE_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_CORNER_PATH_EFFECT_DESCRIPTOR_NEGATIVE_RADIUS_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-advance-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ADVANCE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_ADVANCE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-zero-advance-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_ZERO_ADVANCE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_ZERO_ADVANCE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-phase-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PHASE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_PHASE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-negative-phase-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PHASE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PHASE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-style-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_STYLE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_STYLE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-fill-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_FILL_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_FILL_TYPE_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-path-data-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_DATA_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_DATA_LENGTH_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-negative-path-data-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PATH_DATA_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_NEGATIVE_PATH_DATA_LENGTH_CORRUPTED"
      ;;
    commands-invalid-stamped-path-effect-descriptor-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STAMPED_PATH_EFFECT_DESCRIPTOR_PATH_VERB_CORRUPTED"
      ;;
    commands-invalid-chain-path-effect-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_CHAIN_PATH_EFFECT_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_CHAIN_PATH_EFFECT_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-shader-descriptor-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_TYPE_CORRUPTED"
      ;;
    commands-invalid-shader-descriptor-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_RECORD_FLAGS_CORRUPTED"
      ;;
    commands-invalid-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-color-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-shader-color-filter-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-shader-descriptor-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_LENGTH=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-invalid-transformed-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_CORRUPT_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-composite-shader-descriptor-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_COLOR_COUNT=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_SHADER_DESCRIPTOR_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_WIDTH=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_WIDTH_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-max-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_WIDTH=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_MAX_WIDTH_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_HEIGHT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_HEIGHT_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-max-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_MAX_HEIGHT=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_MAX_HEIGHT_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-tile-mode-x-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_X=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_X_CORRUPTED"
      ;;
    commands-invalid-image-shader-descriptor-tile-mode-y-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_Y=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_SHADER_DESCRIPTOR_TILE_MODE_Y_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-kind-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_KIND=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_KIND_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-frequency-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_FREQUENCY=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_FREQUENCY_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-octaves-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_OCTAVES=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_OCTAVES_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-zero-octaves-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_ZERO_OCTAVES=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_ZERO_OCTAVES_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-tile-size-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_SIZE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_TILE_SIZE_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-tile-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_TILE_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_TILE_HEIGHT_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-negative-tile-size-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_SIZE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_NEGATIVE_TILE_SIZE_CORRUPTED"
      ;;
    commands-invalid-perlin-noise-shader-negative-tile-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_PERLIN_NOISE_SHADER_NEGATIVE_TILE_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PERLIN_NOISE_SHADER_NEGATIVE_TILE_HEIGHT_CORRUPTED"
      ;;
    commands-invalid-descriptor-version-fallback|commands-invalid-shader-descriptor-version-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_VERSION_CORRUPTED"
      ;;
    commands-shader-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_HANDLE_TYPE_CORRUPTED target=fillRectShader"
      ;;
    commands-transformed-shader-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_HANDLE_TYPE_CORRUPTED target=transformedShaderChild"
      ;;
    commands-composite-shader-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_HANDLE_TYPE_CORRUPTED target=compositeShaderDstChild"
      ;;
    commands-composite-shader-src-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_SRC_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_HANDLE_TYPE_CORRUPTED target=compositeShaderSrcChild"
      ;;
    commands-composite-shader-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_MISSING_CORRUPTED target=compositeShaderDstChild"
      ;;
    commands-composite-shader-src-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_SRC_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_MISSING_CORRUPTED target=compositeShaderSrcChild"
      ;;
    commands-runtime-effect-shader-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_SHADER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_HANDLE_TYPE_CORRUPTED target=runtimeEffectShaderChild"
      ;;
    commands-transformed-shader-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_MISSING_CORRUPTED target=transformedShaderChild"
      ;;
    commands-shader-color-filter-shader-child-missing-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_CHILD_MISSING=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_CHILD_MISSING_CORRUPTED target=shaderColorFilterShaderChild"
      ;;
    commands-color-filter-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=fillRectColorFilter"
      ;;
    commands-runtime-effect-color-filter-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=runtimeEffectColorFilterChild"
      ;;
    commands-runtime-effect-color-filter-child-path-effect-wrong-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=runtimeEffectColorFilterChildPathEffect"
      ;;
    commands-color-filter-path-effect-wrong-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TO_PATH_EFFECT_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=fillRectColorFilterPathEffect"
      ;;
    commands-shader-color-filter-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_COLOR_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_FILTER_HANDLE_TYPE_CORRUPTED target=shaderColorFilter"
      ;;
    commands-image-filter-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_FILTER_HANDLE_TYPE_CORRUPTED target=saveLayerImageFilter"
      ;;
    commands-path-effect-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_PATH_EFFECT_USE_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PATH_EFFECT_HANDLE_TYPE_CORRUPTED target=drawPathPathEffect"
      ;;
    commands-offset-image-filter-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_FILTER_HANDLE_TYPE_CORRUPTED target=offsetImageFilterChild"
      ;;
    commands-blur-image-filter-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLUR_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_IMAGE_FILTER_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_IMAGE_FILTER_HANDLE_TYPE_CORRUPTED target=blurImageFilterChild"
      ;;
    commands-chain-path-effect-child-wrong-effect-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_PATH_EFFECT_HANDLE_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_PATH_EFFECT_HANDLE_TYPE_CORRUPTED target=chainPathEffectChild"
      ;;
    commands-image-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-resize-image-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-image-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-image-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-image-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-image-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-image-raw-table-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_RAW_TABLE_COLOR_FILTER=true
      ;;
    commands-gradient-stroke)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-resize-gradient-stroke)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-forced-context-gradient-stroke)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-invalid-linear-gradient-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-round-rect-stroke-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_ROUND_RECT_STROKE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_ROUND_RECT_STROKE_WIDTH_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-stroke-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_STROKE_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-stroke-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_STROKE_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_STROKE_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-round-rect-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-fill-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_FILL_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_FILL_TYPE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-data-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_DATA_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_DATA_LENGTH_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_PATH_VERB_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-fill-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_FILL_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_FILL_TYPE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-data-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_DATA_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_DATA_LENGTH_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_PATH_VERB_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-path-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_PATH_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_PATH_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-path-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_PATH_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_PATH_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-path-fill-type-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_PATH_FILL_TYPE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_PATH_FILL_TYPE_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-path-data-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_PATH_DATA_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_PATH_DATA_LENGTH_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-path-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_PATH_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_PATH_VERB_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-round-rect-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_ROUND_RECT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_ROUND_RECT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-round-rect-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-round-rect-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_ROUND_RECT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_ROUND_RECT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-sweep-gradient-round-rect-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_SWEEP_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SWEEP_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stroke-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STROKE_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STROKE_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stroke-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STROKE_RADIUS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STROKE_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stroke-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STROKE_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STROKE_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stroke-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STROKE_TILE_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STROKE_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stroke-color-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STROKE_COLOR_COUNT_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-round-rect-stroke-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_ROUND_RECT_STROKE_STOP_ORDER_CORRUPTED"
      ;;
    commands-color-filter|commands-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true
      ;;
    commands-resize-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-color-filter-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_BLEND_MODE=true
      ;;
    commands-resize-color-filter-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-color-filter-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-invalid-fill-rect-color-filter-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_COLOR_FILTER_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_COLOR_FILTER_BLEND_MODE_CORRUPTED
      ;;
    commands-invalid-fill-rect-color-filter-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_COLOR_FILTER_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_COLOR_FILTER_WIDTH_CORRUPTED
      ;;
    commands-invalid-fill-rect-color-filter-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_COLOR_FILTER_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_COLOR_FILTER_HEIGHT_CORRUPTED
      ;;
    commands-invalid-fill-rect-color-filter-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_COLOR_FILTER_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_COLOR_FILTER_REF_WIDTH_CORRUPTED
      ;;
    commands-invalid-fill-rect-color-filter-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_COLOR_FILTER_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_COLOR_FILTER_REF_HEIGHT_CORRUPTED
      ;;
    commands-raw-blend-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_BLEND_COLOR_FILTER=true
      ;;
    commands-raw-table-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_TABLE_COLOR_FILTER=true
      ;;
    commands-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-color-filter-handle)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
        commands-color-matrix-filter-nonfinite-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_INVALID_COLOR_MATRIX_FILTER=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-lighting-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-lighting-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-lighting-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-descriptor-eviction)
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
    commands-resize-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-forced-context-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-resize-color-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-forced-context-color-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-resize-noise-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-forced-context-noise-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-resize-turbulence-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-forced-context-turbulence-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-resize-composite-noise-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
    commands-forced-context-composite-noise-shader-descriptor-redefine)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
    commands-path-effect|commands-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=5 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=5
      ;;
    commands-resize-path-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=10 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=10
      ;;
    commands-forced-context-path-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=10 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=10
      ;;
        commands-path-effect-color-filter-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_PATH_EFFECT_COLOR_FILTER=true
          ;;
    commands-raw-discrete-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_DISCRETE_PATH_EFFECT=true
      ;;
    commands-vertices)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true
      ;;
    commands-resize-vertices)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-vertices)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-vertices-raw-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_COMPOSE_VERTICES_RAW_COLOR_FILTER=true
      ;;
        commands-vertices-invalid-blend-mode-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_VERTICES_INVALID_BLEND_MODE=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-invalid-draw-vertices-vertex-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_VERTEX_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_VERTEX_COUNT_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-max-vertex-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_MAX_VERTEX_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_MAX_VERTEX_COUNT_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-vertex-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_VERTEX_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_VERTEX_MODE_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_BLEND_MODE_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-index-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_INDEX_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_INDEX_COUNT_CORRUPTED"
      ;;
    commands-invalid-draw-vertices-max-index-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true \
        MAGIC_JEWEL_CORRUPT_DRAW_VERTICES_MAX_INDEX_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DRAW_VERTICES_MAX_INDEX_COUNT_CORRUPTED"
      ;;
    commands-blend-mode|commands-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true
      ;;
    commands-resize-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-invalid-fill-rect-blend-mode-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_BLEND_MODE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_BLEND_MODE_WIDTH_CORRUPTED
      ;;
    commands-invalid-fill-rect-blend-mode-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_FILL_RECT_BLEND_MODE_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_FILL_RECT_BLEND_MODE_HEIGHT_CORRUPTED
      ;;
    commands-graphics-layer|commands-graphics-layer-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true
      ;;
    commands-resize-graphics-layer)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
        commands-graphics-layer-invalid-size-width-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SIZE_WIDTH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-graphics-layer-invalid-size-height-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SIZE_HEIGHT=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-graphics-layer-invalid-alpha-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_ALPHA=true
          ;;
        commands-graphics-layer-invalid-scale-x-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SCALE_X=true
          ;;
        commands-graphics-layer-invalid-scale-y-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SCALE_Y=true
          ;;
        commands-graphics-layer-invalid-rotation-z-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_ROTATION_Z=true
          ;;
        commands-graphics-layer-invalid-translation-x-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_TRANSLATION_X=true
          ;;
        commands-graphics-layer-invalid-translation-y-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_TRANSLATION_Y=true
          ;;
        commands-graphics-layer-invalid-rotation-x-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_ROTATION_X=true
          ;;
        commands-graphics-layer-invalid-rotation-y-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_ROTATION_Y=true
          ;;
    commands-graphics-layer-modulate-alpha)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_MODULATE_ALPHA=true
      ;;
    commands-resize-graphics-layer-modulate-alpha)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_MODULATE_ALPHA=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-modulate-alpha)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_MODULATE_ALPHA=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-offscreen)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSCREEN=true
      ;;
    commands-resize-graphics-layer-offscreen)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSCREEN=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-offscreen)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSCREEN=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP=true
      ;;
    commands-resize-graphics-layer-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-round-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true
      ;;
    commands-resize-graphics-layer-round-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-round-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-path-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true
      ;;
    commands-resize-graphics-layer-path-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-path-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true
      ;;
    commands-resize-graphics-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
        commands-graphics-layer-invalid-blend-mode-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_BLEND_MODE=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
        commands-graphics-layer-unrecorded-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_UNRECORDED=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-graphics-layer-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true
      ;;
    commands-resize-graphics-layer-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-raw-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_COLOR_FILTER=true
      ;;
    commands-graphics-layer-raw-table-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_TABLE_COLOR_FILTER=true
      ;;
        commands-graphics-layer-unsupported-child-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHILD_UNSUPPORTED=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-graphics-layer-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-raw-image-filter-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_IMAGE_FILTER_EFFECT=true
      ;;
    commands-graphics-layer-offset-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-offset-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-offset-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-chained-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-graphics-layer-chained-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-forced-context-graphics-layer-chained-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-graphics-layer-render-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-render-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-render-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-render-effect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-render-effect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-render-effect-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-render-effect-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-graphics-layer-render-effect-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-forced-context-graphics-layer-render-effect-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-graphics-layer-render-effect-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-render-effect-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-render-effect-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-graphics-layer-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-forced-context-graphics-layer-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-graphics-layer-offset-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-resize-graphics-layer-offset-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-forced-context-graphics-layer-offset-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=4
      ;;
    commands-graphics-layer-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=3
      ;;
    commands-resize-graphics-layer-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=6
      ;;
    commands-forced-context-graphics-layer-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=6
      ;;
    commands-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
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
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=3
      ;;
    commands-resize-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=6
      ;;
    commands-forced-context-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=6 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=6
      ;;
    commands-graphics-layer-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-resize-graphics-layer-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
        commands-graphics-layer-invalid-shadow-elevation-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SHADOW_ELEVATION=true
          ;;
        commands-graphics-layer-invalid-shadow-path-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_SHADOW_PATH=true \
            EXPECT_SCREENSHOT_ASSERTION=false
          ;;
    commands-graphics-layer-round-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-resize-graphics-layer-round-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-round-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-path-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-resize-graphics-layer-path-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-path-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-rotationx)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true
      ;;
    commands-resize-graphics-layer-rotationx)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-rotationx)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-rotationy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true
      ;;
    commands-resize-graphics-layer-rotationy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-rotationy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-rotationxy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true
      ;;
    commands-resize-graphics-layer-rotationxy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-rotationxy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-scale-translate)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SCALE_TRANSLATE=true
      ;;
    commands-resize-graphics-layer-scale-translate)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SCALE_TRANSLATE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-scale-translate)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SCALE_TRANSLATE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-near-camera)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true
      ;;
    commands-resize-graphics-layer-near-camera)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-near-camera)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
        commands-graphics-layer-invalid-camera-distance-fallback)
          run_case "$1" \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
            MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_INVALID_CAMERA_DISTANCE=true
          ;;
    commands-graphics-layer-offcenter-pivot)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true
      ;;
    commands-resize-graphics-layer-offcenter-pivot)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-offcenter-pivot)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true
      ;;
    commands-resize-graphics-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-graphics-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-graphics-layer-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-graphics-layer-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-graphics-layer-blend-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-save-layer-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-resize-save-layer-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-save-layer-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-save-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-resize-save-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-forced-context-save-layer-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-save-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-resize-save-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-save-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-save-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_COLOR_FILTER=true \
        EXPECT_SCREENSHOT_ASSERTION=false
      ;;
    commands-resize-save-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_COLOR_FILTER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-forced-context-save-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_COLOR_FILTER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_SCREENSHOT_ASSERTION=false \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1
      ;;
    commands-invalid-save-layer-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-ref-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_REF_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_REF_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-image-filter-ref-record-flags-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_IMAGE_FILTER_REF_RECORD_FLAGS=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_IMAGE_FILTER_REF_RECORD_FLAGS_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-ref-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_REF_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_REF_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-image-filter-ref-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_IMAGE_FILTER_REF_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_IMAGE_FILTER_REF_RECORD_LENGTH_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-image-filter-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-image-filter-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_IMAGE_FILTER_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_IMAGE_FILTER_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-image-filter-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_IMAGE_FILTER_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_IMAGE_FILTER_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_REF_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_REF_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_REF_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_ALPHA_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_BLEND_MODE_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-width-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_WIDTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_WIDTH_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-ref-height-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_REF_HEIGHT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_REF_HEIGHT_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_COLOR_FILTER_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_COLOR_FILTER_BLEND_MODE_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_MODE_CORRUPTED
      ;;
    commands-invalid-save-layer-blend-color-filter-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_BLEND_COLOR_FILTER_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_BLEND_COLOR_FILTER_BLEND_MODE_CORRUPTED
      ;;
    commands-invalid-save-layer-color-filter-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=52"
      ;;
    commands-invalid-save-layer-blend-color-filter-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=54"
      ;;
    commands-invalid-save-layer-image-filter-use-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_CORRUPTED op=55"
      ;;
    commands-invalid-save-layer-color-filter-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=52"
      ;;
    commands-invalid-save-layer-blend-color-filter-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=54"
      ;;
    commands-invalid-save-layer-image-filter-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=55"
      ;;
    commands-save-layer-raw-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_RAW_COLOR_FILTER=true
      ;;
    commands-save-layer-raw-table-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_RAW_TABLE_COLOR_FILTER=true
      ;;
    commands-opaque-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_OPAQUE_SHADER=true
      ;;
    commands-descriptor-stroke-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_DESCRIPTOR_STROKE_SHADER=true
      ;;
    commands-raw-image-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_IMAGE_SHADER=true
      ;;
    commands-composite-opaque-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_OPAQUE_SHADER=true
      ;;
    commands-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-resize-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-forced-context-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-resize-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-forced-context-turbulence-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TURBULENCE_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-raw-noise-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_NOISE_SHADER=true
      ;;
    commands-raw-linear-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_LINEAR_GRADIENT_SHADER=true
      ;;
    commands-raw-radial-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RADIAL_GRADIENT_SHADER=true
      ;;
    commands-raw-sweep-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_SWEEP_GRADIENT_SHADER=true
      ;;
    commands-raw-conical-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_CONICAL_GRADIENT_SHADER=true
      ;;
    commands-raw-turbulence-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_TURBULENCE_SHADER=true
      ;;
    commands-picture-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PICTURE_SHADER=true
      ;;
    commands-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
      ;;
    commands-resize-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_SURFACE_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
    commands-forced-context-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=6
      ;;
	    commands-invalid-gradient-fallback)
	      run_case "$1" \
	        MAGIC_JEWEL_INVALID_SWEEP_GRADIENT=true \
	        EXPECT_SCREENSHOT_ASSERTION=false
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
