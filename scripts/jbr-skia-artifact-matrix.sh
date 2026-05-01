#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-artifact-matrix/$(date +%Y%m%d-%H%M%S)}"
DURATION_SECONDS="${DURATION_SECONDS:-5}"
WARMUP_SECONDS="${WARMUP_SECONDS:-1}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
CURRENT_DESKTOP_PATCH="${CURRENT_DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
CURRENT_JBR_API_SHIM="${CURRENT_JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
CURRENT_JBR_SKIA_LIB="${CURRENT_JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
CURRENT_SKIKO_VERSION="${CURRENT_SKIKO_VERSION:-${SKIKO_VERSION:-0.0.0-SNAPSHOT}}"
CURRENT_CMP_OUT="${CURRENT_CMP_OUT:-/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core}"
OLD_DESKTOP_PATCH="${OLD_DESKTOP_PATCH:-}"
OLD_JBR_API_SHIM="${OLD_JBR_API_SHIM:-}"
OLD_JBR_SKIA_LIB="${OLD_JBR_SKIA_LIB:-}"
OLD_SKIKO_VERSION="${OLD_SKIKO_VERSION:-}"
OLD_CMP_OUT="${OLD_CMP_OUT:-}"
OLD_ARTIFACT_BUNDLE="${OLD_ARTIFACT_BUNDLE:-}"
OLD_JBR_EXPECTED_REASON="${OLD_JBR_EXPECTED_REASON:-native-abi-mismatch}"
OLD_API_EXPECTED_REASON="${OLD_API_EXPECTED_REASON:-public-api-missing}"
OLD_SKIKO_EXPECTED_REASON="${OLD_SKIKO_EXPECTED_REASON:-native-abi-mismatch}"
OLD_CMP_EXPECTED_REASON="${OLD_CMP_EXPECTED_REASON:-public-api-missing}"
DRY_RUN="${DRY_RUN:-false}"
REQUIRE_OLD_ARTIFACT_ROWS="${REQUIRE_OLD_ARTIFACT_ROWS:-false}"
SKIPPED_OPTIONAL_ROWS=0

mkdir -p "${OUT_ROOT}"
MATRIX_TSV="${OUT_ROOT}/matrix.tsv"
printf "case\tstatus\texpected\tactual_fallbacks\tcommand_frames\treport\tnote\n" >"${MATRIX_TSV}"

usage() {
  cat <<EOF_USAGE
Usage: $0 [--dry-run]

Runs launch-level Magic Jewel compatibility rows using named local artifacts.
The current/current row is required. Old/new rows run only when their OLD_*
artifact variables are provided; otherwise they are recorded as skipped.

Current artifact variables:
  CURRENT_DESKTOP_PATCH   Default: /tmp/jbr-skia-run/desktop
  CURRENT_JBR_API_SHIM    Default: /tmp/jbr-api-shim.jar
  CURRENT_JBR_SKIA_LIB    Default: /tmp/jbr-skia-native/libjbrskiainterop.dylib
  CURRENT_SKIKO_VERSION   Default: SKIKO_VERSION or 0.0.0-SNAPSHOT
  CURRENT_CMP_OUT         Default: /Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core

Optional old artifact variables:
  OLD_ARTIFACT_BUNDLE    Bundle created by package-jbr-skia-artifact-bundle.sh.
  OLD_DESKTOP_PATCH       Old java.desktop patch directory.
  OLD_JBR_API_SHIM        Old public JBR API shim jar.
  OLD_JBR_SKIA_LIB        Old/native-incompatible JBR Skia dylib.
  OLD_SKIKO_VERSION       Old Skiko Maven version available to Gradle.
  OLD_CMP_OUT             Old patched CMP output root.

Expected fallback variables for optional rows:
  OLD_JBR_EXPECTED_REASON     Default: native-abi-mismatch
  OLD_API_EXPECTED_REASON     Default: public-api-missing
  OLD_SKIKO_EXPECTED_REASON   Default: native-abi-mismatch
  OLD_CMP_EXPECTED_REASON     Default: public-api-missing

Validation controls:
  REQUIRE_OLD_ARTIFACT_ROWS   When true, fail if any optional old-artifact row is skipped. Default: false
EOF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

require_file() {
  local label="$1"
  local path="$2"
  if [[ ! -f "${path}" ]]; then
    echo "Missing ${label}: ${path}" >&2
    return 1
  fi
}

require_dir() {
  local label="$1"
  local path="$2"
  if [[ ! -d "${path}" ]]; then
    echo "Missing ${label}: ${path}" >&2
    return 1
  fi
}

append_row() {
  local name="$1"
  local status="$2"
  local expected="$3"
  local fallbacks="$4"
  local command_frames="$5"
  local report="$6"
  local note="$7"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${expected}" "${fallbacks}" "${command_frames}" "${report}" "${note}" >>"${MATRIX_TSV}"
}

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

load_old_artifact_bundle() {
  local bundle="$1"
  local manifest="${bundle}/manifest.properties"
  require_file "old artifact bundle manifest" "${manifest}"

  local key value
  while IFS='=' read -r key value; do
    case "${key}" in
      desktop_patch)
        OLD_DESKTOP_PATCH="${OLD_DESKTOP_PATCH:-${value}}"
        ;;
      jbr_api_shim)
        OLD_JBR_API_SHIM="${OLD_JBR_API_SHIM:-${value}}"
        ;;
      jbr_skia_lib)
        OLD_JBR_SKIA_LIB="${OLD_JBR_SKIA_LIB:-${value}}"
        ;;
      skiko_version)
        OLD_SKIKO_VERSION="${OLD_SKIKO_VERSION:-${value}}"
        ;;
      cmp_out)
        OLD_CMP_OUT="${OLD_CMP_OUT:-${value}}"
        ;;
    esac
  done <"${manifest}"
}

