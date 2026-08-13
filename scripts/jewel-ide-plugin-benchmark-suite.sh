#!/usr/bin/env bash
set -euo pipefail

# Locale-proof numeric formatting: driver shells with comma-decimal locales corrupt
# printf "%.2f" CSV columns and awk float output.
export LC_ALL=C

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
# Gradle's runIde daemon does not preserve the caller's working directory. Make
# a caller-relative result directory absolute before it is passed to Gradle.
if [[ "${OUT_ROOT}" != /* ]]; then
  OUT_ROOT="$(pwd -P)/${OUT_ROOT}"
fi
CASES="${CASES:-hypnotoad chat}"
VARIANTS="${VARIANTS:-old new}"
REPEAT_COUNT="${REPEAT_COUNT:-1}"
MAX_PREFLIGHT_RETRIES_PER_SLOT="${MAX_PREFLIGHT_RETRIES_PER_SLOT:-2}"
SAMPLE_SECONDS="${SAMPLE_SECONDS:-90}"
COLLECT_POWERMETRICS="${COLLECT_POWERMETRICS:-true}"
COLLECT_THREAD_CPU="${COLLECT_THREAD_CPU:-true}"
COLLECT_MACHINE_CPU="${COLLECT_MACHINE_CPU:-true}"
PAINT_PROBE="${PAINT_PROBE:-true}"
EDT_DISPATCH_PROBE="${EDT_DISPATCH_PROBE:-false}"
BENCHMARK_JVM_ARGS="${BENCHMARK_JVM_ARGS:-}"
GC_LOG_TO_FILE="${GC_LOG_TO_FILE:-false}"
DIAGNOSTIC_RUN="${DIAGNOSTIC_RUN:-false}"
DIAGNOSTIC_REUSE_SANDBOX="${DIAGNOSTIC_REUSE_SANDBOX:-false}"
REQUIRE_TRACE_OUTPUT="${REQUIRE_TRACE_OUTPUT:-false}"
REQUIRE_PACING_INTERVALS="${REQUIRE_PACING_INTERVALS:-false}"
REQUIRE_PRESENT_PACING="${REQUIRE_PRESENT_PACING:-false}"
REQUIRE_DISPLAY_LINK_PACING="${REQUIRE_DISPLAY_LINK_PACING:-false}"
REQUIRE_DISPLAY_REGIME_MATCH="${REQUIRE_DISPLAY_REGIME_MATCH:-true}"
REQUIRE_PINNED_SURFACE_REGIME="${REQUIRE_PINNED_SURFACE_REGIME:-false}"
EXPECTED_TOOLWINDOW_SURFACE_REGIME="${EXPECTED_TOOLWINDOW_SURFACE_REGIME:-}"
REQUIRE_REMOTE_SESSION_CLEAN="${REQUIRE_REMOTE_SESSION_CLEAN:-true}"
REQUIRE_FOREIGN_GPU_WATCH_CLEAN="${REQUIRE_FOREIGN_GPU_WATCH_CLEAN:-false}"
MAX_FOREIGN_GPU_WATCH_CPU="${MAX_FOREIGN_GPU_WATCH_CPU:-1.0}"
FOREIGN_GPU_WATCH_QUIET_WAIT_SECONDS="${FOREIGN_GPU_WATCH_QUIET_WAIT_SECONDS:-0}"
FOREIGN_GPU_WATCH_QUIET_POLL_SECONDS="${FOREIGN_GPU_WATCH_QUIET_POLL_SECONDS:-2}"
TRACE_OUTPUT_DIR="${TRACE_OUTPUT_DIR:-}"
PACE_OLD_BASELINE="${PACE_OLD_BASELINE:-true}"
PER_VARIANT_PREFLIGHT="${PER_VARIANT_PREFLIGHT:-false}"
REQUIRE_CLEAN_PREFLIGHT="${REQUIRE_CLEAN_PREFLIGHT:-false}"
MAX_PREFLIGHT_LOAD_1="${MAX_PREFLIGHT_LOAD_1:-6.0}"
MAX_PREFLIGHT_TOP_CPU="${MAX_PREFLIGHT_TOP_CPU:-75.0}"
MAX_VARIANT_PREFLIGHT_LOAD_1="${MAX_VARIANT_PREFLIGHT_LOAD_1:-999.0}"
MAX_VARIANT_PREFLIGHT_TOP_CPU="${MAX_VARIANT_PREFLIGHT_TOP_CPU:-${MAX_PREFLIGHT_TOP_CPU}}"
MAX_VARIANT_PREFLIGHT_WATCH_CPU="${MAX_VARIANT_PREFLIGHT_WATCH_CPU:-${MAX_VARIANT_PREFLIGHT_TOP_CPU}}"
PREFLIGHT_WATCH_PROCESSES="${PREFLIGHT_WATCH_PROCESSES:-fseventsd mds mds_stores}"
PREFLIGHT_GPU_SAMPLE_SECONDS="${PREFLIGHT_GPU_SAMPLE_SECONDS:-10}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW:-400}"
MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW="${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW:-500}"
MAX_SAMPLE_TOP_CPU="${MAX_SAMPLE_TOP_CPU:-${MAX_VARIANT_PREFLIGHT_TOP_CPU}}"
MACHINE_CPU_SAMPLE_INTERVAL_SECONDS="${MACHINE_CPU_SAMPLE_INTERVAL_SECONDS:-5}"
RUNTIME_ENVIRONMENT_SAMPLE_INTERVAL_SECONDS="${RUNTIME_ENVIRONMENT_SAMPLE_INTERVAL_SECONDS:-5}"
REMOTE_SESSION_PROCESS_REGEX="${REMOTE_SESSION_PROCESS_REGEX:-screensharingd|ScreensharingAgent|AppleVNC|screensharing}"
FOREIGN_GPU_WATCH_PROCESS_REGEX="${FOREIGN_GPU_WATCH_PROCESS_REGEX:-BetterDisplay|Google Chrome|Chrome|Codex|ChatGPT}"
BENCHMARK_PROJECT_PATH="${BENCHMARK_PROJECT_PATH:-${ROOT_DIR}}"
POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS:-500}"
POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS:-cpu_power,gpu_power}"
DEFAULT_POWERMETRICS="/usr/bin/powermetrics"
if [[ -x "/usr/local/sbin/jbr-powermetrics-cpu-gpu" ]]; then
  DEFAULT_POWERMETRICS="/usr/local/sbin/jbr-powermetrics-cpu-gpu"
fi
POWERMETRICS="${POWERMETRICS:-${DEFAULT_POWERMETRICS}}"
GPU_POWER_PREFLIGHT="${GPU_POWER_PREFLIGHT:-${ROOT_DIR}/scripts/jbr-skia-gpu-power-preflight.sh}"
PAINT_PROBE_SHUTDOWN_WAIT_SECONDS="${PAINT_PROBE_SHUTDOWN_WAIT_SECONDS:-15}"
BENCHMARK_EXIT_WAIT_SECONDS="${BENCHMARK_EXIT_WAIT_SECONDS:-20}"
BENCHMARK_START_WAIT_SECONDS="${BENCHMARK_START_WAIT_SECONDS:-660}"
BENCHMARK_PROJECT_OPEN_WAIT_SECONDS="${BENCHMARK_PROJECT_OPEN_WAIT_SECONDS:-30}"
BENCHMARK_TERMINATE_GRACE_SECONDS="${BENCHMARK_TERMINATE_GRACE_SECONDS:-5}"
DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-/tmp/jbr-skia-native/libjbrskiainterop.dylib}"
JBR_SKIA_RENDER_MODE="${JBR_SKIA_RENDER_MODE:-commands}"
JBR_SKIA_LOG_COMMAND_FRAMES="${JBR_SKIA_LOG_COMMAND_FRAMES:-true}"
JBR_SKIA_PACING_MARKERS="${JBR_SKIA_PACING_MARKERS:-true}"
JBR_SKIA_INTEROP_EXTRA_JVM_ARGS="${JBR_SKIA_INTEROP_EXTRA_JVM_ARGS:--Dcompose.jbr.skia.command.logOpCounts=true -Dcompose.jbr.skia.command.strict=true -Dcompose.jbr.skia.command.logFrames=true -Dskiko.jbr.interop.logCommandFrames=true -Dsun.java2d.skia.interop.logCommandFrames=true}"
CMP_SWING_PAINT_MARKER="${CMP_SWING_PAINT_MARKER:-CMP_SWING_SKIA_LAYER_PAINT}"
ANDROIDX_TRACING_VERSION="${ANDROIDX_TRACING_VERSION:-2.0.0-alpha09}"
ANDROIDX_TRACING_JARS="${ANDROIDX_TRACING_JARS:-}"
LOCAL_CMP_OUT="${LOCAL_CMP_OUT:-${ROOT_DIR}/../cmp/out/compose-multiplatform-core}"
LOCAL_SKIKO_AWT_JAR="${LOCAL_SKIKO_AWT_JAR:-${ROOT_DIR}/../skiko/skiko/build/libs/skiko-awt-0.0.0-SNAPSHOT.jar}"
LOCAL_SKIKO_NATIVE_LIB="${LOCAL_SKIKO_NATIVE_LIB:-${ROOT_DIR}/../skiko/skiko/build/maybe-signed-macos-arm64/libskiko-macos-arm64.dylib}"
LOCAL_JBR_RUNTIME_HOME="${LOCAL_JBR_RUNTIME_HOME:-}"
IDE_PRODUCT_LIB="${IDE_PRODUCT_LIB:-$(find "${HOME}/.gradle/caches/9.4.1/transforms" -type d -path '*/transformed/idea-2026.1.1-aarch64/lib' 2>/dev/null | head -1)}"
IDE_PRODUCT_HOME="${IDE_PRODUCT_HOME:-${IDE_PRODUCT_LIB%/lib}}"
PATCHED_IDE_PRODUCT_HOME="${PATCHED_IDE_PRODUCT_HOME:-${OUT_ROOT}/patched-idea-2026.1.1-aarch64}"
IDE_SANDBOX_ROOT="${IDE_SANDBOX_ROOT:-${ROOT_DIR}/ide-benchmark-plugin/build/idea-sandbox}"
COMPOSE_RUNTIME_BOOT_JAR="${COMPOSE_RUNTIME_BOOT_JAR:-${HOME}/.gradle/caches/modules-2/files-2.1/androidx.compose.runtime/runtime-desktop/1.11.0-beta02/175abab71b8fd8352e7b19505bf1f07d4415a37a/runtime-desktop-1.11.0-beta02.jar}"
DISPLAY_REGIME_SOURCE="${DISPLAY_REGIME_SOURCE:-${ROOT_DIR}/scripts/macos-display-regime.swift}"
DISPLAY_REGIME_HELPER="${DISPLAY_REGIME_HELPER:-${OUT_ROOT}/.tools/macos-display-regime}"

mkdir -p "${OUT_ROOT}"
if [[ "${DIAGNOSTIC_REUSE_SANDBOX}" == "true" && "${DIAGNOSTIC_RUN}" != "true" ]]; then
  echo "error: DIAGNOSTIC_REUSE_SANDBOX=true requires DIAGNOSTIC_RUN=true" >&2
  exit 2
fi
export JBR_SKIA_LOG_COMMAND_FRAMES
export JBR_SKIA_PACING_MARKERS

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

uses_patched_ide_product() {
  local variant="$1"
  [[ "${variant}" == "new" || "${PACE_OLD_BASELINE}" == "true" ]]
}

require_file() {
  local label="$1"
  local path="$2"
  [[ -f "${path}" ]] || {
    echo "error: ${label} does not exist: ${path}" >&2
    exit 2
  }
}

powermetrics_sudo_available() {
  sudo -n true 2>/dev/null && return 0
  [[ "$(basename "${POWERMETRICS}")" == "jbr-powermetrics-cpu-gpu" ]] || return 1
  sudo -n "${POWERMETRICS}" --check >/dev/null 2>&1
}

if [[ "${COLLECT_POWERMETRICS}" == "true" ]] && ! powermetrics_sudo_available; then
  echo "error: COLLECT_POWERMETRICS=true requires cached sudo or passwordless ${POWERMETRICS}" >&2
  exit 2
fi

if [[ "${REQUIRE_FOREIGN_GPU_WATCH_CLEAN}" == "true" ]] &&
    ! awk -v threshold="${MAX_FOREIGN_GPU_WATCH_CPU}" 'BEGIN { exit threshold ~ /^[0-9]+([.][0-9]+)?$/ && threshold >= 0 ? 0 : 1 }'; then
  echo "error: MAX_FOREIGN_GPU_WATCH_CPU must be a non-negative number" >&2
  exit 2
fi

write_machine_preflight() {
  local label="$1"
  local file="$2"
  local ps_file="$3"
  local max_load_1="${4:-${MAX_PREFLIGHT_LOAD_1}}"
  local max_top_cpu="${5:-${MAX_PREFLIGHT_TOP_CPU}}"
  local gpu_power_file="${6:-${file%.txt}-powermetrics.txt}"
  local powermetrics_sudo_cached="not-required"
  if [[ "${COLLECT_POWERMETRICS}" == "true" ]]; then
    if powermetrics_sudo_available; then
      powermetrics_sudo_cached="true"
    else
      powermetrics_sudo_cached="false"
    fi
  fi

  local preflight_load_1
  preflight_load_1="$(
    uptime | awk '
      {
        load = $0
        sub(/^.*load averages?: /, "", load)
        split(load, parts, /[ ,]+/)
        print parts[1]
      }' 2>/dev/null || true
  )"
  local preflight_top_cpu=""
  local preflight_watch_cpu=""
  local preflight_watch_process=""
  if command -v ps >/dev/null 2>&1 && command -v sort >/dev/null 2>&1; then
    ps -Ao pid,pcpu,pmem,comm 2>/dev/null | sort -k2 -nr | head -15 > "${ps_file}" || true
    preflight_top_cpu="$(awk 'NR == 1 { print $2; exit }' "${ps_file}" 2>/dev/null || true)"
    local preflight_watch_summary
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
        }' "${ps_file}" 2>/dev/null || true
    )"
    preflight_watch_cpu="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^cpu=/) { sub(/^cpu=/, "", $i); print $i; exit } }' <<< "${preflight_watch_summary:-}" 2>/dev/null || true)"
    preflight_watch_process="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^process=/) { sub(/^process=/, "", $i); print $i; exit } }' <<< "${preflight_watch_summary:-}" 2>/dev/null || true)"
  fi

  local preflight_gpu_power_summary="status=disabled reason=none samples=0 gpu_power_avg_mw=0 gpu_power_max_mw=0 max_gpu_power_avg_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW} max_gpu_power_peak_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}"
  local preflight_gpu_power_status=0
  if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" == "true" ]]; then
    set +e
    preflight_gpu_power_summary="$(
      POWERMETRICS="${POWERMETRICS}" \
      POWERMETRICS_INTERVAL_MS="${POWERMETRICS_INTERVAL_MS}" \
      POWERMETRICS_SAMPLERS="${POWERMETRICS_SAMPLERS}" \
        "${GPU_POWER_PREFLIGHT}" \
          "${gpu_power_file}" \
          "${PREFLIGHT_GPU_SAMPLE_SECONDS}" \
          "${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}" \
          "${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}"
    )"
    preflight_gpu_power_status=$?
    set -e
  fi

  local preflight_ready="true"
  local preflight_reasons=()
  if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" != "true" ]]; then
    preflight_ready="false"
    preflight_reasons+=("powermetrics-sudo-missing")
  fi
  if [[ "${COLLECT_POWERMETRICS}" == "true" && "${powermetrics_sudo_cached}" == "true" ]]; then
    if [[ "${preflight_gpu_power_status}" -eq 1 ]]; then
      preflight_ready="false"
      local preflight_gpu_power_reason
      preflight_gpu_power_reason="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^reason=/) { sub(/^reason=/, "", $i); print $i; exit } }' <<< "${preflight_gpu_power_summary}")"
      preflight_reasons+=("${preflight_gpu_power_reason:-gpu-power-blocked}")
    elif [[ "${preflight_gpu_power_status}" -ne 0 ]]; then
      preflight_ready="false"
      preflight_reasons+=("gpu-power-unavailable")
    fi
  fi
  if [[ -n "${preflight_load_1}" ]] && ! awk -v value="${preflight_load_1}" -v max="${max_load_1}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
    preflight_ready="false"
    preflight_reasons+=("load1>${max_load_1}")
  fi
  if [[ -n "${preflight_top_cpu}" ]] && ! awk -v value="${preflight_top_cpu}" -v max="${max_top_cpu}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
    preflight_ready="false"
    preflight_reasons+=("top-cpu>${max_top_cpu}")
  fi
  if [[ -n "${preflight_watch_cpu}" ]] && ! awk -v value="${preflight_watch_cpu}" -v max="${MAX_VARIANT_PREFLIGHT_WATCH_CPU}" 'BEGIN { exit value <= max ? 0 : 1 }'; then
    preflight_ready="false"
    preflight_reasons+=("${preflight_watch_process:-watched-process}-cpu>${MAX_VARIANT_PREFLIGHT_WATCH_CPU}")
  fi
  local preflight_reason="none"
  if ((${#preflight_reasons[@]})); then
    preflight_reason="${preflight_reasons[*]}"
  fi

  {
    echo "== IDE perf variant preflight =="
    uptime || true
    echo
    if [[ -s "${ps_file}" ]]; then
      cat "${ps_file}"
    fi
    echo
    echo "label=${label}"
    echo "collect_powermetrics=${COLLECT_POWERMETRICS}"
    echo "powermetrics_sudo_cached=${powermetrics_sudo_cached}"
    echo "require_clean_preflight=${REQUIRE_CLEAN_PREFLIGHT}"
    echo "max_preflight_load_1=${max_load_1}"
    echo "max_preflight_top_cpu=${max_top_cpu}"
    echo "max_preflight_watch_cpu=${MAX_VARIANT_PREFLIGHT_WATCH_CPU}"
    echo "preflight_gpu_sample_seconds=${PREFLIGHT_GPU_SAMPLE_SECONDS}"
    echo "max_preflight_gpu_power_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}"
    echo "max_preflight_gpu_power_peak_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}"
    echo "preflight_watch_processes=${PREFLIGHT_WATCH_PROCESSES}"
    echo "preflight_load_1=${preflight_load_1:-unknown}"
    echo "preflight_top_cpu=${preflight_top_cpu:-unknown}"
    echo "preflight_watch_process=${preflight_watch_process:-none}"
    echo "preflight_watch_cpu=${preflight_watch_cpu:-0}"
    echo "preflight_gpu_power_file=${gpu_power_file}"
    echo "preflight_gpu_power_summary=${preflight_gpu_power_summary}"
    echo "preflight_ready=${preflight_ready}"
    echo "preflight_reason=${preflight_reason}"
  } > "${file}"

  [[ "${preflight_ready}" == "true" || "${REQUIRE_CLEAN_PREFLIGHT}" != "true" ]]
}

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

runtime_jars_in_dir() {
  local dir="$1"
  find "${dir}" -type f -name '*.jar' \
    ! -name '*-sources.jar' \
    ! -name '*-javadoc.jar' \
    2>/dev/null | sort
}

resolved_androidx_tracing_jars() {
  if [[ -n "${ANDROIDX_TRACING_JARS}" ]]; then
    # shellcheck disable=SC2086
    printf '%s\n' ${ANDROIDX_TRACING_JARS}
    return
  fi

  local module_cache="${HOME}/.gradle/caches/modules-2/files-2.1"
  local coordinates=(
    "androidx.tracing/tracing-desktop/${ANDROIDX_TRACING_VERSION}"
    "androidx.tracing/tracing-wire-desktop/${ANDROIDX_TRACING_VERSION}"
    "com.squareup.wire/wire-runtime-jvm/6.4.0"
    "com.squareup.okio/okio-jvm/3.17.0"
    "androidx.annotation/annotation-jvm/1.7.0"
    "androidx.collection/collection-jvm/1.5.0"
  )
  local coordinate
  for coordinate in "${coordinates[@]}"; do
    runtime_jars_in_dir "${module_cache}/${coordinate}" | tail -1
  done
}

require_androidx_tracing_jar_set() {
  if [[ "$#" -lt 6 ]]; then
    echo "error: expected AndroidX tracing, tracing-wire, Wire, Okio, annotation, and collection jars; set ANDROIDX_TRACING_JARS or build once to populate Gradle cache" >&2
    exit 2
  fi
}

require_androidx_tracing_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/tracing/Tracer.class$'; then
      return 0
    fi
  done
  echo "error: AndroidX tracing classpath is missing androidx/tracing/Tracer.class" >&2
  exit 2
}

require_androidx_tracing_wire_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/tracing/wire/TraceDriver.class$'; then
      return 0
    fi
  done
  echo "error: AndroidX tracing classpath is missing androidx/tracing/wire/TraceDriver.class" >&2
  exit 2
}

