#!/usr/bin/env bash
set -euo pipefail

# Locale-proof numeric formatting: driver shells with comma-decimal locales corrupt
# printf "%.2f" CSV columns and awk float output.
export LC_ALL=C

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jbr-skia-evidence-pass/$(date +%Y%m%d-%H%M%S)}"
SUMMARY="${OUT_ROOT}/summary.md"

RUN_IDE_SUITE="${RUN_IDE_SUITE:-true}"
RUN_PRESENTATION_SMOKE="${RUN_PRESENTATION_SMOKE:-true}"
RUN_TRACE_SANITY="${RUN_TRACE_SANITY:-true}"

REFRESH_SUDO="${REFRESH_SUDO:-true}"
DISCONNECT_DELAY_SECONDS="${DISCONNECT_DELAY_SECONDS:-30}"
SUDO_KEEPALIVE_INTERVAL_SECONDS="${SUDO_KEEPALIVE_INTERVAL_SECONDS:-60}"
WAIT_FOR_QUIET="${WAIT_FOR_QUIET:-false}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-2700}"
WAIT_INTERVAL_SECONDS="${WAIT_INTERVAL_SECONDS:-60}"

IDE_OUT_ROOT="${IDE_OUT_ROOT:-${OUT_ROOT}/ide-suite}"
BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH:-${ROOT_DIR}}"
IDE_CASES="${IDE_CASES:-redraw hypnotoad chat}"
IDE_REPEAT_COUNT="${IDE_REPEAT_COUNT:-1}"
IDE_SAMPLE_SECONDS="${IDE_SAMPLE_SECONDS:-60}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
DEFAULT_POWERMETRICS="/usr/bin/powermetrics"
if [[ -x "/usr/local/sbin/jbr-powermetrics-cpu-gpu" ]]; then
  DEFAULT_POWERMETRICS="/usr/local/sbin/jbr-powermetrics-cpu-gpu"
fi
POWERMETRICS="${POWERMETRICS:-${DEFAULT_POWERMETRICS}}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU:-true}"
REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT:-true}"
IDE_PER_VARIANT_PREFLIGHT="${IDE_PER_VARIANT_PREFLIGHT:-true}"
MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1:-999.0}"
MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU:-75.0}"
MAX_VARIANT_PREFLIGHT_WATCH_CPU="${MAX_VARIANT_PREFLIGHT_WATCH_CPU:-${MAX_VARIANT_PREFLIGHT_TOP_CPU}}"
PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES:-fseventsd mds mds_stores}"
PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS:-10}"
MAX_PREFLIGHT_GPU_POWER_MW="${MAX_PREFLIGHT_GPU_POWER_MW:-400}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW:-${MAX_PREFLIGHT_GPU_POWER_MW}}"
MAX_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_PREFLIGHT_GPU_POWER_PEAK_MW:-500}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW:-${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}}"
PACE_OLD_BASELINE="${PACE_OLD_BASELINE:-true}"
IDE_REQUIRE_PERF_REGRESSION_CLEAN="${IDE_REQUIRE_PERF_REGRESSION_CLEAN:-false}"
IDE_REQUIRE_POWERMETRICS="${IDE_REQUIRE_POWERMETRICS:-${COLLECT_POWERMETRICS}}"

PRESENTATION_OUT_ROOT="${PRESENTATION_OUT_ROOT:-${OUT_ROOT}/presentation-smoke}"
PRESENTATION_CASES="${PRESENTATION_CASES:-commands-live-animation commands-popup commands-popup-window commands-menu}"

TRACE_SECONDS="${TRACE_SECONDS:-25}"
TRACE_RENDER_MODE="${TRACE_RENDER_MODE:-commands}"
TRACE_ENABLED_DIR="${TRACE_ENABLED_DIR:-${OUT_ROOT}/trace-enabled}"
TRACE_DISABLED_DIR="${TRACE_DISABLED_DIR:-${OUT_ROOT}/trace-disabled-check}"
TRACE_CATEGORY="${TRACE_CATEGORY:-jbr-skia}"
TRACE_EXTRA_JVM_ARGS="${JBR_SKIA_INTEROP_EXTRA_JVM_ARGS:-}"