run_case() {
  local name="$1"
  local desktop_patch="$2"
  local api_shim="$3"
  local native_lib="$4"
  local skiko_version="$5"
  local cmp_out="$6"
  local expected_reason="$7"
  local out_dir="${OUT_ROOT}/${name}"

  echo "== ${name} =="
  if [[ "${DRY_RUN}" == "true" ]]; then
    append_row "${name}" "dry-run" "${expected_reason}" "-" "-" "${out_dir}/report.md" "not launched"
    return 0
  fi

  local expect_env=()
  if [[ "${expected_reason}" == "none" ]]; then
    expect_env+=(EXPECT_MIN_IMAGE_REFS=1)
  else
    expect_env+=(EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON="${expected_reason}")
  fi

  env \
    OUT_DIR="${out_dir}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    JBR_SKIA_RENDER_MODE=commands \
    DESKTOP_PATCH="${desktop_patch}" \
    JBR_API_SHIM="${api_shim}" \
    JBR_SKIA_LIB="${native_lib}" \
    SKIKO_VERSION="${skiko_version}" \
    LOCAL_CMP_OUT="${cmp_out}" \
    "${expect_env[@]}" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" >/tmp/magic-jewel-${name}-artifact-matrix-report.txt

  local summary="${out_dir}/summary.properties"
  local status
  status="$(summary_value "${summary}" validation_status)"
  local fallbacks
  fallbacks="$(summary_value "${summary}" fallback_new_count)"
  local command_frames
  command_frames="$(summary_value "${summary}" jbr_command_frames)"
  local report
  report="$(cat /tmp/magic-jewel-${name}-artifact-matrix-report.txt)"
  append_row "${name}" "${status}" "${expected_reason}" "${fallbacks}" "${command_frames}" "${report}" ""
  echo "status=${status} expected=${expected_reason} fallback_new_count=${fallbacks} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

skip_case() {
  local name="$1"
  local reason="$2"
  echo "== ${name} skipped: ${reason} =="
  SKIPPED_OPTIONAL_ROWS=$((SKIPPED_OPTIONAL_ROWS + 1))
  append_row "${name}" "skipped" "-" "-" "-" "-" "${reason}"
}

require_dir "current desktop patch" "${CURRENT_DESKTOP_PATCH}"
require_file "current JBR API shim" "${CURRENT_JBR_API_SHIM}"
require_file "current JBR Skia dylib" "${CURRENT_JBR_SKIA_LIB}"
require_dir "current CMP output" "${CURRENT_CMP_OUT}"

if [[ -n "${OLD_ARTIFACT_BUNDLE}" ]]; then
  load_old_artifact_bundle "${OLD_ARTIFACT_BUNDLE}"
fi

run_case \
  current-all \
  "${CURRENT_DESKTOP_PATCH}" \
  "${CURRENT_JBR_API_SHIM}" \
  "${CURRENT_JBR_SKIA_LIB}" \
  "${CURRENT_SKIKO_VERSION}" \
  "${CURRENT_CMP_OUT}" \
  none

run_case \
  missing-public-api \
  "${CURRENT_DESKTOP_PATCH}" \
  /tmp/missing-jbr-api-shim.jar \
  "${CURRENT_JBR_SKIA_LIB}" \
  "${CURRENT_SKIKO_VERSION}" \
  "${CURRENT_CMP_OUT}" \
  public-api-missing

if [[ -n "${OLD_JBR_API_SHIM}" ]]; then
  require_file "old JBR API shim" "${OLD_JBR_API_SHIM}"
  run_case old-api-current-runtime "${CURRENT_DESKTOP_PATCH}" "${OLD_JBR_API_SHIM}" "${CURRENT_JBR_SKIA_LIB}" "${CURRENT_SKIKO_VERSION}" "${CURRENT_CMP_OUT}" "${OLD_API_EXPECTED_REASON}"
else
  skip_case old-api-current-runtime "set OLD_JBR_API_SHIM to run"
fi

if [[ -n "${OLD_JBR_SKIA_LIB}" ]]; then
  require_file "old JBR Skia dylib" "${OLD_JBR_SKIA_LIB}"
  run_case old-native-current-api "${CURRENT_DESKTOP_PATCH}" "${CURRENT_JBR_API_SHIM}" "${OLD_JBR_SKIA_LIB}" "${CURRENT_SKIKO_VERSION}" "${CURRENT_CMP_OUT}" "${OLD_JBR_EXPECTED_REASON}"
else
  skip_case old-native-current-api "set OLD_JBR_SKIA_LIB to run"
fi

if [[ -n "${OLD_DESKTOP_PATCH}" ]]; then
  require_dir "old desktop patch" "${OLD_DESKTOP_PATCH}"
  run_case old-desktop-current-runtime "${OLD_DESKTOP_PATCH}" "${CURRENT_JBR_API_SHIM}" "${CURRENT_JBR_SKIA_LIB}" "${CURRENT_SKIKO_VERSION}" "${CURRENT_CMP_OUT}" "${OLD_JBR_EXPECTED_REASON}"
else
  skip_case old-desktop-current-runtime "set OLD_DESKTOP_PATCH to run"
fi

if [[ -n "${OLD_SKIKO_VERSION}" ]]; then
  run_case old-skiko-current-jbr "${CURRENT_DESKTOP_PATCH}" "${CURRENT_JBR_API_SHIM}" "${CURRENT_JBR_SKIA_LIB}" "${OLD_SKIKO_VERSION}" "${CURRENT_CMP_OUT}" "${OLD_SKIKO_EXPECTED_REASON}"
else
  skip_case old-skiko-current-jbr "set OLD_SKIKO_VERSION to run"
fi

if [[ -n "${OLD_CMP_OUT}" ]]; then
  require_dir "old CMP output" "${OLD_CMP_OUT}"
  run_case old-cmp-current-jbr "${CURRENT_DESKTOP_PATCH}" "${CURRENT_JBR_API_SHIM}" "${CURRENT_JBR_SKIA_LIB}" "${CURRENT_SKIKO_VERSION}" "${OLD_CMP_OUT}" "${OLD_CMP_EXPECTED_REASON}"
else
  skip_case old-cmp-current-jbr "set OLD_CMP_OUT to run"
fi

if [[ "${REQUIRE_OLD_ARTIFACT_ROWS}" == "true" && "${SKIPPED_OPTIONAL_ROWS}" -gt 0 ]]; then
  echo "JBR_SKIA_ARTIFACT_MATRIX failed: ${SKIPPED_OPTIONAL_ROWS} optional old-artifact rows were skipped" >&2
  echo "matrix=${MATRIX_TSV}" >&2
  exit 1
fi

echo "JBR_SKIA_ARTIFACT_MATRIX passed out_root=${OUT_ROOT}"
echo "matrix=${MATRIX_TSV}"
