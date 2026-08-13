#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-standalone-software-fallback-suite/$(date +%Y%m%d-%H%M%S)}"
RUN_SECONDS="${RUN_SECONDS:-30}"
MAXIMIZED="${MAXIMIZED:-false}"
DISPLAY_TARGET="${DISPLAY_TARGET:-default}"
START_WAIT_SECONDS="${START_WAIT_SECONDS:-90}"
LOCAL_SKIKO_AWT_JAR="${LOCAL_SKIKO_AWT_JAR:-${ROOT_DIR}/../skiko/skiko/build/libs/skiko-awt-0.0.0-SNAPSHOT.jar}"
LOCAL_JBR_RUNTIME_HOME="${LOCAL_JBR_RUNTIME_HOME:-${ROOT_DIR}/../jbr/build/macosx-aarch64-server-release/images/jdk}"
DESKTOP_PATCH="${DESKTOP_PATCH:-/tmp/jbr-skia-run/desktop}"
JBR_API_SHIM="${JBR_API_SHIM:-/tmp/jbr-api-shim.jar}"
JBR_SKIA_LIB="${JBR_SKIA_LIB:-${LOCAL_JBR_RUNTIME_HOME}/lib/libjbrskiainterop.dylib}"

mkdir -p "${OUT_ROOT}"
[[ -f "${LOCAL_SKIKO_AWT_JAR}" ]] || { echo "missing local Skiko AWT jar: ${LOCAL_SKIKO_AWT_JAR}" >&2; exit 2; }

jbr_args() {
  printf '%s ' \
    "--patch-module=java.desktop=${DESKTOP_PATCH}" \
    "-Xbootclasspath/a:${JBR_API_SHIM}" \
    "--add-exports=java.desktop/com.jetbrains.desktop=ALL-UNNAMED" \
    "-Dsun.java2d.skia.interop=true" \
    "-Dsun.java2d.skia.interop.library=${JBR_SKIA_LIB}" \
    "-Dcompose.jbr.skia.command.strict=true" \
    "-Dcompose.jbr.skia.command.logFrames=true" \
    "-Dskiko.jbr.interop.logCommandFrames=true"
}

summarize_cpu() {
  awk -F, 'NR > 1 { cpu += $2; rss += $3; n++; if ($2 > maxCpu) maxCpu = $2 } END { if (n) printf "samples=%d avg_cpu=%.2f max_cpu=%.2f avg_rss_kb=%.0f", n, cpu/n, maxCpu, rss/n; else print "samples=0" }' "$1"
}

