#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-standalone-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
SKIKO_VERSION="${SKIKO_VERSION:-0.0.0-SNAPSHOT}"
DURATION_SECONDS="${DURATION_SECONDS:-30}"
WARMUP_SECONDS="${WARMUP_SECONDS:-5}"
SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS:-1}"
JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE:-commands}"
JEWEL_STANDALONE_SPECTRE_STRESS="${JEWEL_STANDALONE_SPECTRE_STRESS:-true}"
JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS="${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS:-350}"

mkdir -p "${OUT_ROOT}"

machine_snapshot() {
  {
    echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "uname=$(uname -a)"
    echo "uptime=$(uptime)"
    echo "spectre_stress=${JEWEL_STANDALONE_SPECTRE_STRESS}"
    echo "spectre_stress_interval_millis=${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS}"
    echo "top_processes:"
    ps -Ao pid,pcpu,pmem,comm | sort -k2 -nr | head -20 || true
  } > "${OUT_ROOT}/machine-snapshot.txt"
}

summary_value() {
  local file="$1"
  local key="$2"
  grep -E "^${key}=" "${file}" | head -n 1 | cut -d= -f2-
}

run_case() {
  local name="$1"
  local out_dir="${OUT_ROOT}/${name}"
  echo "== ${name} =="
  mkdir -p "${out_dir}"
  env \
    OUT_DIR="${out_dir}" \
    SKIKO_VERSION="${SKIKO_VERSION}" \
    DURATION_SECONDS="${DURATION_SECONDS}" \
    WARMUP_SECONDS="${WARMUP_SECONDS}" \
    SAMPLE_INTERVAL_SECONDS="${SAMPLE_INTERVAL_SECONDS}" \
    JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE}" \
    EXPECT_SCREENSHOT_ASSERTION=false \
    OLD_GRADLE_TASK=runJewelStandalone \
    NEW_GRADLE_TASK=runJewelStandaloneJbrSkiaInterop \
    APP_PROCESS_QUERY=org.jetbrains.jewel.samples.standalone.SwingMainKt \
    CAPTURE_WINDOW_QUERY=JewelStandaloneJbrSkiaWindow \
    APP_FRAME_MARKER=JEWEL_STANDALONE_FRAME \
    EXPECT_MIN_APP_NEW_FRAMES=1 \
    JEWEL_STANDALONE_INITIAL_VIEW=Hypnotoad \
    JEWEL_STANDALONE_INITIAL_COMPONENT= \
    JEWEL_STANDALONE_SPECTRE_STRESS="${JEWEL_STANDALONE_SPECTRE_STRESS}" \
    JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS="${JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS}" \
    "${SCRIPT_DIR}/jbr-skia-interop-report.sh" > "${out_dir}/report-path.txt"
}

write_suite_summary() {
  local suite_tsv="${OUT_ROOT}/suite.tsv"
  printf "case\tstatus\told_avg_cpu\tnew_avg_cpu\told_fps\tnew_fps\tjbr_command_fps\tjbr_command_frames\tfallbacks\treport\n" > "${suite_tsv}"
  local case_dir
  for case_dir in "${OUT_ROOT}"/*; do
    [[ -d "${case_dir}" && -f "${case_dir}/summary.properties" ]] || continue
    local name
    name="$(basename "${case_dir}")"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "${name}" \
      "$(summary_value "${case_dir}/summary.properties" validation_status)" \
      "$(summary_value "${case_dir}/summary.properties" old_avg_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" new_avg_cpu)" \
      "$(summary_value "${case_dir}/summary.properties" app_old_fps)" \
      "$(summary_value "${case_dir}/summary.properties" app_new_fps)" \
      "$(summary_value "${case_dir}/summary.properties" jbr_command_fps)" \
      "$(summary_value "${case_dir}/summary.properties" jbr_command_frames)" \
      "$(summary_value "${case_dir}/summary.properties" fallback_new_count)" \
      "$(cat "${case_dir}/report-path.txt" 2>/dev/null || true)" >> "${suite_tsv}"
  done
  echo "${suite_tsv}"
}

machine_snapshot
run_case hypnotoad
write_suite_summary
