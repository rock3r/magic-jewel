# Magic Jewel

Standalone Jewel-on-Compose sample for the JBR Skia interop PoC. The app is intentionally hosted in a Swing `JFrame` with a `ComposePanel` so it exercises the Compose Multiplatform Swing rendering path instead of the direct Compose window path.

The scene mixes animated Compose drawing with an embedded Swing island and a Compose overlay, plus app-level draw-frame markers for old/new FPS-style smoke reporting.

## Run

Baseline SwingGraphics path:

```bash
./gradlew run
```

JBR Skia interop path, using the same patched module/native-library flags as the CMP smoke sample:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/run-jbr-skia.sh
```

By default Magic Jewel compiles against and the interop run prepends patched CMP jars from `/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core`. Override that with `LOCAL_CMP_OUT=/path/to/out/compose-multiplatform-core` or `-PlocalCmpOut=/path/to/out/compose-multiplatform-core` if the worktree moves. Keeping those jars on both classpaths is intentional: command probes that exercise new Compose APIs must not compile against published Compose jars and run against the patched local ABI.
Set `JBR_SKIA_RENDER_MODE=commands` to exercise the lower-level command-list probe instead of the default Skia picture replay path.
Command mode currently supports Magic Jewel text through a temporary text-as-inline-ARGB bridge by default: CMP rasterizes Skia Paragraph output into the existing image command so the sample stays on JBR command replay while preserving the resolved Jewel font, size, and alignment. This is useful for mixed-content validation, but it is not the final JBR-owned font/typeface solution. Set `JBR_SKIA_NATIVE_TEXT=true` to probe the ABI 43 native text commands, which now carry font-family metadata and are covered by the native-text report row below; the default remains text-as-image until broader typography parity is proven.
To validate deliberate fallback paths, run with `EXPECT_COMMAND_FALLBACK=true` and set `EXPECT_COMMAND_FALLBACK_REASON` to the unsupported operation being probed.

Old/new process and marker report:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE=true MAGIC_JEWEL_COMPOSE_TRANSFORM=true MAGIC_JEWEL_COMPOSE_SAVELAYER=true MAGIC_JEWEL_COMPOSE_CLIP=true MAGIC_JEWEL_COMPOSE_CLIP_OUT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_BLEND_MODE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_DEFINES=0 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_POPUP_WINDOW_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_MENU_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands JBR_SKIA_NATIVE_TEXT=true MAGIC_JEWEL_UNSUPPORTED_TEXT=true MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_EXPECTED_ABI_ID_FOR_TEST=999 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=999 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_REQUIRED_COMMAND_CAPABILITIES_FOR_TEST=-1 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands JBR_API_SHIM=/tmp/missing-jbr-api-shim.jar EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=public-api-missing SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_INVALID_SWEEP_GRADIENT=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=sweepGradientStops SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_CLIP_PATH=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_DRAW_PATH=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_DRAW_ARC=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

Launch-level compatibility matrix smoke:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-compatibility-matrix.sh
```

The matrix runs the command-mode happy path plus forced `abi-mismatch`, `native-abi-mismatch`, `command-capability-mismatch`, and `public-api-missing` fallbacks. It validates that happy path gets JBR command frames, while each forced mismatch emits one structured fallback marker and produces no JBR command frames.

Launch-level artifact matrix smoke:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-artifact-matrix.sh
```

The artifact matrix uses named local artifact roots instead of test-only mismatch properties. The required `current-all` row validates the current JBR desktop patch, public API shim, native dylib, Skiko version, and CMP output root together; `missing-public-api` validates one real missing-artifact fallback. Optional rows run only when `OLD_JBR_API_SHIM`, `OLD_JBR_SKIA_LIB`, `OLD_DESKTOP_PATCH`, `OLD_SKIKO_VERSION`, or `OLD_CMP_OUT` are provided. Set `REQUIRE_OLD_ARTIFACT_ROWS=true` in CI when those old bundles are expected; the matrix then fails if any optional row is skipped. Results are written to `matrix.tsv` with stable columns for row status, expected fallback, actual fallback count, JBR command frames, and report path.

Command rendering probe suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-command-probe-suite.sh
```

The suite groups the manual command-mode probes into repeatable cases for core primitives, gradient surfaces, gradient paths, glass-pane popup layering, real popup-window capture, Swing menu popup layering, text-as-image replay, native text opt-in, image-shader rendering, linear-gradient stroked-rect rendering, tint color-filter rendering, Plus/Multiply/Screen/Overlay/Darken/Lighten/Difference/Exclusion/ColorDodge/ColorBurn/Hardlight/Softlight/Hue/Saturation/Color/Luminosity blend-mode rendering, dashed-line path-effect rendering, graphics-layer command replay, rectangular/rounded/generic-path clipped graphics-layer command replay, graphics-layer blend-mode replay, graphics-layer tint color-filter replay, image-filter/saveLayer-filter fallback, and invalid-gradient fallback. Use `CASES="commands-core-primitives commands-popup"` to run a subset. It writes `suite.tsv` with one row per case, including validation status, fallback count, unsupported reasons, picture/command frame counts, command FPS, and report path.

