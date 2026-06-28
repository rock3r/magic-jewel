#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
CASES="${CASES:-hypnotoad chat}"
SAMPLE_SECONDS="${SAMPLE_SECONDS:-90}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH:-/Users/rock3r/src/uel}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
POWERMETRICS="${POWERMETRICS:-/usr/bin/powermetrics}"
DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE:-commands}"
JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${JBR_SKIA_INTEROP_EXTRA_JVM_ARGS:--Dcompose.jbr.skia.command.logOpCounts=true -Dcompose.jbr.skia.command.strict=true}"

mkdir -p "${OUT_ROOT}"

if [[ ! -d "${BENCHMARK_PROJECT_PATH}" ]]; then
  echo "error: BENCHMARK_PROJECT_PATH does not exist: ${BENCHMARK_PROJECT_PATH}" >&2
  exit 2
fi

if [[ "${COLLECT_POWERMETRICS}" == "true" ]] && ! sudo -n true 2>/dev/null; then
  echo "error: COLLECT_POWERMETRICS=true requires a cached sudo credential; run 'sudo -v' first" >&2
  exit 2
fi

jbr_args() {
  printf '%s ' \
    "--patch-module=java.desktop=${DESKTOP_PATCH}" \
    "-Xbootclasspath/a:${JBR_API_SHIM}" \
    "--add-exports=java.desktop/com.jetbrains.desktop=ALL-UNNAMED" \
    "-Dsun.java2d.skia.interop=true" \
    "-Dsun.java2d.skia.interop.library=${JBR_SKIA_LIB}" \
    ${JBR_SKIA_INTEROP_EXTRA_JVM_ARGS}
}

find_ide_pid() {
  local mode="$1"
  pgrep -f "magic.jewel.benchmark.mode=${mode}" | tail -1 || true
}

sample_process() {
  local mode="$1"
  local variant="$2"
  local pid="$3"
  local csv="$4"
  echo "timestamp,mode,variant,pid,cpu_percent,rss_kb" > "${csv}"
  while kill -0 "${pid}" 2>/dev/null; do
    ps -p "${pid}" -o %cpu= -o rss= | awk -v mode="${mode}" -v variant="${variant}" -v pid="${pid}" \
      '{printf "%s,%s,%s,%s,%.2f,%s\n", systime(), mode, variant, pid, $1, $2}'
    sleep 2
  done >> "${csv}"
}

start_powermetrics() {
  local out="$1"
  if [[ "${COLLECT_POWERMETRICS}" != "true" ]]; then
    echo "disabled" > "${out}.status"
    return
  fi
  sudo -n "${POWERMETRICS}" --samplers "${POWERMETRICS_SAMPLERS}" -i "${POWERMETRICS_INTERVAL_MS}" -o "${out}" \
    >"${out}.stdout" 2>"${out}.stderr" &
  echo $! > "${out}.pid"
  echo "started pid=$! samplers=${POWERMETRICS_SAMPLERS} intervalMs=${POWERMETRICS_INTERVAL_MS}" > "${out}.status"
}

stop_pid_file() {
  local pid_file="$1"
  [[ -f "${pid_file}" ]] || return
  local pid
  pid="$(cat "${pid_file}")"
  kill "${pid}" 2>/dev/null || true
  wait "${pid}" 2>/dev/null || true
}

summarize_ps() {
  local csv="$1"
  awk -F, 'NR>1 {sum+=$5; rss+=$6; if($5>max) max=$5; if($6>maxrss) maxrss=$6; n++}
    END {if(n) printf "samples=%d avg_cpu=%.2f max_cpu=%.2f avg_rss_kb=%.0f max_rss_kb=%.0f", n, sum/n, max, rss/n, maxrss; else printf "samples=0"}' "${csv}"
}

