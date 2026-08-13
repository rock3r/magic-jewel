#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

summarize_gpu_power() {
  local file="$1"
  local max_gpu_power_avg_mw="$2"
  local max_gpu_power_peak_mw="$3"
  local summary
  set +e
  summary="$(
    awk \
      -v max_gpu_power_avg_mw="${max_gpu_power_avg_mw}" \
      -v max_gpu_power_peak_mw="${max_gpu_power_peak_mw}" '
      /^GPU Power:/ {
        samples++
        sum += $3 + 0
        if ($3 + 0 > max) max = $3 + 0
      }
      END {
        if (!samples) {
          printf "status=unavailable reason=gpu-power-unavailable samples=0 gpu_power_avg_mw=0 gpu_power_max_mw=0 max_gpu_power_avg_mw=%.0f max_gpu_power_peak_mw=%.0f", max_gpu_power_avg_mw, max_gpu_power_peak_mw
          exit 2
        }
        avg = sum / samples
        status = "passed"
        reason = "none"
        if (avg > max_gpu_power_avg_mw) {
          status = "blocked"
          reason = sprintf("gpu-power-avg>%.0fmW", max_gpu_power_avg_mw)
        } else if (max > max_gpu_power_peak_mw) {
          status = "blocked"
          reason = sprintf("gpu-power-peak>%.0fmW", max_gpu_power_peak_mw)
        }
        printf "status=%s reason=%s samples=%d gpu_power_avg_mw=%.0f gpu_power_max_mw=%.0f max_gpu_power_avg_mw=%.0f max_gpu_power_peak_mw=%.0f", status, reason, samples, avg, max, max_gpu_power_avg_mw, max_gpu_power_peak_mw
        exit status == "passed" ? 0 : 1
      }' "${file}"
  )"
  local status=$?
  set -e
  printf '%s\n' "${summary}"
  return "${status}"
}

if [[ "${1:-}" == "--summarize" ]]; then
  [[ $# -eq 4 ]] || {
    echo "usage: $0 --summarize POWERMETRICS_FILE MAX_GPU_POWER_AVG_MW MAX_GPU_POWER_PEAK_MW" >&2
    exit 2
  }
  summarize_gpu_power "$2" "$3" "$4"
  exit $?
fi

[[ $# -eq 4 ]] || {
  echo "usage: $0 OUTPUT_FILE SAMPLE_SECONDS MAX_GPU_POWER_AVG_MW MAX_GPU_POWER_PEAK_MW" >&2
  exit 2
}

out="$1"
sample_seconds="$2"
max_gpu_power_avg_mw="$3"
max_gpu_power_peak_mw="$4"
powermetrics="${POWERMETRICS:-/usr/bin/powermetrics}"
interval_ms="${POWERMETRICS_INTERVAL_MS:-500}"
samplers="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
pid=""

cleanup() {
  if [[ -n "${pid}" ]]; then
    kill "${pid}" 2>/dev/null || true
    wait "${pid}" 2>/dev/null || true
    pid=""
  fi
}

trap cleanup EXIT

rm -f "${out}" "${out}.stdout" "${out}.stderr"
sudo -n "${powermetrics}" --samplers "${samplers}" -i "${interval_ms}" -o "${out}" \
  >"${out}.stdout" 2>"${out}.stderr" &
pid=$!
sleep "${sample_seconds}"
cleanup
trap - EXIT

summarize_gpu_power "${out}" "${max_gpu_power_avg_mw}" "${max_gpu_power_peak_mw}"