mkdir -p "${OUT_ROOT}"

{
  echo "# JBR Skia Evidence Pass"
  echo
  echo "- generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- out root: \`${OUT_ROOT}\`"
  echo "- IDE cases: \`${IDE_CASES}\`"
  echo "- IDE repeat count: \`${IDE_REPEAT_COUNT}\`"
  echo "- presentation cases: \`${PRESENTATION_CASES}\`"
  echo "- trace seconds: \`${TRACE_SECONDS}\`"
  echo
} > "${SUMMARY}"

overall_status=0
RUN_STATUS=0
SUDO_KEEPALIVE_PID=""

cleanup() {
  if [[ -n "${SUDO_KEEPALIVE_PID}" ]]; then
    kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
    wait "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

record_result() {
  local label="$1"
  local status="$2"
  local artifact="$3"

  if [[ "${status}" -eq 0 ]]; then
    echo "- ${label}: passed (\`${artifact}\`)" >> "${SUMMARY}"
  else
    echo "- ${label}: failed status=${status} (\`${artifact}\`)" >> "${SUMMARY}"
    overall_status=1
  fi
}

run_logged() {
  local label="$1"
  local log="$2"
  shift 2

  mkdir -p "$(dirname "${log}")"
  echo
  echo "== ${label} =="
  echo "log=${log}"

  set +e
  "$@" 2>&1 | tee "${log}"
  RUN_STATUS=${PIPESTATUS[0]}
  set -e

  record_result "${label}" "${RUN_STATUS}" "${log}"
  return 0
}

start_sudo_keepalive() {
  if [[ "${COLLECT_POWERMETRICS}" != "true" || "${REFRESH_SUDO}" != "true" ]]; then
    return
  fi
  (
    while true; do
      sudo -n -v 2>/dev/null || exit 0
      sleep "${SUDO_KEEPALIVE_INTERVAL_SECONDS}"
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
}

powermetrics_sudo_available() {
  sudo -n true 2>/dev/null && return 0
  [[ "$(basename "${POWERMETRICS}")" == "jbr-powermetrics-cpu-gpu" ]] || return 1
  sudo -n "${POWERMETRICS}" --check >/dev/null 2>&1
}

count_files() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    echo 0
    return
  fi
  find "${dir}" -type f 2>/dev/null | wc -l | tr -d ' '
}

if [[ "${RUN_IDE_SUITE}" == "true" ]]; then
  if [[ "${COLLECT_POWERMETRICS}" == "true" && "${REFRESH_SUDO}" == "true" ]]; then
    if ! powermetrics_sudo_available; then
      run_logged "sudo refresh for powermetrics" "${OUT_ROOT}/sudo-refresh.log" sudo -v
      if [[ "${RUN_STATUS}" -ne 0 ]]; then
        echo "error: sudo refresh failed; cannot collect powermetrics" >&2
        exit 1
      fi
      start_sudo_keepalive
    fi
    if [[ "${DISCONNECT_DELAY_SECONDS}" -gt 0 ]]; then
      run_logged "Screen Sharing disconnect delay" "${OUT_ROOT}/disconnect-delay.log" \
        sleep "${DISCONNECT_DELAY_SECONDS}"
    fi
  fi

  if [[ "${WAIT_FOR_QUIET}" == "true" ]]; then
    run_logged "fresh paced-vs-paced IDE suite after readiness wait" "${OUT_ROOT}/ide-suite.log" \
      env \
        OUT_ROOT="${IDE_OUT_ROOT}" \
        BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH}" \
        CASES="${IDE_CASES}" \
        REPEAT_COUNT="${IDE_REPEAT_COUNT}" \
        SAMPLE_SECONDS="${IDE_SAMPLE_SECONDS}" \
        COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
        POWERMETRICS="${POWERMETRICS}" \
        POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
        POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
        COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU}" \
        REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT}" \
        PER_VARIANT_PREFLIGHT="${IDE_PER_VARIANT_PREFLIGHT}" \
        MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1}" \
        MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU}" \
        MAX_VARIANT_PREFLIGHT_WATCH_CPU="${MAX_VARIANT_PREFLIGHT_WATCH_CPU}" \
        PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES}" \
        PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS}" \
        MAX_PREFLIGHT_GPU_POWER_MW="${MAX_PREFLIGHT_GPU_POWER_MW}" \
        MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}" \
        MAX_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}" \
        MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}" \
        PACE_OLD_BASELINE="${PACE_OLD_BASELINE}" \
        WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS}" \
        WAIT_INTERVAL_SECONDS="${WAIT_INTERVAL_SECONDS}" \
        "${SCRIPT_DIR}/jewel-ide-plugin-perf-ready-and-run.sh"
  else
    run_logged "fresh paced-vs-paced IDE suite" "${OUT_ROOT}/ide-suite.log" \
      env \
        OUT_ROOT="${IDE_OUT_ROOT}" \
        BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH}" \
        CASES="${IDE_CASES}" \
        REPEAT_COUNT="${IDE_REPEAT_COUNT}" \
        SAMPLE_SECONDS="${IDE_SAMPLE_SECONDS}" \
        COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
        POWERMETRICS="${POWERMETRICS}" \
        POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
        POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
        COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU}" \
        REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT}" \
        PER_VARIANT_PREFLIGHT="${IDE_PER_VARIANT_PREFLIGHT}" \
        MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1}" \
        MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU}" \
        MAX_VARIANT_PREFLIGHT_WATCH_CPU="${MAX_VARIANT_PREFLIGHT_WATCH_CPU}" \
        PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES}" \
        PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS}" \
        MAX_PREFLIGHT_GPU_POWER_MW="${MAX_PREFLIGHT_GPU_POWER_MW}" \
        MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}" \
        MAX_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}" \
        MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}" \
        PACE_OLD_BASELINE="${PACE_OLD_BASELINE}" \
        "${SCRIPT_DIR}/jewel-ide-plugin-perf-confirmation-suite.sh"
  fi

  if [[ -f "${IDE_OUT_ROOT}/suite.tsv" ]]; then
    run_logged "IDE suite analysis" "${OUT_ROOT}/ide-analysis.log" \
      env \
        REQUIRE_COMMAND_CLEAN=true \
        REQUIRE_VISUAL_PROBES=true \
        REQUIRE_POWERMETRICS="${IDE_REQUIRE_POWERMETRICS}" \
        REQUIRE_PERF_REGRESSION_CLEAN="${IDE_REQUIRE_PERF_REGRESSION_CLEAN}" \
        "${SCRIPT_DIR}/analyze-jewel-ide-plugin-benchmark-suite.sh" \
        "${IDE_OUT_ROOT}/suite.tsv" \
        "${IDE_OUT_ROOT}/analysis.md"
    {
      echo "- IDE suite: \`${IDE_OUT_ROOT}/suite.tsv\`"
      echo "- IDE analysis: \`${IDE_OUT_ROOT}/analysis.md\`"
    } >> "${SUMMARY}"
  else
    record_result "IDE suite analysis" 2 "${IDE_OUT_ROOT}/suite.tsv missing"
  fi
