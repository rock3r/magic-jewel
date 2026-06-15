#!/usr/bin/env bash

jbr_skia_daily_broad_validation_guard() {
  local label="$1"
  local root_dir="${ROOT_DIR:?ROOT_DIR must be set before sourcing the daily validation guard}"
  local stamp_dir="${JBR_SKIA_DAILY_VALIDATION_STAMP_DIR:-${root_dir}/out/.jbr-skia-daily-validation}"
  local today
  today="$(date +%Y-%m-%d)"
  local stamp_file="${stamp_dir}/broad.${today}.stamp"

  if [[ "${JBR_SKIA_ALLOW_EXTRA_BROAD_VALIDATION:-false}" == "true" ]]; then
    echo "JBR_SKIA_DAILY_VALIDATION_GUARD override for ${label} on ${today}" >&2
    return 0
  fi

  mkdir -p "${stamp_dir}"
  if [[ -f "${stamp_file}" ]]; then
    echo "Broad JBR Skia validation is capped to once per local day." >&2
    echo "Today's slot (${today}) was already consumed:" >&2
    sed 's/^/  /' "${stamp_file}" >&2
    echo "Use exact CASES/CASE_GROUPS for focused validation, or set JBR_SKIA_ALLOW_EXTRA_BROAD_VALIDATION=true for an explicit override." >&2
    exit 3
  fi

  {
    echo "validation=${label}"
    echo "date=${today}"
    echo "started_at=$(date +%Y-%m-%dT%H:%M:%S%z)"
    echo "out=${OUT_ROOT:-${OUT_DIR:-}}"
  } >"${stamp_file}"
  echo "Recorded daily broad JBR Skia validation slot: ${stamp_file}" >&2
}
