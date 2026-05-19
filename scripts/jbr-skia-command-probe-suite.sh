#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
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
CASES="${CASES:-commands-live-animation commands-native-bridge-load-library commands-core-primitives commands-point-lines commands-point-dots commands-concat-transform commands-skew-transform commands-gradient-surfaces commands-gradient-paths commands-popup commands-popup-window commands-menu commands-text-image commands-native-custom-font-text-image commands-native-generic-font-text commands-native-loaded-font-data-text commands-native-resource-font-text commands-native-system-font-text commands-resize-native-generic-font-text commands-resize-native-loaded-font-data-text commands-resize-native-resource-font-text commands-resize-native-system-font-text commands-forced-context-native-custom-font-text-image commands-forced-context-native-generic-font-text commands-forced-context-native-loaded-font-data-text commands-forced-context-native-resource-font-text commands-forced-context-native-system-font-text commands-forced-context-dynamic-images commands-image-path-effect-fallback commands-image-shader commands-raw-image-shader-fallback commands-color-shader commands-descriptor-stroke-shader-fallback commands-gradient-shaders commands-noise-shader commands-turbulence-shader commands-raw-linear-gradient-shader-fallback commands-raw-radial-gradient-shader-fallback commands-raw-sweep-gradient-shader-fallback commands-raw-noise-shader-fallback commands-raw-turbulence-shader-fallback commands-image-shader-color-filter commands-composite-shader commands-composite-noise-shader commands-composite-shader-color-filter commands-transformed-shader commands-runtime-effect-shader commands-raw-runtime-effect-shader-fallback commands-runtime-effect-shader-color-filter commands-linear-gradient-shader-color-filter commands-runtime-effect-pure-color commands-runtime-effect-uniform-only commands-runtime-effect-child-only commands-runtime-effect-shader-source-cache-eviction commands-runtime-effect-invalid-uniform-schema-fallback commands-runtime-effect-invalid-child-schema-fallback commands-runtime-effect-invalid-nested-child-fallback commands-runtime-effect-color-filter commands-runtime-effect-stable-color-filter commands-resize-runtime-effect-stable-color-filter commands-forced-context-runtime-effect-stable-color-filter commands-raw-runtime-effect-color-filter-fallback commands-runtime-effect-color-filter-child commands-runtime-effect-source-cache-eviction commands-runtime-effect-color-filter-invalid-uniform-schema-fallback commands-runtime-effect-color-filter-invalid-child-schema-fallback commands-runtime-effect-color-filter-invalid-nested-child-fallback commands-runtime-effect-color-filter-compile-fallback commands-runtime-effect-color-filter-build-fallback commands-runtime-effect-color-filter-child-type-fallback commands-runtime-effect-compile-fallback commands-runtime-effect-build-fallback commands-runtime-effect-child-type-fallback commands-invalid-descriptor-use-fallback commands-invalid-shader-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback commands-invalid-path-effect-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-missing-fallback commands-offset-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback commands-shader-color-filter-effect-child-missing-fallback commands-invalid-shader-descriptor-type-fallback commands-invalid-descriptor-version-fallback commands-shader-wrong-effect-type-fallback commands-transformed-shader-child-wrong-effect-type-fallback commands-composite-shader-child-wrong-effect-type-fallback commands-composite-shader-src-child-wrong-effect-type-fallback commands-runtime-effect-shader-child-wrong-effect-type-fallback commands-transformed-shader-child-missing-fallback commands-composite-shader-child-missing-fallback commands-composite-shader-src-child-missing-fallback commands-shader-color-filter-shader-child-missing-fallback commands-color-filter-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-wrong-effect-type-fallback commands-color-filter-path-effect-wrong-type-fallback commands-shader-color-filter-wrong-effect-type-fallback commands-image-filter-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback commands-chain-path-effect-child-wrong-effect-type-fallback commands-gradient-stroke commands-image-filter commands-image-color-matrix-filter commands-raw-blend-color-filter-fallback commands-color-filter commands-color-filter-handle commands-color-matrix-filter commands-lighting-filter commands-descriptor-eviction commands-resize-descriptor-redefine commands-forced-context-descriptor-redefine commands-resize-shader-descriptor-redefine commands-forced-context-shader-descriptor-redefine commands-resize-color-shader-descriptor-redefine commands-forced-context-color-shader-descriptor-redefine commands-resize-noise-shader-descriptor-redefine commands-forced-context-noise-shader-descriptor-redefine commands-resize-turbulence-shader-descriptor-redefine commands-forced-context-turbulence-shader-descriptor-redefine commands-resize-composite-noise-shader-descriptor-redefine commands-forced-context-composite-noise-shader-descriptor-redefine commands-path-effect commands-path-effect-color-filter-fallback commands-raw-discrete-path-effect-fallback commands-vertices commands-blend-mode commands-graphics-layer commands-graphics-layer-modulate-alpha commands-graphics-layer-offscreen commands-graphics-layer-clip commands-graphics-layer-round-clip commands-graphics-layer-path-clip commands-graphics-layer-blend-mode commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-resize-graphics-layer-color-matrix-filter commands-forced-context-graphics-layer-color-matrix-filter commands-graphics-layer-raw-color-filter-fallback commands-graphics-layer-render-effect commands-resize-graphics-layer-render-effect commands-forced-context-graphics-layer-render-effect commands-graphics-layer-raw-image-filter-effect-fallback commands-graphics-layer-offset-effect commands-graphics-layer-chained-render-effect commands-graphics-layer-render-effect-color-filter commands-graphics-layer-render-effect-blend-mode commands-graphics-layer-render-effect-color-matrix-filter commands-graphics-layer-render-effect-blend-color-filter commands-graphics-layer-render-effect-blend-color-matrix-filter commands-graphics-layer-offset-effect-blend-color-matrix-filter commands-graphics-layer-chained-render-effect-blend-color-matrix-filter commands-graphics-layer-near-camera-chained-render-effect-blend-color-matrix-filter commands-graphics-layer-shadow commands-graphics-layer-round-shadow commands-graphics-layer-path-shadow commands-graphics-layer-rotationx commands-graphics-layer-rotationy commands-graphics-layer-rotationxy commands-graphics-layer-scale-translate commands-graphics-layer-near-camera commands-graphics-layer-offcenter-pivot commands-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter commands-save-layer-filter commands-save-layer-raw-color-filter-fallback commands-opaque-shader-fallback commands-composite-opaque-shader-fallback commands-picture-shader-fallback commands-invalid-gradient-fallback}"
list_case_groups() {
  printf "%s\n" \
    smoke \
    path-invalid \
    effect-descriptor-invalid \
    shader-descriptor-invalid \
    gradient-invalid \
    gradient-path-invalid \
    runtime-effect-invalid \
    descriptor-handles-invalid \
    image-handles-invalid \
    save-layer-invalid \
    color-filters \
    native-text \
    native-text-invalid \
    graphics-layer
}