require_androidx_tracing_wire_runtime() {
  local has_wire=false
  local has_okio=false
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^com/squareup/wire/Message.class$'; then
      has_wire=true
    fi
    if jar tf "${jar}" | grep -q '^okio/Okio.class$'; then
      has_okio=true
    fi
  done
  if [[ "${has_wire}" == "true" && "${has_okio}" == "true" ]]; then
    return 0
  fi
  echo "error: AndroidX tracing-wire runtime is missing Wire or Okio classes" >&2
  exit 2
}

require_androidx_collection_api() {
  local jar
  for jar in "$@"; do
    if jar tf "${jar}" | grep -q '^androidx/collection/LongObjectMapKt.class$'; then
      return 0
    fi
  done
  echo "error: AndroidX tracing classpath is missing androidx/collection/LongObjectMapKt.class" >&2
  exit 2
}

prepare_patched_ide_product() {
  [[ -d "${IDE_PRODUCT_HOME}" ]] || {
    echo "error: IDE_PRODUCT_HOME does not exist: ${IDE_PRODUCT_HOME}" >&2
    exit 2
  }
  [[ -f "${COMPOSE_RUNTIME_BOOT_JAR}" ]] || {
    echo "error: COMPOSE_RUNTIME_BOOT_JAR does not exist: ${COMPOSE_RUNTIME_BOOT_JAR}" >&2
    exit 2
  }
  if [[ -n "${LOCAL_JBR_RUNTIME_HOME}" && ! -x "${LOCAL_JBR_RUNTIME_HOME}/bin/java" ]]; then
    echo "error: LOCAL_JBR_RUNTIME_HOME must contain bin/java: ${LOCAL_JBR_RUNTIME_HOME}" >&2
    exit 2
  fi
  local tracing_jars=()
  while IFS= read -r jar; do
    [[ -n "${jar}" ]] && tracing_jars+=("${jar}")
  done < <(resolved_androidx_tracing_jars)
  require_androidx_tracing_jar_set "${tracing_jars[@]}"
  for jar in "${tracing_jars[@]}"; do
    require_file "AndroidX tracing classpath jar" "${jar}"
  done
  require_androidx_tracing_api "${tracing_jars[@]}"
  require_androidx_tracing_wire_api "${tracing_jars[@]}"
  require_androidx_tracing_wire_runtime "${tracing_jars[@]}"
  require_androidx_collection_api "${tracing_jars[@]}"
  local compose_jars=()
  while IFS= read -r jar; do
    compose_jars+=("${jar}")
  done < <(patched_compose_desktop_jars)
  local local_jbr_runtime_digest="stock"
  if [[ -n "${LOCAL_JBR_RUNTIME_HOME}" ]]; then
    local_jbr_runtime_digest="$({
      find "${LOCAL_JBR_RUNTIME_HOME}" -type f -exec shasum -a 256 {} + | LC_ALL=C sort
    } | shasum -a 256 | awk '{print $1}')"
  fi
  local desktop_patch_digest
  desktop_patch_digest="$({
    find "${DESKTOP_PATCH}" -type f -exec shasum -a 256 {} + | LC_ALL=C sort
  } | shasum -a 256 | awk '{print $1}')"
  local jbr_api_shim_digest
  jbr_api_shim_digest="$(shasum -a 256 "${JBR_API_SHIM}" | awk '{print $1}')"
  local jbr_skia_lib_digest
  jbr_skia_lib_digest="$(shasum -a 256 "${JBR_SKIA_LIB}" | awk '{print $1}')"
  local patched_artifacts_digest
  patched_artifacts_digest="$({
    shasum -a 256 \
      "${LOCAL_SKIKO_AWT_JAR}" \
      "${LOCAL_SKIKO_NATIVE_LIB}" \
      "${COMPOSE_RUNTIME_BOOT_JAR}" \
      "${tracing_jars[@]}" \
      "${compose_jars[@]}"
    printf '%s\n' "local-jbr-runtime=${local_jbr_runtime_digest}"
    printf '%s\n' "desktop-patch=${desktop_patch_digest}"
    printf '%s\n' "jbr-api-shim=${jbr_api_shim_digest}"
    printf '%s\n' "jbr-skia-lib=${jbr_skia_lib_digest}"
  } | shasum -a 256 | awk '{print $1}')"
  if [[ -f "${PATCHED_IDE_PRODUCT_HOME}/.magic-jewel-patched" ]]; then
    if grep -qx "patched_artifacts_digest=${patched_artifacts_digest}" "${PATCHED_IDE_PRODUCT_HOME}/.magic-jewel-patched"; then
      return
    fi
  fi

  rm -rf "${PATCHED_IDE_PRODUCT_HOME}"
  mkdir -p "$(dirname "${PATCHED_IDE_PRODUCT_HOME}")"
  if cp -R -c "${IDE_PRODUCT_HOME}" "${PATCHED_IDE_PRODUCT_HOME}" 2>/dev/null; then
    :
  else
    cp -R "${IDE_PRODUCT_HOME}" "${PATCHED_IDE_PRODUCT_HOME}"
  fi
  if [[ -n "${LOCAL_JBR_RUNTIME_HOME}" ]]; then
    rm -rf "${PATCHED_IDE_PRODUCT_HOME}/jbr/Contents/Home"
    mkdir -p "${PATCHED_IDE_PRODUCT_HOME}/jbr/Contents"
    cp -R -c "${LOCAL_JBR_RUNTIME_HOME}" "${PATCHED_IDE_PRODUCT_HOME}/jbr/Contents/Home" 2>/dev/null || \
      cp -R "${LOCAL_JBR_RUNTIME_HOME}" "${PATCHED_IDE_PRODUCT_HOME}/jbr/Contents/Home"
  fi

  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.skiko.jar" \
    "${LOCAL_SKIKO_AWT_JAR}" \
    "${tracing_jars[@]}"
  mkdir -p "${PATCHED_IDE_PRODUCT_HOME}/lib/skiko-awt-runtime-all"
  cp "${LOCAL_SKIKO_NATIVE_LIB}" "${PATCHED_IDE_PRODUCT_HOME}/lib/skiko-awt-runtime-all/libskiko-macos-arm64.dylib"
  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.compose.runtime.desktop.jar" \
    "${COMPOSE_RUNTIME_BOOT_JAR}"

  overlay_jar "${PATCHED_IDE_PRODUCT_HOME}/lib/intellij.libraries.compose.foundation.desktop.jar" "${compose_jars[@]}"
  {
    echo "patched_ide_product_home=${PATCHED_IDE_PRODUCT_HOME}"
    echo "patched_artifacts_digest=${patched_artifacts_digest}"
    echo "local_jbr_runtime_digest=${local_jbr_runtime_digest}"
    echo "desktop_patch_digest=${desktop_patch_digest}"
    echo "jbr_api_shim_digest=${jbr_api_shim_digest}"
    echo "jbr_skia_lib_digest=${jbr_skia_lib_digest}"
  } > "${PATCHED_IDE_PRODUCT_HOME}/.magic-jewel-patched"
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
  local benchmark_out="$2"
  local pid command
  while IFS= read -r line; do
    pid="${line%% *}"
    command="${line#* }"
    [[ -n "${pid}" && "${pid}" != "${command}" ]] || continue
    [[ "${command}" == *'/jbr/Contents/Home/bin/java'* ]] || continue
    [[ "${command}" == *"magic.jewel.benchmark.mode=${mode}"* ]] || continue
    [[ "${command}" == *"magic.jewel.benchmark.out=${benchmark_out}"* ]] || continue
    echo "${pid}"
    return 0
  done < <(ps -axo pid=,command= 2>/dev/null || true)
  return 0
}

