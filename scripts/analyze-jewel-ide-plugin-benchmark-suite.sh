#!/usr/bin/env bash
set -euo pipefail

# Locale-proof numeric formatting: driver shells with comma-decimal locales corrupt
# printf "%.2f" CSV columns and awk float output.
export LC_ALL=C

suite_tsv="${1:-}"
out_md="${2:-}"
REQUIRE_COMMAND_CLEAN="${REQUIRE_COMMAND_CLEAN:-false}"
REQUIRE_POWERMETRICS="${REQUIRE_POWERMETRICS:-false}"
REQUIRE_VISUAL_PROBES="${REQUIRE_VISUAL_PROBES:-false}"
MAX_CPU_REGRESSION_PCT="${MAX_CPU_REGRESSION_PCT:-${MAX_IDE_CPU_REGRESSION_PCT:-10}}"
MAX_GPU_REGRESSION_PCT="${MAX_GPU_REGRESSION_PCT:-${MAX_IDE_GPU_REGRESSION_PCT:-15}}"
REQUIRE_PERF_REGRESSION_CLEAN="${REQUIRE_PERF_REGRESSION_CLEAN:-${REQUIRE_IDE_PERF_REGRESSION_CLEAN:-${REQUIRE_POWERMETRICS}}}"
DISCARD_WARMUP_REPS="${DISCARD_WARMUP_REPS:-true}"
OUTLIER_POWER_MULTIPLIER="${OUTLIER_POWER_MULTIPLIER:-1.5}"
MAX_SAMPLE_TOP_CPU="${MAX_SAMPLE_TOP_CPU:-75.0}"

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
    if grep -q "^old_skip_reason=preflight\\|^new_skip_reason=preflight" "${summary}"; then
      status="preflight-skipped"
      printf "%s\t%s\n" "${case_name}" "${status}"
      continue
    fi
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

awk -F '\t' \
  -v suite="${suite_tsv}" \
  -v visual_summary="${visual_summary_tsv}" \
  -v max_cpu_regression_pct="${MAX_CPU_REGRESSION_PCT}" \
  -v max_gpu_regression_pct="${MAX_GPU_REGRESSION_PCT}" \
  -v discard_warmup_reps="${DISCARD_WARMUP_REPS}" \
  -v outlier_power_multiplier="${OUTLIER_POWER_MULTIPLIER}" \
  -v max_sample_top_cpu="${MAX_SAMPLE_TOP_CPU}" '
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

function per_kframe(value, frames) {
  if (value == "" || frames == "" || frames + 0 == 0) {
    return ""
  }
  return (value + 0) * 1000.0 / (frames + 0)
}

function frame_denominator(paint_frames, command_frames, benchmark_frames) {
  if (paint_frames != "" && paint_frames + 0 > 0) {
    return paint_frames
  }
  if (command_frames != "" && command_frames + 0 > 0) {
    return command_frames
  }
  return benchmark_frames
}

function fmt2(value) {
  return value == "" ? "n/a" : sprintf("%.2f", value)
}

function pct_increase_value(old_value, new_value) {
  if (old_value == "" || new_value == "" || old_value + 0 == 0) {
    return ""
  }
  return ((new_value - old_value) / old_value) * 100.0
}

function regression_label(label, old_value, new_value, threshold, delta) {
  delta = pct_increase_value(old_value, new_value)
  if (delta == "") {
    return ""
  }
  if (delta > threshold + 0) {
    return sprintf("%s %+.1f%%>%s%%", label, delta, threshold)
  }
  return ""
}

