#!/usr/bin/env bash
set -euo pipefail

suite_tsv="${1:-}"
out_md="${2:-}"
REQUIRE_COMMAND_CLEAN="${REQUIRE_COMMAND_CLEAN:-false}"
REQUIRE_TOUR_COMPLETE="${REQUIRE_TOUR_COMPLETE:-false}"
REQUIRE_COMPONENTS="${REQUIRE_COMPONENTS:-}"
REQUIRE_CASES="${REQUIRE_CASES:-}"

if [[ -z "${suite_tsv}" || ! -f "${suite_tsv}" ]]; then
  echo "usage: $0 /path/to/jewel-standalone-focused-benchmark-suite/<timestamp>/suite.tsv [analysis.md]" >&2
  exit 2
fi

suite_dir="$(cd -- "$(dirname -- "${suite_tsv}")" >/dev/null && pwd)"
if [[ -z "${out_md}" ]]; then
  out_md="${suite_dir}/analysis.md"
fi

awk -F '\t' -v suite="${suite_tsv}" -v require_components="${REQUIRE_COMPONENTS}" -v require_cases="${REQUIRE_CASES}" '
function number_or_zero(value) {
  return value == "" ? 0 : value + 0
}

function pct_delta(old_value, new_value) {
  if (old_value == "" || new_value == "" || old_value + 0 == 0) {
    return "n/a"
  }
  return sprintf("%+.1f%%", ((new_value - old_value) / old_value) * 100.0)
}

function command_ok(status, command_frames, fallbacks, unsupported) {
  return status == "passed" && number_or_zero(command_frames) > 0 &&
      number_or_zero(fallbacks) == 0 && number_or_zero(unsupported) == 0
}

function tour_ok(complete, errors) {
  return number_or_zero(complete) == 1 && number_or_zero(errors) == 0
}

function remember_components(text, parts, count, i, component) {
  count = split(text, parts, ",")
  for (i = 1; i <= count; i++) {
    component = parts[i]
    gsub(/^ +| +$/, "", component)
    if (component != "") {
      componentSeen[component] = 1
    }
  }
}

NR == 1 {
  for (i = 1; i <= NF; i++) {
    col[$i] = i
  }
  next
}

{
  case_name = $col["case"]
  status = $col["status"]
  old_cpu = $col["old_avg_cpu"]
  new_cpu = $col["new_avg_cpu"]
  old_rss = $col["old_avg_rss_kb"]
  new_rss = $col["new_avg_rss_kb"]
  old_fps = $col["old_fps"]
  new_fps = $col["new_fps"]
  command_fps = $col["jbr_command_fps"]
  command_frames = $col["jbr_command_frames"]
  fallbacks = $col["fallbacks"]
  unsupported = $col["unsupported_max"]
  tour_complete = $col["spectre_tour_complete"]
  tour_errors = $col["spectre_errors"]
  components = $col["spectre_tour_components"]
  old_powermetrics = $col["old_powermetrics"]
  new_powermetrics = $col["new_powermetrics"]

  rows++
  caseSeen[case_name] = 1
  if (command_ok(status, command_frames, fallbacks, unsupported)) {
    command_clean++
  }
  if (tour_ok(tour_complete, tour_errors)) {
    tour_clean++
  }
  if (old_powermetrics != "" && old_powermetrics != "disabled" &&
      new_powermetrics != "" && new_powermetrics != "disabled") {
    powermetrics_rows++
  }
  remember_components(components)

  case_line[rows] = sprintf("| `%s` | `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | `%s` |",
      case_name,
      status,
      command_ok(status, command_frames, fallbacks, unsupported) ? "clean" : "check",
      tour_ok(tour_complete, tour_errors) ? "complete" : "check",
      old_cpu == "" ? "n/a" : old_cpu,
      new_cpu == "" ? "n/a" : new_cpu,
      pct_delta(number_or_zero(old_cpu), number_or_zero(new_cpu)),
      old_rss == "" ? "n/a" : old_rss,
      new_rss == "" ? "n/a" : new_rss,
      pct_delta(number_or_zero(old_rss), number_or_zero(new_rss)),
      old_fps == "" ? "n/a" : old_fps,
      new_fps == "" ? "n/a" : new_fps,
      command_frames == "" ? "n/a" : command_frames,
      components)
}