find_sandbox_ide_pid() {
  local pid command
  while IFS= read -r line; do
    pid="${line%% *}"
    command="${line#* }"
    [[ -n "${pid}" && "${pid}" != "${command}" ]] || continue
    [[ "${command}" == *'/jbr/Contents/Home/bin/java'* ]] || continue
    [[ "${command}" == *"idea.config.path=${IDE_SANDBOX_ROOT}/"* ]] || continue
    echo "${pid}"
    return 0
  done < <(ps -axo pid=,command= 2>/dev/null || true)
  return 0
}

reset_ide_sandbox() {
  local active_pid
  active_pid="$(find_sandbox_ide_pid)"
  if [[ -n "${active_pid}" ]]; then
    echo "error: refusing to reset active IDE sandbox ${IDE_SANDBOX_ROOT}; pid=${active_pid}" >&2
    return 1
  fi
  rm -rf "${IDE_SANDBOX_ROOT}"
}

started_ide_pid_from_log() {
  local log="$1"
  local pid
  pid="$(
    awk '
      /MAGIC_JEWEL_IDE_BENCHMARK status=started/ {
        for (i = 1; i <= NF; i++) {
          if ($i ~ /^pid=[0-9]+$/) {
            split($i, parts, "=")
            startedPid = parts[2]
          }
        }
      }
      END {
        if (startedPid != "") {
          print startedPid
        }
      }' "${log}" 2>/dev/null || true
  )"
  if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
    echo "${pid}"
  fi
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

sample_thread_cpu() {
  local mode="$1"
  local variant="$2"
  local pid="$3"
  local csv="$4"
  echo "timestamp,mode,variant,pid,thread_index,cpu_percent,command" > "${csv}"
  [[ "${COLLECT_THREAD_CPU}" == "true" ]] || return
  while kill -0 "${pid}" 2>/dev/null; do
    local timestamp
    timestamp="$(date +%s)"
    ps -M -p "${pid}" 2>/dev/null |
      awk -v timestamp="${timestamp}" -v mode="${mode}" -v variant="${variant}" '
        NR == 1 { next }
        {
          pid = $2
          cpu = $4
          command = ""
          if ($1 ~ /^[0-9]+$/) {
            pid = $1
            cpu = $2
          } else if ($1 == "") {
            pid = $2
            cpu = $3
          }
          if (cpu !~ /^[0-9.]+$/) {
            next
          }
          for (i = 9; i <= NF; i++) {
            command = command (command == "" ? "" : " ") $i
          }
          gsub(/,/, " ", command)
          printf "%s,%s,%s,%s,%d,%s,%s\n", timestamp, mode, variant, pid, ++threadIndex, cpu, command
        }
      ' >> "${csv}"
    sleep 2
  done
}

sample_machine_cpu() {
  local mode="$1"
  local variant="$2"
  local ide_pid="$3"
  local csv="$4"
  echo "timestamp,mode,variant,top_pid,top_cpu_percent,top_command" > "${csv}"
  [[ "${COLLECT_MACHINE_CPU}" == "true" ]] || return
  while kill -0 "${ide_pid}" 2>/dev/null; do
    local timestamp
    timestamp="$(date +%s)"
    ps -axo pid=,ppid=,pcpu=,comm= 2>/dev/null |
      awk -v timestamp="${timestamp}" -v mode="${mode}" -v variant="${variant}" -v ide_pid="${ide_pid}" '
        {
          pid = $1
          ppid = $2
          cpu = $3
          parent[pid] = ppid
          rowPid[NR] = pid
          rowCpu[NR] = cpu
          command = ""
          for (i = 4; i <= NF; i++) {
            command = command (command == "" ? "" : " ") $i
          }
          rowCommand[NR] = command
        }
        END {
          for (row = 1; row <= NR; row++) {
            pid = rowPid[row]
            cpu = rowCpu[row]
            if (cpu !~ /^[0-9.]+$/) {
              continue
            }
            current = pid
            benchmarkProcess = 0
            while (current != "" && current != "0") {
              if (current == ide_pid) {
                benchmarkProcess = 1
                break
              }
              current = parent[current]
            }
            if (benchmarkProcess) {
              continue
            }
            command = rowCommand[row]
            if ((cpu + 0) > maxCpu) {
              maxCpu = cpu + 0
              maxPid = pid
              maxCommand = command
            }
          }
          if (maxPid != "") {
            gsub(/,/, " ", maxCommand)
            printf "%s,%s,%s,%s,%.2f,%s\n", timestamp, mode, variant, maxPid, maxCpu, maxCommand
          }
        }
      ' >> "${csv}"
    sleep "${MACHINE_CPU_SAMPLE_INTERVAL_SECONDS}"
  done
}

ensure_display_regime_helper() {
  [[ "$(uname -s)" == "Darwin" ]] || return 1
  [[ -f "${DISPLAY_REGIME_SOURCE}" ]] || return 1
  if [[ -x "${DISPLAY_REGIME_HELPER}" && "${DISPLAY_REGIME_HELPER}" -nt "${DISPLAY_REGIME_SOURCE}" ]]; then
    return
  fi
  command -v xcrun >/dev/null 2>&1 || return 1
  mkdir -p "$(dirname "${DISPLAY_REGIME_HELPER}")"
  xcrun --sdk macosx swiftc "${DISPLAY_REGIME_SOURCE}" -o "${DISPLAY_REGIME_HELPER}"
}

capture_display_regime() {
  local file="$1"
  if ! ensure_display_regime_helper; then
    echo "status=unavailable" > "${file}"
    return 1
  fi
  if ! {
    echo "status=available"
    "${DISPLAY_REGIME_HELPER}"
  } > "${file}"; then
    echo "status=unavailable" > "${file}"
    return 1
  fi
}

display_regime_signature() {
  local file="$1"
  awk -F= '
    $1 == "status" { status = $2 }
    $1 == "display_id" { display = $2 }
    $1 == "mode_width" { width = $2 }
    $1 == "mode_height" { height = $2 }
    $1 == "pixel_width" { pixelWidth = $2 }
    $1 == "pixel_height" { pixelHeight = $2 }
    $1 == "refresh_hz" { refresh = $2 }
    $1 == "io_flags" { flags = $2 }
    $1 == "backing_scale" { backingScale = $2 }
    $1 == "logical_width" { logicalWidth = $2 }
    $1 == "logical_height" { logicalHeight = $2 }
    END {
      if (status == "available" && display != "" && width != "" && height != "" &&
          pixelWidth != "" && pixelHeight != "" && refresh != "" && flags != "" &&
          backingScale != "" && backingScale != "unknown" && logicalWidth != "" && logicalHeight != "") {
        printf "display=%s;mode=%sx%s;pixels=%sx%s;refresh_hz=%s;io_flags=%s;backing_scale=%s;logical=%sx%s", display, width, height, pixelWidth, pixelHeight, refresh, flags, backingScale, logicalWidth, logicalHeight
      }
    }
  ' "${file}"
}

benchmark_surface_regime_signature() {
  local log="$1"
  awk '
    /MAGIC_JEWEL_IDE_BENCHMARK_SURFACE_REGIME label=toolWindow/ {
      logicalWidth = logicalHeight = scaleX = scaleY = pixelWidth = pixelHeight = pixelArea = ""
      for (i = 1; i <= NF; i++) {
        split($i, value, "=")
        if (value[1] == "logicalWidth") logicalWidth = value[2]
        if (value[1] == "logicalHeight") logicalHeight = value[2]
        if (value[1] == "backingScaleX") scaleX = value[2]
        if (value[1] == "backingScaleY") scaleY = value[2]
        if (value[1] == "pixelWidth") pixelWidth = value[2]
        if (value[1] == "pixelHeight") pixelHeight = value[2]
        if (value[1] == "pixelArea") pixelArea = value[2]
      }
      if (logicalWidth + 0 > 0 && logicalHeight + 0 > 0 && scaleX + 0 > 0 && scaleY + 0 > 0 &&
          pixelWidth + 0 > 0 && pixelHeight + 0 > 0 && pixelArea + 0 > 0) {
        signature = "logical=" logicalWidth "x" logicalHeight ";backing=" scaleX "x" scaleY ";pixels=" pixelWidth "x" pixelHeight ";area=" pixelArea
      }
    }
    END {
      if (signature != "") print signature
    }
  ' "${log}"
}

