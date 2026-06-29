#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
CASES="${CASES:-hypnotoad chat}"
VARIANTS="${VARIANTS:-old new}"
SAMPLE_SECONDS="${SAMPLE_SECONDS:-90}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
PAINT_PROBE="${PAINT_PROBE:-true}"
BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH:-/Users/rock3r/src/uel}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
POWERMETRICS="${POWERMETRICS:-/usr/bin/powermetrics}"
DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE:-commands}"
JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${JBR_SKIA_INTEROP_EXTRA_JVM_ARGS:--Dcompose.jbr.skia.command.logOpCounts=true -Dcompose.jbr.skia.command.strict=true}"
LOCAL_CMP_OUT="${LOCAL_CMP_OUT:-${ROOT_DIR}/../cmp/out/compose-multiplatform-core}"
LOCAL_SKIKO_AWT_JAR="${LOCAL_SKIKO_AWT_JAR:-${ROOT_DIR}/../skiko/skiko/build/libs/skiko-awt-0.0.0-SNAPSHOT.jar}"
LOCAL_SKIKO_NATIVE_LIB="${LOCAL_SKIKO_NATIVE_LIB:-${ROOT_DIR}/../skiko/skiko/build/maybe-signed-macos-arm64/libskiko-macos-arm64.dylib}"
IDE_PRODUCT_LIB="${IDE_PRODUCT_LIB:-$(find "${HOME}/.gradle/caches/9.4.1/transforms" -type d -path '*/transformed/idea-2026.1.1-aarch64/lib' 2>/dev/null | head -1)}"
IDE_PRODUCT_HOME="${IDE_PRODUCT_HOME:-${IDE_PRODUCT_LIB%/lib}}"
PATCHED_IDE_PRODUCT_HOME="${PATCHED_IDE_PRODUCT_HOME:-${OUT_ROOT}/patched-idea-2026.1.1-aarch64}"
COMPOSE_RUNTIME_BOOT_JAR="${COMPOSE_RUNTIME_BOOT_JAR:-${HOME}/.gradle/caches/modules-2/files-2.1/androidx.compose.runtime/runtime-desktop/1.11.0-beta02/175abab71b8fd8352e7b19505bf1f07d4415a37a/runtime-desktop-1.11.0-beta02.jar}"

mkdir -p "${OUT_ROOT}"

if [[ ! -d "${BENCHMARK_PROJECT_PATH}" ]]; then
  echo "error: BENCHMARK_PROJECT_PATH does not exist: ${BENCHMARK_PROJECT_PATH}" >&2
  exit 2
fi

validate_jbr_skia_inputs() {
  [[ -d "${DESKTOP_PATCH}" ]] || {
    echo "error: DESKTOP_PATCH does not exist: ${DESKTOP_PATCH}" >&2
    exit 2
  }
  [[ -f "${JBR_API_SHIM}" ]] || {
    echo "error: JBR_API_SHIM does not exist: ${JBR_API_SHIM}" >&2
    exit 2
  }
  [[ -f "${JBR_SKIA_LIB}" ]] || {
    echo "error: JBR_SKIA_LIB does not exist: ${JBR_SKIA_LIB}" >&2
    exit 2
  }
}

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

patched_compose_desktop_jars() {
  find "${LOCAL_CMP_OUT}" -type f -path '*/build/libs/*.jar' \
    \( -name '*-desktop-9999.0.0-SNAPSHOT.jar' -o -name 'desktop-jvm-9999.0.0-SNAPSHOT.jar' -o -name 'annotation-jvm-9999.0.0-SNAPSHOT.jar' -o -name 'collection-jvm-9999.0.0-SNAPSHOT.jar' \) \
    ! -path '*/compose/runtime/runtime/*' \
    | sort
}

