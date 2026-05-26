#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-compatibility-matrix/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-5}"
WARMUP_SECONDS="${WARMUP_SECONDS:-1}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
EXPECT_BACKGROUND_WINDOW="${EXPECT_BACKGROUND_WINDOW:-true}"
CASES_FILTER="${CASES:-}"
LIST_CASES="${LIST_CASES:-false}"
LIST_CASE_COUNT="${LIST_CASE_COUNT:-false}"
LISTED_CASE_COUNT=0
MATCHED_CASES=""
MATRIX_INITIALIZED=false
MATRIX_TSV="${OUT_ROOT}/matrix.tsv"

case_selected() {
  local name="$1"
  if [[ -n "${CASES_FILTER}" ]]; then
    local selected=false
    local filter
    for filter in ${CASES_FILTER}; do
      if [[ "${filter}" == "${name}" ]]; then
        selected=true
        break
      fi
    done
    if [[ "${selected}" != "true" ]]; then
      return 1
    fi
  fi
  MATCHED_CASES="${MATCHED_CASES} ${name}"
  return 0
}

validate_case_filter() {
  if [[ -z "${CASES_FILTER}" ]]; then
    return 0
  fi
  local filter
  for filter in ${CASES_FILTER}; do
    if [[ " ${MATCHED_CASES} " != *" ${filter} "* ]]; then
      echo "Unknown CASES entry: ${filter}" >&2
      exit 2
    fi
  done
}

init_matrix() {
  if [[ "${MATRIX_INITIALIZED}" == "true" ]]; then
    return
  fi
  mkdir -p "${OUT_ROOT}"
  printf "case\tstatus\tfallbacks\tcommand_frames\tbackground_window\treport\n" > "${MATRIX_TSV}"
  MATRIX_INITIALIZED=true
}

run_case() {
  local name="$1"
  shift
  if ! case_selected "${name}"; then
    return 0
  fi
  if [[ "${LIST_CASES}" == "true" ]]; then
    echo "${name}"
    LISTED_CASE_COUNT=$((LISTED_CASE_COUNT + 1))
    return 0
  fi
  if [[ "${LIST_CASE_COUNT}" == "true" ]]; then
    LISTED_CASE_COUNT=$((LISTED_CASE_COUNT + 1))
    return 0
  fi
  init_matrix
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} =="
  env \
    OUT_DIR="${out_dir}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    JBR_SKIA_RENDER_MODE=commands \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    "$@" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" >/tmp/magic-jewel-${name}-matrix-report.txt
  local report
  report="$(cat /tmp/magic-jewel-${name}-matrix-report.txt)"
  local status
  status="$(grep -E '^validation_status=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local fallback
  fallback="$(grep -E '^fallback_new_count=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local command_frames
  command_frames="$(grep -E '^jbr_command_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local background_window
  background_window="$(grep -E '^magic_jewel_background_window=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "${name}" "${status}" "${fallback}" "${command_frames}" "${background_window}" "${report}" >> "${MATRIX_TSV}"
  echo "status=${status} fallback_new_count=${fallback} jbr_command_frames=${command_frames} background_window=${background_window} report=${report}"
  [[ "${background_window}" == "${EXPECT_BACKGROUND_WINDOW}" ]]
  [[ "${status}" == "passed" ]]
}

run_case happy EXPECT_MIN_IMAGE_REFS=1
run_case abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch SKIKO_EXPECTED_ABI_ID_FOR_TEST=999
run_case native-abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=999
run_case command-capability-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=0
run_case fill-rect-linear-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1073741825
run_case fill-round-rect-linear-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-2147483649
run_case fill-rect-radial-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-4294967297
run_case fill-round-rect-radial-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-8589934593
run_case fill-path-linear-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-17179869185
run_case fill-path-radial-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-34359738369
run_case fill-rect-sweep-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-68719476737
run_case fill-round-rect-sweep-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-137438953473
run_case fill-path-sweep-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-274877906945
run_case stroke-rect-linear-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-4398046511105
run_case stroke-round-rect-linear-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-8796093022209
run_case stroke-rect-radial-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-17592186044417
run_case stroke-round-rect-radial-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-35184372088833
run_case stroke-rect-sweep-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-70368744177665
run_case stroke-round-rect-sweep-gradient-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-140737488355329
run_case text-font-family-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1099511627777
run_case fill-rect-image-shader-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-2199023255553
run_case fill-rect-blend-mode-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-281474976710657
run_case fill-rect-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-562949953421313
run_case stroke-line-dash-path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1125899906842625
run_case save-layer-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-2251799813685249
run_case draw-image-ref-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-4503599627370497
run_case define-color-filter-tint-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-9007199254740993
run_case fill-rect-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-18014398509481985
run_case evict-color-filter-handle-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-36028797018963969
run_case define-effect-descriptor-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-72057594037927937
run_case save-layer-blend-mode-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-144115188075855873
run_case save-layer-blend-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-288230376151711745
run_case color-matrix-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-576460752303423489
run_case lighting-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1152921504606846977
run_case save-layer-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-2305843009213693953
run_case image-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-4611686018427387905
run_case save-layer-blend-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=9223372036854775807
run_case command-capability-high-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST=-1
run_case image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262142
run_case offset-image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262141
run_case chained-image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262139
run_case shader-descriptor-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262135
run_case runtime-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262127
run_case stroke-rect-dash-path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262111
run_case stroke-round-rect-dash-path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262079
run_case stroke-path-dash-path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=262015
run_case path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=261887
run_case concat-matrix-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=261631
run_case direct-shadow-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=261119
run_case shader-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=260095
run_case draw-points-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=258047
run_case shader-transform-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=253951
run_case font-data-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=245759
run_case shader-color-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=229375
run_case shader-perlin-noise-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=196607
run_case draw-vertices-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=131071
run_case public-api-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing JBR_API_SHIM=/tmp/missing-jbr-api-shim.jar

validate_case_filter

if [[ "${LIST_CASE_COUNT}" == "true" ]]; then
  echo "${LISTED_CASE_COUNT}"
  exit 0
fi

if [[ "${LIST_CASES}" == "true" ]]; then
  exit 0
fi

echo "JBR_SKIA_COMPATIBILITY_MATRIX passed out_root=${OUT_ROOT}"
echo "matrix=${MATRIX_TSV}"