if [[ "${LIST_CASE_GROUPS}" == "true" ]]; then
  list_case_groups
  exit 0
fi

case_group_cases() {
  case "$1" in
    smoke)
      echo "commands-live-animation commands-core-primitives commands-color-shader commands-color-filter-handle commands-color-matrix-filter commands-graphics-layer"
      ;;
    path-invalid)
      echo "commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback commands-invalid-draw-path-path-effect-verb-fallback commands-invalid-stroke-path-dash-path-effect-verb-fallback commands-invalid-draw-shadow-path-verb-fallback"
      ;;
    effect-descriptor-invalid)
      echo "commands-invalid-effect-descriptor-type-fallback commands-invalid-effect-descriptor-version-fallback commands-invalid-effect-descriptor-payload-count-fallback commands-invalid-effect-descriptor-record-length-fallback commands-invalid-lighting-filter-descriptor-payload-count-fallback commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-sigma-fallback commands-invalid-blur-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-corner-path-effect-descriptor-negative-radius-fallback commands-invalid-stamped-path-effect-descriptor-advance-fallback commands-invalid-stamped-path-effect-descriptor-zero-advance-fallback commands-invalid-stamped-path-effect-descriptor-phase-fallback commands-invalid-stamped-path-effect-descriptor-negative-phase-fallback commands-invalid-stamped-path-effect-descriptor-style-fallback commands-invalid-stamped-path-effect-descriptor-fill-type-fallback commands-invalid-stamped-path-effect-descriptor-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-negative-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-path-verb-fallback commands-invalid-chain-path-effect-descriptor-payload-count-fallback"
      ;;
    shader-descriptor-invalid)
      echo "commands-invalid-shader-descriptor-type-fallback commands-invalid-shader-descriptor-payload-count-fallback commands-invalid-color-shader-descriptor-payload-count-fallback commands-invalid-shader-color-filter-descriptor-payload-count-fallback commands-invalid-shader-descriptor-record-length-fallback commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-composite-shader-descriptor-blend-mode-fallback commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback commands-invalid-radial-gradient-shader-descriptor-radius-fallback commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback commands-invalid-image-shader-descriptor-width-fallback commands-invalid-image-shader-descriptor-max-width-fallback commands-invalid-image-shader-descriptor-height-fallback commands-invalid-image-shader-descriptor-max-height-fallback commands-invalid-image-shader-descriptor-tile-mode-x-fallback commands-invalid-image-shader-descriptor-tile-mode-y-fallback commands-invalid-perlin-noise-shader-kind-fallback commands-invalid-perlin-noise-shader-frequency-fallback commands-invalid-perlin-noise-shader-octaves-fallback commands-invalid-perlin-noise-shader-zero-octaves-fallback commands-invalid-perlin-noise-shader-tile-size-fallback commands-invalid-perlin-noise-shader-tile-height-fallback commands-invalid-perlin-noise-shader-negative-tile-size-fallback commands-invalid-perlin-noise-shader-negative-tile-height-fallback commands-invalid-descriptor-version-fallback"
      ;;
    gradient-invalid)
      echo "commands-invalid-linear-gradient-stroke-width-fallback commands-invalid-linear-gradient-round-rect-stroke-width-fallback commands-invalid-radial-gradient-stroke-width-fallback commands-invalid-radial-gradient-round-rect-stroke-width-fallback commands-invalid-sweep-gradient-stroke-width-fallback commands-invalid-sweep-gradient-round-rect-stroke-width-fallback commands-invalid-linear-gradient-tile-mode-fallback commands-invalid-linear-gradient-round-rect-tile-mode-fallback commands-invalid-linear-gradient-stroke-tile-mode-fallback commands-invalid-linear-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-linear-gradient-color-count-fallback commands-invalid-linear-gradient-round-rect-color-count-fallback commands-invalid-linear-gradient-stroke-color-count-fallback commands-invalid-linear-gradient-round-rect-stroke-color-count-fallback commands-invalid-linear-gradient-stop-order-fallback commands-invalid-linear-gradient-round-rect-stop-order-fallback commands-invalid-linear-gradient-stroke-stop-order-fallback commands-invalid-linear-gradient-round-rect-stroke-stop-order-fallback commands-invalid-linear-gradient-path-tile-mode-fallback commands-invalid-linear-gradient-path-color-count-fallback commands-invalid-linear-gradient-path-stop-order-fallback commands-invalid-linear-gradient-path-fill-type-fallback commands-invalid-linear-gradient-path-data-length-fallback commands-invalid-linear-gradient-path-verb-fallback commands-invalid-radial-gradient-path-radius-fallback commands-invalid-radial-gradient-path-tile-mode-fallback commands-invalid-radial-gradient-path-color-count-fallback commands-invalid-radial-gradient-path-stop-order-fallback commands-invalid-radial-gradient-path-fill-type-fallback commands-invalid-radial-gradient-path-data-length-fallback commands-invalid-radial-gradient-path-verb-fallback commands-invalid-sweep-gradient-path-color-count-fallback commands-invalid-sweep-gradient-path-stop-order-fallback commands-invalid-sweep-gradient-path-fill-type-fallback commands-invalid-sweep-gradient-path-data-length-fallback commands-invalid-sweep-gradient-path-verb-fallback commands-invalid-sweep-gradient-color-count-fallback commands-invalid-sweep-gradient-round-rect-color-count-fallback commands-invalid-sweep-gradient-stroke-color-count-fallback commands-invalid-sweep-gradient-round-rect-stroke-color-count-fallback commands-invalid-sweep-gradient-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stop-order-fallback commands-invalid-sweep-gradient-stroke-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stroke-stop-order-fallback commands-invalid-radial-gradient-radius-fallback commands-invalid-radial-gradient-round-rect-radius-fallback commands-invalid-radial-gradient-stroke-radius-fallback commands-invalid-radial-gradient-round-rect-stroke-radius-fallback commands-invalid-radial-gradient-tile-mode-fallback commands-invalid-radial-gradient-round-rect-tile-mode-fallback commands-invalid-radial-gradient-stroke-tile-mode-fallback commands-invalid-radial-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-radial-gradient-color-count-fallback commands-invalid-radial-gradient-round-rect-color-count-fallback commands-invalid-radial-gradient-stroke-color-count-fallback commands-invalid-radial-gradient-round-rect-stroke-color-count-fallback commands-invalid-radial-gradient-stop-order-fallback commands-invalid-radial-gradient-round-rect-stop-order-fallback commands-invalid-radial-gradient-stroke-stop-order-fallback commands-invalid-radial-gradient-round-rect-stroke-stop-order-fallback"
      ;;
    gradient-path-invalid)
      echo "commands-invalid-linear-gradient-path-tile-mode-fallback commands-invalid-linear-gradient-path-color-count-fallback commands-invalid-linear-gradient-path-stop-order-fallback commands-invalid-linear-gradient-path-fill-type-fallback commands-invalid-linear-gradient-path-data-length-fallback commands-invalid-linear-gradient-path-verb-fallback commands-invalid-radial-gradient-path-radius-fallback commands-invalid-radial-gradient-path-tile-mode-fallback commands-invalid-radial-gradient-path-color-count-fallback commands-invalid-radial-gradient-path-stop-order-fallback commands-invalid-radial-gradient-path-fill-type-fallback commands-invalid-radial-gradient-path-data-length-fallback commands-invalid-radial-gradient-path-verb-fallback commands-invalid-sweep-gradient-path-color-count-fallback commands-invalid-sweep-gradient-path-stop-order-fallback commands-invalid-sweep-gradient-path-fill-type-fallback commands-invalid-sweep-gradient-path-data-length-fallback commands-invalid-sweep-gradient-path-verb-fallback"
      ;;
    runtime-effect-invalid)
      echo "commands-runtime-effect-shader-source-hash-fallback commands-runtime-effect-shader-source-code-fallback commands-runtime-effect-shader-sksl-length-fallback commands-runtime-effect-shader-uniform-float-count-fallback commands-runtime-effect-shader-negative-uniform-float-count-fallback commands-runtime-effect-shader-child-count-fallback commands-runtime-effect-shader-negative-child-count-fallback commands-runtime-effect-shader-named-uniform-count-fallback commands-runtime-effect-shader-negative-named-uniform-count-fallback commands-runtime-effect-shader-named-child-count-fallback commands-runtime-effect-shader-negative-named-child-count-fallback commands-runtime-effect-shader-uniform-name-fallback commands-runtime-effect-shader-uniform-schema-float-count-fallback commands-runtime-effect-shader-uniform-schema-float-offset-fallback commands-runtime-effect-shader-uniform-schema-float-range-fallback commands-runtime-effect-shader-uniform-schema-name-length-fallback commands-runtime-effect-shader-uniform-schema-max-name-length-fallback commands-runtime-effect-shader-uniform-schema-name-range-fallback commands-runtime-effect-shader-child-name-fallback commands-runtime-effect-shader-child-schema-name-length-fallback commands-runtime-effect-shader-child-schema-max-name-length-fallback commands-runtime-effect-shader-child-schema-name-range-fallback commands-runtime-effect-shader-child-index-fallback commands-runtime-effect-shader-negative-child-index-fallback commands-runtime-effect-shader-duplicate-child-index-fallback commands-runtime-effect-color-filter-source-hash-fallback commands-runtime-effect-color-filter-source-code-fallback commands-runtime-effect-color-filter-sksl-length-fallback commands-runtime-effect-color-filter-uniform-float-count-fallback commands-runtime-effect-color-filter-negative-uniform-float-count-fallback commands-runtime-effect-color-filter-child-count-fallback commands-runtime-effect-color-filter-negative-child-count-fallback commands-runtime-effect-color-filter-named-uniform-count-fallback commands-runtime-effect-color-filter-negative-named-uniform-count-fallback commands-runtime-effect-color-filter-named-child-count-fallback commands-runtime-effect-color-filter-negative-named-child-count-fallback commands-runtime-effect-color-filter-uniform-name-fallback commands-runtime-effect-color-filter-uniform-schema-float-count-fallback commands-runtime-effect-color-filter-uniform-schema-float-offset-fallback commands-runtime-effect-color-filter-uniform-schema-float-range-fallback commands-runtime-effect-color-filter-uniform-schema-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-max-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-name-range-fallback commands-runtime-effect-color-filter-child-name-fallback commands-runtime-effect-color-filter-child-schema-name-length-fallback commands-runtime-effect-color-filter-child-schema-max-name-length-fallback commands-runtime-effect-color-filter-child-schema-name-range-fallback commands-runtime-effect-color-filter-child-index-fallback commands-runtime-effect-color-filter-negative-child-index-fallback commands-runtime-effect-color-filter-duplicate-child-index-fallback commands-runtime-effect-invalid-uniform-schema-fallback commands-runtime-effect-invalid-child-schema-fallback commands-runtime-effect-invalid-nested-child-fallback commands-runtime-effect-color-filter-invalid-uniform-schema-fallback commands-runtime-effect-color-filter-invalid-child-schema-fallback commands-runtime-effect-color-filter-invalid-nested-child-fallback commands-runtime-effect-color-filter-compile-fallback commands-runtime-effect-color-filter-build-fallback commands-runtime-effect-color-filter-child-type-fallback commands-runtime-effect-compile-fallback commands-runtime-effect-build-fallback commands-runtime-effect-child-type-fallback"
      ;;
    descriptor-handles-invalid)
      echo "commands-invalid-descriptor-use-fallback commands-invalid-shader-descriptor-use-fallback commands-invalid-path-effect-descriptor-use-fallback commands-invalid-save-layer-color-filter-use-fallback commands-invalid-save-layer-blend-color-filter-use-fallback commands-invalid-save-layer-image-filter-use-fallback commands-invalid-descriptor-use-after-evict-fallback commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-path-effect-descriptor-use-after-evict-fallback commands-invalid-save-layer-color-filter-use-after-evict-fallback commands-invalid-save-layer-blend-color-filter-use-after-evict-fallback commands-invalid-save-layer-image-filter-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback commands-composite-shader-child-use-after-evict-fallback commands-composite-shader-src-child-use-after-evict-fallback commands-shader-color-filter-shader-child-use-after-evict-fallback commands-runtime-effect-shader-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-use-after-evict-fallback commands-shader-color-filter-effect-child-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback commands-invalid-blur-effect-child-use-after-evict-fallback commands-invalid-path-effect-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-missing-fallback commands-blur-image-filter-child-missing-fallback commands-offset-image-filter-child-missing-fallback commands-chain-path-effect-child-missing-fallback commands-shader-color-filter-effect-child-missing-fallback commands-shader-wrong-effect-type-fallback commands-transformed-shader-child-wrong-effect-type-fallback commands-composite-shader-child-wrong-effect-type-fallback commands-composite-shader-src-child-wrong-effect-type-fallback commands-runtime-effect-shader-child-wrong-effect-type-fallback commands-transformed-shader-child-missing-fallback commands-composite-shader-child-missing-fallback commands-composite-shader-src-child-missing-fallback commands-shader-color-filter-shader-child-missing-fallback commands-color-filter-wrong-effect-type-fallback commands-runtime-effect-color-filter-child-wrong-effect-type-fallback commands-color-filter-path-effect-wrong-type-fallback commands-shader-color-filter-wrong-effect-type-fallback commands-image-filter-wrong-effect-type-fallback commands-path-effect-wrong-effect-type-fallback commands-blur-image-filter-child-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback commands-chain-path-effect-child-wrong-effect-type-fallback"
      ;;
    image-handles-invalid)
      echo "commands-invalid-image-define-pixel-count-fallback commands-invalid-image-use-fallback commands-invalid-image-use-after-evict-fallback commands-invalid-image-ref-width-fallback commands-invalid-image-ref-height-fallback commands-invalid-image-ref-alpha-fallback commands-invalid-image-ref-filter-quality-fallback commands-invalid-image-color-filter-use-fallback commands-invalid-image-color-filter-use-after-evict-fallback commands-invalid-image-color-filter-ref-width-fallback commands-invalid-image-color-filter-ref-height-fallback commands-invalid-image-color-filter-ref-alpha-fallback commands-invalid-image-color-filter-ref-filter-quality-fallback commands-invalid-image-color-filter-blend-mode-fallback commands-invalid-image-color-filter-ref-use-fallback commands-invalid-image-color-filter-ref-use-after-evict-fallback commands-invalid-image-color-filter-descriptor-ref-width-fallback commands-invalid-image-color-filter-descriptor-ref-height-fallback commands-invalid-image-color-filter-descriptor-ref-alpha-fallback commands-invalid-image-color-filter-descriptor-ref-filter-quality-fallback"
      ;;
    save-layer-invalid)
      echo "commands-invalid-save-layer-alpha-fallback commands-invalid-save-layer-color-filter-blend-mode-fallback commands-invalid-save-layer-blend-mode-fallback commands-invalid-save-layer-blend-color-filter-blend-mode-fallback commands-invalid-save-layer-image-filter-alpha-fallback"
      ;;
    color-filters)
      echo "commands-image-color-matrix-filter commands-raw-blend-color-filter-fallback commands-color-filter commands-color-filter-handle commands-color-matrix-filter commands-lighting-filter commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-graphics-layer-blend-color-filter commands-graphics-layer-blend-color-matrix-filter"
      ;;
    native-text)
      echo "commands-native-custom-font-text-image commands-native-generic-font-text commands-native-loaded-font-data-text commands-native-resource-font-text commands-native-system-font-text commands-resize-native-generic-font-text commands-resize-native-loaded-font-data-text commands-resize-native-resource-font-text commands-resize-native-system-font-text commands-forced-context-native-custom-font-text-image commands-forced-context-native-generic-font-text commands-forced-context-native-loaded-font-data-text commands-forced-context-native-resource-font-text commands-forced-context-native-system-font-text"
      ;;
    native-text-invalid)
      echo "commands-invalid-text-font-size-fallback commands-invalid-text-font-weight-fallback commands-invalid-text-font-width-fallback commands-invalid-text-font-slant-fallback commands-invalid-text-font-family-count-fallback commands-invalid-paragraph-font-size-fallback commands-invalid-paragraph-font-weight-fallback commands-invalid-paragraph-font-width-fallback commands-invalid-paragraph-font-slant-fallback commands-invalid-paragraph-font-family-count-fallback"
      ;;
    graphics-layer)
      echo "commands-graphics-layer commands-graphics-layer-modulate-alpha commands-graphics-layer-offscreen commands-graphics-layer-clip commands-graphics-layer-round-clip commands-graphics-layer-path-clip commands-graphics-layer-blend-mode commands-graphics-layer-color-filter commands-graphics-layer-color-matrix-filter commands-graphics-layer-render-effect commands-graphics-layer-offset-effect commands-graphics-layer-chained-render-effect commands-graphics-layer-shadow commands-graphics-layer-round-shadow commands-graphics-layer-path-shadow commands-graphics-layer-rotationx commands-graphics-layer-rotationy commands-graphics-layer-rotationxy commands-graphics-layer-scale-translate commands-graphics-layer-near-camera commands-graphics-layer-offcenter-pivot"
      ;;
    *)
      echo "Unknown CASE_GROUPS entry: $1" >&2
      exit 2
      ;;
  esac
}
if [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  CASES=""
  for group in ${CASE_GROUPS}; do
    CASES="${CASES} $(case_group_cases "${group}")"
  done
  CASES="${CASES# }"
fi
if [[ -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" ]]; then
  CASES="${CASES/commands-core-primitives commands-point-lines/commands-core-primitives commands-invalid-image-define-pixel-count-fallback commands-invalid-image-use-fallback commands-invalid-image-use-after-evict-fallback commands-invalid-image-ref-width-fallback commands-invalid-image-ref-height-fallback commands-invalid-image-ref-alpha-fallback commands-invalid-image-ref-filter-quality-fallback commands-invalid-clip-path-verb-fallback commands-invalid-draw-path-verb-fallback commands-invalid-draw-path-path-effect-verb-fallback commands-invalid-stroke-path-dash-path-effect-verb-fallback commands-invalid-draw-shadow-path-verb-fallback commands-point-lines}"
  CASES="${CASES/commands-native-generic-font-text commands-native-loaded-font-data-text/commands-native-generic-font-text commands-invalid-text-font-size-fallback commands-invalid-text-font-weight-fallback commands-invalid-text-font-width-fallback commands-invalid-text-font-slant-fallback commands-invalid-text-font-family-count-fallback commands-invalid-paragraph-font-size-fallback commands-invalid-paragraph-font-weight-fallback commands-invalid-paragraph-font-width-fallback commands-invalid-paragraph-font-slant-fallback commands-invalid-paragraph-font-family-count-fallback commands-native-loaded-font-data-text}"
  CASES="${CASES/commands-gradient-stroke commands-image-filter/commands-gradient-stroke commands-invalid-linear-gradient-stroke-width-fallback commands-invalid-linear-gradient-round-rect-stroke-width-fallback commands-invalid-radial-gradient-stroke-width-fallback commands-invalid-radial-gradient-round-rect-stroke-width-fallback commands-invalid-sweep-gradient-stroke-width-fallback commands-invalid-sweep-gradient-round-rect-stroke-width-fallback commands-invalid-linear-gradient-tile-mode-fallback commands-invalid-linear-gradient-round-rect-tile-mode-fallback commands-invalid-linear-gradient-stroke-tile-mode-fallback commands-invalid-linear-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-linear-gradient-color-count-fallback commands-invalid-linear-gradient-round-rect-color-count-fallback commands-invalid-linear-gradient-stroke-color-count-fallback commands-invalid-linear-gradient-round-rect-stroke-color-count-fallback commands-invalid-linear-gradient-stop-order-fallback commands-invalid-linear-gradient-round-rect-stop-order-fallback commands-invalid-linear-gradient-stroke-stop-order-fallback commands-invalid-linear-gradient-round-rect-stroke-stop-order-fallback commands-invalid-linear-gradient-path-tile-mode-fallback commands-invalid-linear-gradient-path-color-count-fallback commands-invalid-linear-gradient-path-stop-order-fallback commands-invalid-linear-gradient-path-fill-type-fallback commands-invalid-linear-gradient-path-data-length-fallback commands-invalid-linear-gradient-path-verb-fallback commands-invalid-radial-gradient-path-radius-fallback commands-invalid-radial-gradient-path-tile-mode-fallback commands-invalid-radial-gradient-path-color-count-fallback commands-invalid-radial-gradient-path-stop-order-fallback commands-invalid-radial-gradient-path-fill-type-fallback commands-invalid-radial-gradient-path-data-length-fallback commands-invalid-radial-gradient-path-verb-fallback commands-invalid-sweep-gradient-path-color-count-fallback commands-invalid-sweep-gradient-path-stop-order-fallback commands-invalid-sweep-gradient-path-fill-type-fallback commands-invalid-sweep-gradient-path-data-length-fallback commands-invalid-sweep-gradient-path-verb-fallback commands-invalid-sweep-gradient-color-count-fallback commands-invalid-sweep-gradient-round-rect-color-count-fallback commands-invalid-sweep-gradient-stroke-color-count-fallback commands-invalid-sweep-gradient-round-rect-stroke-color-count-fallback commands-invalid-sweep-gradient-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stop-order-fallback commands-invalid-sweep-gradient-stroke-stop-order-fallback commands-invalid-sweep-gradient-round-rect-stroke-stop-order-fallback commands-invalid-radial-gradient-radius-fallback commands-invalid-radial-gradient-round-rect-radius-fallback commands-invalid-radial-gradient-stroke-radius-fallback commands-invalid-radial-gradient-round-rect-stroke-radius-fallback commands-invalid-radial-gradient-tile-mode-fallback commands-invalid-radial-gradient-round-rect-tile-mode-fallback commands-invalid-radial-gradient-stroke-tile-mode-fallback commands-invalid-radial-gradient-round-rect-stroke-tile-mode-fallback commands-invalid-radial-gradient-color-count-fallback commands-invalid-radial-gradient-round-rect-color-count-fallback commands-invalid-radial-gradient-stroke-color-count-fallback commands-invalid-radial-gradient-round-rect-stroke-color-count-fallback commands-invalid-radial-gradient-stop-order-fallback commands-invalid-radial-gradient-round-rect-stop-order-fallback commands-invalid-radial-gradient-stroke-stop-order-fallback commands-invalid-radial-gradient-round-rect-stroke-stop-order-fallback commands-image-filter}"
  CASES="${CASES/commands-image-filter commands-image-color-matrix-filter/commands-image-filter commands-invalid-image-color-filter-use-fallback commands-invalid-image-color-filter-use-after-evict-fallback commands-invalid-image-color-filter-ref-width-fallback commands-invalid-image-color-filter-ref-height-fallback commands-invalid-image-color-filter-ref-alpha-fallback commands-invalid-image-color-filter-ref-filter-quality-fallback commands-invalid-image-color-filter-blend-mode-fallback commands-invalid-image-color-filter-ref-use-fallback commands-invalid-image-color-filter-ref-use-after-evict-fallback commands-invalid-image-color-filter-descriptor-ref-width-fallback commands-invalid-image-color-filter-descriptor-ref-height-fallback commands-invalid-image-color-filter-descriptor-ref-alpha-fallback commands-invalid-image-color-filter-descriptor-ref-filter-quality-fallback commands-image-color-matrix-filter}"
  CASES="${CASES/commands-save-layer-filter commands-save-layer-raw-color-filter-fallback/commands-save-layer-filter commands-save-layer-blend-mode commands-invalid-save-layer-alpha-fallback commands-invalid-save-layer-color-filter-blend-mode-fallback commands-invalid-save-layer-blend-mode-fallback commands-invalid-save-layer-blend-color-filter-blend-mode-fallback commands-invalid-save-layer-image-filter-alpha-fallback commands-save-layer-raw-color-filter-fallback}"
  CASES="${CASES/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-save-layer-color-filter-use-fallback commands-invalid-save-layer-blend-color-filter-use-fallback commands-invalid-save-layer-image-filter-use-fallback commands-invalid-save-layer-color-filter-use-after-evict-fallback commands-invalid-save-layer-blend-color-filter-use-after-evict-fallback commands-invalid-save-layer-image-filter-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback}"
  CASES="${CASES/commands-shader-color-filter-effect-child-missing-fallback commands-invalid-shader-descriptor-type-fallback/commands-shader-color-filter-effect-child-missing-fallback commands-invalid-effect-descriptor-type-fallback commands-invalid-effect-descriptor-version-fallback commands-invalid-effect-descriptor-payload-count-fallback commands-invalid-effect-descriptor-record-length-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-effect-descriptor-record-length-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-effect-descriptor-record-length-fallback commands-invalid-lighting-filter-descriptor-payload-count-fallback commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-tint-color-filter-descriptor-blend-mode-fallback commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-color-matrix-filter-descriptor-payload-fallback commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-blur-image-filter-descriptor-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-sigma-fallback commands-invalid-blur-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-with-input-image-filter-descriptor-negative-sigma-fallback commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-blur-image-filter-descriptor-tile-mode-fallback commands-invalid-blur-with-input-image-filter-descriptor-tile-mode-fallback commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-offset-with-input-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-offset-image-filter-descriptor-delta-fallback commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-shader-descriptor-type-fallback/commands-invalid-corner-path-effect-descriptor-radius-fallback commands-invalid-corner-path-effect-descriptor-negative-radius-fallback commands-invalid-stamped-path-effect-descriptor-advance-fallback commands-invalid-stamped-path-effect-descriptor-zero-advance-fallback commands-invalid-stamped-path-effect-descriptor-phase-fallback commands-invalid-stamped-path-effect-descriptor-negative-phase-fallback commands-invalid-stamped-path-effect-descriptor-style-fallback commands-invalid-stamped-path-effect-descriptor-fill-type-fallback commands-invalid-stamped-path-effect-descriptor-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-negative-path-data-length-fallback commands-invalid-stamped-path-effect-descriptor-path-verb-fallback commands-invalid-chain-path-effect-descriptor-payload-count-fallback commands-invalid-shader-descriptor-type-fallback}"
  CASES="${CASES/commands-invalid-shader-descriptor-type-fallback commands-invalid-descriptor-version-fallback/commands-invalid-shader-descriptor-type-fallback commands-invalid-shader-descriptor-payload-count-fallback commands-invalid-color-shader-descriptor-payload-count-fallback commands-invalid-shader-color-filter-descriptor-payload-count-fallback commands-invalid-shader-descriptor-record-length-fallback commands-invalid-descriptor-version-fallback}"
  CASES="${CASES/commands-invalid-shader-descriptor-record-length-fallback commands-invalid-descriptor-version-fallback/commands-invalid-shader-descriptor-record-length-fallback commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-descriptor-version-fallback}"
  CASES="${CASES/commands-invalid-shader-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback/commands-invalid-shader-descriptor-use-fallback commands-invalid-path-effect-descriptor-use-fallback commands-invalid-descriptor-use-after-evict-fallback}"
  CASES="${CASES/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-path-effect-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback}"
  CASES="${CASES/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback/commands-invalid-color-filter-descriptor-use-after-evict-fallback commands-transformed-shader-child-use-after-evict-fallback commands-composite-shader-child-use-after-evict-fallback commands-composite-shader-src-child-use-after-evict-fallback commands-shader-color-filter-shader-child-use-after-evict-fallback commands-runtime-effect-shader-child-use-after-evict-fallback commands-runtime-effect-color-filter-child-use-after-evict-fallback commands-shader-color-filter-effect-child-use-after-evict-fallback commands-invalid-effect-child-use-after-evict-fallback}"
  CASES="${CASES/commands-runtime-effect-invalid-uniform-schema-fallback/commands-runtime-effect-shader-source-hash-fallback commands-runtime-effect-shader-source-code-fallback commands-runtime-effect-shader-sksl-length-fallback commands-runtime-effect-shader-uniform-float-count-fallback commands-runtime-effect-shader-negative-uniform-float-count-fallback commands-runtime-effect-shader-child-count-fallback commands-runtime-effect-shader-negative-child-count-fallback commands-runtime-effect-shader-named-uniform-count-fallback commands-runtime-effect-shader-negative-named-uniform-count-fallback commands-runtime-effect-shader-named-child-count-fallback commands-runtime-effect-shader-negative-named-child-count-fallback commands-runtime-effect-shader-uniform-name-fallback commands-runtime-effect-shader-uniform-schema-float-count-fallback commands-runtime-effect-shader-uniform-schema-float-offset-fallback commands-runtime-effect-shader-uniform-schema-float-range-fallback commands-runtime-effect-shader-uniform-schema-name-length-fallback commands-runtime-effect-shader-uniform-schema-max-name-length-fallback commands-runtime-effect-shader-uniform-schema-name-range-fallback commands-runtime-effect-shader-child-name-fallback commands-runtime-effect-shader-child-schema-name-length-fallback commands-runtime-effect-shader-child-schema-max-name-length-fallback commands-runtime-effect-shader-child-schema-name-range-fallback commands-runtime-effect-shader-child-index-fallback commands-runtime-effect-shader-negative-child-index-fallback commands-runtime-effect-shader-duplicate-child-index-fallback commands-runtime-effect-color-filter-source-hash-fallback commands-runtime-effect-color-filter-source-code-fallback commands-runtime-effect-color-filter-sksl-length-fallback commands-runtime-effect-color-filter-uniform-float-count-fallback commands-runtime-effect-color-filter-negative-uniform-float-count-fallback commands-runtime-effect-color-filter-child-count-fallback commands-runtime-effect-color-filter-negative-child-count-fallback commands-runtime-effect-color-filter-named-uniform-count-fallback commands-runtime-effect-color-filter-negative-named-uniform-count-fallback commands-runtime-effect-color-filter-named-child-count-fallback commands-runtime-effect-color-filter-negative-named-child-count-fallback commands-runtime-effect-color-filter-uniform-name-fallback commands-runtime-effect-color-filter-uniform-schema-float-count-fallback commands-runtime-effect-color-filter-uniform-schema-float-offset-fallback commands-runtime-effect-color-filter-uniform-schema-float-range-fallback commands-runtime-effect-color-filter-uniform-schema-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-max-name-length-fallback commands-runtime-effect-color-filter-uniform-schema-name-range-fallback commands-runtime-effect-color-filter-child-name-fallback commands-runtime-effect-color-filter-child-schema-name-length-fallback commands-runtime-effect-color-filter-child-schema-max-name-length-fallback commands-runtime-effect-color-filter-child-schema-name-range-fallback commands-runtime-effect-color-filter-child-index-fallback commands-runtime-effect-color-filter-negative-child-index-fallback commands-runtime-effect-color-filter-duplicate-child-index-fallback commands-runtime-effect-invalid-uniform-schema-fallback}"
  CASES="${CASES/commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-descriptor-version-fallback/commands-invalid-transformed-shader-descriptor-payload-count-fallback commands-invalid-composite-shader-descriptor-blend-mode-fallback commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback commands-invalid-radial-gradient-shader-descriptor-radius-fallback commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback commands-invalid-sweep-gradient-shader-descriptor-color-count-fallback commands-invalid-sweep-gradient-shader-descriptor-stop-order-fallback commands-invalid-image-shader-descriptor-width-fallback commands-invalid-image-shader-descriptor-max-width-fallback commands-invalid-image-shader-descriptor-height-fallback commands-invalid-image-shader-descriptor-max-height-fallback commands-invalid-image-shader-descriptor-tile-mode-x-fallback commands-invalid-image-shader-descriptor-tile-mode-y-fallback commands-invalid-perlin-noise-shader-kind-fallback commands-invalid-perlin-noise-shader-frequency-fallback commands-invalid-perlin-noise-shader-octaves-fallback commands-invalid-perlin-noise-shader-zero-octaves-fallback commands-invalid-perlin-noise-shader-tile-size-fallback commands-invalid-perlin-noise-shader-tile-height-fallback commands-invalid-perlin-noise-shader-negative-tile-size-fallback commands-invalid-perlin-noise-shader-negative-tile-height-fallback commands-invalid-descriptor-version-fallback}"
  CASES="${CASES/commands-image-filter-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback/commands-image-filter-wrong-effect-type-fallback commands-path-effect-wrong-effect-type-fallback commands-offset-image-filter-child-wrong-effect-type-fallback}"
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
    commands-invalid-stroke-path-dash-path-effect-verb-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true \
        MAGIC_JEWEL_CORRUPT_STROKE_PATH_DASH_PATH_EFFECT_VERB=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_STROKE_PATH_DASH_PATH_EFFECT_VERB_CORRUPTED"
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
    commands-skew-transform)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SKEW_TRANSFORM=true
      ;;
    commands-point-lines)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_LINES=true
      ;;
    commands-point-dots)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_POINT_DOTS=true
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
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-resize-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-resize-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_AUTO_RESIZE=true \
        MAGIC_JEWEL_AUTO_RESIZE_DELAY_MILLIS=500 \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
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
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
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
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-loaded-font-data-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_LOADED_FONT_DATA_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-forced-context-native-resource-font-text)
      run_case "$1" \
        JBR_SKIA_NATIVE_TEXT=true \
        MAGIC_JEWEL_RESOURCE_FONT_TEXT=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_TEXT_COMMANDS=1 \
        EXPECT_MIN_JBR_FONT_DATA_DEFINES=2 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
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
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
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
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-forced-context-dynamic-images)
      run_case "$1" \
        MAGIC_JEWEL_IMAGE_CACHE_CHURN=true \
        MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_IMAGE_CACHE_EVICTS=1 \
        EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 \
        EXPECT_MAX_IMAGE_CACHE_CLEARS=0 \
        EXPECT_MIN_SURFACE_CHANGES=1 \
        EXPECT_SURFACE_CONTEXT_CHANGED=true \
        EXPECT_SURFACE_CHANGED=false \
        EXPECT_MIN_COMMAND_CACHE_CLEARS=1
      ;;
    commands-image-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true \
        EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-image-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_PATH_EFFECT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=pathEffect
      ;;
    commands-color-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=1
      ;;
    commands-gradient-shaders)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRADIENT_SHADERS=true
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
    commands-composite-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3
      ;;
    commands-composite-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_NOISE_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=3 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=3
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
    commands-runtime-effect-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1
      ;;
    commands-raw-runtime-effect-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
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
    commands-runtime-effect-uniform-only)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_UNIFORM_ONLY=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=1 \
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
    commands-runtime-effect-shader-source-cache-eviction)
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
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shaderDescriptor
      ;;
    commands-runtime-effect-invalid-child-schema-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_INVALID_CHILD_SCHEMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shaderDescriptor
      ;;
    commands-runtime-effect-invalid-nested-child-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_CHILD_ONLY=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_INVALID_NESTED_CHILD=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shaderDescriptor
      ;;
    commands-runtime-effect-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_HITS=1 \
        EXPECT_MAX_JBR_RUNTIME_EFFECT_CACHE_MISSES=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-raw-runtime-effect-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilter
      ;;
    commands-runtime-effect-color-filter-child)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
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
        EXPECT_MIN_JBR_RUNTIME_EFFECT_CACHE_EVICTS=1 \
        EXPECT_JBR_RUNTIME_EFFECT_CACHE_EVICT_TYPE=colorFilter
      ;;
    commands-runtime-effect-color-filter-invalid-uniform-schema-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_UNIFORM_SCHEMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilterDescriptor
      ;;
    commands-runtime-effect-color-filter-invalid-child-schema-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_CHILD_SCHEMA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilterDescriptor
      ;;
    commands-runtime-effect-color-filter-invalid-nested-child-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_INVALID_NESTED_CHILD=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilterDescriptor
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
    commands-invalid-color-filter-descriptor-use-after-evict-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true \
        MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_DESCRIPTOR_USE_AFTER_EVICT_CORRUPTED op=47"
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
    commands-invalid-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-color-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COLOR_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-shader-color-filter-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_COLOR_FILTER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-shader-descriptor-record-length-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_SHADER_DESCRIPTOR_RECORD_LENGTH=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_SHADER_DESCRIPTOR_RECORD_LENGTH_CORRUPTED"
      ;;
    commands-invalid-transformed-shader-descriptor-payload-count-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        MAGIC_JEWEL_CORRUPT_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_TRANSFORMED_SHADER_DESCRIPTOR_PAYLOAD_COUNT_CORRUPTED"
      ;;
    commands-invalid-composite-shader-descriptor-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_COMPOSITE_SHADER_DESCRIPTOR_BLEND_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-shader-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-linear-gradient-shader-descriptor-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true \
        MAGIC_JEWEL_CORRUPT_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_LINEAR_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-radius-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_SHADER_DESCRIPTOR_RADIUS_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-tile-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER="SKIKO_JBR_INTEROP_RADIAL_GRADIENT_SHADER_DESCRIPTOR_TILE_MODE_CORRUPTED"
      ;;
    commands-invalid-radial-gradient-shader-descriptor-stop-order-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true \
        MAGIC_JEWEL_CORRUPT_RADIAL_GRADIENT_SHADER_DESCRIPTOR_STOP_ORDER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=3 \
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
    commands-invalid-descriptor-version-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_PURE_COLOR=true \
        MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION=true \
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
    commands-image-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_IMAGE_REFS=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-gradient-stroke)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true
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
    commands-raw-blend-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_BLEND_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilter
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
    commands-color-matrix-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COLOR_MATRIX_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
      ;;
    commands-lighting-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_LIGHTING_FILTER=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=1
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
    commands-path-effect-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PATH_EFFECT_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=colorFilter
      ;;
    commands-raw-discrete-path-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_DISCRETE_PATH_EFFECT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=pathEffect
      ;;
    commands-vertices)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_VERTICES=true
      ;;
    commands-blend-mode|commands-blend-mode-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_BLEND_MODE=true
      ;;
    commands-graphics-layer|commands-graphics-layer-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true
      ;;
    commands-graphics-layer-modulate-alpha)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_MODULATE_ALPHA=true
      ;;
    commands-graphics-layer-offscreen)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSCREEN=true
      ;;
    commands-graphics-layer-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP=true
      ;;
    commands-graphics-layer-round-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true
      ;;
    commands-graphics-layer-path-clip)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true
      ;;
    commands-graphics-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true
      ;;
    commands-graphics-layer-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-raw-color-filter-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=graphicsLayer:colorFilter
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
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
      ;;
    commands-graphics-layer-raw-image-filter-effect-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_IMAGE_FILTER_EFFECT=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=graphicsLayer:renderEffect
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
    commands-graphics-layer-chained-render-effect)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true \
        EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_USES=1 \
        EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_EFFECT_HANDLE_DEFINES=2
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
    commands-graphics-layer-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-graphics-layer-round-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-graphics-layer-path-shadow)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true \
        EXPECT_MIN_JBR_SHADOW_COMMANDS=1
      ;;
    commands-graphics-layer-rotationx)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true
      ;;
    commands-graphics-layer-rotationy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true
      ;;
    commands-graphics-layer-rotationxy)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true
      ;;
    commands-graphics-layer-scale-translate)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SCALE_TRANSLATE=true
      ;;
    commands-graphics-layer-near-camera)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true
      ;;
    commands-graphics-layer-offcenter-pivot)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true
      ;;
    commands-graphics-layer-blend-color-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true \
        MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER=true
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
    commands-save-layer-filter)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true
      ;;
    commands-save-layer-blend-mode)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER_BLEND_MODE=true
      ;;
    commands-invalid-save-layer-alpha-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_SAVELAYER=true \
        MAGIC_JEWEL_CORRUPT_SAVE_LAYER_ALPHA=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid \
        EXPECT_COMMAND_FALLBACK_MARKER=SKIKO_JBR_INTEROP_SAVE_LAYER_ALPHA_CORRUPTED
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
        MAGIC_JEWEL_COMPOSE_SAVELAYER_RAW_COLOR_FILTER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=saveLayer
      ;;
    commands-opaque-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_OPAQUE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-descriptor-stroke-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_DESCRIPTOR_STROKE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=paintStyle
      ;;
    commands-raw-image-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_IMAGE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-composite-opaque-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_COMPOSITE_OPAQUE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-noise-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true \
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
    commands-raw-noise-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_NOISE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-raw-linear-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_LINEAR_GRADIENT_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-raw-radial-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_RADIAL_GRADIENT_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-raw-sweep-gradient-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_SWEEP_GRADIENT_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-raw-turbulence-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_RAW_TURBULENCE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-picture-shader-fallback)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_PICTURE_SHADER=true \
        EXPECT_COMMAND_FALLBACK=true \
        EXPECT_COMMAND_FALLBACK_REASON=shader
      ;;
    commands-transformed-shader)
      run_case "$1" \
        MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true \
        EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 \
        EXPECT_MIN_JBR_SHADER_HANDLE_USES=1 \
        EXPECT_MIN_JBR_SHADER_HANDLE_CACHE_HITS=1 \
        EXPECT_MAX_JBR_SHADER_HANDLE_DEFINES=2
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