run_variant() {
  local name="$1"
  local task="$2"
  local expected_painter="$3"
  local log="${OUT_ROOT}/${name}.log"
  local cpu_csv="${OUT_ROOT}/${name}-cpu.csv"
  local summary="${OUT_ROOT}/${name}.properties"
  local -a gradle_args=("${task}" --no-daemon --no-configuration-cache --console=plain "-PjewelStandaloneMaximized=${MAXIMIZED}" "-PjewelStandaloneDisplayTarget=${DISPLAY_TARGET}")

  printf 'variant=%s\nfresh_per_run=true\nmaximized=%s\ndisplay_target=%s\nlocal_skiko_awt_jar=%s\nlocal_skiko_awt_sha256=%s\nexpected_painter=%s\n' \
    "${name}" "${MAXIMIZED}" "${DISPLAY_TARGET}" "${LOCAL_SKIKO_AWT_JAR}" "$(shasum -a 256 "${LOCAL_SKIKO_AWT_JAR}" | awk '{print $1}')" "${expected_painter}" > "${summary}"
  if [[ "${name}" == *jbr* ]]; then
    [[ -x "${LOCAL_JBR_RUNTIME_HOME}/bin/java" && -d "${DESKTOP_PATCH}" && -f "${JBR_API_SHIM}" && -f "${JBR_SKIA_LIB}" ]] || {
      echo "missing JBR inputs for ${name}" >&2
      return 1
    }
    gradle_args+=("-PjbrSkiaRenderMode=commands" "-PjbrSkiaInteropJvmArgs=$(jbr_args)")
  fi

  (
    export JAVA_HOME="${LOCAL_JBR_RUNTIME_HOME}"
    export JEWEL_STANDALONE_AUTO_EXIT_SECONDS="$((RUN_SECONDS + 8))"
    export JEWEL_STANDALONE_INITIAL_VIEW=Hypnotoad
    export JEWEL_STANDALONE_SPECTRE_STRESS=true
    export JEWEL_STANDALONE_SPECTRE_STRESS_INTERVAL_MILLIS=250
    export JEWEL_STANDALONE_SPECTRE_STRESS_MODE=hypnotoad
    export SKIKO_SWING_PAINTER_PROBE_ENABLED=true
    export JBR_SKIA_RENDER_MODE=commands
    cd "${ROOT_DIR}"
    exec ./gradlew "${gradle_args[@]}"
  ) > "${log}" 2>&1 &
  local gradle_pid=$!
  local app_pid=""
  for ((waited = 0; waited < START_WAIT_SECONDS; waited++)); do
    app_pid="$(awk '/JEWEL_STANDALONE status=started/ { for (i = 1; i <= NF; i++) if ($i ~ /^pid=[0-9]+$/) { split($i, p, "="); print p[2]; exit } }' "${log}")"
    [[ -n "${app_pid}" ]] && break
    sleep 1
  done
  [[ -n "${app_pid}" ]] || { echo "${name}_startup=missing" >> "${summary}"; wait "${gradle_pid}" || true; return 1; }
  grep -q "SKIKO_SWING_PAINTER painter=${expected_painter}" "${log}" || {
    echo "${name}_painter_probe=missing-or-wrong" >> "${summary}"; wait "${gradle_pid}" || true; return 1;
  }
  grep -q 'JEWEL_STANDALONE_SPECTRE status=started' "${log}" || {
    echo "${name}_spectre=missing" >> "${summary}"; wait "${gradle_pid}" || true; return 1;
  }
  local painter_class render_mode scope_registration start_marker
  painter_class="AcceleratedSwingPainter"
  [[ "${expected_painter}" == "software" ]] && painter_class="SoftwareSwingPainter"
  render_mode="swing-graphics"
  scope_registration="not-requested"
  if [[ "${name}" == *jbr* ]]; then
    grep -q 'SKIKO_JBR_INTEROP_SCOPE_ACQUIRED' "${log}" || {
      echo "${name}_scope_registration=missing" >> "${summary}"; wait "${gradle_pid}" || true; return 1;
    }
    render_mode="jbr-command"
    scope_registration="acquired"
  fi
  start_marker="$(grep 'JEWEL_STANDALONE status=started' "${log}" | head -1)"
  printf 'observed_painter_class=%s\nrender_mode=%s\nscope_registration=%s\nstart_marker=%s\n' \
    "${painter_class}" "${render_mode}" "${scope_registration}" "${start_marker}" >> "${summary}"
  printf 'time,cpu,rss_kb\n' > "${cpu_csv}"
  for ((sample = 0; sample < RUN_SECONDS; sample++)); do
    ps -p "${app_pid}" -o %cpu= -o rss= 2>/dev/null | awk -v now="$(date +%s)" '{ printf "%s,%s,%s\n", now, $1, $2 }' >> "${cpu_csv}" || true
    sleep 1
  done
  wait "${gradle_pid}"
  grep -q 'JEWEL_STANDALONE status=auto-exit' "${log}" || { echo "${name}_auto_exit=missing" >> "${summary}"; return 1; }
  printf '%s_painter_probe=ok\n%s_spectre=ok\n%s_cpu=%s\n' "${name}" "${name}" "${name}" "$(summarize_cpu "${cpu_csv}")" >> "${summary}"
}

run_variant accelerated :runJewelStandalone accelerated
run_variant jbr-accelerated :runJewelStandaloneJbrSkiaInterop accelerated
run_variant jbr-software :runJewelStandaloneSoftwareJbrSkiaInterop software

echo "suite=${OUT_ROOT}"
