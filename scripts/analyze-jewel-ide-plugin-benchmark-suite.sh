#!/usr/bin/env bash
set -euo pipefail

suite_tsv="${1:-}"
out_md="${2:-}"

if [[ -z "${suite_tsv}" || ! -f "${suite_tsv}" ]]; then
  echo "usage: $0 /path/to/jewel-ide-plugin-benchmark-suite/<timestamp>/suite.tsv [analysis.md]" >&2
  exit 2
fi

suite_dir="$(cd -- "$(dirname -- "${suite_tsv}")" >/dev/null && pwd)"
if [[ -z "${out_md}" ]]; then
  out_md="${suite_dir}/analysis.md"
fi

awk -F '\t' -v suite="${suite_tsv}" '
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

NR == 1 {
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

  rows++
  if (command_ok(status, new_command, new_picture, new_fallbacks)) {
    command_clean++
  }
  if (old_powermetrics != "disabled" && new_powermetrics != "disabled" &&
      old_powermetrics != "" && new_powermetrics != "") {
    powermetrics_rows++
  }

  case_line[rows] = sprintf("| `%s` | `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
      case_name,
      status,
      command_ok(status, new_command, new_picture, new_fallbacks) ? "clean" : "check",
      old_cpu == "" ? "n/a" : old_cpu,
      new_cpu == "" ? "n/a" : new_cpu,
      pct_delta(number_or_zero(old_cpu), number_or_zero(new_cpu)),
      old_rss == "" ? "n/a" : old_rss,
      new_rss == "" ? "n/a" : new_rss,
      pct_delta(number_or_zero(old_rss), number_or_zero(new_rss)),
      old_hot_thread == "" ? "n/a" : old_hot_thread,
      new_hot_thread == "" ? "n/a" : new_hot_thread,
      pct_delta(number_or_zero(old_hot_thread), number_or_zero(new_hot_thread)),
      avg_commands == "" ? "n/a" : avg_commands,
      avg_total_ms == "" ? "n/a" : avg_total_ms)

  detail_line[rows] = sprintf("- `%s`: old/new frames `%s`/`%s`; old/new command frames `%s`/`%s`; old/new picture frames `%s`/`%s`; old/new fallbacks `%s`/`%s`; new timing avg draw/flush `%s`/`%s` ms; powermetrics `%s`/`%s`.",
      case_name, old_frames, new_frames, old_command, new_command, old_picture, new_picture,
      old_fallbacks, new_fallbacks, avg_draw_ms == "" ? "n/a" : avg_draw_ms,
      avg_flush_ms == "" ? "n/a" : avg_flush_ms, old_powermetrics, new_powermetrics)
}

END {
  print "# Jewel IDE Plugin Benchmark Analysis"
  print ""
  print "- suite: `" suite "`"
  print "- rows: " rows
  print "- command-clean rows: " command_clean "/" rows
  print "- powermetrics rows: " (powermetrics_rows + 0) "/" rows
  if (command_clean == rows && rows > 0) {
    print "- command coverage verdict: clean for this suite"
  } else {
    print "- command coverage verdict: inspect failures before making coverage claims"
  }
  if (powermetrics_rows == rows && rows > 0) {
    print "- perf evidence verdict: includes powermetrics-backed CPU/GPU evidence"
  } else {
    print "- perf evidence verdict: incomplete for GPU/Metal claims; powermetrics is missing for at least one row"
  }
  print ""
  print "| Case | Status | Command Path | Old CPU | New CPU | CPU Delta | Old RSS KB | New RSS KB | RSS Delta | Old Hot Thread | New Hot Thread | Hot Thread Delta | New Avg Commands | New Avg Total ms |"
  print "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"
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
