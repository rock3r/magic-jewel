#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
CASES="${CASES:-redraw hypnotoad chat}"
VARIANTS="${VARIANTS:-old new}"
REPEAT_COUNT="${REPEAT_COUNT:-1}"
SAMPLE_SECONDS="${SAMPLE_SECONDS:-60}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU:-true}"
PAINT_PROBE="${PAINT_PROBE:-true}"
PER_VARIANT_PREFLIGHT="${PER_VARIANT_PREFLIGHT:-true}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
DEFAULT_POWERMETRICS="/usr/bin/powermetrics"
if [[ -x "/usr/local/sbin/jbr-powermetrics-cpu-gpu" ]]; then
  DEFAULT_POWERMETRICS="/usr/local/sbin/jbr-powermetrics-cpu-gpu"
fi
POWERMETRICS="${POWERMETRICS:-${DEFAULT_POWERMETRICS}}"
GPU_POWER_PREFLIGHT="${GPU_POWER_PREFLIGHT:-${SCRIPT_DIR}/jbr-skia-gpu-power-preflight.sh}"
PREFLIGHT_ONLY="${PREFLIGHT_ONLY:-false}"
REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT:-true}"
MAX_PREFLIGHT_LOAD_1="${MAX_PREFLIGHT_LOAD_1:-6.0}"
MAX_PREFLIGHT_TOP_CPU="${MAX_PREFLIGHT_TOP_CPU:-75.0}"
MAX_PREFLIGHT_WATCH_CPU="${MAX_PREFLIGHT_WATCH_CPU:-${MAX_PREFLIGHT_TOP_CPU}}"
PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES:-fseventsd mds mds_stores}"
MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1:-999.0}"
MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU:-${MAX_PREFLIGHT_TOP_CPU}}"
PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS:-10}"
MAX_PREFLIGHT_GPU_POWER_MW="${MAX_PREFLIGHT_GPU_POWER_MW:-400}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW:-${MAX_PREFLIGHT_GPU_POWER_MW}}"
MAX_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_PREFLIGHT_GPU_POWER_PEAK_MW:-500}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW:-${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}}"

powermetrics_sudo_available() {
  sudo -n true 2>/dev/null && return 0
  [[ "$(basename "${POWERMETRICS}")" == "jbr-powermetrics-cpu-gpu" ]] || return 1
  sudo -n "${POWERMETRICS}" --check >/dev/null 2>&1
}

powermetrics_sudo_cached="not-required"
if [[ "${COLLECT_POWERMETRICS}" == "true" ]]; then
  if powermetrics_sudo_available; then
    powermetrics_sudo_cached="true"
  else
    powermetrics_sudo_cached="false"
  fi
fi

mkdir -p "${OUT_ROOT}"
preflight_file="${OUT_ROOT}/machine-preflight.txt"
preflight_ps_file="${OUT_ROOT}/machine-preflight-ps.txt"
preflight_load_1="$(
  uptime | awk '
    {
      load = $0
      sub(/^.*load averages?: /, "", load)
      split(load, parts, /[ ,]+/)
      print parts[1]
    }' 2>/dev/null || true
)"
preflight_top_cpu=""
preflight_watch_cpu=""
preflight_watch_process=""
if command -v ps >/dev/null 2>&1 && command -v sort >/dev/null 2>&1; then
  ps -Ao pid,pcpu,pmem,comm 2>/dev/null | sort -k2 -nr | head -15 > "${preflight_ps_file}" || true
  preflight_top_cpu="$(awk 'NR == 1 { print $2; exit }' "${preflight_ps_file}" 2>/dev/null || true)"
  preflight_watch_summary="$(
    awk -v watch_processes="${PREFLIGHT_WATCH_PROCESSES}" '
      BEGIN {
        split(watch_processes, watched, " ")
      }
      NR == 1 { next }
      {
        command = $4
        for (i = 5; i <= NF; i++) {
          command = command " " $i
        }
        basename = command
        sub(/^.*\//, "", basename)
        for (i in watched) {
          if (basename == watched[i] && $2 + 0 > maxCpu) {
            maxCpu = $2 + 0
            maxProcess = basename
            maxPid = $1
          }
        }
      }
      END {
        if (maxProcess != "") {
          printf "process=%s pid=%s cpu=%.2f", maxProcess, maxPid, maxCpu
        }
      }' "${preflight_ps_file}" 2>/dev/null || true
  )"
  preflight_watch_cpu="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^cpu=/) { sub(/^cpu=/, "", $i); print $i; exit } }' <<< "${preflight_watch_summary:-}" 2>/dev/null || true)"
  preflight_watch_process="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^process=/) { sub(/^process=/, "", $i); print $i; exit } }' <<< "${preflight_watch_summary:-}" 2>/dev/null || true)"