sample_runtime_environment() {
  local mode="$1"
  local variant="$2"
  local ide_pid="$3"
  local csv="$4"
  echo "timestamp,mode,variant,kind,pid,cpu_percent,command" > "${csv}"
  while kill -0 "${ide_pid}" 2>/dev/null; do
    local timestamp
    timestamp="$(date +%s)"
    ps -axo pid=,pcpu=,comm= 2>/dev/null |
      awk -v timestamp="${timestamp}" -v mode="${mode}" -v variant="${variant}" \
          -v remote="${REMOTE_SESSION_PROCESS_REGEX}" -v foreign="${FOREIGN_GPU_WATCH_PROCESS_REGEX}" '
        {
          pid = $1
          cpu = $2
          command = ""
          for (i = 3; i <= NF; i++) {
            command = command (command == "" ? "" : " ") $i
          }
          if (command ~ remote) {
            kind = "remote_session"
          } else if (command ~ foreign) {
            kind = "foreign_gpu_watch"
          } else {
            next
          }
          gsub(/,/, " ", command)
          printf "%s,%s,%s,%s,%s,%s,%s\n", timestamp, mode, variant, kind, pid, cpu, command
        }
      ' >> "${csv}"
    sleep "${RUNTIME_ENVIRONMENT_SAMPLE_INTERVAL_SECONDS}"
  done
}

summarize_runtime_environment() {
  local csv="$1"
  awk -F, '
    NR == 1 { next }
    $4 == "remote_session" {
      remoteSamples++
      if (!seenRemote[$7]++) remoteProcesses = remoteProcesses (remoteProcesses == "" ? "" : "+") $7
    }
    $4 == "foreign_gpu_watch" {
      foreignSamples++
      if ($6 + 0 > foreignMaxCpu) foreignMaxCpu = $6 + 0
      if (!seenForeign[$7]++) foreignProcesses = foreignProcesses (foreignProcesses == "" ? "" : "+") $7
    }
    END {
      printf "remote_samples=%d remote_processes=%s foreign_gpu_watch_samples=%d foreign_gpu_watch_max_cpu_percent=%.2f foreign_gpu_watch_processes=%s", remoteSamples, (remoteProcesses == "" ? "none" : remoteProcesses), foreignSamples, foreignMaxCpu, (foreignProcesses == "" ? "none" : foreignProcesses)
    }
  ' "${csv}"
}

foreign_gpu_watch_max_cpu() {
  ps -axo pcpu=,comm= 2>/dev/null |
    awk -v foreign="${FOREIGN_GPU_WATCH_PROCESS_REGEX}" '
      {
        cpu = $1 + 0
        command = ""
        for (i = 2; i <= NF; i++) {
          command = command (command == "" ? "" : " ") $i
        }
        if (command ~ foreign && cpu > maxCpu) maxCpu = cpu
      }
      END { printf "%.2f", maxCpu }
    '
}

wait_for_foreign_gpu_watch_quiet() {
  [[ "${REQUIRE_FOREIGN_GPU_WATCH_CLEAN}" == "true" ]] || return 0
  local deadline=$(( $(date +%s) + FOREIGN_GPU_WATCH_QUIET_WAIT_SECONDS ))
  local observed
  while true; do
    observed="$(foreign_gpu_watch_max_cpu)"
    if awk -v observed="${observed}" -v threshold="${MAX_FOREIGN_GPU_WATCH_CPU}" 'BEGIN { exit observed <= threshold ? 0 : 1 }'; then
      printf "%s" "${observed}"
      return 0
    fi
    if (( $(date +%s) >= deadline )); then
      printf "%s" "${observed}"
      return 1
    fi
    sleep "${FOREIGN_GPU_WATCH_QUIET_POLL_SECONDS}"
  done
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

summarize_thread_cpu() {
  local csv="$1"
  awk -F, '
    NR > 1 {
      cpu = $6 + 0
      thread = $5
      n++
      if (cpu > max) {
        max = cpu
        maxThread = thread
      }
      totalByThread[thread] += cpu
      countByThread[thread]++
    }
    END {
      if (!n) {
        printf "samples=0"
        exit
      }
      bestAvg = -1
      bestAvgThread = ""
      for (thread in totalByThread) {
        avg = totalByThread[thread] / countByThread[thread]
        if (avg > bestAvg) {
          bestAvg = avg
          bestAvgThread = thread
        }
      }
      printf "samples=%d max_thread_index=%s max_thread_cpu=%.2f hottest_avg_thread_index=%s hottest_avg_thread_cpu=%.2f",
        n, maxThread, max, bestAvgThread, bestAvg
    }' "${csv}"
}

summarize_machine_cpu() {
  local csv="$1"
  awk -F, '
    NR > 1 {
      cpu = $5 + 0
      n++
      if (cpu > max) {
        max = cpu
        maxPid = $4
        maxCommand = $6
        maxProcess = maxCommand
        sub(/^.*\//, "", maxProcess)
        sub(/ .*/, "", maxProcess)
      }
    }
    END {
      if (!n) {
        printf "samples=0"
        exit
      }
      printf "samples=%d max_top_cpu=%.2f max_top_pid=%s max_top_process=%s max_top_command=%s",
        n, max, maxPid, maxProcess, maxCommand
    }' "${csv}"
}

summarize_command_frames() {
  local log="$1"
  awk '
    /JBR_SKIA_INTEROP_COMMAND_FRAME/ {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^commands=/) {
          split($i, a, "=")
          commands = a[2] + 0
          frames++
          total += commands
          if (commands > max) {
            max = commands
          }
        }
      }
    }
    END {
      if (frames) {
        printf "frames=%d avg_commands=%.1f max_commands=%d", frames, total / frames, max
      } else {
        printf "frames=0"
      }
    }' "${log}"
}

summarize_pacing_intervals() {
  local log="$1"
  local marker="$2"
  local default_interval_nanos="$3"
  local samples sorted
  samples="$(mktemp "${TMPDIR:-/tmp}/jbr-skia-pacing.XXXXXX")"
  sorted="$(mktemp "${TMPDIR:-/tmp}/jbr-skia-pacing-sorted.XXXXXX")"
  awk -v marker="${marker}" -v defaultInterval="${default_interval_nanos}" '
    index($0, marker) {
      time = interval = 0
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^timeNanos=/) {
          split($i, value, "=")
          time = value[2] + 0
        } else if ($i ~ /^expectedIntervalNanos=/) {
          split($i, value, "=")
          interval = value[2] + 0
        }
      }
      if (time > 0 && previous > 0) {
        if (interval <= 0) interval = defaultInterval
        print time - previous, interval
      }
      if (time > 0) previous = time
    }
  ' "${log}" > "${samples}"
  local count
  count="$(wc -l < "${samples}" | tr -d ' ')"
  if [[ "${count}" == "0" ]]; then
    rm -f "${samples}" "${sorted}"
    printf "intervals=0"
    return
  fi
  cut -d ' ' -f 1 "${samples}" | sort -n > "${sorted}"
  local p50 p95 p99 stats
  p50="$(awk -v q=0.50 '{ values[NR] = $1 } END { print values[int((NR - 1) * q) + 1] }' "${sorted}")"
  p95="$(awk -v q=0.95 '{ values[NR] = $1 } END { print values[int((NR - 1) * q) + 1] }' "${sorted}")"
  p99="$(awk -v q=0.99 '{ values[NR] = $1 } END { print values[int((NR - 1) * q) + 1] }' "${sorted}")"
  stats="$(awk '
    { sum += $1; sumSquares += $1 * $1; if ($1 > 1.5 * $2) missed++ }
    END {
      mean = sum / NR
      variance = sumSquares / NR - mean * mean
      if (variance < 0) variance = 0
      printf "mean=%.3f jitter=%.3f missed=%d", mean / 1000000, sqrt(variance) / 1000000, missed
    }
  ' "${samples}")"
  rm -f "${samples}" "${sorted}"
  printf "intervals=%s p50_ms=%.3f p95_ms=%.3f p99_ms=%.3f %s" \
    "${count}" "$(awk -v value="${p50}" 'BEGIN { print value / 1000000 }')" \
    "$(awk -v value="${p95}" 'BEGIN { print value / 1000000 }')" \
    "$(awk -v value="${p99}" 'BEGIN { print value / 1000000 }')" "${stats}"
}

summarize_marker_sources() {
  local log="$1"
  local marker="$2"
  awk -v marker="${marker}" '
    index($0, marker) {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^timeSource=/) {
          split($i, value, "=")
          sources[value[2]] = 1
        }
      }
    }
    END {
      for (source in sources) {
        count++
        selected = source
      }
      if (count == 0) print "source=none"
      else if (count == 1) print "source=" selected
      else print "source=mixed"
    }
  ' "${log}"
}

summarize_command_timing() {
  local log="$1"
  awk '
    /JBR_SKIA_INTEROP_COMMAND_TIMING/ {
      total = malloc = context = surface = draw = flush = purge = paragraph = shadow = 0
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^totalNanos=/) {
          split($i, a, "=")
          total = a[2] + 0
        } else if ($i ~ /^mallocNanos=/) {
          split($i, a, "=")
          malloc = a[2] + 0
        } else if ($i ~ /^contextNanos=/) {
          split($i, a, "=")
          context = a[2] + 0
        } else if ($i ~ /^surfaceNanos=/) {
          split($i, a, "=")
          surface = a[2] + 0
        } else if ($i ~ /^drawNanos=/) {
          split($i, a, "=")
          draw = a[2] + 0
        } else if ($i ~ /^flushNanos=/) {
          split($i, a, "=")
          flush = a[2] + 0
        } else if ($i ~ /^purgeNanos=/) {
          split($i, a, "=")
          purge = a[2] + 0
        } else if ($i ~ /^paragraphCommands=/) {
          split($i, a, "=")
          paragraph = a[2] + 0
        } else if ($i ~ /^shadowCommands=/) {
          split($i, a, "=")
          shadow = a[2] + 0
        }
      }
      frames++
      totalSum += total
      mallocSum += malloc
      contextSum += context
      surfaceSum += surface
      drawSum += draw
      flushSum += flush
      purgeSum += purge
      if (total > totalMax) totalMax = total
      if (malloc > mallocMax) mallocMax = malloc
      if (context > contextMax) contextMax = context
      if (surface > surfaceMax) surfaceMax = surface
      if (draw > drawMax) drawMax = draw
      if (flush > flushMax) flushMax = flush
      if (purge > purgeMax) purgeMax = purge
      if (paragraph > paragraphMax) paragraphMax = paragraph
      if (shadow > shadowMax) shadowMax = shadow
    }
    /JBR_SKIA_INTEROP_COMMAND_COMPLETION/ {
      completion = 0
      gpu = -1
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^completionNanos=/) {
          split($i, a, "=")
          completion = a[2] + 0
        } else if ($i ~ /^gpuNanos=/) {
          split($i, a, "=")
          gpu = a[2] + 0
        }
      }
      completionFrames++
      completionSum += completion
      if (completion > completionMax) completionMax = completion
      if (gpu >= 0) {
        gpuFrames++
        gpuSum += gpu
        if (gpu > gpuMax) gpuMax = gpu
      }
    }
    END {
      if (frames) {
        printf "frames=%d avg_total_ms=%.3f max_total_ms=%.3f avg_malloc_ms=%.3f max_malloc_ms=%.3f avg_context_ms=%.3f max_context_ms=%.3f avg_surface_ms=%.3f max_surface_ms=%.3f avg_draw_ms=%.3f max_draw_ms=%.3f avg_flush_ms=%.3f max_flush_ms=%.3f avg_purge_ms=%.3f max_purge_ms=%.3f max_paragraph_commands=%d max_shadow_commands=%d",
          frames, totalSum / frames / 1000000, totalMax / 1000000,
          mallocSum / frames / 1000000, mallocMax / 1000000,
          contextSum / frames / 1000000, contextMax / 1000000,
          surfaceSum / frames / 1000000, surfaceMax / 1000000,
          drawSum / frames / 1000000, drawMax / 1000000,
          flushSum / frames / 1000000, flushMax / 1000000,
          purgeSum / frames / 1000000, purgeMax / 1000000,
          paragraphMax, shadowMax
        if (completionFrames) {
          printf " completion_frames=%d avg_completion_ms=%.3f max_completion_ms=%.3f",
            completionFrames, completionSum / completionFrames / 1000000, completionMax / 1000000
        }
        if (gpuFrames) {
          printf " gpu_frames=%d avg_gpu_ms=%.3f max_gpu_ms=%.3f",
            gpuFrames, gpuSum / gpuFrames / 1000000, gpuMax / 1000000
        }
      } else {
        printf "frames=0"
      }
    }' "${log}"
}