prepare_patched_ide_product() {
  validate_jbr_skia_inputs
  [[ -d "${IDE_PRODUCT_HOME}" ]] || {
    echo "error: IDE_PRODUCT_HOME does not exist: ${IDE_PRODUCT_HOME}" >&2
    exit 2
  }
  [[ -f "${COMPOSE_RUNTIME_BOOT_JAR}" ]] || {
    echo "error: COMPOSE_RUNTIME_BOOT_JAR does not exist: ${COMPOSE_RUNTIME_BOOT_JAR}" >&2
    exit 2
  }
  if [[ -f "${PATCHED_IDE_PRODUCT_HOME}/.magic-jewel-patched" ]]; then
    return
  fi

  rm -rf "${PATCHED_IDE_PRODUCT_HOME}"
  mkdir -p "$(dirname "${PATCHED_IDE_PRODUCT_HOME}")"
  if cp -R -c "${IDE_PRODUCT_HOME}" "${PATCHED_IDE_PRODUCT_HOME}" 2>/dev/null; then
    :
  else
    cp -R "${IDE_PRODUCT_HOME}" "${PATCHED_IDE_PRODUCT_HOME}"
  fi

  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.skiko.jar" "${LOCAL_SKIKO_AWT_JAR}"
  mkdir -p "${PATCHED_IDE_PRODUCT_HOME}/lib/skiko-awt-runtime-all"
  cp "${LOCAL_SKIKO_NATIVE_LIB}" "${PATCHED_IDE_PRODUCT_HOME}/lib/skiko-awt-runtime-all/libskiko-macos-arm64.dylib"
  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.compose.runtime.desktop.jar" "${COMPOSE_RUNTIME_BOOT_JAR}"

  local compose_jars=()
  while IFS= read -r jar; do
    compose_jars+=("${jar}")
  done < <(patched_compose_desktop_jars)
  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.compose.foundation.desktop.jar" "${compose_jars[@]}"
  echo "patched_ide_product_home=${PATCHED_IDE_PRODUCT_HOME}" > "${PATCHED_IDE_PRODUCT_HOME}/.magic-jewel-patched"
}

overlay_jar() {
  local target="$1"
  shift
  local merge_dir="${OUT_ROOT}/jar-overlay-$(basename "${target}")"
  rm -rf "${merge_dir}"
  mkdir -p "${merge_dir}"
  for jar in "$@"; do
    (cd "${merge_dir}" && jar xf "${jar}")
  done
  (cd "${merge_dir}" && jar uf "${target}" .)
  rm -rf "${merge_dir}"
}

find_ide_pid() {
  local mode="$1"
  local pid
  while read -r pid; do
    [[ -n "${pid}" ]] || continue
    ps -p "${pid}" -o command= 2>/dev/null | grep -q '/jbr/Contents/Home/bin/java' || continue
    ps -p "${pid}" -o command= 2>/dev/null | grep -q "magic.jewel.benchmark.mode=${mode}" || continue
    echo "${pid}"
    return 0
  done < <(pgrep -f "magic.jewel.benchmark.mode=${mode}" || true)
  return 0
}

