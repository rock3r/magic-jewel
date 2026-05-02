#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-compatibility-matrix/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-5}"
WARMUP_SECONDS="${WARMUP_SECONDS:-1}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"

mkdir -p "${OUT_ROOT}"
MATRIX_TSV="${OUT_ROOT}/matrix.tsv"
printf "case\tstatus\tfallbacks\tcommand_frames\treport\n" > "${MATRIX_TSV}"

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
  printf "%s\t%s\t%s\t%s\t%s\n" "${name}" "${status}" "${fallback}" "${command_frames}" "${report}" >> "${MATRIX_TSV}"
  echo "status=${status} fallback_new_count=${fallback} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

run_case happy EXPECT_MIN_IMAGE_REFS=1
run_case abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch SKIKO_EXPECTED_ABI_ID_FOR_TEST=999
run_case native-abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=999
run_case command-capability-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=0
run_case text-font-family-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1099511627777
run_case color-matrix-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-576460752303423489
run_case lighting-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-1152921504606846977
run_case save-layer-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-2305843009213693953
run_case image-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=-4611686018427387905
run_case save-layer-blend-color-filter-ref-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_MASK_FOR_TEST=9223372036854775807
run_case command-capability-high-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST=-1
run_case image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=8190
run_case offset-image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=8189
run_case chained-image-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=8187
run_case shader-descriptor-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=8183
run_case runtime-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=8175
run_case path-effect-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=7935
run_case concat-matrix-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=7679
run_case direct-shadow-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=7167
run_case shader-color-filter-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=6143
run_case draw-points-capability-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch JBR_SKIA_COMMAND_CAPABILITIES_HIGH_MASK_FOR_TEST=4095
run_case public-api-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing JBR_API_SHIM=/tmp/missing-jbr-api-shim.jar

echo "JBR_SKIA_COMPATIBILITY_MATRIX passed out_root=${OUT_ROOT}"
echo "matrix=${MATRIX_TSV}"