summarize_powermetrics() {
  local file="$1"
  if [[ ! -s "${file}" ]]; then
    printf "samples=0"
    return
  fi
  awk '
    function pct_value(line, value) {
      if (match(line, /[0-9]+([.][0-9]+)?%/)) {
        value = substr(line, RSTART, RLENGTH - 1)
        return value + 0
      }
      return ""
    }

    /^CPU Power:/ {
      cpuPowerSamples++
      cpuPowerSum += $3 + 0
      if ($3 + 0 > cpuPowerMax) cpuPowerMax = $3 + 0
    }

    /^GPU Power:/ {
      gpuPowerSamples++
      gpuPowerSum += $3 + 0
      if ($3 + 0 > gpuPowerMax) gpuPowerMax = $3 + 0
    }

    /^GPU HW active residency:/ {
      value = pct_value($0)
      if (value != "") {
        gpuActiveSamples++
        gpuActiveSum += value
        if (value > gpuActiveMax) gpuActiveMax = value
      }
    }

    /^GPU idle residency:/ {
      value = pct_value($0)
      if (value != "") {
        gpuIdleSamples++
        gpuIdleSum += value
      }
    }

    /^CPU [0-9]+ active residency:/ {
      cpu = "CPU" $2
      value = pct_value($0)
      if (value != "") {
        cpuActiveSamples++
        cpuActiveSum[cpu] += value
        cpuActiveCount[cpu]++
        if (value > maxCpuActive) {
          maxCpuActive = value
          maxCpu = cpu
        }
      }
    }

    END {
      if (!cpuPowerSamples && !gpuPowerSamples && !gpuActiveSamples && !cpuActiveSamples) {
        printf "samples=0"
        exit
      }
      samples = gpuActiveSamples
      if (cpuPowerSamples > 0) {
        samples = cpuPowerSamples
      }
      cpuPowerAvg = 0
      if (cpuPowerSamples > 0) {
        cpuPowerAvg = cpuPowerSum / cpuPowerSamples
      }
      gpuPowerAvg = 0
      if (gpuPowerSamples > 0) {
        gpuPowerAvg = gpuPowerSum / gpuPowerSamples
      }
      gpuActiveAvg = 0
      if (gpuActiveSamples > 0) {
        gpuActiveAvg = gpuActiveSum / gpuActiveSamples
      }
      gpuIdleAvg = 0
      if (gpuIdleSamples > 0) {
        gpuIdleAvg = gpuIdleSum / gpuIdleSamples
      }
      hottestAvg = -1
      hottestCpu = ""
      for (cpu in cpuActiveSum) {
        avg = cpuActiveSum[cpu] / cpuActiveCount[cpu]
        if (avg > hottestAvg) {
          hottestAvg = avg
          hottestCpu = cpu
        }
      }
      if (hottestCpu == "") {
        hottestCpu = "n/a"
      }
      if (hottestAvg < 0) {
        hottestAvg = 0
      }
      if (maxCpu == "") {
        maxCpu = "n/a"
      }
      printf "samples=%d cpu_power_avg_mw=%.0f cpu_power_max_mw=%.0f gpu_power_avg_mw=%.0f gpu_power_max_mw=%.0f gpu_active_avg=%.2f gpu_active_max=%.2f gpu_idle_avg=%.2f hottest_cpu=%s hottest_cpu_active_avg=%.2f max_cpu=%s max_cpu_active=%.2f",
        samples,
        cpuPowerAvg,
        cpuPowerMax,
        gpuPowerAvg,
        gpuPowerMax,
        gpuActiveAvg,
        gpuActiveMax,
        gpuIdleAvg,
        hottestCpu,
        hottestAvg,
        maxCpu,
        maxCpuActive
    }' "${file}"
}

summary_value() {
  local file="$1"
  local key="$2"
  awk -F= -v key="${key}" '$1 == key { sub(/^[^=]*=/, ""); print; found=1; exit } END { if (!found) exit 0 }' "${file}"
}

wait_for_paint_probe() {
  local log="$1"
  [[ "${PAINT_PROBE}" == "true" ]] || return 0
  local waited=0
  while (( waited < PAINT_PROBE_SHUTDOWN_WAIT_SECONDS )); do
    if grep -q 'MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=' "${log}" 2>/dev/null; then
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1
}

capture_startup_failure_evidence() {
  local case_dir="$1"
  local variant="$2"
  local log="$3"
  local pid="$4"
  local prefix="${case_dir}/${variant}-startup-failure"

  {
    echo "pid=${pid:-unknown}"
    echo "captured_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    if [[ -n "${pid}" && -x /usr/bin/swift ]]; then
      TARGET_PID="${pid}" \
        CLANG_MODULE_CACHE_PATH=/private/tmp/jbr-skia-swift-module-cache \
        SWIFT_MODULECACHE_PATH=/private/tmp/jbr-skia-swift-module-cache \
        /usr/bin/swift \
          -module-cache-path /private/tmp/jbr-skia-swift-module-cache \
          -e 'import Foundation; import CoreGraphics; let target = Int(ProcessInfo.processInfo.environment["TARGET_PID"] ?? "") ?? -1; let windows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] ?? []; let matches = windows.filter { ($0[kCGWindowOwnerPID as String] as? Int) == target }; if matches.isEmpty { print("window=unavailable") } else { for window in matches { let owner = window[kCGWindowOwnerName as String] as? String ?? "unavailable"; let name = window[kCGWindowName as String] as? String ?? "unavailable"; let bounds = String(describing: window[kCGWindowBounds as String] ?? "unavailable"); print("owner=\(owner) window_title=\(name) bounds=\(bounds)") } }' \
          2>&1 || true
    fi
  } > "${prefix}-frontmost-window.txt"

  if [[ -x /usr/sbin/screencapture ]]; then
    /usr/sbin/screencapture -x "${prefix}-screen.png" 2>/dev/null || true
  fi
  tail -n 300 "${log}" > "${prefix}-log-tail.txt" 2>/dev/null || true

  local idea_log
  idea_log="$(find "${IDE_SANDBOX_ROOT}" -type f -path '*/log/idea.log' -print 2>/dev/null | head -1)"
  if [[ -n "${idea_log}" ]]; then
    cp "${idea_log}" "${prefix}-idea.log" 2>/dev/null || true
  fi
  local thread_dump
  while IFS= read -r thread_dump; do
    cp "${thread_dump}" "${prefix}-$(basename "${thread_dump}")" 2>/dev/null || true
  done < <(find "${IDE_SANDBOX_ROOT}" -type f -path '*/log/bg-wa/thread-dump-*.txt' -print 2>/dev/null)
}

terminate_launched_processes() {
  local pid="$1"
  local gradle_pid="$2"
  local waited=0

  [[ -z "${pid}" ]] || kill "${pid}" 2>/dev/null || true
  [[ -z "${gradle_pid}" ]] || kill "${gradle_pid}" 2>/dev/null || true
  while (( waited < BENCHMARK_TERMINATE_GRACE_SECONDS )); do
    if { [[ -z "${pid}" ]] || ! kill -0 "${pid}" 2>/dev/null; } &&
      { [[ -z "${gradle_pid}" ]] || ! kill -0 "${gradle_pid}" 2>/dev/null; }; then
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  [[ -z "${pid}" ]] || kill -KILL "${pid}" 2>/dev/null || true
  [[ -z "${gradle_pid}" ]] || kill -KILL "${gradle_pid}" 2>/dev/null || true
}

request_benchmark_exit() {
  local case_dir="$1"
  local variant="$2"
  local log="$3"
  local pid="$4"
  local gradle_pid="$5"

  touch "${case_dir}/stop-requested"
  local waited=0
  while (( waited < BENCHMARK_EXIT_WAIT_SECONDS )); do
    if ! kill -0 "${pid}" 2>/dev/null && ! kill -0 "${gradle_pid}" 2>/dev/null; then
      echo "${variant}_benchmark_exit=graceful waited=${waited}" >> "${case_dir}/summary.properties"
      return 0
    fi
    if grep -q 'MAGIC_JEWEL_IDE_BENCHMARK status=application-exit-requested' "${log}" 2>/dev/null &&
      ! kill -0 "${pid}" 2>/dev/null; then
      echo "${variant}_benchmark_exit=graceful waited=${waited}" >> "${case_dir}/summary.properties"
      kill "${gradle_pid}" 2>/dev/null || true
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  echo "${variant}_benchmark_exit=forced waited=${BENCHMARK_EXIT_WAIT_SECONDS}" >> "${case_dir}/summary.properties"
  return 1
}

