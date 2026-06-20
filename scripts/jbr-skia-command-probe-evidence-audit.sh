#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd -- "${SCRIPT_DIR}/.." >/dev/null && pwd)}"
SUITE_ROOT="${SUITE_ROOT:-${ROOT_DIR}/out/jbr-skia-command-probe-suite}"

if [[ ! -d "${SUITE_ROOT}" ]]; then
  echo "Missing command-probe suite root: ${SUITE_ROOT}" >&2
  exit 2
fi

CASES_FILE="$(mktemp "${TMPDIR:-/tmp}/jbr-skia-current-cases.XXXXXX")"
EVIDENCE_FILE="$(mktemp "${TMPDIR:-/tmp}/jbr-skia-suite-evidence.XXXXXX")"
trap 'rm -f "${CASES_FILE}" "${EVIDENCE_FILE}"' EXIT

LIST_CASES=true "${SCRIPT_DIR}/jbr-skia-command-probe-suite.sh" > "${CASES_FILE}"

find "${SUITE_ROOT}" -mindepth 2 -maxdepth 2 -name suite.tsv -print | sort > "${EVIDENCE_FILE}"

awk -F '\t' '
  FNR == NR {
    current[$1] = 1
    order[++case_count] = $1
    next
  }
  FNR == 1 {
    suite = FILENAME
    next
  }
  current[$1] {
    latest_suite[$1] = suite
    status[$1] = $2
    fallbacks[$1] = $3 + 0
    unsupported[$1] = $4
    picture_frames[$1] = $5 + 0
    command_frames[$1] = $6 + 0
    report[$1] = $8
  }
  END {
    for (i = 1; i <= case_count; i++) {
      name = order[i]
      if (!(name in latest_suite)) {
        missing++
        missing_rows = missing_rows name "\n"
        continue
      }
      covered++
      if (status[name] != "passed") {
        non_pass++
        non_pass_rows = non_pass_rows name "\t" status[name] "\t" latest_suite[name] "\n"
      }
      if (unsupported[name] != "none") {
        unsupported_count++
        unsupported_rows = unsupported_rows name "\t" unsupported[name] "\t" latest_suite[name] "\n"
      }
      if (picture_frames[name] != 0) {
        picture_rows++
        picture_row_list = picture_row_list name "\t" picture_frames[name] "\t" latest_suite[name] "\n"
      }
      if (fallbacks[name] != 0) {
        fallback_rows++
        if (command_frames[name] == 0) {
          cmd0_expected_fallback_rows++
        } else {
          fallback_with_command_rows++
          fallback_with_command_list = fallback_with_command_list name "\t" fallbacks[name] "\t" command_frames[name] "\t" latest_suite[name] "\n"
        }
      }
      if (command_frames[name] == 0 && fallbacks[name] == 0) {
        cmd0_without_fallback_rows++
        cmd0_without_fallback_list = cmd0_without_fallback_list name "\t" latest_suite[name] "\n"
      }
    }

    printf "current_rows=%d\n", case_count
    printf "covered_current_rows=%d/%d\n", covered, case_count
    printf "missing=%d\n", missing
    printf "non_pass=%d\n", non_pass
    printf "unsupported=%d\n", unsupported_count
    printf "picture_rows=%d\n", picture_rows
    printf "fallback_rows=%d\n", fallback_rows
    printf "cmd0_expected_fallback_rows=%d\n", cmd0_expected_fallback_rows
    printf "fallback_with_command_rows=%d\n", fallback_with_command_rows
    printf "cmd0_without_fallback_rows=%d\n", cmd0_without_fallback_rows

    if (missing_rows != "") {
      printf "\nmissing_rows:\n%s", missing_rows
    }
    if (non_pass_rows != "") {
      printf "\nnon_pass_rows:\n%s", non_pass_rows
    }
    if (unsupported_rows != "") {
      printf "\nunsupported_rows:\n%s", unsupported_rows
    }
    if (picture_row_list != "") {
      printf "\npicture_rows:\n%s", picture_row_list
    }
    if (fallback_with_command_list != "") {
      printf "\nfallback_with_command_rows:\n%s", fallback_with_command_list
    }
    if (cmd0_without_fallback_list != "") {
      printf "\ncmd0_without_fallback_rows:\n%s", cmd0_without_fallback_list
    }

    if (missing || non_pass || unsupported_count || picture_rows || cmd0_without_fallback_rows) {
      exit 1
    }
  }
' "${CASES_FILE}" $(cat "${EVIDENCE_FILE}")
