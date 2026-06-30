#!/usr/bin/env bash
set -euo pipefail

suite_tsv="${1:-}"
out_md="${2:-}"
REQUIRE_COMMAND_CLEAN="${REQUIRE_COMMAND_CLEAN:-false}"
REQUIRE_POWERMETRICS="${REQUIRE_POWERMETRICS:-false}"
REQUIRE_VISUAL_PROBES="${REQUIRE_VISUAL_PROBES:-false}"

if [[ -z "${suite_tsv}" || ! -f "${suite_tsv}" ]]; then
  echo "usage: $0 /path/to/jewel-ide-plugin-benchmark-suite/<timestamp>/suite.tsv [analysis.md]" >&2
  exit 2
fi

suite_dir="$(cd -- "$(dirname -- "${suite_tsv}")" >/dev/null && pwd)"
if [[ -z "${out_md}" ]]; then
  out_md="${suite_dir}/analysis.md"
fi

visual_summary_tsv="$(mktemp "${TMPDIR:-/tmp}/jewel-ide-visual-summary.XXXXXX")"
trap 'rm -f "${visual_summary_tsv}"' EXIT
awk -F '\t' '
  NR == 1 {
    for (i = 1; i <= NF; i++) {
      col[$i] = i
    }
    next
  }
  {
    print $col["case"] "\t" $col["report"]
  }
' "${suite_tsv}" | while IFS=$'\t' read -r case_name report_dir; do
  [[ -n "${case_name}" && -n "${report_dir}" ]] || continue
  summary="${report_dir}/summary.properties"
  status="missing"
  if [[ -f "${summary}" ]]; then
    status="complete"
    for variant in old new; do
      if ! grep -q "^${variant}_paint_probe=.*status=captured" "${summary}" ||
          ! grep -q "^${variant}_paint_probe_expected_node=.*present=true" "${summary}"; then
        status="incomplete"
      fi
      for marker in \
        paint_probe_wait_timeout \
        paint_probe_expected_node_missing \
        paint_probe_missing \
        paint_probe_image_missing \
        paint_probe_blank; do
        if grep -q "^${variant}_${marker}=true" "${summary}"; then
          status="incomplete"
        fi
      done
    done
  fi
  printf "%s\t%s\n" "${case_name}" "${status}"
done > "${visual_summary_tsv}"

awk -F '\t' -v suite="${suite_tsv}" -v visual_summary="${visual_summary_tsv}" '
function metric(text, key, parts, count, i, prefix) {
  count = split(text, parts, " ")
  prefix = key "="
  for (i = 1; i <= count; i++) {
    if (index(parts[i], prefix) == 1) {
      return substr(parts[i], length(prefix) + 1)
    }
  }
  return ""
}

function number_or_zero(value) {
  return value == "" ? 0 : value + 0
}

function pct_delta(old_value, new_value) {
  if (old_value == "" || new_value == "" || old_value + 0 == 0) {
    return "n/a"
  }
  return sprintf("%+.1f%%", ((new_value - old_value) / old_value) * 100.0)
}

function abs_delta(old_value, new_value) {
  if (old_value == "" || new_value == "") {
    return "n/a"
  }
  return sprintf("%+.2f", new_value - old_value)
}

function command_ok(status, new_command, new_picture, new_fallbacks) {
  return status == "passed" && number_or_zero(new_command) > 0 &&
      number_or_zero(new_picture) == 0 && number_or_zero(new_fallbacks) == 0
}

function column_value(name) {
  return (name in col) ? $col[name] : ""
}

function powermetrics_ok(status, summary) {
  return status != "" && status != "disabled" &&
      metric(summary, "samples") != "" && number_or_zero(metric(summary, "samples")) > 0 &&
      metric(summary, "gpu_power_avg_mw") != "" &&
      metric(summary, "gpu_active_avg") != "" &&
      metric(summary, "hottest_cpu_active_avg") != ""
}

NR == 1 {
  while ((getline visualLine < visual_summary) > 0) {
    split(visualLine, visualParts, "\t")
    visualStatus[visualParts[1]] = visualParts[2]
  }
  close(visual_summary)
  for (i = 1; i <= NF; i++) {
    col[$i] = i
  }
  next
}