Window-only old/new screenshot parity:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-screenshot-parity.sh
```

The parity script freezes animation phase, frame ticks, and Swing timer movement so the old SwingGraphics renderer and new JBR Skia command renderer can be captured at the same deterministic point. It captures only the `MagicJewelJbrSkiaWindow` window, runs the strict command screenshot oracle for the new renderer, then compares `old-window.png` and `new-window.png` with `scripts/compare-jbr-skia-window-screenshots.sh`. The comparison writes `parity-diff.png`, appends whole-window and coarse ownership-region metrics to the report, and mirrors scalar `screenshot_parity_*` keys into `summary.properties`. Use `MAGIC_JEWEL_FIXED_ANIMATION_PHASE`, `MAGIC_JEWEL_FIXED_FRAME_TICKS`, and `MAGIC_JEWEL_PAUSE_SWING_ANIMATION=false` to override the default deterministic setup. A frozen parity window is expected not to animate; use a normal `jbr-skia-interop-report.sh` command-mode run for animation/FPS smoke checks.

Quiet-machine benchmark collection suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-benchmark-suite.sh
```

The suite writes one report directory per scenario under `out/jbr-skia-benchmark-suite/...`: SKP picture replay, command replay, stable image-cache workload, dynamic image-cache workload, and resize plus dynamic image-cache workload. It also writes `suite.tsv` with per-case status, old/new sample counts, CPU averages, FPS keys, and report paths. If a side has zero `ps` samples, the suite table records `na` for that CPU average. Use `CASES="commands-stable-images commands-resize-dynamic-images"` to rerun a subset. Set `ENABLE_ASPROF=true` to collect async-profiler output for each case. Treat short-duration smoke runs as wiring checks only.

The image-cache churn report records both generic JBR clear markers and scoped clear markers. New scoped markers have the form
`JBR_SKIA_INTEROP_IMAGE_CACHE_CLEAR backend=native contextId=0x... cleared=N`, which verifies that JBR clears the current destination context namespace instead of dropping one process-global image cache.
Use `MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true` with `EXPECT_MAX_IMAGE_DEFINES=0 EXPECT_MAX_IMAGE_CACHE_CLEARS=0` to validate that stable cached images are defined during warmup and then reused without steady-state cache churn.
Current ABI dynamic churn should prefer single-key eviction over whole-cache clears; use `EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0` to validate that path.
Set `MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=5` to add an animated Swing glass-pane popup over the ComposePanel. In command mode the report asserts popup paint markers, a captured popup color signature, zero picture replay, and zero fallback markers.
Set `MAGIC_JEWEL_POPUP_WINDOW_STRESS=true EXPECT_MIN_POPUP_FRAMES=5` to show an animated undecorated Swing popup window over the ComposePanel. The report captures the main window and the popup window separately by window id and asserts both screenshots.
Set `MAGIC_JEWEL_MENU_STRESS=true EXPECT_MIN_POPUP_FRAMES=5` to show an animated Swing `JPopupMenu` over the ComposePanel. The report asserts the menu-shown marker, popup repaint markers, and the same main-window popup color signature used by the glass-pane case.

Each report directory includes `report.md` for humans and `summary.properties` for automation. The properties file uses stable `key=value` entries such as `validation_status`, `fallback_new_count`, `host_cpu_count`, `host_load_1m`, `old_avg_cpu`, `new_avg_cpu`, `cmp_unsupported_reasons`, `cmp_frame_kind_full_scene`, `cmp_frame_kind_interop_only`, `skiko_command_frames`, `jbr_command_frames`, `jbr_command_fps`, `app_new_fps`, `skiko_surface_change_markers`, `screenshot_parity_avgDelta`, `screenshot_parity_region_composeCanvas_badPixelRatio`, and scalar screenshot counters like `screenshot_paragraphCentered` or `screenshot_probeRightDark`.

Surface identity changes are reported with `SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=... newContextId=... contextChanged=... surfaceChanged=... oldSurfaceId=... newSurfaceId=... oldMetalTexture=... newMetalTexture=...`. A non-zero `skiko_surface_change_markers` count means Skiko observed a different JBR destination surface during the run and discarded cached state tied to the previous surface. `contextChanged=false surfaceChanged=true` means a same-context surface replacement, such as resize.

The report validator also has explicit compatibility-matrix fixtures. A new Skiko build running against an old/pre-native-metadata JBR must emit `SKIKO_JBR_INTEROP_FALLBACK reason=native-abi-mismatch` and produce no command frames. An old or otherwise uninstrumented Skiko-style log that produces neither command frames nor a structured fallback marker is treated as a validation failure instead of a successful fallback.

Async-profiler collection is optional and off by default:

```bash
ENABLE_ASPROF=true ASPROF=/path/to/asprof ASPROF_EVENT=cpu JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

When enabled and available, the report directory contains `old-asprof-<event>.html` and `new-asprof-<event>.html`; otherwise the report records `disabled` or `unavailable` and continues.

The window title is `MagicJewelJbrSkiaWindow`, which is stable for screenshot/report scripts.