run_variant() {
  local case_name="$1"
  local variant="$2"
  local case_dir="$3"
  local log="${case_dir}/${variant}.log"
  local ps_csv="${case_dir}/${variant}-ps.csv"
  local pm="${case_dir}/${variant}-powermetrics.txt"

  local -a args=(
    --no-daemon --no-configuration-cache
    :ide-benchmark-plugin:runIde
    -PmagicJewelBenchmarkAutorun=true
    "-PmagicJewelBenchmarkMode=${case_name}"
    "-PmagicJewelBenchmarkOut=${case_dir}"
    "-PmagicJewelBenchmarkProjectPath=${BENCHMARK_PROJECT_PATH}"
    --console=plain
  )
  if [[ "${variant}" == "new" ]]; then
    args+=(
      -PjbrSkiaInterop=true
      "-PjbrSkiaRenderMode=${JBR_SKIA_RENDER_MODE}"
      "-PjbrSkiaInteropJvmArgs=$(jbr_args)"
    )
  fi

  (cd "${ROOT_DIR}" && ./gradlew "${args[@]}") > "${log}" 2>&1 &
  local gradle_pid=$!

  local pid=""
  for _ in {1..180}; do
    pid="$(find_ide_pid "${case_name}")"
    if [[ -n "${pid}" ]] && grep -q "MAGIC_JEWEL_IDE_BENCHMARK status=started" "${log}" 2>/dev/null; then
      break
    fi
    sleep 1
  done
  if [[ -z "${pid}" ]]; then
    echo "failed_to_find_ide_pid=true" >> "${case_dir}/summary.properties"
    kill "${gradle_pid}" 2>/dev/null || true
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi

  sample_process "${case_name}" "${variant}" "${pid}" "${ps_csv}" &
  local sampler_pid=$!
  start_powermetrics "${pm}"

  sleep "${SAMPLE_SECONDS}"

  stop_pid_file "${pm}.pid"
  kill "${sampler_pid}" 2>/dev/null || true
  kill "${pid}" 2>/dev/null || true
  kill "${gradle_pid}" 2>/dev/null || true
  wait "${sampler_pid}" 2>/dev/null || true
  wait "${gradle_pid}" 2>/dev/null || true

  echo "${variant}_pid=${pid}" >> "${case_dir}/summary.properties"
  echo "${variant}_ps=$(summarize_ps "${ps_csv}")" >> "${case_dir}/summary.properties"
  echo "${variant}_command_frames=$(grep -c 'JBR_SKIA_INTEROP_COMMAND_FRAME' "${log}" || true)" >> "${case_dir}/summary.properties"
  echo "${variant}_picture_frames=$(grep -c 'JBR_SKIA_INTEROP_PICTURE_FRAME' "${log}" || true)" >> "${case_dir}/summary.properties"
  echo "${variant}_fallbacks=$(grep -c 'JBR_SKIA_INTEROP_FALLBACK' "${log}" || true)" >> "${case_dir}/summary.properties"
}

suite_tsv="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\told_ps\tnew_ps\told_command_frames\tnew_command_frames\told_picture_frames\tnew_picture_frames\told_fallbacks\tnew_fallbacks\treport\n" > "${suite_tsv}"

for case_name in ${CASES}; do
  case_dir="${OUT_ROOT}/${case_name}"
  mkdir -p "${case_dir}"
  echo "case=${case_name}" > "${case_dir}/summary.properties"
  echo "sample_seconds=${SAMPLE_SECONDS}" >> "${case_dir}/summary.properties"
  echo "collect_powermetrics=${COLLECT_POWERMETRICS}" >> "${case_dir}/summary.properties"
  echo "benchmark_project_path=${BENCHMARK_PROJECT_PATH}" >> "${case_dir}/summary.properties"
  status="passed"
  run_variant "${case_name}" old "${case_dir}" || status="failed"
  run_variant "${case_name}" new "${case_dir}" || status="failed"
  old_ps="$(grep '^old_ps=' "${case_dir}/summary.properties" | sed 's/^old_ps=//' || true)"
  new_ps="$(grep '^new_ps=' "${case_dir}/summary.properties" | sed 's/^new_ps=//' || true)"
  old_command="$(grep '^old_command_frames=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  new_command="$(grep '^new_command_frames=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  old_picture="$(grep '^old_picture_frames=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  new_picture="$(grep '^new_picture_frames=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  old_fallbacks="$(grep '^old_fallbacks=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  new_fallbacks="$(grep '^new_fallbacks=' "${case_dir}/summary.properties" | cut -d= -f2 || true)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${case_name}" "${status}" "${old_ps}" "${new_ps}" "${old_command}" "${new_command}" \
    "${old_picture}" "${new_picture}" "${old_fallbacks}" "${new_fallbacks}" "${case_dir}" >> "${suite_tsv}"
done

echo "suite=${suite_tsv}"