sample_process() {
  local mode="$1"
  local variant="$2"
  local pid="$3"
  local csv="$4"
  echo "timestamp,mode,variant,pid,cpu_percent,rss_kb" > "${csv}"
  while kill -0 "${pid}" 2>/dev/null; do
    ps -p "${pid}" -o %cpu= -o rss= | while read -r cpu rss; do
      [[ -n "${cpu}" && -n "${rss}" ]] || continue
      printf "%s,%s,%s,%s,%.2f,%s\n" "$(date +%s)" "${mode}" "${variant}" "${pid}" "${cpu}" "${rss}"
    done
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

summary_value() {
  local file="$1"
  local key="$2"
  awk -F= -v key="${key}" '$1 == key { sub(/^[^=]*=/, ""); print; found=1; exit } END { if (!found) exit 0 }' "${file}"
}

run_variant() {
  local case_name="$1"
  local variant="$2"
  local case_dir="$3"
  local log="${case_dir}/${variant}.log"
  local ps_csv="${case_dir}/${variant}-ps.csv"
  local pm="${case_dir}/${variant}-powermetrics.txt"

  if [[ "${variant}" == "new" ]]; then
    prepare_patched_ide_product
  fi

  local -a args=(
    --no-daemon --no-configuration-cache
    :ide-benchmark-plugin:runIde
    -PmagicJewelBenchmarkAutorun=true
    "-PmagicJewelBenchmarkMode=${case_name}"
    "-PmagicJewelBenchmarkOut=${case_dir}"
    "-PmagicJewelBenchmarkPaintProbe=${PAINT_PROBE}"
    "-PmagicJewelBenchmarkProjectPath=${BENCHMARK_PROJECT_PATH}"
    --console=plain
  )
  if [[ "${variant}" == "new" ]]; then
    echo "new_jbr_skia_render_mode=${JBR_SKIA_RENDER_MODE}" >> "${case_dir}/summary.properties"
    echo "new_jbr_skia_jvm_args=$(jbr_args)" >> "${case_dir}/summary.properties"
    echo "new_patched_ide_product=${PATCHED_IDE_PRODUCT_HOME}" >> "${case_dir}/summary.properties"
    args+=(
      -PjbrSkiaInterop=true
      "-PjbrSkiaRenderMode=${JBR_SKIA_RENDER_MODE}"
      "-PjbrSkiaInteropJvmArgs=$(jbr_args)"
      "-PmagicJewelPatchedIdeProductPath=${PATCHED_IDE_PRODUCT_HOME}"
    )
  fi

  (cd "${ROOT_DIR}" && ./gradlew "${args[@]}") > "${log}" 2>&1 &
  local gradle_pid=$!

  local pid=""
  for _ in {1..180}; do
    pid="$(find_ide_pid "${case_name}")"
    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null && grep -q "MAGIC_JEWEL_IDE_BENCHMARK status=started" "${log}" 2>/dev/null; then
      break
    fi
    pid=""
    sleep 1
  done
  if [[ -z "${pid}" ]]; then
    echo "failed_to_find_ide_pid=true" >> "${case_dir}/summary.properties"
    kill "${gradle_pid}" 2>/dev/null || true
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  ps -p "${pid}" -o command= > "${case_dir}/${variant}-command.txt" 2>/dev/null || true

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
  local benchmark_ticks benchmark_frames command_frames picture_frames fallbacks
  benchmark_ticks="$(grep -c 'MAGIC_JEWEL_IDE_BENCHMARK phase=tick' "${log}" || true)"
  benchmark_frames="$(grep -c 'MAGIC_JEWEL_IDE_BENCHMARK_FRAME' "${log}" || true)"
  command_frames="$(grep -c 'JBR_SKIA_INTEROP_COMMAND_FRAME' "${log}" || true)"
  picture_frames="$(grep -c 'JBR_SKIA_INTEROP_PICTURE_FRAME' "${log}" || true)"
  fallbacks="$(grep -c 'JBR_SKIA_INTEROP_FALLBACK' "${log}" || true)"
  echo "${variant}_benchmark_ticks=${benchmark_ticks}" >> "${case_dir}/summary.properties"
  echo "${variant}_benchmark_frames=${benchmark_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_command_frames=${command_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_picture_frames=${picture_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_fallbacks=${fallbacks}" >> "${case_dir}/summary.properties"
  if [[ "${benchmark_frames}" == "0" ]]; then
    echo "${variant}_benchmark_frames_missing=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${PAINT_PROBE}" == "true" ]]; then
    local paint_probe
    paint_probe="$(grep 'MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=' "${log}" | tail -1 || true)"
    echo "${variant}_paint_probe=${paint_probe}" >> "${case_dir}/summary.properties"
    local expected_node_probe
    expected_node_probe="$(grep 'MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE_EXPECTED_NODE' "${log}" | tail -1 || true)"
    echo "${variant}_paint_probe_expected_node=${expected_node_probe}" >> "${case_dir}/summary.properties"
    if [[ -z "${expected_node_probe}" || "${expected_node_probe}" != *"present=true"* ]]; then
      echo "${variant}_paint_probe_expected_node_missing=true" >> "${case_dir}/summary.properties"
      return 1
    fi
    if [[ -z "${paint_probe}" || "${paint_probe}" != *"status=captured"* ]]; then
      echo "${variant}_paint_probe_missing=true" >> "${case_dir}/summary.properties"
      return 1
    fi
    local non_dominant_ratio distinct_colors content_non_dominant_ratio content_distinct_colors
    non_dominant_ratio="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^nonDominantRatio=/) {split($i, a, "="); print a[2]}}' <<< "${paint_probe}")"
    distinct_colors="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^distinct=/) {split($i, a, "="); print a[2]}}' <<< "${paint_probe}")"
    content_non_dominant_ratio="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^contentNonDominantRatio=/) {split($i, a, "="); print a[2]}}' <<< "${paint_probe}")"
    content_distinct_colors="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^contentDistinct=/) {split($i, a, "="); print a[2]}}' <<< "${paint_probe}")"
    if ! awk \
      -v ratio="${non_dominant_ratio:-0}" \
      -v distinct="${distinct_colors:-0}" \
      -v content_ratio="${content_non_dominant_ratio:-0}" \
      -v content_distinct="${content_distinct_colors:-0}" \
      'BEGIN { exit (ratio >= 0.005 && distinct >= 8 && content_ratio >= 0.02 && content_distinct >= 16) ? 0 : 1 }'; then
      echo "${variant}_paint_probe_blank=true" >> "${case_dir}/summary.properties"
      return 1
    fi
  fi
  if [[ "${variant}" == "new" ]] && ! grep -q 'JBR_SKIA_INTEROP_.*FRAME' "${log}"; then
    echo "new_missing_jbr_markers=true" >> "${case_dir}/summary.properties"
    return 1
  fi
}

