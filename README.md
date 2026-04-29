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

By default the interop run prepends patched CMP jars from `/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core`. Override that with `-PlocalCmpOut=/path/to/out/compose-multiplatform-core` if the worktree moves.
Set `JBR_SKIA_RENDER_MODE=commands` to exercise the lower-level command-list probe instead of the default Skia picture replay path.
Command mode currently supports Magic Jewel text through a temporary text-as-inline-ARGB bridge by default: CMP rasterizes Skia Paragraph output into the existing image command so the sample stays on JBR command replay while preserving the resolved Jewel font, size, and alignment. This is useful for mixed-content validation, but it is not the final JBR-owned font/typeface solution. Set `JBR_SKIA_NATIVE_TEXT=true` only when deliberately probing the experimental native text commands.
To validate deliberate fallback paths, run with `EXPECT_COMMAND_FALLBACK=true` and set `EXPECT_COMMAND_FALLBACK_REASON` to the unsupported operation being probed.

Old/new process and marker report:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE=true MAGIC_JEWEL_COMPOSE_TRANSFORM=true MAGIC_JEWEL_COMPOSE_SAVELAYER=true MAGIC_JEWEL_COMPOSE_CLIP=true MAGIC_JEWEL_COMPOSE_CLIP_OUT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=shader SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_DEFINES=0 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
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

Command rendering probe suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-command-probe-suite.sh
```

The suite groups the manual command-mode probes into repeatable cases for core primitives, gradient surfaces, gradient paths, popup layering, text-as-image replay, native text opt-in, shader fallback, and invalid-gradient fallback. Use `CASES="commands-core-primitives commands-popup"` to run a subset.

Quiet-machine benchmark collection suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-benchmark-suite.sh
```

The suite writes one report directory per scenario under `out/jbr-skia-benchmark-suite/...`: SKP picture replay, command replay, stable image-cache workload, dynamic image-cache workload, and resize plus dynamic image-cache workload. Set `ENABLE_ASPROF=true` to collect async-profiler output for each case. Treat short-duration smoke runs as wiring checks only.

The image-cache churn report records both generic JBR clear markers and scoped clear markers. New scoped markers have the form
`JBR_SKIA_INTEROP_IMAGE_CACHE_CLEAR backend=native contextId=0x... cleared=N`, which verifies that JBR clears the current destination context namespace instead of dropping one process-global image cache.
Use `MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true` with `EXPECT_MAX_IMAGE_DEFINES=0 EXPECT_MAX_IMAGE_CACHE_CLEARS=0` to validate that stable cached images are defined during warmup and then reused without steady-state cache churn.
ABI 42 dynamic churn should prefer single-key eviction over whole-cache clears; use `EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0` to validate that path.
Set `MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=5` to add an animated Swing glass-pane popup over the ComposePanel. In command mode the report asserts popup paint markers, a captured popup color signature, zero picture replay, and zero fallback markers.

Each report directory includes `report.md` for humans and `summary.properties` for automation. The properties file uses stable `key=value` entries such as `validation_status`, `fallback_new_count`, `cmp_unsupported_reasons`, `skiko_command_frames`, `jbr_command_frames`, and `skiko_surface_change_markers`.

Surface identity changes are reported with `SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=... newContextId=... contextChanged=... surfaceChanged=... oldSurfaceId=... newSurfaceId=... oldMetalTexture=... newMetalTexture=...`. A non-zero `skiko_surface_change_markers` count means Skiko observed a different JBR destination surface during the run and discarded cached state tied to the previous surface. `contextChanged=false surfaceChanged=true` means a same-context surface replacement, such as resize.

The report validator also has explicit compatibility-matrix fixtures. A new Skiko build running against an old/pre-native-metadata JBR must emit `SKIKO_JBR_INTEROP_FALLBACK reason=native-abi-mismatch` and produce no command frames. An old or otherwise uninstrumented Skiko-style log that produces neither command frames nor a structured fallback marker is treated as a validation failure instead of a successful fallback.

Async-profiler collection is optional and off by default:

```bash
ENABLE_ASPROF=true ASPROF=/path/to/asprof ASPROF_EVENT=cpu JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

When enabled and available, the report directory contains `old-asprof-<event>.html` and `new-asprof-<event>.html`; otherwise the report records `disabled` or `unavailable` and continues.

The window title is `MagicJewelJbrSkiaWindow`, which is stable for screenshot/report scripts.