{
  case_name = $col["case"]
  status = $col["status"]
  old_ps = $col["old_ps"]
  new_ps = $col["new_ps"]
  old_thread = $col["old_thread_cpu"]
  new_thread = $col["new_thread_cpu"]
  new_command_summary = $col["new_command_summary"]
  new_timing_summary = $col["new_timing_summary"]
  old_powermetrics = $col["old_powermetrics"]
  new_powermetrics = $col["new_powermetrics"]
  old_powermetrics_summary = column_value("old_powermetrics_summary")
  new_powermetrics_summary = column_value("new_powermetrics_summary")
  old_frames = $col["old_benchmark_frames"]
  new_frames = $col["new_benchmark_frames"]
  old_command = $col["old_command_frames"]
  new_command = $col["new_command_frames"]
  old_picture = $col["old_picture_frames"]
  new_picture = $col["new_picture_frames"]
  old_fallbacks = $col["old_fallbacks"]
  new_fallbacks = $col["new_fallbacks"]

  old_cpu = metric(old_ps, "avg_cpu")
  new_cpu = metric(new_ps, "avg_cpu")
  old_rss = metric(old_ps, "avg_rss_kb")
  new_rss = metric(new_ps, "avg_rss_kb")
  old_hot_thread = metric(old_thread, "hottest_avg_thread_cpu")
  new_hot_thread = metric(new_thread, "hottest_avg_thread_cpu")
  avg_commands = metric(new_command_summary, "avg_commands")
  avg_total_ms = metric(new_timing_summary, "avg_total_ms")
  avg_draw_ms = metric(new_timing_summary, "avg_draw_ms")
  avg_flush_ms = metric(new_timing_summary, "avg_flush_ms")
  old_gpu_power = metric(old_powermetrics_summary, "gpu_power_avg_mw")
  new_gpu_power = metric(new_powermetrics_summary, "gpu_power_avg_mw")
  old_gpu_active = metric(old_powermetrics_summary, "gpu_active_avg")
  new_gpu_active = metric(new_powermetrics_summary, "gpu_active_avg")
  old_hot_core = metric(old_powermetrics_summary, "hottest_cpu_active_avg")
  new_hot_core = metric(new_powermetrics_summary, "hottest_cpu_active_avg")

  rows++
  if (command_ok(status, new_command, new_picture, new_fallbacks)) {
    command_clean++
  }
  if (powermetrics_ok(old_powermetrics, old_powermetrics_summary) &&
      powermetrics_ok(new_powermetrics, new_powermetrics_summary)) {
    powermetrics_rows++
  }
  if (visualStatus[case_name] == "complete") {
    visual_complete++
  } else if (visualStatus[case_name] == "missing") {
    visual_missing++
  } else {
    visual_incomplete++
  }

  case_line[rows] = sprintf("| `%s` | `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
      case_name,
      status,
      command_ok(status, new_command, new_picture, new_fallbacks) ? "clean" : "check",
      visualStatus[case_name] == "" ? "missing" : visualStatus[case_name],
      old_cpu == "" ? "n/a" : old_cpu,
      new_cpu == "" ? "n/a" : new_cpu,
      pct_delta(number_or_zero(old_cpu), number_or_zero(new_cpu)),
      old_rss == "" ? "n/a" : old_rss,
      new_rss == "" ? "n/a" : new_rss,
      pct_delta(number_or_zero(old_rss), number_or_zero(new_rss)),
      old_hot_thread == "" ? "n/a" : old_hot_thread,
      new_hot_thread == "" ? "n/a" : new_hot_thread,
      pct_delta(number_or_zero(old_hot_thread), number_or_zero(new_hot_thread)),
      old_hot_core == "" ? "n/a" : old_hot_core,
      new_hot_core == "" ? "n/a" : new_hot_core,
      old_gpu_power == "" ? "n/a" : old_gpu_power,
      new_gpu_power == "" ? "n/a" : new_gpu_power,
      old_gpu_active == "" ? "n/a" : old_gpu_active,
      new_gpu_active == "" ? "n/a" : new_gpu_active,
      avg_commands == "" ? "n/a" : avg_commands,
      avg_total_ms == "" ? "n/a" : avg_total_ms)

  detail_line[rows] = sprintf("- `%s`: old/new frames `%s`/`%s`; old/new command frames `%s`/`%s`; old/new picture frames `%s`/`%s`; old/new fallbacks `%s`/`%s`; new timing avg draw/flush `%s`/`%s` ms; powermetrics `%s`/`%s`; old/new powermetrics summary `%s` / `%s`.",
      case_name, old_frames, new_frames, old_command, new_command, old_picture, new_picture,
      old_fallbacks, new_fallbacks, avg_draw_ms == "" ? "n/a" : avg_draw_ms,
      avg_flush_ms == "" ? "n/a" : avg_flush_ms, old_powermetrics, new_powermetrics,
      old_powermetrics_summary == "" ? "n/a" : old_powermetrics_summary,
      new_powermetrics_summary == "" ? "n/a" : new_powermetrics_summary)
}

END {
  print "# Jewel IDE Plugin Benchmark Analysis"
  print ""
  print "- suite: `" suite "`"
  print "- rows: " rows
  print "- command-clean rows: " command_clean "/" rows
  print "- visual-proof rows: " (visual_complete + 0) "/" rows
  print "- powermetrics rows: " (powermetrics_rows + 0) "/" rows
  if (command_clean == rows && rows > 0) {
    print "- command coverage verdict: clean for this suite"
  } else {
    print "- command coverage verdict: inspect failures before making coverage claims"
  }
  if (visual_complete == rows && rows > 0) {
    print "- visual proof verdict: Spectre toolwindow proof complete for this suite"
  } else {
    print "- visual proof verdict: incomplete; missing or failed Spectre paint probes remain"
  }
  if (powermetrics_rows == rows && rows > 0) {
    print "- perf evidence verdict: includes powermetrics-backed CPU/GPU evidence"
  } else {
    print "- perf evidence verdict: incomplete for GPU/Metal claims; powermetrics is missing for at least one row"
  }
  print ""
  print "| Case | Status | Command Path | Visual Proof | Old CPU | New CPU | CPU Delta | Old RSS KB | New RSS KB | RSS Delta | Old Hot Thread | New Hot Thread | Hot Thread Delta | Old Hot Core | New Hot Core | Old GPU mW | New GPU mW | Old GPU Active | New GPU Active | New Avg Commands | New Avg Total ms |"
  print "| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"
  for (i = 1; i <= rows; i++) {
    print case_line[i]
  }
  print ""
  print "## Details"
  print ""
  for (i = 1; i <= rows; i++) {
    print detail_line[i]
  }
}
' "${suite_tsv}" | tee "${out_md}"