suite_tsv="${OUT_ROOT}/suite.tsv"
printf "case\tstatus\told_ps\tnew_ps\told_benchmark_ticks\tnew_benchmark_ticks\told_benchmark_frames\tnew_benchmark_frames\told_command_frames\tnew_command_frames\told_picture_frames\tnew_picture_frames\told_fallbacks\tnew_fallbacks\treport\n" > "${suite_tsv}"

for case_name in ${CASES}; do
  case_dir="${OUT_ROOT}/${case_name}"
  mkdir -p "${case_dir}"
  echo "case=${case_name}" > "${case_dir}/summary.properties"
  echo "sample_seconds=${SAMPLE_SECONDS}" >> "${case_dir}/summary.properties"
  echo "variants=${VARIANTS}" >> "${case_dir}/summary.properties"
  echo "collect_powermetrics=${COLLECT_POWERMETRICS}" >> "${case_dir}/summary.properties"
  echo "paint_probe=${PAINT_PROBE}" >> "${case_dir}/summary.properties"
  echo "benchmark_project_path=${BENCHMARK_PROJECT_PATH}" >> "${case_dir}/summary.properties"
  status="passed"
  for variant in ${VARIANTS}; do
    run_variant "${case_name}" "${variant}" "${case_dir}" || status="failed"
  done
  old_ps="$(summary_value "${case_dir}/summary.properties" old_ps)"
  new_ps="$(summary_value "${case_dir}/summary.properties" new_ps)"
  old_ticks="$(summary_value "${case_dir}/summary.properties" old_benchmark_ticks)"
  new_ticks="$(summary_value "${case_dir}/summary.properties" new_benchmark_ticks)"
  old_frames="$(summary_value "${case_dir}/summary.properties" old_benchmark_frames)"
  new_frames="$(summary_value "${case_dir}/summary.properties" new_benchmark_frames)"
  old_command="$(summary_value "${case_dir}/summary.properties" old_command_frames)"
  new_command="$(summary_value "${case_dir}/summary.properties" new_command_frames)"
  old_picture="$(summary_value "${case_dir}/summary.properties" old_picture_frames)"
  new_picture="$(summary_value "${case_dir}/summary.properties" new_picture_frames)"
  old_fallbacks="$(summary_value "${case_dir}/summary.properties" old_fallbacks)"
  new_fallbacks="$(summary_value "${case_dir}/summary.properties" new_fallbacks)"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${case_name}" "${status}" "${old_ps}" "${new_ps}" "${old_ticks}" "${new_ticks}" "${old_frames}" "${new_frames}" "${old_command}" "${new_command}" \
    "${old_picture}" "${new_picture}" "${old_fallbacks}" "${new_fallbacks}" "${case_dir}" >> "${suite_tsv}"
done

echo "suite=${suite_tsv}"