fi
preflight_gpu_power_file="${OUT_ROOT}/machine-preflight-powermetrics.txt"
preflight_gpu_power_summary="status=disabled reason=none samples=0 gpu_power_avg_mw=0 gpu_power_max_mw=0 max_gpu_power_avg_mw=${MAX_PREFLIGHT_GPU_POWER_MW} max_gpu_power_peak_mw=${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}"
preflight_gpu_power_status=0
if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" == "true" ]]; then
  set +e
  preflight_gpu_power_summary="$(
    POWERMETRICS="${POWERMETRICS}" \
    POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
    POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
      "${GPU_POWER_PREFLIGHT}" \
        "${preflight_gpu_power_file}" \
        "${PREFLIGHT_GPU_SAMPLE_SECONDS}" \
        "${MAX_PREFLIGHT_GPU_POWER_MW}" \
        "${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}"
  )"
  preflight_gpu_power_status=$?
  set -e
fi
preflight_ready="true"
preflight_reasons=()
if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" != "true" ]]; then
  preflight_ready="false"
  preflight_reasons+=("powermetrics-sudo-missing")
fi
if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" == "true" ]]; then
  if [[ "${preflight_gpu_power_status}" -eq 1 ]]; then
    preflight_ready="false"
    preflight_gpu_power_reason="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^reason=/) { sub(/^reason=/, "", $i); print $i; exit } }' <<< "${preflight_gpu_power_summary}")"
    preflight_reasons+=("${preflight_gpu_power_reason:-gpu-power-blocked}")
  elif [[ "${preflight_gpu_power_status}" -ne 0 ]]; then
    preflight_ready="false"
    preflight_reasons+=("gpu-power-unavailable")
  fi
fi
if [[ -n "${preflight_load_1}" ]] && ! awk -v value="${preflight_load_1}" -v max="${MAX_PREFLIGHT_LOAD_1}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
  preflight_ready="false"
  preflight_reasons+=("load1>${MAX_PREFLIGHT_LOAD_1}")
fi
if [[ -n "${preflight_top_cpu}" ]] && ! awk -v value="${preflight_top_cpu}" -v max="${MAX_PREFLIGHT_TOP_CPU}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
  preflight_ready="false"
  preflight_reasons+=("top-cpu>${MAX_PREFLIGHT_TOP_CPU}")
fi
if [[ -n "${preflight_watch_cpu}" ]] && ! awk -v value="${preflight_watch_cpu}" -v max="${MAX_PREFLIGHT_WATCH_CPU}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
  preflight_ready="false"
  preflight_reasons+=("${preflight_watch_process:-watched-process}-cpu>${MAX_PREFLIGHT_WATCH_CPU}")
