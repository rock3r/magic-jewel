#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/$(date +%Y%m%d-%H%M%S)}"
READY_ROOT="${READY_ROOT:-${OUT_ROOT}/readiness}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-2700}"
WAIT_INTERVAL_SECONDS="${WAIT_INTERVAL_SECONDS:-60}"
READY_REQUIRED_STABLE_ATTEMPTS="${READY_REQUIRED_STABLE_ATTEMPTS:-2}"
CLEAN_STALE_SPECTRE="${CLEAN_STALE_SPECTRE:-true}"

mkdir -p "${OUT_ROOT}" "${READY_ROOT}"

if [[ "${CLEAN_STALE_SPECTRE}" == "true" ]]; then
  pkill -9 -f 'spectre-screencapture' 2>/dev/null || true
fi

deadline=$((SECONDS + WAIT_TIMEOUT_SECONDS))
attempt=0
stable_attempts=0
last_status=1
last_log=""

while ((SECONDS <= deadline)); do
  attempt=$((attempt + 1))
  ready_out="${READY_ROOT}/attempt-$(printf '%03d' "${attempt}")"
  last_log="${ready_out}/readiness.log"
  mkdir -p "${ready_out}"

  set +e
  OUT_ROOT="${ready_out}" "${SCRIPT_DIR}/jewel-ide-plugin-perf-readiness.sh" > "${last_log}" 2>&1
  last_status=$?
  set -e

  cat "${last_log}"

  if [[ "${last_status}" -eq 0 ]]; then
    stable_attempts=$((stable_attempts + 1))
    if ((stable_attempts >= READY_REQUIRED_STABLE_ATTEMPTS)); then
      echo "Perf readiness passed on ${stable_attempts} consecutive attempts; starting confirmation suite."
      exec env \
        OUT_ROOT="${OUT_ROOT}" \
        "${SCRIPT_DIR}/jewel-ide-plugin-perf-confirmation-suite.sh"
    fi
    echo "Perf readiness passed on attempt ${attempt}; waiting for ${READY_REQUIRED_STABLE_ATTEMPTS} consecutive clean samples (${stable_attempts}/${READY_REQUIRED_STABLE_ATTEMPTS})."
  else
    stable_attempts=0
  fi

  if ((SECONDS + WAIT_INTERVAL_SECONDS > deadline)); then
    break
  fi
  echo "Perf readiness failed on attempt ${attempt}; sleeping ${WAIT_INTERVAL_SECONDS}s before retry."
  sleep "${WAIT_INTERVAL_SECONDS}"
done

cat >&2 <<EOF
error: perf readiness did not pass within ${WAIT_TIMEOUT_SECONDS}s.
last_status=${last_status}
last_log=${last_log}

Run \`sudo -v\` before retrying if the log reports powermetrics-sudo-missing.
EOF
exit 1