run_variant() {
  local case_name="$1"
  local variant="$2"
  local case_dir="$3"
  local case_label="${4:-${case_name}}"
  local log="${case_dir}/${variant}.log"
  local ps_csv="${case_dir}/${variant}-ps.csv"
  local thread_csv="${case_dir}/${variant}-thread-cpu.csv"
  local machine_cpu_csv="${case_dir}/${variant}-machine-cpu.csv"
  local runtime_environment_csv="${case_dir}/${variant}-runtime-environment.csv"
  local display_regime_start="${case_dir}/${variant}-display-regime-start.properties"
  local display_regime_end="${case_dir}/${variant}-display-regime-end.properties"
  local pm="${case_dir}/${variant}-powermetrics.txt"

  rm -f "${case_dir}/stop-requested"

  if uses_patched_ide_product "${variant}"; then
    prepare_patched_ide_product
  fi

  local -a args=(
    --no-daemon --no-configuration-cache
    :ide-benchmark-plugin:runIde
    -PmagicJewelBenchmarkAutorun=true
    "-PmagicJewelBenchmarkMode=${case_name}"
    "-PmagicJewelBenchmarkOut=${case_dir}"
    "-PmagicJewelBenchmarkPaintProbe=${PAINT_PROBE}"
    "-PmagicJewelBenchmarkEdtDispatchProbe=${EDT_DISPATCH_PROBE}"
    "-PmagicJewelBenchmarkProjectPath=${BENCHMARK_PROJECT_PATH}"
    --console=plain
  )
  local benchmark_jvm_args="${BENCHMARK_JVM_ARGS}"
  if [[ "${GC_LOG_TO_FILE}" == "true" ]]; then
    local gc_log="${case_dir}/${variant}-gc.log"
    benchmark_jvm_args+=" -Xlog:gc*:file=${gc_log}:uptimenanos"
    echo "${variant}_gc_log=${gc_log}" >> "${case_dir}/summary.properties"
  fi
  if [[ -n "${benchmark_jvm_args// }" ]]; then
    echo "${variant}_benchmark_jvm_args=${benchmark_jvm_args}" >> "${case_dir}/summary.properties"
    args+=("-PmagicJewelBenchmarkJvmArgs=${benchmark_jvm_args}")
  fi
  if uses_patched_ide_product "${variant}"; then
    echo "${variant}_patched_ide_product=${PATCHED_IDE_PRODUCT_HOME}" >> "${case_dir}/summary.properties"
    args+=(
      "-PmagicJewelPatchedIdeProductPath=${PATCHED_IDE_PRODUCT_HOME}"
    )
  fi
  if [[ "${variant}" == "old" && "${PACE_OLD_BASELINE}" == "true" ]]; then
    echo "old_paced_baseline=true" >> "${case_dir}/summary.properties"
  fi
  if [[ "${variant}" == "new" ]]; then
    validate_jbr_skia_inputs
    echo "new_jbr_skia_render_mode=${JBR_SKIA_RENDER_MODE}" >> "${case_dir}/summary.properties"
    echo "new_jbr_skia_jvm_args=$(jbr_args)" >> "${case_dir}/summary.properties"
    args+=(
      -PjbrSkiaInterop=true
      "-PjbrSkiaRenderMode=${JBR_SKIA_RENDER_MODE}"
      "-PjbrSkiaInteropJvmArgs=$(jbr_args)"
    )
  fi

  if [[ "${PER_VARIANT_PREFLIGHT}" == "true" ]]; then
    local preflight_file="${case_dir}/${variant}-preflight.txt"
    local preflight_ps_file="${case_dir}/${variant}-preflight-ps.txt"
    local preflight_gpu_power_file="${case_dir}/${variant}-preflight-powermetrics.txt"
    echo "${variant}_preflight=${preflight_file}" >> "${case_dir}/summary.properties"
    if write_machine_preflight \
        "${case_label}/${variant}" \
        "${preflight_file}" \
        "${preflight_ps_file}" \
        "${MAX_VARIANT_PREFLIGHT_LOAD_1}" \
        "${MAX_VARIANT_PREFLIGHT_TOP_CPU}" \
        "${preflight_gpu_power_file}"; then
      echo "${variant}_preflight_ready=true" >> "${case_dir}/summary.properties"
    else
      echo "${variant}_preflight_ready=false" >> "${case_dir}/summary.properties"
      echo "${variant}_preflight_failed=true" >> "${case_dir}/summary.properties"
      echo "${variant}_skip_reason=preflight" >> "${case_dir}/summary.properties"
      return 1
    fi
  fi

  if [[ "${DIAGNOSTIC_REUSE_SANDBOX}" == "true" ]]; then
    echo "${variant}_ide_sandbox_policy=reused-diagnostic" >> "${case_dir}/summary.properties"
    echo "${variant}_sandbox_reused=true" >> "${case_dir}/summary.properties"
    local active_sandbox_pid
    active_sandbox_pid="$(find_sandbox_ide_pid)"
    if [[ -n "${active_sandbox_pid}" ]]; then
      echo "${variant}_ide_sandbox_active_pid=${active_sandbox_pid}" >> "${case_dir}/summary.properties"
      return 1
    fi
  else
    echo "${variant}_ide_sandbox_policy=fresh-per-variant" >> "${case_dir}/summary.properties"
    if ! reset_ide_sandbox; then
      echo "${variant}_ide_sandbox_reset_failed=true" >> "${case_dir}/summary.properties"
      return 1
    fi
  fi
  echo "${variant}_startup_dialog_suppression=intellij.startup.wizard=false,idea.initially.ask.config=never,ide.newUsersOnboarding=false,ide.experimental.ui.onboarding=false,idea.trust.all.projects=true" >> "${case_dir}/summary.properties"

  (cd "${ROOT_DIR}" && ./gradlew "${args[@]}") > "${log}" 2>&1 &
  local gradle_pid=$!

  local pid=""
  local observed_pid=""
  local candidate_pid=""
  local project_open_observed_at=-1
  local startup_failure_reason=""
  local waited
  for ((waited = 0; waited < BENCHMARK_START_WAIT_SECONDS; waited++)); do
    candidate_pid="$(started_ide_pid_from_log "${log}")"
    if [[ -z "${candidate_pid}" ]]; then
      candidate_pid="$(find_ide_pid "${case_name}" "${case_dir}")"
    fi
    if [[ -n "${candidate_pid}" ]] && kill -0 "${candidate_pid}" 2>/dev/null; then
      observed_pid="${candidate_pid}"
    fi
    if grep -q 'MAGIC_JEWEL_IDE_BENCHMARK status=startup-failed' "${log}" 2>/dev/null; then
      startup_failure_reason="explicit-startup-failure"
      break
    fi
    if grep -Fq '[Plugin: com.magicjewel.jbrskia.benchmark]' "${log}" 2>/dev/null; then
      startup_failure_reason="benchmark-plugin-exception"
      break
    fi
    if grep -Eq 'MAGIC_JEWEL_IDE_BENCHMARK status=(indexing-timeout|tool-window-missing|spectre-timeout)' "${log}" 2>/dev/null; then
      startup_failure_reason="benchmark-readiness-failure"
      break
    fi
    if ! kill -0 "${gradle_pid}" 2>/dev/null; then
      startup_failure_reason="gradle-exited-before-benchmark-ready"
      break
    fi
    if grep -q 'MAGIC_JEWEL_IDE_BENCHMARK status=project-opened' "${log}" 2>/dev/null; then
      project_open_observed_at=-2
    elif [[ -n "${observed_pid}" && "${project_open_observed_at}" -lt 0 ]]; then
      project_open_observed_at=${waited}
    elif [[ "${project_open_observed_at}" -ge 0 ]] &&
        (( waited - project_open_observed_at >= BENCHMARK_PROJECT_OPEN_WAIT_SECONDS )); then
      startup_failure_reason="project-activity-not-started"
      break
    fi
    if [[ -n "${observed_pid}" ]] &&
        grep -q 'MAGIC_JEWEL_IDE_BENCHMARK status=tool-window-activated' "${log}" 2>/dev/null &&
        grep -q 'MAGIC_JEWEL_IDE_BENCHMARK status=started' "${log}" 2>/dev/null; then
      pid="${observed_pid}"
      break
    fi
    sleep 1
  done
  if [[ -z "${pid}" ]]; then
    observed_pid="$(find_ide_pid "${case_name}" "${case_dir}")"
    echo "${variant}_failed_to_start_ide=true" >> "${case_dir}/summary.properties"
    echo "${variant}_startup_failure_reason=${startup_failure_reason:-timeout}" >> "${case_dir}/summary.properties"
    if [[ -z "${observed_pid}" ]]; then
      echo "failed_to_find_ide_pid=true" >> "${case_dir}/summary.properties"
    else
      echo "${variant}_startup_ide_pid=${observed_pid}" >> "${case_dir}/summary.properties"
    fi
    capture_startup_failure_evidence "${case_dir}" "${variant}" "${log}" "${observed_pid}"
    terminate_launched_processes "${observed_pid}" "${gradle_pid}"
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  ps -p "${pid}" -o command= > "${case_dir}/${variant}-command.txt" 2>/dev/null || true

  if ! wait_for_paint_probe "${log}"; then
    echo "${variant}_startup_ui_ready=false" >> "${case_dir}/summary.properties"
    echo "${variant}_startup_ui_failure=paint-probe-timeout" >> "${case_dir}/summary.properties"
    capture_startup_failure_evidence "${case_dir}" "${variant}" "${log}" "${pid}"
    terminate_launched_processes "${pid}" "${gradle_pid}"
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  local startup_paint_probe startup_expected_node_probe startup_probe_image
  startup_paint_probe="$(grep 'MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=' "${log}" | tail -1 || true)"
  startup_expected_node_probe="$(grep 'MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE_EXPECTED_NODE' "${log}" | tail -1 || true)"
  startup_probe_image="${case_dir}/toolwindow-paint-probe.png"
  local startup_non_dominant_ratio startup_distinct_colors
  local startup_content_non_dominant_ratio startup_content_distinct_colors
  startup_non_dominant_ratio="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^nonDominantRatio=/) {split($i, a, "="); print a[2]}}' <<< "${startup_paint_probe}")"
  startup_distinct_colors="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^distinct=/) {split($i, a, "="); print a[2]}}' <<< "${startup_paint_probe}")"
  startup_content_non_dominant_ratio="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^contentNonDominantRatio=/) {split($i, a, "="); print a[2]}}' <<< "${startup_paint_probe}")"
  startup_content_distinct_colors="$(awk '{for (i=1; i<=NF; i++) if ($i ~ /^contentDistinct=/) {split($i, a, "="); print a[2]}}' <<< "${startup_paint_probe}")"
  if [[ "${startup_expected_node_probe}" != *"present=true"* ||
        "${startup_paint_probe}" != *"status=captured"* ||
        ! -f "${startup_probe_image}" ]] ||
      ! awk \
        -v ratio="${startup_non_dominant_ratio:-0}" \
        -v distinct="${startup_distinct_colors:-0}" \
        -v content_ratio="${startup_content_non_dominant_ratio:-0}" \
        -v content_distinct="${startup_content_distinct_colors:-0}" \
        'BEGIN { exit (ratio >= 0.005 && distinct >= 8 && content_ratio >= 0.02 && content_distinct >= 16) ? 0 : 1 }'; then
    echo "${variant}_startup_ui_ready=false" >> "${case_dir}/summary.properties"
    echo "${variant}_startup_ui_failure=expected-node-or-render-proof" >> "${case_dir}/summary.properties"
    capture_startup_failure_evidence "${case_dir}" "${variant}" "${log}" "${pid}"
    terminate_launched_processes "${pid}" "${gradle_pid}"
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  echo "${variant}_startup_ui_ready=true" >> "${case_dir}/summary.properties"

  local foreign_gpu_watch_preflight_max_cpu
  if ! foreign_gpu_watch_preflight_max_cpu="$(wait_for_foreign_gpu_watch_quiet)"; then
    echo "${variant}_foreign_gpu_watch_preflight_max_cpu_percent=${foreign_gpu_watch_preflight_max_cpu:-unavailable}" >> "${case_dir}/summary.properties"
    echo "${variant}_foreign_gpu_watch_preflight_threshold_exceeded=true" >> "${case_dir}/summary.properties"
    echo "${variant}_foreign_gpu_watch_cpu_threshold=${MAX_FOREIGN_GPU_WATCH_CPU}" >> "${case_dir}/summary.properties"
    terminate_launched_processes "${pid}" "${gradle_pid}"
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  echo "${variant}_foreign_gpu_watch_preflight_max_cpu_percent=${foreign_gpu_watch_preflight_max_cpu:-0}" >> "${case_dir}/summary.properties"

  local surface_regime_signature
  surface_regime_signature="$(benchmark_surface_regime_signature "${log}")"
  if [[ "${REQUIRE_PINNED_SURFACE_REGIME}" == "true" &&
      ( -z "${EXPECTED_TOOLWINDOW_SURFACE_REGIME}" || "${surface_regime_signature}" != "${EXPECTED_TOOLWINDOW_SURFACE_REGIME}" ) ]]; then
    echo "${variant}_surface_regime_expected=${EXPECTED_TOOLWINDOW_SURFACE_REGIME:-missing}" >> "${case_dir}/summary.properties"
    echo "${variant}_surface_regime_actual=${surface_regime_signature:-unavailable}" >> "${case_dir}/summary.properties"
    echo "${variant}_surface_regime_mismatch=true" >> "${case_dir}/summary.properties"
    terminate_launched_processes "${pid}" "${gradle_pid}"
    wait "${gradle_pid}" 2>/dev/null || true
    return 1
  fi
  capture_display_regime "${display_regime_start}" || true
  local display_regime_start_signature
  display_regime_start_signature="$(display_regime_signature "${display_regime_start}")"
  if [[ -n "${display_regime_start_signature}" && -n "${surface_regime_signature}" ]]; then
    display_regime_start_signature+=";surface:${surface_regime_signature}"
  else
    display_regime_start_signature=""
  fi
  sample_process "${case_name}" "${variant}" "${pid}" "${ps_csv}" &
  local active_window_start_line active_window_end_line active_window_log
  active_window_start_line=$(( $(wc -l < "${log}") + 1 ))
  local sampler_pid=$!
  sample_thread_cpu "${case_name}" "${variant}" "${pid}" "${thread_csv}" &
  local thread_sampler_pid=$!
  sample_machine_cpu "${case_name}" "${variant}" "${pid}" "${machine_cpu_csv}" &
  local machine_sampler_pid=$!
  sample_runtime_environment "${case_name}" "${variant}" "${pid}" "${runtime_environment_csv}" &
  local runtime_environment_sampler_pid=$!
  start_powermetrics "${pm}"

  sleep "${SAMPLE_SECONDS}"
  capture_display_regime "${display_regime_end}" || true
  active_window_end_line="$(wc -l < "${log}")"
  active_window_log="${case_dir}/${variant}-active-window.log"
  sed -n "${active_window_start_line},${active_window_end_line}p" "${log}" > "${active_window_log}"
  local paint_probe_ready=true
  wait_for_paint_probe "${log}" || {
    paint_probe_ready=false
    echo "${variant}_paint_probe_wait_timeout=true" >> "${case_dir}/summary.properties"
  }

  stop_pid_file "${pm}.pid"
  kill "${sampler_pid}" 2>/dev/null || true
  kill "${thread_sampler_pid}" 2>/dev/null || true
  kill "${machine_sampler_pid}" 2>/dev/null || true
  kill "${runtime_environment_sampler_pid}" 2>/dev/null || true
  wait "${sampler_pid}" 2>/dev/null || true
  wait "${thread_sampler_pid}" 2>/dev/null || true
  wait "${machine_sampler_pid}" 2>/dev/null || true
  wait "${runtime_environment_sampler_pid}" 2>/dev/null || true
  request_benchmark_exit "${case_dir}" "${variant}" "${log}" "${pid}" "${gradle_pid}" || {
    terminate_launched_processes "${pid}" "${gradle_pid}"
  }
  wait "${gradle_pid}" 2>/dev/null || true

  if [[ "${REQUIRE_TRACE_OUTPUT}" == "true" ]]; then
    if [[ -z "${TRACE_OUTPUT_DIR}" ]]; then
      echo "${variant}_trace_output_status=missing-directory-config" >> "${case_dir}/summary.properties"
      return 1
    fi
    local trace_file_count trace_nonempty_file_count
    trace_file_count="$({ find "${TRACE_OUTPUT_DIR}" -type f -name '*.perfetto-trace' 2>/dev/null || true; } | wc -l | tr -d ' ')"
    trace_nonempty_file_count="$({ find "${TRACE_OUTPUT_DIR}" -type f -name '*.perfetto-trace' -size +0c 2>/dev/null || true; } | wc -l | tr -d ' ')"
    echo "${variant}_trace_output_dir=${TRACE_OUTPUT_DIR}" >> "${case_dir}/summary.properties"
    echo "${variant}_trace_file_count=${trace_file_count}" >> "${case_dir}/summary.properties"
    echo "${variant}_trace_nonempty_file_count=${trace_nonempty_file_count}" >> "${case_dir}/summary.properties"
    if [[ "${trace_nonempty_file_count}" == "0" ]]; then
      echo "${variant}_trace_output_status=trace-empty" >> "${case_dir}/summary.properties"
      return 1
    fi
    echo "${variant}_trace_output_status=complete" >> "${case_dir}/summary.properties"
  fi

  echo "${variant}_pid=${pid}" >> "${case_dir}/summary.properties"
  echo "${variant}_ps=$(summarize_ps "${ps_csv}")" >> "${case_dir}/summary.properties"
  echo "${variant}_thread_cpu=$(summarize_thread_cpu "${thread_csv}")" >> "${case_dir}/summary.properties"
  echo "${variant}_machine_cpu=$(summarize_machine_cpu "${machine_cpu_csv}")" >> "${case_dir}/summary.properties"
  local display_regime_end_signature runtime_environment_summary
  display_regime_end_signature="$(display_regime_signature "${display_regime_end}")"
  if [[ -n "${display_regime_end_signature}" && -n "${surface_regime_signature}" ]]; then
    display_regime_end_signature+=";surface:${surface_regime_signature}"
  else
    display_regime_end_signature=""
  fi
  runtime_environment_summary="$(summarize_runtime_environment "${runtime_environment_csv}")"
  echo "${variant}_display_regime_start=${display_regime_start}" >> "${case_dir}/summary.properties"
  echo "${variant}_display_regime_end=${display_regime_end}" >> "${case_dir}/summary.properties"
  echo "${variant}_display_regime_start_signature=${display_regime_start_signature:-unavailable}" >> "${case_dir}/summary.properties"
  echo "${variant}_display_regime_end_signature=${display_regime_end_signature:-unavailable}" >> "${case_dir}/summary.properties"
  echo "${variant}_surface_regime_signature=${surface_regime_signature:-unavailable}" >> "${case_dir}/summary.properties"
  echo "${variant}_runtime_environment=${runtime_environment_summary}" >> "${case_dir}/summary.properties"
  echo "${variant}_powermetrics_status=$(cat "${pm}.status" 2>/dev/null || echo not-run)" >> "${case_dir}/summary.properties"
  echo "${variant}_powermetrics_summary=$(summarize_powermetrics "${pm}")" >> "${case_dir}/summary.properties"
  local benchmark_ticks benchmark_frames paint_frames command_frames picture_frames fallbacks
  benchmark_ticks="$(grep -c 'MAGIC_JEWEL_IDE_BENCHMARK phase=tick' "${active_window_log}" || true)"
  benchmark_frames="$(grep -c 'MAGIC_JEWEL_IDE_BENCHMARK_FRAME' "${active_window_log}" || true)"
  paint_frames="$(grep -c "${CMP_SWING_PAINT_MARKER}" "${active_window_log}" || true)"
  command_frames="$(grep -c 'JBR_SKIA_INTEROP_COMMAND_FRAME' "${active_window_log}" || true)"
  picture_frames="$(grep -c 'JBR_SKIA_INTEROP_PICTURE_FRAME' "${active_window_log}" || true)"
  fallbacks="$(grep -c 'JBR_SKIA_INTEROP_FALLBACK' "${active_window_log}" || true)"
  echo "${variant}_benchmark_ticks=${benchmark_ticks}" >> "${case_dir}/summary.properties"
  echo "${variant}_benchmark_frames=${benchmark_frames}" >> "${case_dir}/summary.properties"
  local paint_pacing present_pacing present_source present_call_pacing
  paint_pacing="$(summarize_pacing_intervals "${active_window_log}" "${CMP_SWING_PAINT_MARKER}" 16666667)"
  present_pacing="$(summarize_pacing_intervals "${active_window_log}" "JBR_SKIA_FRAME_PRESENTED" 16666667)"
  present_source="$(summarize_marker_sources "${active_window_log}" "JBR_SKIA_FRAME_PRESENTED")"
  present_call_pacing="$(summarize_pacing_intervals "${active_window_log}" "JBR_SKIA_FRAME_PRESENT_CALL" 16666667)"
  echo "${variant}_active_window_log=${active_window_log}" >> "${case_dir}/summary.properties"
  echo "${variant}_active_window_start_line=${active_window_start_line}" >> "${case_dir}/summary.properties"
  echo "${variant}_active_window_end_line=${active_window_end_line}" >> "${case_dir}/summary.properties"
  echo "${variant}_paint_frames=${paint_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_paint_pacing=${paint_pacing}" >> "${case_dir}/summary.properties"
  echo "${variant}_present_pacing=${present_pacing}" >> "${case_dir}/summary.properties"
  echo "${variant}_present_pacing_source=${present_source}" >> "${case_dir}/summary.properties"
  echo "${variant}_present_call_pacing=${present_call_pacing}" >> "${case_dir}/summary.properties"
  if [[ "${variant}" == "new" && "${present_source}" == "source=none" && "${present_call_pacing}" =~ ^intervals=[1-9] ]]; then
    echo "${variant}_present_glass_unavailable=true" >> "${case_dir}/summary.properties"
  fi
  echo "${variant}_command_frames=${command_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_command_frame_summary=$(summarize_command_frames "${log}")" >> "${case_dir}/summary.properties"
  echo "${variant}_command_timing_summary=$(summarize_command_timing "${log}")" >> "${case_dir}/summary.properties"
  echo "${variant}_picture_frames=${picture_frames}" >> "${case_dir}/summary.properties"
  echo "${variant}_fallbacks=${fallbacks}" >> "${case_dir}/summary.properties"
  if [[ "${benchmark_frames}" == "0" ]]; then
    echo "${variant}_benchmark_frames_missing=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_DISPLAY_REGIME_MATCH}" == "true" &&
      ( -z "${display_regime_start_signature}" || "${display_regime_start_signature}" != "${display_regime_end_signature}" ) ]]; then
    echo "${variant}_display_regime_changed_or_unavailable=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_REMOTE_SESSION_CLEAN}" == "true" && "${runtime_environment_summary}" != *"remote_samples=0"* ]]; then
    echo "${variant}_remote_session_detected=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  local foreign_gpu_watch_max_cpu
  foreign_gpu_watch_max_cpu="$(awk '{ for (i = 1; i <= NF; i++) if ($i ~ /^foreign_gpu_watch_max_cpu_percent=/) { sub(/^foreign_gpu_watch_max_cpu_percent=/, "", $i); print $i; exit } }' <<< "${runtime_environment_summary}")"
  echo "${variant}_foreign_gpu_watch_max_cpu_percent=${foreign_gpu_watch_max_cpu:-0}" >> "${case_dir}/summary.properties"
  if [[ "${REQUIRE_FOREIGN_GPU_WATCH_CLEAN}" == "true" ]] &&
      ! awk -v observed="${foreign_gpu_watch_max_cpu:-0}" -v threshold="${MAX_FOREIGN_GPU_WATCH_CPU}" 'BEGIN { exit observed <= threshold ? 0 : 1 }'; then
    echo "${variant}_foreign_gpu_watch_cpu_threshold_exceeded=true" >> "${case_dir}/summary.properties"
    echo "${variant}_foreign_gpu_watch_cpu_threshold=${MAX_FOREIGN_GPU_WATCH_CPU}" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_PACING_INTERVALS}" == "true" ]] && [[ ! "${paint_pacing}" =~ ^intervals=[1-9] ]]; then
    echo "${variant}_pacing_intervals_missing=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_PRESENT_PACING}" == "true" ]] && [[ ! "${present_pacing}" =~ ^intervals=[1-9] ]]; then
    echo "${variant}_present_pacing_intervals_missing=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_PRESENT_PACING}" == "false" && "${variant}" == "new" &&
      "${present_source}" == "source=none" && ! "${present_call_pacing}" =~ ^intervals=[1-9] ]]; then
    echo "${variant}_present_call_pacing_missing=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${present_source}" == "source=mixed" ]]; then
    echo "${variant}_present_pacing_source_mixed=true" >> "${case_dir}/summary.properties"
    return 1
  fi
  if [[ "${REQUIRE_DISPLAY_LINK_PACING}" == "true" && "${variant}" == "new" ]]; then
    if ! grep -q 'CMP_SWING_DISPLAY_LINK_PACING status=handshake' "${log}"; then
      echo "${variant}_display_link_pacing_handshake_missing=true" >> "${case_dir}/summary.properties"
      return 1
    fi
    if ! grep -Eq 'SKIKO_JBR_DISPLAY_LINK_PACING counters emitted=[1-9][0-9]* coalesced=[0-9]+ consumed=[1-9][0-9]*' "${log}"; then
      echo "${variant}_display_link_pacing_counters_missing=true" >> "${case_dir}/summary.properties"
      return 1
    fi
    if grep -Eq '(CMP_SWING|SKIKO_JBR)_DISPLAY_LINK_PACING status=timer-fallback' "${log}"; then
      echo "${variant}_display_link_pacing_timer_fallback=true" >> "${case_dir}/summary.properties"
      return 1
    fi
  fi
  if [[ "${paint_probe_ready}" != "true" ]]; then
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
    local probe_image="${case_dir}/toolwindow-paint-probe.png"
    local variant_probe_image="${case_dir}/${variant}-toolwindow-paint-probe.png"
    if [[ -f "${probe_image}" ]]; then
      cp "${probe_image}" "${variant_probe_image}"
      echo "${variant}_paint_probe_image=${variant_probe_image}" >> "${case_dir}/summary.properties"
    else
      echo "${variant}_paint_probe_image_missing=true" >> "${case_dir}/summary.properties"
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
printf "case\titeration\tattempts\tstatus\told_ps\tnew_ps\told_thread_cpu\tnew_thread_cpu\told_machine_cpu\tnew_machine_cpu\told_command_summary\tnew_command_summary\told_timing_summary\tnew_timing_summary\told_powermetrics\tnew_powermetrics\told_powermetrics_summary\tnew_powermetrics_summary\told_benchmark_ticks\tnew_benchmark_ticks\told_benchmark_frames\tnew_benchmark_frames\told_paint_frames\tnew_paint_frames\told_command_frames\tnew_command_frames\told_picture_frames\tnew_picture_frames\told_fallbacks\tnew_fallbacks\told_display_regime\tnew_display_regime\told_runtime_environment\tnew_runtime_environment\treport\n" > "${suite_tsv}"