echo "analysis=${out_md}"

strict_failures=0

if [[ "${REQUIRE_COMMAND_CLEAN}" == "true" || "${REQUIRE_POWERMETRICS}" == "true" ]]; then
  if ! awk -F '\t' \
    -v require_command_clean="${REQUIRE_COMMAND_CLEAN}" \
    -v require_powermetrics="${REQUIRE_POWERMETRICS}" '
      function number_or_zero(value) {
        return value == "" ? 0 : value + 0
      }
      NR == 1 {
        for (i = 1; i <= NF; i++) {
          col[$i] = i
        }
        next
      }
      function column_value(name) {
        return (name in col) ? $col[name] : ""
      }
      function metric(text, key, parts, count, i, prefix) {
        count = split(text, parts, " ")
        prefix = key "="
        for (i = 1; i <= count; i++) {
          if (index(parts[i], prefix) == 1) {
            return substr(parts[i], length(prefix) + 1)
          }
        }
        return ""
      }
      function powermetrics_ok(status, summary) {
        return status != "" && status != "disabled" &&
            metric(summary, "samples") != "" && number_or_zero(metric(summary, "samples")) > 0 &&
            metric(summary, "gpu_power_avg_mw") != "" &&
            metric(summary, "gpu_active_avg") != "" &&
            metric(summary, "hottest_cpu_active_avg") != ""
      }
      {
        case_name = $col["case"]
        status = $col["status"]
        new_command = $col["new_command_frames"]
        new_picture = $col["new_picture_frames"]
        new_fallbacks = $col["new_fallbacks"]
        old_powermetrics = $col["old_powermetrics"]
        new_powermetrics = $col["new_powermetrics"]
        old_powermetrics_summary = column_value("old_powermetrics_summary")
        new_powermetrics_summary = column_value("new_powermetrics_summary")
        if (require_command_clean == "true" &&
            !(status == "passed" && number_or_zero(new_command) > 0 &&
              number_or_zero(new_picture) == 0 && number_or_zero(new_fallbacks) == 0)) {
          printf("strict failure: %s command path is not clean\n", case_name) > "/dev/stderr"
          failures = 1
        }
        if (require_powermetrics == "true" &&
            (!powermetrics_ok(old_powermetrics, old_powermetrics_summary) ||
             !powermetrics_ok(new_powermetrics, new_powermetrics_summary))) {
          printf("strict failure: %s powermetrics missing old=%s (%s) new=%s (%s)\n",
              case_name, old_powermetrics, old_powermetrics_summary,
              new_powermetrics, new_powermetrics_summary) > "/dev/stderr"
          failures = 1
        }
      }
      END {
        exit failures
      }
    ' "${suite_tsv}"; then
    strict_failures=1
  fi
fi

if [[ "${REQUIRE_VISUAL_PROBES}" == "true" ]]; then
  while IFS=$'\t' read -r case_name report_dir; do
    [[ -n "${case_name}" && -n "${report_dir}" ]] || continue
    summary="${report_dir}/summary.properties"
    if [[ ! -f "${summary}" ]]; then
      echo "strict failure: ${case_name} missing summary.properties at ${summary}" >&2
      strict_failures=1
      continue
    fi
    for variant in old new; do
      if ! grep -q "^${variant}_paint_probe=.*status=captured" "${summary}"; then
        echo "strict failure: ${case_name} ${variant} paint probe was not captured" >&2
        strict_failures=1
      fi
      if ! grep -q "^${variant}_paint_probe_expected_node=.*present=true" "${summary}"; then
        echo "strict failure: ${case_name} ${variant} expected Spectre node was not present" >&2
        strict_failures=1
      fi
      for marker in \
        paint_probe_wait_timeout \
        paint_probe_expected_node_missing \
        paint_probe_missing \
        paint_probe_image_missing \
        paint_probe_blank; do
        if grep -q "^${variant}_${marker}=true" "${summary}"; then
          echo "strict failure: ${case_name} ${variant} ${marker}=true" >&2
          strict_failures=1
        fi
      done
    done
  done < <(
    awk -F '\t' '
      NR == 1 {
        for (i = 1; i <= NF; i++) {
          col[$i] = i
        }
        next
      }
      {
        print $col["case"] "\t" $col["report"]
      }
    ' "${suite_tsv}"
  )
fi

if [[ "${strict_failures}" -ne 0 ]]; then
  exit 1
fi