function append_issue(issues, issue) {
  if (issue == "") {
    return issues
  }
  return issues == "" ? issue : issues "; " issue
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

function median_metric(base_case_name, metric_name,    i, n, j, tmp, values) {
  n = 0
  for (i = 1; i <= rows; i++) {
    if (row_base_case[i] != base_case_name || !row_policy_candidate[i]) {
      continue
    }
    if (metric_name == "old_cpu_power" && row_old_cpu_power[i] != "") {
      values[++n] = row_old_cpu_power[i] + 0
    } else if (metric_name == "new_cpu_power" && row_new_cpu_power[i] != "") {
      values[++n] = row_new_cpu_power[i] + 0
    } else if (metric_name == "old_gpu_power" && row_old_gpu_power[i] != "") {
      values[++n] = row_old_gpu_power[i] + 0
    } else if (metric_name == "new_gpu_power" && row_new_gpu_power[i] != "") {
      values[++n] = row_new_gpu_power[i] + 0
    }
  }
  if (n == 0) {
    return ""
  }
  for (i = 1; i <= n; i++) {
    for (j = i + 1; j <= n; j++) {
      if (values[j] < values[i]) {
        tmp = values[i]
        values[i] = values[j]
        values[j] = tmp
      }
    }
  }
  if (n % 2 == 1) {
    return values[(n + 1) / 2]
  }
  return (values[n / 2] + values[n / 2 + 1]) / 2.0
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
  attempts = ("attempts" in col) ? $col["attempts"] : 1
  if (attempts == "" || attempts + 0 < 1) {
    attempts = 1
  }
  total_retry_attempts += attempts - 1
  status = $col["status"]
  old_ps = $col["old_ps"]
  new_ps = $col["new_ps"]
  old_thread = $col["old_thread_cpu"]
  new_thread = $col["new_thread_cpu"]
  old_machine = column_value("old_machine_cpu")
  new_machine = column_value("new_machine_cpu")
  new_command_summary = $col["new_command_summary"]
  new_timing_summary = $col["new_timing_summary"]
  old_powermetrics = $col["old_powermetrics"]
  new_powermetrics = $col["new_powermetrics"]
  old_powermetrics_summary = column_value("old_powermetrics_summary")
  new_powermetrics_summary = column_value("new_powermetrics_summary")
  old_frames = $col["old_benchmark_frames"]
  new_frames = $col["new_benchmark_frames"]
  old_paint_frames = column_value("old_paint_frames")
  new_paint_frames = column_value("new_paint_frames")
  old_command = $col["old_command_frames"]
  new_command = $col["new_command_frames"]
  old_normalized_frames = frame_denominator(old_paint_frames, old_command, old_frames)
  new_normalized_frames = frame_denominator(new_paint_frames, new_command, new_frames)
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
  avg_completion_ms = metric(new_timing_summary, "avg_completion_ms")
  old_gpu_power = metric(old_powermetrics_summary, "gpu_power_avg_mw")
  new_gpu_power = metric(new_powermetrics_summary, "gpu_power_avg_mw")
  old_cpu_power = metric(old_powermetrics_summary, "cpu_power_avg_mw")
  new_cpu_power = metric(new_powermetrics_summary, "cpu_power_avg_mw")
  old_gpu_active = metric(old_powermetrics_summary, "gpu_active_avg")
  new_gpu_active = metric(new_powermetrics_summary, "gpu_active_avg")
  old_hot_core = metric(old_powermetrics_summary, "hottest_cpu_active_avg")
  new_hot_core = metric(new_powermetrics_summary, "hottest_cpu_active_avg")
  old_machine_top_cpu = metric(old_machine, "max_top_cpu")
  new_machine_top_cpu = metric(new_machine, "max_top_cpu")
  old_machine_top_process = metric(old_machine, "max_top_process")
  new_machine_top_process = metric(new_machine, "max_top_process")
  old_cpu_kframe = per_kframe(old_cpu, old_normalized_frames)
  new_cpu_kframe = per_kframe(new_cpu, new_normalized_frames)
  old_gpu_power_kframe = per_kframe(old_gpu_power, old_normalized_frames)
  new_gpu_power_kframe = per_kframe(new_gpu_power, new_normalized_frames)
  old_gpu_active_kframe = per_kframe(old_gpu_active, old_normalized_frames)
  new_gpu_active_kframe = per_kframe(new_gpu_active, new_normalized_frames)
  perf_issues = ""
  perf_issues = append_issue(perf_issues, regression_label("avg_cpu", old_cpu, new_cpu, max_cpu_regression_pct))
  perf_issues = append_issue(perf_issues, regression_label("hot_thread", old_hot_thread, new_hot_thread, max_cpu_regression_pct))
  perf_issues = append_issue(perf_issues, regression_label("hot_core", old_hot_core, new_hot_core, max_cpu_regression_pct))
  perf_issues = append_issue(perf_issues, regression_label("gpu_power", old_gpu_power, new_gpu_power, max_gpu_regression_pct))
  perf_issues = append_issue(perf_issues, regression_label("gpu_active", old_gpu_active, new_gpu_active, max_gpu_regression_pct))

  rows++
  if (command_ok(status, new_command, new_picture, new_fallbacks)) {
    command_clean++
  }
  if (powermetrics_ok(old_powermetrics, old_powermetrics_summary) &&
      powermetrics_ok(new_powermetrics, new_powermetrics_summary)) {
    powermetrics_rows++
  }
  if (perf_issues == "") {
    perf_clean++
  } else {
    perf_regressions++
  }
  if (visualStatus[case_name] == "complete") {
    visual_complete++
  } else if (visualStatus[case_name] == "preflight-skipped") {
    preflight_skipped++
  } else if (visualStatus[case_name] == "missing") {
    visual_missing++
  } else {
    visual_incomplete++
  }

  base_case_name = case_name
  sub(/#r[0-9]+$/, "", base_case_name)
  if (!(base_case_name in aggregate_seen)) {
    aggregate_seen[base_case_name] = 1
    aggregate_order[++aggregate_count] = base_case_name
  }
  aggregate_rows[base_case_name]++
  aggregate_row_is_clean = status == "passed" &&
      command_ok(status, new_command, new_picture, new_fallbacks) &&
      visualStatus[case_name] == "complete" &&
      powermetrics_ok(old_powermetrics, old_powermetrics_summary) &&
      powermetrics_ok(new_powermetrics, new_powermetrics_summary)
  row_base_case[rows] = base_case_name
  row_case_name[rows] = case_name
  row_attempts[rows] = attempts
  row_policy_candidate[rows] = aggregate_row_is_clean
  row_old_cpu_kframe[rows] = old_cpu_kframe
  row_new_cpu_kframe[rows] = new_cpu_kframe
  row_old_gpu_power_kframe[rows] = old_gpu_power_kframe
  row_new_gpu_power_kframe[rows] = new_gpu_power_kframe
  row_old_gpu_active_kframe[rows] = old_gpu_active_kframe
  row_new_gpu_active_kframe[rows] = new_gpu_active_kframe
  row_old_cpu_power[rows] = old_cpu_power
  row_new_cpu_power[rows] = new_cpu_power
  row_old_gpu_power[rows] = old_gpu_power
  row_new_gpu_power[rows] = new_gpu_power
  row_old_machine_top_cpu[rows] = old_machine_top_cpu
  row_new_machine_top_cpu[rows] = new_machine_top_cpu
  row_old_machine_top_process[rows] = old_machine_top_process
  row_new_machine_top_process[rows] = new_machine_top_process

  if (visualStatus[case_name] == "preflight-skipped") {
    command_status = "skipped"
  } else if (command_ok(status, new_command, new_picture, new_fallbacks)) {
    command_status = "clean"
  } else {
    command_status = "check"
  }

  case_line[rows] = sprintf("| `%s` | `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
      case_name,
      status,
      command_status,
      visualStatus[case_name] == "" ? "missing" : visualStatus[case_name],
      old_cpu == "" ? "n/a" : old_cpu,
      new_cpu == "" ? "n/a" : new_cpu,
      pct_delta(old_cpu, new_cpu),
      old_rss == "" ? "n/a" : old_rss,
      new_rss == "" ? "n/a" : new_rss,
      pct_delta(old_rss, new_rss),
      old_hot_thread == "" ? "n/a" : old_hot_thread,
      new_hot_thread == "" ? "n/a" : new_hot_thread,
      pct_delta(old_hot_thread, new_hot_thread),
      old_hot_core == "" ? "n/a" : old_hot_core,
      new_hot_core == "" ? "n/a" : new_hot_core,
      old_gpu_power == "" ? "n/a" : old_gpu_power,
      new_gpu_power == "" ? "n/a" : new_gpu_power,
      old_gpu_active == "" ? "n/a" : old_gpu_active,
      new_gpu_active == "" ? "n/a" : new_gpu_active,
      old_normalized_frames == "" ? "n/a" : old_normalized_frames,
      new_normalized_frames == "" ? "n/a" : new_normalized_frames,
      fmt2(old_cpu_kframe),
      fmt2(new_cpu_kframe),
      pct_delta(old_cpu_kframe, new_cpu_kframe),
      fmt2(old_gpu_power_kframe),
      fmt2(new_gpu_power_kframe),
      pct_delta(old_gpu_power_kframe, new_gpu_power_kframe),
      fmt2(old_gpu_active_kframe),
      fmt2(new_gpu_active_kframe),
      pct_delta(old_gpu_active_kframe, new_gpu_active_kframe),
      avg_commands == "" ? "n/a" : avg_commands,
      avg_total_ms == "" ? "n/a" : avg_total_ms,
      avg_completion_ms == "" ? "n/a" : avg_completion_ms)

  detail_line[rows] = sprintf("- `%s`: old/new benchmark frames `%s`/`%s`; old/new paint frames `%s`/`%s`; normalized denominator `%s`/`%s`; per-kFrame CPU `%s`/`%s`, GPU mW `%s`/`%s`, GPU active `%s`/`%s`; old/new command frames `%s`/`%s`; old/new picture frames `%s`/`%s`; old/new fallbacks `%s`/`%s`; new timing avg draw/flush/completion `%s`/`%s`/%s ms; powermetrics `%s`/`%s`; old/new powermetrics summary `%s` / `%s`.",
      case_name, old_frames, new_frames,
      old_paint_frames == "" ? "n/a" : old_paint_frames,
      new_paint_frames == "" ? "n/a" : new_paint_frames,
      old_normalized_frames, new_normalized_frames,
      fmt2(old_cpu_kframe), fmt2(new_cpu_kframe),
      fmt2(old_gpu_power_kframe), fmt2(new_gpu_power_kframe),
      fmt2(old_gpu_active_kframe), fmt2(new_gpu_active_kframe),
      old_command, new_command, old_picture, new_picture, old_fallbacks, new_fallbacks,
      avg_draw_ms == "" ? "n/a" : avg_draw_ms,
      avg_flush_ms == "" ? "n/a" : avg_flush_ms,
      avg_completion_ms == "" ? "n/a" : avg_completion_ms,
      old_powermetrics, new_powermetrics,
      old_powermetrics_summary == "" ? "n/a" : old_powermetrics_summary,
      new_powermetrics_summary == "" ? "n/a" : new_powermetrics_summary)
  if (perf_issues != "") {
    detail_line[rows] = detail_line[rows] " perf regression gate: " perf_issues "."
  }
}

END {
  print "# Jewel IDE Plugin Benchmark Analysis"
  print ""
  print "- suite: `" suite "`"
  print "- rows: " rows
  print "- retry/backfill attempts: " (total_retry_attempts + 0)
  print "- preflight-skipped rows: " (preflight_skipped + 0)
  print "- command-clean rows: " (command_clean + 0) "/" rows
  print "- visual-proof rows: " (visual_complete + 0) "/" rows
  print "- powermetrics rows: " (powermetrics_rows + 0) "/" rows
  print "- perf-regression-clean rows: " (perf_clean + 0) "/" rows
  print "- perf regression thresholds: CPU<=" max_cpu_regression_pct "% GPU<=" max_gpu_regression_pct "%"
  print "- command flush timing note: after the 2026-07-06 async command-flush cutover, new-path `avg_flush_ms` is native flush/submit wall time, not a CPU wait for GPU completion"
  if (command_clean + preflight_skipped == rows && rows > 0) {
    print "- command coverage verdict: clean for measured rows"
  } else {
    print "- command coverage verdict: inspect failures before making coverage claims"
  }
  if (visual_complete + preflight_skipped == rows && rows > 0) {
    print "- visual proof verdict: Spectre toolwindow proof complete for measured rows"
  } else {
    print "- visual proof verdict: incomplete; missing or failed Spectre paint probes remain"
  }
  if (powermetrics_rows + preflight_skipped == rows && rows > 0) {
    print "- perf evidence verdict: includes powermetrics-backed CPU/GPU evidence for measured rows"
  } else {
    print "- perf evidence verdict: incomplete for GPU/Metal claims; powermetrics is missing for at least one row"
  }
  if (perf_regressions == 0 && rows > 0) {
    print "- perf regression verdict: no measured CPU/GPU regression exceeds configured thresholds"
  } else {
    print "- perf regression verdict: inspect CPU/GPU regressions before making performance claims"
  }
  print ""
  print "| Case | Status | Command Path | Visual Proof | Old CPU | New CPU | CPU Delta | Old RSS KB | New RSS KB | RSS Delta | Old Hot Thread | New Hot Thread | Hot Thread Delta | Old Hot Core | New Hot Core | Old GPU mW | New GPU mW | Old GPU Active | New GPU Active | Old Norm Frames | New Norm Frames | Old CPU/kFrame | New CPU/kFrame | CPU/kFrame Delta | Old GPU mW/kFrame | New GPU mW/kFrame | GPU mW/kFrame Delta | Old GPU Active/kFrame | New GPU Active/kFrame | GPU Active/kFrame Delta | New Avg Commands | New Avg Total ms | New Avg Completion ms |"
  print "| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"
  for (i = 1; i <= rows; i++) {
    print case_line[i]
  }
  for (i = 1; i <= aggregate_count; i++) {
    base_case_name = aggregate_order[i]
    median_old_cpu_power[base_case_name] = median_metric(base_case_name, "old_cpu_power")
    median_new_cpu_power[base_case_name] = median_metric(base_case_name, "new_cpu_power")
    median_old_gpu_power[base_case_name] = median_metric(base_case_name, "old_gpu_power")
    median_new_gpu_power[base_case_name] = median_metric(base_case_name, "new_gpu_power")
  }
  for (i = 1; i <= rows; i++) {
    base_case_name = row_base_case[i]
    reason = ""
    if (!row_policy_candidate[i]) {
      continue
    }
    if (discard_warmup_reps == "true" && aggregate_rows[base_case_name] > 1 && row_case_name[i] ~ /#r01$/) {
      reason = append_issue(reason, "warmup-r01")
    }
    if (row_old_machine_top_cpu[i] != "" && row_old_machine_top_cpu[i] + 0 > max_sample_top_cpu + 0) {
      reason = append_issue(reason, sprintf("old-machine-top-cpu %.1f>%s (%s)",
          row_old_machine_top_cpu[i], max_sample_top_cpu,
          row_old_machine_top_process[i] == "" ? "unknown" : row_old_machine_top_process[i]))
    }
    if (row_new_machine_top_cpu[i] != "" && row_new_machine_top_cpu[i] + 0 > max_sample_top_cpu + 0) {
      reason = append_issue(reason, sprintf("new-machine-top-cpu %.1f>%s (%s)",
          row_new_machine_top_cpu[i], max_sample_top_cpu,
          row_new_machine_top_process[i] == "" ? "unknown" : row_new_machine_top_process[i]))
    }
    if (median_old_cpu_power[base_case_name] != "" && row_old_cpu_power[i] != "" &&
        row_old_cpu_power[i] + 0 > (median_old_cpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
      reason = append_issue(reason, sprintf("old-cpu-power %.0f>%.1fx-median", row_old_cpu_power[i], outlier_power_multiplier))
    }
    if (median_new_cpu_power[base_case_name] != "" && row_new_cpu_power[i] != "" &&
        row_new_cpu_power[i] + 0 > (median_new_cpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
      reason = append_issue(reason, sprintf("new-cpu-power %.0f>%.1fx-median", row_new_cpu_power[i], outlier_power_multiplier))
    }
    if (median_old_gpu_power[base_case_name] != "" && row_old_gpu_power[i] != "" &&
        row_old_gpu_power[i] + 0 > (median_old_gpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
      reason = append_issue(reason, sprintf("old-gpu-power %.0f>%.1fx-median", row_old_gpu_power[i], outlier_power_multiplier))
    }
    if (median_new_gpu_power[base_case_name] != "" && row_new_gpu_power[i] != "" &&
        row_new_gpu_power[i] + 0 > (median_new_gpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
      reason = append_issue(reason, sprintf("new-gpu-power %.0f>%.1fx-median", row_new_gpu_power[i], outlier_power_multiplier))
    }
    if (reason != "") {
      policy_excluded_rows++
      policy_exclusion_line[policy_excluded_rows] = sprintf("- `%s`: %s", row_case_name[i], reason)
      continue
    }
    aggregate_clean_rows[base_case_name]++
    if (row_old_cpu_kframe[i] != "" && row_new_cpu_kframe[i] != "") {
      aggregate_old_cpu_kframe[base_case_name] += row_old_cpu_kframe[i]
      aggregate_new_cpu_kframe[base_case_name] += row_new_cpu_kframe[i]
      aggregate_cpu_kframe_count[base_case_name]++
    }
    if (row_old_gpu_power_kframe[i] != "" && row_new_gpu_power_kframe[i] != "") {
      aggregate_old_gpu_power_kframe[base_case_name] += row_old_gpu_power_kframe[i]
      aggregate_new_gpu_power_kframe[base_case_name] += row_new_gpu_power_kframe[i]
      aggregate_gpu_power_kframe_count[base_case_name]++
    }
    if (row_old_gpu_active_kframe[i] != "" && row_new_gpu_active_kframe[i] != "") {
      aggregate_old_gpu_active_kframe[base_case_name] += row_old_gpu_active_kframe[i]
      aggregate_new_gpu_active_kframe[base_case_name] += row_new_gpu_active_kframe[i]
      aggregate_gpu_active_kframe_count[base_case_name]++
    }
  }
  repeated_aggregates = 0
  for (i = 1; i <= aggregate_count; i++) {
    if (aggregate_rows[aggregate_order[i]] > 1) {
      repeated_aggregates++
    }
  }
  if (repeated_aggregates > 0) {
    print ""
    print "## Policy-Clean Aggregates"
    print ""
    print "- policy: discard warmup `#r01` rows; exclude rows where old/new machine-window top CPU exceeds " max_sample_top_cpu "%; exclude rows where old/new CPU or GPU power exceeds " outlier_power_multiplier "x the case median among otherwise clean rows."
    print "- policy-excluded rows: " (policy_excluded_rows + 0)
    if (policy_excluded_rows > 0) {
      for (i = 1; i <= policy_excluded_rows; i++) {
        print policy_exclusion_line[i]
      }
      print ""
    }
    print "| Case | Rows | Clean Rows | Old CPU/kFrame Avg | New CPU/kFrame Avg | CPU/kFrame Delta | Old GPU mW/kFrame Avg | New GPU mW/kFrame Avg | GPU mW/kFrame Delta | Old GPU Active/kFrame Avg | New GPU Active/kFrame Avg | GPU Active/kFrame Delta |"
    print "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"
    for (i = 1; i <= aggregate_count; i++) {
      base_case_name = aggregate_order[i]
      if (aggregate_rows[base_case_name] <= 1) {
        continue
      }
      old_cpu_avg = new_cpu_avg = old_gpu_power_avg = new_gpu_power_avg = old_gpu_active_avg = new_gpu_active_avg = ""
      if (aggregate_cpu_kframe_count[base_case_name] > 0) {
        old_cpu_avg = aggregate_old_cpu_kframe[base_case_name] / aggregate_cpu_kframe_count[base_case_name]
        new_cpu_avg = aggregate_new_cpu_kframe[base_case_name] / aggregate_cpu_kframe_count[base_case_name]
      }
      if (aggregate_gpu_power_kframe_count[base_case_name] > 0) {
        old_gpu_power_avg = aggregate_old_gpu_power_kframe[base_case_name] / aggregate_gpu_power_kframe_count[base_case_name]
        new_gpu_power_avg = aggregate_new_gpu_power_kframe[base_case_name] / aggregate_gpu_power_kframe_count[base_case_name]
      }
      if (aggregate_gpu_active_kframe_count[base_case_name] > 0) {
        old_gpu_active_avg = aggregate_old_gpu_active_kframe[base_case_name] / aggregate_gpu_active_kframe_count[base_case_name]
        new_gpu_active_avg = aggregate_new_gpu_active_kframe[base_case_name] / aggregate_gpu_active_kframe_count[base_case_name]
      }
      print sprintf("| `%s` | %d | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
        base_case_name,
        aggregate_rows[base_case_name],
        aggregate_clean_rows[base_case_name] + 0,
        fmt2(old_cpu_avg),
        fmt2(new_cpu_avg),
        pct_delta(old_cpu_avg, new_cpu_avg),
        fmt2(old_gpu_power_avg),
        fmt2(new_gpu_power_avg),
        pct_delta(old_gpu_power_avg, new_gpu_power_avg),
        fmt2(old_gpu_active_avg),
        fmt2(new_gpu_active_avg),
        pct_delta(old_gpu_active_avg, new_gpu_active_avg))
    }
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

if [[ "${REQUIRE_COMMAND_CLEAN}" == "true" || "${REQUIRE_POWERMETRICS}" == "true" || "${REQUIRE_PERF_REGRESSION_CLEAN}" == "true" ]]; then
  if ! awk -F '\t' \
    -v require_command_clean="${REQUIRE_COMMAND_CLEAN}" \
    -v require_powermetrics="${REQUIRE_POWERMETRICS}" \
    -v require_perf_regression_clean="${REQUIRE_PERF_REGRESSION_CLEAN}" \
    -v max_cpu_regression_pct="${MAX_CPU_REGRESSION_PCT}" \
    -v max_gpu_regression_pct="${MAX_GPU_REGRESSION_PCT}" \
    -v visual_summary="${visual_summary_tsv}" \
    -v discard_warmup_reps="${DISCARD_WARMUP_REPS}" \
    -v outlier_power_multiplier="${OUTLIER_POWER_MULTIPLIER}" \
    -v max_sample_top_cpu="${MAX_SAMPLE_TOP_CPU}" '
      function number_or_zero(value) {
        return value == "" ? 0 : value + 0
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
      function pct_increase_value(old_value, new_value) {
        if (old_value == "" || new_value == "" || old_value + 0 == 0) {
          return ""
        }
        return ((new_value - old_value) / old_value) * 100.0
      }
      function per_kframe(value, frames) {
        if (value == "" || frames == "" || frames + 0 == 0) {
          return ""
        }
        return (value + 0) * 1000.0 / (frames + 0)
      }
      function frame_denominator(paint_frames, command_frames, benchmark_frames) {
        if (paint_frames != "" && paint_frames + 0 > 0) {
          return paint_frames
        }
        if (command_frames != "" && command_frames + 0 > 0) {
          return command_frames
        }
        return benchmark_frames
      }
      function append_issue(issues, issue) {
        if (issue == "") {
          return issues
        }
        return issues == "" ? issue : issues "; " issue
      }
      function command_ok(status, new_command, new_picture, new_fallbacks) {
        return status == "passed" && number_or_zero(new_command) > 0 &&
            number_or_zero(new_picture) == 0 && number_or_zero(new_fallbacks) == 0
      }
      function median_metric(base_case_name, metric_name,    i, n, j, tmp, values) {
        n = 0
        for (i = 1; i <= rows; i++) {
          if (row_base_case[i] != base_case_name || !row_policy_candidate[i]) {
            continue
          }
          if (metric_name == "old_cpu_power" && row_old_cpu_power[i] != "") {
            values[++n] = row_old_cpu_power[i] + 0
          } else if (metric_name == "new_cpu_power" && row_new_cpu_power[i] != "") {
            values[++n] = row_new_cpu_power[i] + 0
          } else if (metric_name == "old_gpu_power" && row_old_gpu_power[i] != "") {
            values[++n] = row_old_gpu_power[i] + 0
          } else if (metric_name == "new_gpu_power" && row_new_gpu_power[i] != "") {
            values[++n] = row_new_gpu_power[i] + 0
          }
        }
        if (n == 0) {
          return ""
        }
        for (i = 1; i <= n; i++) {
          for (j = i + 1; j <= n; j++) {
            if (values[j] < values[i]) {
              tmp = values[i]
              values[i] = values[j]
              values[j] = tmp
            }
          }
        }
        if (n % 2 == 1) {
          return values[(n + 1) / 2]
        }
        return (values[n / 2] + values[n / 2 + 1]) / 2.0
      }
      function fail_regression(case_name, label, old_value, new_value, threshold, delta) {
        delta = pct_increase_value(old_value, new_value)
        if (delta != "" && delta > threshold + 0) {
          printf("strict failure: %s %s regression %+.1f%% exceeds %s%% old=%s new=%s\n",
              case_name, label, delta, threshold, old_value, new_value) > "/dev/stderr"
          failures = 1
        }
      }
      {
        case_name = $col["case"]
        status = $col["status"]
        base_case_name = case_name
        sub(/#r[0-9]+$/, "", base_case_name)
        new_command = $col["new_command_frames"]
        new_picture = $col["new_picture_frames"]
        new_fallbacks = $col["new_fallbacks"]
        old_powermetrics = $col["old_powermetrics"]
        new_powermetrics = $col["new_powermetrics"]
        old_powermetrics_summary = column_value("old_powermetrics_summary")
        new_powermetrics_summary = column_value("new_powermetrics_summary")
        old_machine = column_value("old_machine_cpu")
        new_machine = column_value("new_machine_cpu")
        old_frames = $col["old_benchmark_frames"]
        new_frames = $col["new_benchmark_frames"]
        old_paint_frames = column_value("old_paint_frames")
        new_paint_frames = column_value("new_paint_frames")
        old_command = $col["old_command_frames"]
        old_cpu = metric(column_value("old_ps"), "avg_cpu")
        new_cpu = metric(column_value("new_ps"), "avg_cpu")
        old_hot_thread = metric(column_value("old_thread_cpu"), "hottest_avg_thread_cpu")
        new_hot_thread = metric(column_value("new_thread_cpu"), "hottest_avg_thread_cpu")
        old_hot_core = metric(old_powermetrics_summary, "hottest_cpu_active_avg")
        new_hot_core = metric(new_powermetrics_summary, "hottest_cpu_active_avg")
        old_gpu_power = metric(old_powermetrics_summary, "gpu_power_avg_mw")
        new_gpu_power = metric(new_powermetrics_summary, "gpu_power_avg_mw")
        old_gpu_active = metric(old_powermetrics_summary, "gpu_active_avg")
        new_gpu_active = metric(new_powermetrics_summary, "gpu_active_avg")
        old_machine_top_cpu = metric(old_machine, "max_top_cpu")
        new_machine_top_cpu = metric(new_machine, "max_top_cpu")
        old_machine_top_process = metric(old_machine, "max_top_process")
        new_machine_top_process = metric(new_machine, "max_top_process")
        preflight_skipped = visualStatus[case_name] == "preflight-skipped"
        old_normalized_frames = frame_denominator(old_paint_frames, old_command, old_frames)
        new_normalized_frames = frame_denominator(new_paint_frames, new_command, new_frames)
        old_cpu_kframe = per_kframe(old_cpu, old_normalized_frames)
        new_cpu_kframe = per_kframe(new_cpu, new_normalized_frames)
        old_gpu_power_kframe = per_kframe(old_gpu_power, old_normalized_frames)
        new_gpu_power_kframe = per_kframe(new_gpu_power, new_normalized_frames)
        old_gpu_active_kframe = per_kframe(old_gpu_active, old_normalized_frames)
        new_gpu_active_kframe = per_kframe(new_gpu_active, new_normalized_frames)
        if (!preflight_skipped && require_command_clean == "true" &&
            !command_ok(status, new_command, new_picture, new_fallbacks)) {
          printf("strict failure: %s command path is not clean\n", case_name) > "/dev/stderr"
          failures = 1
        }
        if (!preflight_skipped && require_powermetrics == "true" &&
            (!powermetrics_ok(old_powermetrics, old_powermetrics_summary) ||
             !powermetrics_ok(new_powermetrics, new_powermetrics_summary))) {
          printf("strict failure: %s powermetrics missing old=%s (%s) new=%s (%s)\n",
              case_name, old_powermetrics, old_powermetrics_summary,
              new_powermetrics, new_powermetrics_summary) > "/dev/stderr"
          failures = 1
        }

        rows++
        row_case_name[rows] = case_name
        row_base_case[rows] = base_case_name
        aggregate_rows[base_case_name]++
        row_policy_candidate[rows] = status == "passed" &&
            command_ok(status, new_command, new_picture, new_fallbacks) &&
            visualStatus[case_name] == "complete" &&
            powermetrics_ok(old_powermetrics, old_powermetrics_summary) &&
            powermetrics_ok(new_powermetrics, new_powermetrics_summary)
        row_old_cpu[rows] = old_cpu
        row_new_cpu[rows] = new_cpu
        row_old_hot_thread[rows] = old_hot_thread
        row_new_hot_thread[rows] = new_hot_thread
        row_old_hot_core[rows] = old_hot_core
        row_new_hot_core[rows] = new_hot_core
        row_old_gpu_power[rows] = old_gpu_power
        row_new_gpu_power[rows] = new_gpu_power
        row_old_gpu_active[rows] = old_gpu_active
        row_new_gpu_active[rows] = new_gpu_active
        row_old_cpu_kframe[rows] = old_cpu_kframe
        row_new_cpu_kframe[rows] = new_cpu_kframe
        row_old_gpu_power_kframe[rows] = old_gpu_power_kframe
        row_new_gpu_power_kframe[rows] = new_gpu_power_kframe
        row_old_gpu_active_kframe[rows] = old_gpu_active_kframe
        row_new_gpu_active_kframe[rows] = new_gpu_active_kframe
        row_old_cpu_power[rows] = metric(old_powermetrics_summary, "cpu_power_avg_mw")
        row_new_cpu_power[rows] = metric(new_powermetrics_summary, "cpu_power_avg_mw")
        row_old_machine_top_cpu[rows] = old_machine_top_cpu
        row_new_machine_top_cpu[rows] = new_machine_top_cpu
        row_old_machine_top_process[rows] = old_machine_top_process
        row_new_machine_top_process[rows] = new_machine_top_process
      }
      END {
        if (require_perf_regression_clean == "true") {
          for (i = 1; i <= rows; i++) {
            if (aggregate_rows[row_base_case[i]] > 1) {
              repeated_perf_suite = 1
              break
            }
          }
          if (!repeated_perf_suite) {
            for (i = 1; i <= rows; i++) {
              case_name = row_case_name[i]
              old_cpu = row_old_cpu[i]
              new_cpu = row_new_cpu[i]
              old_hot_thread = row_old_hot_thread[i]
              new_hot_thread = row_new_hot_thread[i]
              old_hot_core = row_old_hot_core[i]
              new_hot_core = row_new_hot_core[i]
              old_gpu_power = row_old_gpu_power[i]
              new_gpu_power = row_new_gpu_power[i]
              old_gpu_active = row_old_gpu_active[i]
              new_gpu_active = row_new_gpu_active[i]
              fail_regression(case_name, "avg_cpu", old_cpu, new_cpu, max_cpu_regression_pct)
              fail_regression(case_name, "hot_thread", old_hot_thread, new_hot_thread, max_cpu_regression_pct)
              fail_regression(case_name, "hot_core", old_hot_core, new_hot_core, max_cpu_regression_pct)
              fail_regression(case_name, "gpu_power", old_gpu_power, new_gpu_power, max_gpu_regression_pct)
              fail_regression(case_name, "gpu_active", old_gpu_active, new_gpu_active, max_gpu_regression_pct)
            }
            exit failures
          }

          for (i = 1; i <= rows; i++) {
            base_case_name = row_base_case[i]
            median_old_cpu_power[base_case_name] = median_metric(base_case_name, "old_cpu_power")
            median_new_cpu_power[base_case_name] = median_metric(base_case_name, "new_cpu_power")
            median_old_gpu_power[base_case_name] = median_metric(base_case_name, "old_gpu_power")
            median_new_gpu_power[base_case_name] = median_metric(base_case_name, "new_gpu_power")
          }
          for (i = 1; i <= rows; i++) {
            base_case_name = row_base_case[i]
            reason = ""
            if (!row_policy_candidate[i]) {
              continue
            }
            if (discard_warmup_reps == "true" && aggregate_rows[base_case_name] > 1 && row_case_name[i] ~ /#r01$/) {
              reason = append_issue(reason, "warmup-r01")
            }
            if (row_old_machine_top_cpu[i] != "" && row_old_machine_top_cpu[i] + 0 > max_sample_top_cpu + 0) {
              reason = append_issue(reason, sprintf("old-machine-top-cpu %.1f>%s (%s)",
                  row_old_machine_top_cpu[i], max_sample_top_cpu,
                  row_old_machine_top_process[i] == "" ? "unknown" : row_old_machine_top_process[i]))
            }
            if (row_new_machine_top_cpu[i] != "" && row_new_machine_top_cpu[i] + 0 > max_sample_top_cpu + 0) {
              reason = append_issue(reason, sprintf("new-machine-top-cpu %.1f>%s (%s)",
                  row_new_machine_top_cpu[i], max_sample_top_cpu,
                  row_new_machine_top_process[i] == "" ? "unknown" : row_new_machine_top_process[i]))
            }
            if (median_old_cpu_power[base_case_name] != "" && row_old_cpu_power[i] != "" &&
                row_old_cpu_power[i] + 0 > (median_old_cpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
              reason = append_issue(reason, "old-cpu-power-outlier")
            }
            if (median_new_cpu_power[base_case_name] != "" && row_new_cpu_power[i] != "" &&
                row_new_cpu_power[i] + 0 > (median_new_cpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
              reason = append_issue(reason, "new-cpu-power-outlier")
            }
            if (median_old_gpu_power[base_case_name] != "" && row_old_gpu_power[i] != "" &&
                row_old_gpu_power[i] + 0 > (median_old_gpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
              reason = append_issue(reason, "old-gpu-power-outlier")
            }
            if (median_new_gpu_power[base_case_name] != "" && row_new_gpu_power[i] != "" &&
                row_new_gpu_power[i] + 0 > (median_new_gpu_power[base_case_name] + 0) * (outlier_power_multiplier + 0)) {
              reason = append_issue(reason, "new-gpu-power-outlier")
            }
            if (reason != "") {
              continue
            }
            aggregate_clean_rows[base_case_name]++
            if (row_old_cpu_kframe[i] != "" && row_new_cpu_kframe[i] != "") {
              aggregate_old_cpu_kframe[base_case_name] += row_old_cpu_kframe[i]
              aggregate_new_cpu_kframe[base_case_name] += row_new_cpu_kframe[i]
              aggregate_cpu_kframe_count[base_case_name]++
            }
            if (row_old_gpu_power_kframe[i] != "" && row_new_gpu_power_kframe[i] != "") {
              aggregate_old_gpu_power_kframe[base_case_name] += row_old_gpu_power_kframe[i]
              aggregate_new_gpu_power_kframe[base_case_name] += row_new_gpu_power_kframe[i]
              aggregate_gpu_power_kframe_count[base_case_name]++
            }
            if (row_old_gpu_active_kframe[i] != "" && row_new_gpu_active_kframe[i] != "") {
              aggregate_old_gpu_active_kframe[base_case_name] += row_old_gpu_active_kframe[i]
              aggregate_new_gpu_active_kframe[base_case_name] += row_new_gpu_active_kframe[i]
              aggregate_gpu_active_kframe_count[base_case_name]++
            }
          }
          for (base_case_name in aggregate_rows) {
            if (aggregate_rows[base_case_name] <= 1) {
              continue
            }
            if (aggregate_clean_rows[base_case_name] == 0) {
              printf("strict failure: %s has no policy-clean rows for aggregate perf gate\n",
                  base_case_name) > "/dev/stderr"
              failures = 1
              continue
            }
            if (aggregate_cpu_kframe_count[base_case_name] > 0) {
              fail_regression(base_case_name, "cpu_per_kframe",
                  aggregate_old_cpu_kframe[base_case_name] / aggregate_cpu_kframe_count[base_case_name],
                  aggregate_new_cpu_kframe[base_case_name] / aggregate_cpu_kframe_count[base_case_name],
                  max_cpu_regression_pct)
            }
            if (aggregate_gpu_power_kframe_count[base_case_name] > 0) {
              fail_regression(base_case_name, "gpu_power_per_kframe",
                  aggregate_old_gpu_power_kframe[base_case_name] / aggregate_gpu_power_kframe_count[base_case_name],
                  aggregate_new_gpu_power_kframe[base_case_name] / aggregate_gpu_power_kframe_count[base_case_name],
                  max_gpu_regression_pct)
            }
            if (aggregate_gpu_active_kframe_count[base_case_name] > 0) {
              fail_regression(base_case_name, "gpu_active_per_kframe",
                  aggregate_old_gpu_active_kframe[base_case_name] / aggregate_gpu_active_kframe_count[base_case_name],
                  aggregate_new_gpu_active_kframe[base_case_name] / aggregate_gpu_active_kframe_count[base_case_name],
                  max_gpu_regression_pct)
            }
          }
        }
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
    if grep -q "^old_skip_reason=preflight\\|^new_skip_reason=preflight" "${summary}"; then
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