fi
preflight_reason="none"
if ((${#preflight_reasons[@]})); then
  preflight_reason="${preflight_reasons[*]}"
fi

{
  echo "== IDE perf confirmation preflight =="
  uptime || true
  echo
  if [[ -s "${preflight_ps_file}" ]]; then
    cat "${preflight_ps_file}"
  fi
  echo
  echo "out_root=${OUT_ROOT}"
  echo "cases=${CASES}"
  echo "variants=${VARIANTS}"
  echo "repeat_count=${REPEAT_COUNT}"
  echo "sample_seconds=${SAMPLE_SECONDS}"
  echo "collect_powermetrics=${COLLECT_POWERMETRICS}"
  echo "collect_thread_cpu=${COLLECT_THREAD_CPU}"
  echo "paint_probe=${PAINT_PROBE}"
  echo "per_variant_preflight=${PER_VARIANT_PREFLIGHT}"
  echo "powermetrics_interval_ms=${POWERMETRICS_INTERVAL_MS}"
  echo "powermetrics_samplers=${POWERMETRICS_SAMPLERS}"
  echo "powermetrics_sudo_cached=${powermetrics_sudo_cached}"
  echo "require_clean_preflight=${REQUIRE_CLEAN_PREFLIGHT}"
  echo "max_preflight_load_1=${MAX_PREFLIGHT_LOAD_1}"
  echo "max_preflight_top_cpu=${MAX_PREFLIGHT_TOP_CPU}"
  echo "max_preflight_watch_cpu=${MAX_PREFLIGHT_WATCH_CPU}"
  echo "preflight_gpu_sample_seconds=${PREFLIGHT_GPU_SAMPLE_SECONDS}"
  echo "max_preflight_gpu_power_mw=${MAX_PREFLIGHT_GPU_POWER_MW}"
  echo "max_preflight_gpu_power_peak_mw=${MAX_PREFLIGHT_GPU_POWER_PEAK_MW}"
  echo "max_variant_preflight_gpu_power_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}"
  echo "max_variant_preflight_gpu_power_peak_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}"
  echo "preflight_watch_processes=${PREFLIGHT_WATCH_PROCESSES}"
  echo "max_variant_preflight_load_1=${MAX_VARIANT_PREFLIGHT_LOAD_1}"
  echo "max_variant_preflight_top_cpu=${MAX_VARIANT_PREFLIGHT_TOP_CPU}"
  echo "preflight_load_1=${preflight_load_1:-unknown}"
  echo "preflight_top_cpu=${preflight_top_cpu:-unknown}"
  echo "preflight_watch_process=${preflight_watch_process:-none}"
  echo "preflight_watch_cpu=${preflight_watch_cpu:-0}"
  echo "preflight_gpu_power_file=${preflight_gpu_power_file}"
  echo "preflight_gpu_power_summary=${preflight_gpu_power_summary}"
  echo "preflight_ready=${preflight_ready}"
  echo "preflight_reason=${preflight_reason}"
  echo "preflight_only=${PREFLIGHT_ONLY}"
} | tee "${preflight_file}"

if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" != "true" ]]; then
  cat >&2 <<EOF
error: COLLECT_POWERMETRICS=true requires a cached sudo credential for powermetrics.
Run \`sudo -v\` first, or rerun with COLLECT_POWERMETRICS=false for CPU/thread/command timing only.
Wrote preflight snapshot: ${preflight_file}
EOF
  exit 2
fi

if [[ "${PREFLIGHT_ONLY}" == "true" ]]; then
  if [[ "${REQUIRE_CLEAN_PREFLIGHT}" == "true" && "${preflight_ready}" != "true" ]]; then
    echo "error: perf preflight is not clean: ${preflight_reason}" >&2
    exit 3
  fi
  echo "PREFLIGHT_ONLY=true; wrote ${preflight_file}"
  exit 0
fi

if [[ "${REQUIRE_CLEAN_PREFLIGHT}" == "true" && "${preflight_ready}" != "true" ]]; then
  cat >&2 <<EOF
error: perf preflight is not clean enough for a confirmation run: ${preflight_reason}
Set REQUIRE_CLEAN_PREFLIGHT=false to force the run, or rerun when the machine is quieter.
Wrote preflight snapshot: ${preflight_file}
EOF
  exit 3
fi

exec env \
  OUT_ROOT="${OUT_ROOT}" \
  CASES="${CASES}" \
  VARIANTS="${VARIANTS}" \
  REPEAT_COUNT="${REPEAT_COUNT}" \
  SAMPLE_SECONDS="${SAMPLE_SECONDS}" \
  COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS}" \
  COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU}" \
  PAINT_PROBE="${PAINT_PROBE}" \
  PER_VARIANT_PREFLIGHT="${PER_VARIANT_PREFLIGHT}" \
  REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT}" \
  MAX_PREFLIGHT_LOAD_1="${MAX_PREFLIGHT_LOAD_1}" \
  MAX_PREFLIGHT_TOP_CPU="${MAX_PREFLIGHT_TOP_CPU}" \
  MAX_PREFLIGHT_WATCH_CPU="${MAX_PREFLIGHT_WATCH_CPU}" \
  PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES}" \
  MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1}" \
  MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU}" \
  PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS}" \
  MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}" \
  MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}" \
  POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
  POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
  "${SCRIPT_DIR}/jewel-ide-plugin-benchmark-suite.sh"
