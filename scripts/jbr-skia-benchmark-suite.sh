#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
source "${SCRIPT_DIR}/jbr-skia-daily-validation-guard.sh"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-20}"
WARMUP_SECONDS="${WARMUP_SECONDS:-5}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
ENABLE_ASPROF="${ENABLE_ASPROF:-false}"
CASE_GROUPS="${CASE_GROUPS:-}"
CASES_WAS_SET="${CASES+x}"
LIST_CASE_GROUPS="${LIST_CASE_GROUPS:-false}"
LIST_CASE_GROUP_COUNTS="${LIST_CASE_GROUP_COUNTS:-false}"
LIST_UNGROUPED_CASES="${LIST_UNGROUPED_CASES:-false}"
LIST_CASES="${LIST_CASES:-false}"
LIST_CASE_COUNT="${LIST_CASE_COUNT:-false}"
EARLY_DEFAULT_BROAD_VALIDATION_GUARDED=false
if [[ "${LIST_CASE_GROUPS}" != "true" && "${LIST_CASE_GROUP_COUNTS}" != "true" && "${LIST_CASES}" != "true" && "${LIST_CASE_COUNT}" != "true" && "${LIST_UNGROUPED_CASES}" != "true" && -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" ]]; then
  jbr_skia_daily_broad_validation_guard "benchmark suite (default launch)"
  EARLY_DEFAULT_BROAD_VALIDATION_GUARDED=true
fi
ALL_CASES=(
  picture
  commands
  commands-stable-images
  commands-dynamic-images
  commands-resize-dynamic-images
)
CASES="${CASES:-${ALL_CASES[*]}}"
SUITE_INITIALIZED=false

SUITE_TSV="${OUT_ROOT}/suite.tsv"

list_case_groups() {
  printf "%s\n" \
    baseline \
    image-cache
}

case_group_cases() {
  case "$1" in
    baseline)
      echo "picture commands"
      ;;
    image-cache)
      echo "commands-stable-images commands-dynamic-images commands-resize-dynamic-images"
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
  for name in "${ALL_CASES[@]}"; do
    if ! case_in_words "${name}" ${grouped_cases}; then
      printf "%s\n" "${name}"
    fi
  done
}

if [[ "${LIST_UNGROUPED_CASES}" == "true" ]]; then
  list_ungrouped_cases
  exit 0
fi

if [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  CASES=""
  for group in ${CASE_GROUPS}; do
    CASES="${CASES} $(case_group_cases "${group}")"
  done
  CASES="${CASES# }"
fi

init_suite() {
  if [[ "${SUITE_INITIALIZED}" == "true" ]]; then
    return 0
  fi
  mkdir -p "${OUT_ROOT}"
  printf "case\tstatus\tfallbacks\told_samples\tnew_samples\told_avg_cpu\tnew_avg_cpu\tapp_old_fps\tapp_new_fps\tjbr_picture_fps\tjbr_command_fps\tjbr_command_frames\treport\n" > "${SUITE_TSV}"
  SUITE_INITIALIZED=true
}

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

run_case() {
  init_suite
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
    ENABLE_ASPROF="${ENABLE_ASPROF}" \
    "$@" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" >/tmp/magic-jewel-${name}-benchmark-report.txt
  local report
  report="$(cat /tmp/magic-jewel-${name}-benchmark-report.txt)"
  local status
  status="$(grep -E '^validation_status=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local command_frames
  command_frames="$(grep -E '^jbr_command_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local picture_frames
  picture_frames="$(grep -E '^jbr_picture_frames=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local fallback
  fallback="$(grep -E '^fallback_new_count=' "${out_dir}/summary.properties" | cut -d= -f2-)"
  local old_samples
  old_samples="$(summary_value "${out_dir}/summary.properties" old_samples)"
  local new_samples
  new_samples="$(summary_value "${out_dir}/summary.properties" new_samples)"
  local old_avg_cpu
  old_avg_cpu="$(summary_value "${out_dir}/summary.properties" old_avg_cpu)"
  local new_avg_cpu
  new_avg_cpu="$(summary_value "${out_dir}/summary.properties" new_avg_cpu)"
  if [[ "${old_samples}" == "0" ]]; then
    old_avg_cpu=na
  fi
  if [[ "${new_samples}" == "0" ]]; then
    new_avg_cpu=na
  fi
  local app_old_fps
  app_old_fps="$(summary_value "${out_dir}/summary.properties" app_old_fps)"
  local app_new_fps
  app_new_fps="$(summary_value "${out_dir}/summary.properties" app_new_fps)"
  local jbr_picture_fps
  jbr_picture_fps="$(summary_value "${out_dir}/summary.properties" jbr_picture_fps)"
  local jbr_command_fps
  jbr_command_fps="$(summary_value "${out_dir}/summary.properties" jbr_command_fps)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${name}" "${status}" "${fallback}" "${old_samples}" "${new_samples}" \
    "${old_avg_cpu}" "${new_avg_cpu}" \
    "${app_old_fps}" "${app_new_fps}" "${jbr_picture_fps}" "${jbr_command_fps}" \
    "${command_frames}" "${report}" >> "${SUITE_TSV}"
  echo "status=${status} fallback_new_count=${fallback} jbr_picture_frames=${picture_frames} jbr_command_frames=${command_frames} report=${report}"
  [[ "${status}" == "passed" ]]
}

case_known() {
  local needle="$1"
  local item
  for item in "${ALL_CASES[@]}"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

selected_cases() {
  printf "%s\n" ${CASES}
}

run_named_case() {
  case "$1" in
    picture)
      run_case "$1" JBR_SKIA_RENDER_MODE=picture
      ;;
    commands)
      run_case "$1" JBR_SKIA_RENDER_MODE=commands EXPECT_MIN_IMAGE_REFS=1
      ;;
    commands-stable-images)
      run_case "$1" JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
      ;;
    commands-dynamic-images)
      run_case "$1" JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0
      ;;
    commands-resize-dynamic-images)
      run_case "$1" JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_IMAGE_CACHE_CLEARS=1 EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 EXPECT_MIN_JBR_SCOPED_IMAGE_CACHE_CLEARS=1 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true
      ;;
    *)
      echo "Unknown benchmark case: $1" >&2
      return 2
      ;;
  esac
}

while IFS= read -r case_name; do
  if ! case_known "${case_name}"; then
    echo "Unknown benchmark case: ${case_name}" >&2
    exit 2
  fi
done < <(selected_cases)

if [[ "${LIST_CASES}" == "true" ]]; then
  selected_cases
  exit 0
fi

if [[ "${LIST_CASE_COUNT}" == "true" ]]; then
  selected_cases | wc -l | tr -d ' '
  exit 0
fi

selection_reason="exact"
if [[ -z "${CASES_WAS_SET}" && -z "${CASE_GROUPS}" ]]; then
  selection_reason="default"
elif [[ -z "${CASES_WAS_SET}" && -n "${CASE_GROUPS}" ]]; then
  selection_reason="case-groups"
fi
if [[ "${EARLY_DEFAULT_BROAD_VALIDATION_GUARDED}" != "true" ]]; then
  jbr_skia_daily_broad_validation_guard_for_selection \
    "benchmark suite" \
    "$(selected_cases | wc -l | tr -d ' ')" \
    "${selection_reason}"
fi

for case_name in ${CASES}; do
  run_named_case "${case_name}"
done

echo "JBR_SKIA_BENCHMARK_SUITE passed out_root=${OUT_ROOT}"
echo "suite=${SUITE_TSV}"
