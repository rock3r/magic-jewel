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
  echo "status=${status} fallback_new_count=${fallback} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

run_case happy EXPECT_MIN_IMAGE_REFS=1
run_case abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch SKIKO_EXPECTED_ABI_ID_FOR_TEST=999
run_case native-abi-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=999
run_case command-capability-high-mismatch EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST=-1
run_case public-api-missing EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing JBR_API_SHIM=/tmp/missing-jbr-api-shim.jar

echo "JBR_SKIA_COMPATIBILITY_MATRIX passed out_root=${OUT_ROOT}"