failed_rows=0
suite_display_regime_signature=""
iteration=1
while (( iteration <= REPEAT_COUNT )); do
  iteration_label="r$(printf '%02d' "${iteration}")"
  for case_name in ${CASES}; do
    case_label="${case_name}"
    case_dir_base="${OUT_ROOT}/${case_name}"
    if (( REPEAT_COUNT > 1 )); then
      case_label="${case_name}#${iteration_label}"
      case_dir_base="${OUT_ROOT}/${case_name}-${iteration_label}"
    fi
    attempt=1
    case_dir="${case_dir_base}"
    status="failed"
    while true; do
      if (( attempt == 1 )); then
        case_dir="${case_dir_base}"
      else
        case_dir="${case_dir_base}-attempt$(printf '%02d' "${attempt}")"
      fi
      mkdir -p "${case_dir}"
      echo "case=${case_name}" > "${case_dir}/summary.properties"
      echo "case_label=${case_label}" >> "${case_dir}/summary.properties"
      echo "iteration=${iteration}" >> "${case_dir}/summary.properties"
      echo "attempt=${attempt}" >> "${case_dir}/summary.properties"
      echo "max_preflight_retries_per_slot=${MAX_PREFLIGHT_RETRIES_PER_SLOT}" >> "${case_dir}/summary.properties"
      echo "repeat_count=${REPEAT_COUNT}" >> "${case_dir}/summary.properties"
      echo "sample_seconds=${SAMPLE_SECONDS}" >> "${case_dir}/summary.properties"
      echo "variants=${VARIANTS}" >> "${case_dir}/summary.properties"
      echo "collect_powermetrics=${COLLECT_POWERMETRICS}" >> "${case_dir}/summary.properties"
      echo "collect_thread_cpu=${COLLECT_THREAD_CPU}" >> "${case_dir}/summary.properties"
      echo "collect_machine_cpu=${COLLECT_MACHINE_CPU}" >> "${case_dir}/summary.properties"
      echo "paint_probe=${PAINT_PROBE}" >> "${case_dir}/summary.properties"
      echo "diagnostic_run=${DIAGNOSTIC_RUN}" >> "${case_dir}/summary.properties"
      echo "diagnostic_sandbox_reused=${DIAGNOSTIC_REUSE_SANDBOX}" >> "${case_dir}/summary.properties"
      echo "gc_log_to_file=${GC_LOG_TO_FILE}" >> "${case_dir}/summary.properties"
      echo "require_trace_output=${REQUIRE_TRACE_OUTPUT}" >> "${case_dir}/summary.properties"
      echo "require_pacing_intervals=${REQUIRE_PACING_INTERVALS}" >> "${case_dir}/summary.properties"
      echo "require_present_pacing=${REQUIRE_PRESENT_PACING}" >> "${case_dir}/summary.properties"
      echo "require_display_link_pacing=${REQUIRE_DISPLAY_LINK_PACING}" >> "${case_dir}/summary.properties"
      echo "require_display_regime_match=${REQUIRE_DISPLAY_REGIME_MATCH}" >> "${case_dir}/summary.properties"
      echo "require_pinned_surface_regime=${REQUIRE_PINNED_SURFACE_REGIME}" >> "${case_dir}/summary.properties"
      echo "expected_toolwindow_surface_regime=${EXPECTED_TOOLWINDOW_SURFACE_REGIME:-missing}" >> "${case_dir}/summary.properties"
      echo "require_remote_session_clean=${REQUIRE_REMOTE_SESSION_CLEAN}" >> "${case_dir}/summary.properties"
      echo "require_foreign_gpu_watch_clean=${REQUIRE_FOREIGN_GPU_WATCH_CLEAN}" >> "${case_dir}/summary.properties"
      echo "max_foreign_gpu_watch_cpu=${MAX_FOREIGN_GPU_WATCH_CPU}" >> "${case_dir}/summary.properties"
      echo "foreign_gpu_watch_quiet_wait_seconds=${FOREIGN_GPU_WATCH_QUIET_WAIT_SECONDS}" >> "${case_dir}/summary.properties"
      echo "foreign_gpu_watch_quiet_poll_seconds=${FOREIGN_GPU_WATCH_QUIET_POLL_SECONDS}" >> "${case_dir}/summary.properties"
      echo "runtime_environment_sample_interval_seconds=${RUNTIME_ENVIRONMENT_SAMPLE_INTERVAL_SECONDS}" >> "${case_dir}/summary.properties"
      echo "remote_session_process_regex=${REMOTE_SESSION_PROCESS_REGEX}" >> "${case_dir}/summary.properties"
      echo "foreign_gpu_watch_process_regex=${FOREIGN_GPU_WATCH_PROCESS_REGEX}" >> "${case_dir}/summary.properties"
      echo "trace_output_dir=${TRACE_OUTPUT_DIR}" >> "${case_dir}/summary.properties"
      echo "pace_old_baseline=${PACE_OLD_BASELINE}" >> "${case_dir}/summary.properties"
      echo "per_variant_preflight=${PER_VARIANT_PREFLIGHT}" >> "${case_dir}/summary.properties"
      echo "require_clean_preflight=${REQUIRE_CLEAN_PREFLIGHT}" >> "${case_dir}/summary.properties"
      echo "max_variant_preflight_load_1=${MAX_VARIANT_PREFLIGHT_LOAD_1}" >> "${case_dir}/summary.properties"
      echo "max_variant_preflight_top_cpu=${MAX_VARIANT_PREFLIGHT_TOP_CPU}" >> "${case_dir}/summary.properties"
      echo "preflight_gpu_sample_seconds=${PREFLIGHT_GPU_SAMPLE_SECONDS}" >> "${case_dir}/summary.properties"
      echo "max_variant_preflight_gpu_power_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_MW}" >> "${case_dir}/summary.properties"
      echo "max_variant_preflight_gpu_power_peak_mw=${MAX_VARIANT_PREFLIGHT_GPU_POWER_PEAK_MW}" >> "${case_dir}/summary.properties"
      echo "max_sample_top_cpu=${MAX_SAMPLE_TOP_CPU}" >> "${case_dir}/summary.properties"
      echo "benchmark_project_path=${BENCHMARK_PROJECT_PATH}" >> "${case_dir}/summary.properties"
      status="passed"
      for variant in ${VARIANTS}; do
        if ! run_variant "${case_name}" "${variant}" "${case_dir}" "${case_label}"; then
          status="failed"
          break
        fi
      done
      if [[ "${status}" == "passed" && "${REQUIRE_DISPLAY_REGIME_MATCH}" == "true" ]]; then
        old_display_regime="$(summary_value "${case_dir}/summary.properties" old_display_regime_start_signature)"
        new_display_regime="$(summary_value "${case_dir}/summary.properties" new_display_regime_start_signature)"
        if [[ -z "${old_display_regime}" || -z "${new_display_regime}" || "${old_display_regime}" != "${new_display_regime}" ]]; then
          echo "display_regime_old_new_match=false" >> "${case_dir}/summary.properties"
          status="failed"
        elif [[ -z "${suite_display_regime_signature}" ]]; then
          suite_display_regime_signature="${old_display_regime}"
          echo "suite_display_regime_signature=${suite_display_regime_signature}" >> "${case_dir}/summary.properties"
        elif [[ "${suite_display_regime_signature}" != "${old_display_regime}" ]]; then
          echo "display_regime_suite_match=false" >> "${case_dir}/summary.properties"
          echo "suite_display_regime_expected=${suite_display_regime_signature}" >> "${case_dir}/summary.properties"
          status="failed"
        else
          echo "suite_display_regime_signature=${suite_display_regime_signature}" >> "${case_dir}/summary.properties"
        fi
      fi
      old_skip_reason="$(summary_value "${case_dir}/summary.properties" old_skip_reason)"
      new_skip_reason="$(summary_value "${case_dir}/summary.properties" new_skip_reason)"
      if [[ "${status}" == "failed" &&
          ( "${old_skip_reason}" == "preflight" || "${new_skip_reason}" == "preflight" ) &&
          "${attempt}" -le "${MAX_PREFLIGHT_RETRIES_PER_SLOT}" ]]; then
        echo "retrying ${case_label} after preflight skip attempt=${attempt}/${MAX_PREFLIGHT_RETRIES_PER_SLOT}" >&2
        attempt=$((attempt + 1))
        continue
      fi
      if [[ "${status}" == "failed" ]]; then
        failed_rows=$((failed_rows + 1))
      fi
      break
    done
    old_ps="$(summary_value "${case_dir}/summary.properties" old_ps)"
    new_ps="$(summary_value "${case_dir}/summary.properties" new_ps)"
    old_thread_cpu="$(summary_value "${case_dir}/summary.properties" old_thread_cpu)"
    new_thread_cpu="$(summary_value "${case_dir}/summary.properties" new_thread_cpu)"
    old_machine_cpu="$(summary_value "${case_dir}/summary.properties" old_machine_cpu)"
    new_machine_cpu="$(summary_value "${case_dir}/summary.properties" new_machine_cpu)"
    old_command_summary="$(summary_value "${case_dir}/summary.properties" old_command_frame_summary)"
    new_command_summary="$(summary_value "${case_dir}/summary.properties" new_command_frame_summary)"
    old_timing_summary="$(summary_value "${case_dir}/summary.properties" old_command_timing_summary)"
    new_timing_summary="$(summary_value "${case_dir}/summary.properties" new_command_timing_summary)"
    old_powermetrics_status="$(summary_value "${case_dir}/summary.properties" old_powermetrics_status)"
    new_powermetrics_status="$(summary_value "${case_dir}/summary.properties" new_powermetrics_status)"
    old_powermetrics_summary="$(summary_value "${case_dir}/summary.properties" old_powermetrics_summary)"
    new_powermetrics_summary="$(summary_value "${case_dir}/summary.properties" new_powermetrics_summary)"
    old_ticks="$(summary_value "${case_dir}/summary.properties" old_benchmark_ticks)"
    new_ticks="$(summary_value "${case_dir}/summary.properties" new_benchmark_ticks)"
    old_frames="$(summary_value "${case_dir}/summary.properties" old_benchmark_frames)"
    new_frames="$(summary_value "${case_dir}/summary.properties" new_benchmark_frames)"
    old_paint_frames="$(summary_value "${case_dir}/summary.properties" old_paint_frames)"
    new_paint_frames="$(summary_value "${case_dir}/summary.properties" new_paint_frames)"
    old_command="$(summary_value "${case_dir}/summary.properties" old_command_frames)"
    new_command="$(summary_value "${case_dir}/summary.properties" new_command_frames)"
    old_picture="$(summary_value "${case_dir}/summary.properties" old_picture_frames)"
    new_picture="$(summary_value "${case_dir}/summary.properties" new_picture_frames)"
    old_fallbacks="$(summary_value "${case_dir}/summary.properties" old_fallbacks)"
    new_fallbacks="$(summary_value "${case_dir}/summary.properties" new_fallbacks)"
    old_display_regime="$(summary_value "${case_dir}/summary.properties" old_display_regime_start_signature)"
    new_display_regime="$(summary_value "${case_dir}/summary.properties" new_display_regime_start_signature)"
    old_runtime_environment="$(summary_value "${case_dir}/summary.properties" old_runtime_environment)"
    new_runtime_environment="$(summary_value "${case_dir}/summary.properties" new_runtime_environment)"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
      "${case_label}" "${iteration}" "${attempt}" "${status}" "${old_ps}" "${new_ps}" "${old_thread_cpu}" "${new_thread_cpu}" "${old_machine_cpu}" "${new_machine_cpu}" "${old_command_summary}" "${new_command_summary}" \
      "${old_timing_summary}" "${new_timing_summary}" "${old_powermetrics_status}" "${new_powermetrics_status}" "${old_powermetrics_summary}" "${new_powermetrics_summary}" "${old_ticks}" "${new_ticks}" "${old_frames}" "${new_frames}" "${old_paint_frames}" "${new_paint_frames}" "${old_command}" "${new_command}" \
      "${old_picture}" "${new_picture}" "${old_fallbacks}" "${new_fallbacks}" "${old_display_regime}" "${new_display_regime}" "${old_runtime_environment}" "${new_runtime_environment}" "${case_dir}" >> "${suite_tsv}"
  done
  iteration=$((iteration + 1))
done

echo "suite=${suite_tsv}"
if (( failed_rows > 0 )); then
  echo "failed_rows=${failed_rows}" >&2
  exit 1
fi