fi

if [[ "${RUN_PRESENTATION_SMOKE}" == "true" ]]; then
  run_logged "presentation smoke command probes" "${OUT_ROOT}/presentation-smoke.log" \
    env \
      OUT_ROOT="${PRESENTATION_OUT_ROOT}" \
      CASES="${PRESENTATION_CASES}" \
      "${SCRIPT_DIR}/jbr-skia-command-probe-suite.sh"
  if [[ -f "${PRESENTATION_OUT_ROOT}/suite.tsv" ]]; then
    echo "- presentation smoke suite: \`${PRESENTATION_OUT_ROOT}/suite.tsv\`" >> "${SUMMARY}"
  fi
fi

if [[ "${RUN_TRACE_SANITY}" == "true" ]]; then
  trace_jvm_args="${TRACE_EXTRA_JVM_ARGS} -Dmagic.jewel.autoExitSeconds=${TRACE_SECONDS}"
  mkdir -p "${TRACE_ENABLED_DIR}" "${TRACE_DISABLED_DIR}"

  run_logged "Perfetto trace enabled sanity" "${OUT_ROOT}/trace-enabled.log" \
    env \
      JBR_SKIA_TRACE_ENABLED=true \
      JBR_SKIA_TRACE_DIR="${TRACE_ENABLED_DIR}" \
      JBR_SKIA_TRACE_CATEGORY="${TRACE_CATEGORY}" \
      JBR_SKIA_RENDER_MODE="${TRACE_RENDER_MODE}" \
      JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${trace_jvm_args}" \
      "${SCRIPT_DIR}/run-jbr-skia.sh"
  enabled_trace_files="$(count_files "${TRACE_ENABLED_DIR}")"
  if [[ "${enabled_trace_files}" -gt 0 ]]; then
    record_result "trace enabled file check" 0 "${TRACE_ENABLED_DIR} (${enabled_trace_files} files)"
  else
    record_result "trace enabled file check" 2 "${TRACE_ENABLED_DIR} (no files)"
  fi

  run_logged "Perfetto trace disabled sanity" "${OUT_ROOT}/trace-disabled.log" \
    env \
      JBR_SKIA_TRACE_ENABLED=false \
      JBR_SKIA_TRACE_DIR="${TRACE_DISABLED_DIR}" \
      JBR_SKIA_TRACE_CATEGORY="${TRACE_CATEGORY}" \
      JBR_SKIA_RENDER_MODE="${TRACE_RENDER_MODE}" \
      JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${trace_jvm_args}" \
      "${SCRIPT_DIR}/run-jbr-skia.sh"
  disabled_trace_files="$(count_files "${TRACE_DISABLED_DIR}")"
  if [[ "${disabled_trace_files}" -eq 0 ]]; then
    record_result "trace disabled file check" 0 "${TRACE_DISABLED_DIR} (no files)"
  else
    record_result "trace disabled file check" 2 "${TRACE_DISABLED_DIR} (${disabled_trace_files} files)"
  fi