END {
  print "# Jewel Standalone Focused Benchmark Analysis"
  print ""
  print "- suite: `" suite "`"
  print "- rows: " rows
  print "- command-clean rows: " command_clean "/" rows
  print "- Spectre-tour-clean rows: " tour_clean "/" rows
  print "- powermetrics rows: " (powermetrics_rows + 0) "/" rows
  if (command_clean == rows && rows > 0) {
    print "- command coverage verdict: clean for this suite"
  } else {
    print "- command coverage verdict: inspect failures before making coverage claims"
  }
  if (tour_clean == rows && rows > 0) {
    print "- Spectre tour verdict: complete for this suite"
  } else {
    print "- Spectre tour verdict: incomplete or errored rows remain"
  }
  if (powermetrics_rows == rows && rows > 0) {
    print "- perf evidence verdict: includes powermetrics-backed CPU/GPU evidence"
  } else {
    print "- perf evidence verdict: incomplete for GPU/Metal claims; powermetrics is missing for at least one row"
  }
  if (require_components != "") {
    requiredCount = split(require_components, required, ",")
    missing = ""
    for (i = 1; i <= requiredCount; i++) {
      component = required[i]
      gsub(/^ +| +$/, "", component)
      if (component != "" && !(component in componentSeen)) {
        missing = missing (missing == "" ? "" : ",") component
      }
    }
    if (missing == "") {
      print "- component coverage verdict: all required components observed"
    } else {
      print "- component coverage verdict: missing `" missing "`"
    }
  }
  if (require_cases != "") {
    requiredCaseCount = split(require_cases, requiredCases, ",")
    missingCases = ""
    for (i = 1; i <= requiredCaseCount; i++) {
      requiredCase = requiredCases[i]
      gsub(/^ +| +$/, "", requiredCase)
      if (requiredCase != "" && !(requiredCase in caseSeen)) {
        missingCases = missingCases (missingCases == "" ? "" : ",") requiredCase
      }
    }
    if (missingCases == "") {
      print "- case coverage verdict: all required cases observed"
    } else {
      print "- case coverage verdict: missing `" missingCases "`"
    }
  }
  print ""
  print "| Case | Status | Command Path | Spectre Tour | Old CPU | New CPU | CPU Delta | Old RSS KB | New RSS KB | RSS Delta | Old FPS | New FPS | JBR Command Frames | Components |"
  print "| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |"
  for (i = 1; i <= rows; i++) {
    print case_line[i]
  }
}
' "${suite_tsv}" | tee "${out_md}"

echo "analysis=${out_md}"

strict_failures=0

if [[ "${REQUIRE_COMMAND_CLEAN}" == "true" || "${REQUIRE_TOUR_COMPLETE}" == "true" || -n "${REQUIRE_COMPONENTS}" || -n "${REQUIRE_CASES}" ]]; then
  if ! awk -F '\t' \
    -v require_command_clean="${REQUIRE_COMMAND_CLEAN}" \
    -v require_tour_complete="${REQUIRE_TOUR_COMPLETE}" \
    -v require_components="${REQUIRE_COMPONENTS}" \
    -v require_cases="${REQUIRE_CASES}" '
      function number_or_zero(value) {
        return value == "" ? 0 : value + 0
      }
      function remember_components(text, parts, count, i, component) {
        count = split(text, parts, ",")
        for (i = 1; i <= count; i++) {
          component = parts[i]
          gsub(/^ +| +$/, "", component)
          if (component != "") {
            componentSeen[component] = 1
          }
        }
      }
      NR == 1 {
        for (i = 1; i <= NF; i++) {
          col[$i] = i
        }
        next
      }
      {
        case_name = $col["case"]
        caseSeen[case_name] = 1
        status = $col["status"]
        command_frames = $col["jbr_command_frames"]
        fallbacks = $col["fallbacks"]
        unsupported = $col["unsupported_max"]
        tour_complete = $col["spectre_tour_complete"]
        tour_errors = $col["spectre_errors"]
        remember_components($col["spectre_tour_components"])
        if (require_command_clean == "true" &&
            !(status == "passed" && number_or_zero(command_frames) > 0 &&
              number_or_zero(fallbacks) == 0 && number_or_zero(unsupported) == 0)) {
          printf("strict failure: %s command path is not clean\n", case_name) > "/dev/stderr"
          failures = 1
        }
        if (require_tour_complete == "true" &&
            !(number_or_zero(tour_complete) == 1 && number_or_zero(tour_errors) == 0)) {
          printf("strict failure: %s Spectre tour is not complete\n", case_name) > "/dev/stderr"
          failures = 1
        }
      }
      END {
        if (require_components != "") {
          requiredCount = split(require_components, required, ",")
          for (i = 1; i <= requiredCount; i++) {
            component = required[i]
            gsub(/^ +| +$/, "", component)
            if (component != "" && !(component in componentSeen)) {
              printf("strict failure: missing component %s\n", component) > "/dev/stderr"
              failures = 1
            }
          }
        }
        if (require_cases != "") {
          requiredCaseCount = split(require_cases, requiredCases, ",")
          for (i = 1; i <= requiredCaseCount; i++) {
            requiredCase = requiredCases[i]
            gsub(/^ +| +$/, "", requiredCase)
            if (requiredCase != "" && !(requiredCase in caseSeen)) {
              printf("strict failure: missing case %s\n", requiredCase) > "/dev/stderr"
              failures = 1
            }
          }
        }
        exit failures
      }
    ' "${suite_tsv}"; then
    strict_failures=1
  fi
fi

if [[ "${strict_failures}" -ne 0 ]]; then
  exit 1
fi
