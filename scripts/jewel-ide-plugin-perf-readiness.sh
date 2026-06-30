#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)"

OUT_ROOT="${OUT_ROOT:-${ROOT_DIR}/out/jewel-ide-plugin-benchmark-suite/readiness-$(date +%Y%m%d-%H%M%S)}"
export OUT_ROOT
export PREFLIGHT_ONLY=true

set +e
"${SCRIPT_DIR}/jewel-ide-plugin-perf-confirmation-suite.sh"
preflight_status=$?
set -e

preflight_file="${OUT_ROOT}/machine-preflight.txt"
if [[ ! -f "${preflight_file}" ]]; then
  echo "readiness=unknown status=${preflight_status} preflight=${preflight_file}" >&2
  exit 2
fi

value() {
  local key="$1"
  awk -F= -v key="${key}" '$1 == key { sub(/^[^=]*=/, ""); print; found=1; exit } END { if (!found) exit 0 }' "${preflight_file}"
}

ready="$(value preflight_ready)"
reason="$(value preflight_reason)"
load_1="$(value preflight_load_1)"
top_cpu="$(value preflight_top_cpu)"
sudo_cached="$(value powermetrics_sudo_cached)"

echo "readiness=${ready:-unknown}"
echo "reason=${reason:-unknown}"
echo "load_1=${load_1:-unknown}"
echo "top_cpu=${top_cpu:-unknown}"
echo "powermetrics_sudo_cached=${sudo_cached:-unknown}"
echo "preflight=${preflight_file}"

if [[ "${ready}" == "true" ]]; then
  exit 0
fi
exit 1