fi

{
  echo
  echo "## Knobs"
  echo
  echo "- \`WAIT_FOR_QUIET=true\`: poll readiness before the IDE suite."
  echo "- \`DISCONNECT_DELAY_SECONDS=N\`: wait after the interactive sudo prompt before measurement starts; default is 30."
  echo "- \`SUDO_KEEPALIVE_INTERVAL_SECONDS=N\`: refresh the sudo ticket during long powermetrics runs; default is 60."
  echo "- \`REQUIRE_CLEAN_PREFLIGHT=false\`: force IDE suite through noisy preflight."
  echo "- \`IDE_REPEAT_COUNT=5\`: run an interleaved N-pass IDE suite, labelled as \`case#rNN\` rows."
  echo "- \`IDE_PER_VARIANT_PREFLIGHT=false\`: skip the per-old/new-launch preflight snapshots."
  echo "- \`MAX_VARIANT_PREFLIGHT_LOAD_1=N\`: override the per-launch load gate; default is informational at 999."
  echo "- \`MAX_VARIANT_PREFLIGHT_TOP_CPU=N\`: override the per-launch top-process CPU gate."
  echo "- \`MAX_VARIANT_PREFLIGHT_WATCH_CPU=N\`: override the watched-process CPU gate for \`PREFLIGHT_WATCH_PROCESSES\`."
  echo "- \`MAX_PREFLIGHT_GPU_POWER_MW=N\` / \`MAX_PREFLIGHT_GPU_POWER_PEAK_MW=N\`: override the symmetric idle GPU average/peak gates; defaults are 400/500 mW."
  echo "- \`RUN_IDE_SUITE=false\`, \`RUN_PRESENTATION_SMOKE=false\`, \`RUN_TRACE_SANITY=false\`: skip sections."
  echo "- \`TRACE_SECONDS=N\`: change the auto-exit duration for standalone trace sanity runs."
} >> "${SUMMARY}"

echo
cat "${SUMMARY}"
exit "${overall_status}"
