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

By default `run-jbr-skia.sh` passes `-Dsun.java2d.skia.interop.library=/tmp/jbr-skia-native/libjbrskiainterop.dylib`
so the patched-module local harness can load the out-of-build native bridge. Set `JBR_SKIA_LIB=` to omit that property
and exercise JBR's bundled `System.loadLibrary("jbrskiainterop")` path instead; that mode requires a real JBR image
where the bridge is on the runtime library path, so the current patched-class harness is expected to produce no JBR
native command frames when the library has not been bundled.

Refresh local patched JBR artifacts:

```bash
./scripts/rebuild-jbr-skia-local-artifacts.sh
```

The helper rebuilds the public JBR API shim, compiles the patched `java.desktop` classes into `/tmp/jbr-skia-run/desktop`, removes the temporary `com.jetbrains.exported` compile stub from that patch output, and links `/tmp/jbr-skia-native/libjbrskiainterop.dylib` against the local Skia archive from the Skiko worktree. Override `JBR_ROOT`, `JBR_API_ROOT`, `SKIKO_ROOT`, `SKIA_ROOT`, `DESKTOP_PATCH_DIR`, `JBR_API_SHIM`, or `NATIVE_LIB` if your worktrees or artifact paths move.

By default Magic Jewel compiles against and the interop run prepends patched CMP jars from the sibling `../cmp/out/compose-multiplatform-core` output when it exists, falling back to the sibling `../cmp` checkout. Override that with `LOCAL_CMP_OUT=/path/to/compose-multiplatform-core` or `-PlocalCmpOut=/path/to/compose-multiplatform-core` if the worktree moves. Keeping those jars on both classpaths is intentional: command probes that exercise new Compose APIs must not compile against published Compose jars and run against the patched local ABI.
Set `JBR_SKIA_RENDER_MODE=commands` to exercise the lower-level command-list probe instead of the default Skia picture replay path.
Command mode currently supports Magic Jewel text through a temporary text-as-inline-ARGB bridge by default: CMP rasterizes Skia Paragraph output into the existing image command so the sample stays on JBR command replay while preserving the resolved Jewel font, size, and alignment. This is useful for mixed-content validation, but it is not the final JBR-owned font/typeface solution. Set `JBR_SKIA_NATIVE_TEXT=true` to probe native text commands, which now carry font-family plus simple text weight/width/slant metadata and are covered by the native-text report row below; the default remains text-as-image until broader typography parity is proven.
To validate deliberate fallback paths, run with `EXPECT_COMMAND_FALLBACK=true` and set `EXPECT_COMMAND_FALLBACK_REASON` to the unsupported operation being probed.

Old/new process and marker report:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE=true MAGIC_JEWEL_COMPOSE_TRANSFORM=true MAGIC_JEWEL_COMPOSE_SAVELAYER=true MAGIC_JEWEL_COMPOSE_CLIP=true MAGIC_JEWEL_COMPOSE_CLIP_OUT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_SHADER=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_SHADER_COLOR_FILTER=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COMPOSITE_SHADER_COLOR_FILTER=true EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=4 EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_SHADER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_SHADER=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=shader SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RAW_RUNTIME_EFFECT_COLOR_FILTER=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=colorFilter SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_SHADER_COLOR_FILTER=true EXPECT_MIN_JBR_SHADER_HANDLE_DEFINES=2 EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE_COLOR_MATRIX_FILTER=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_BLEND_MODE=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RENDER_EFFECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_RAW_IMAGE_FILTER_EFFECT=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=graphicsLayer:renderEffect SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFSET_EFFECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CHAINED_RENDER_EFFECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_X=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROTATION_Y=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_NEAR_CAMERA=true MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_OFFCENTER_PIVOT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RAW_BLEND_COLOR_FILTER=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=colorFilter SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_PATH_EFFECT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RAW_DISCRETE_PATH_EFFECT=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=pathEffect SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_BLEND_MODE=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_SAVELAYER_FILTER=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_REFS=1 EXPECT_MAX_IMAGE_DEFINES=0 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true MAGIC_JEWEL_AUTO_RESIZE=true EXPECT_MIN_IMAGE_CACHE_EVICTS=1 EXPECT_MIN_JBR_IMAGE_CACHE_EVICTS=1 EXPECT_MAX_IMAGE_CACHE_CLEARS=0 EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=false EXPECT_SURFACE_CHANGED=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_COLOR_FILTER=true MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true EXPECT_MIN_SURFACE_CHANGES=1 EXPECT_SURFACE_CONTEXT_CHANGED=true EXPECT_SURFACE_CHANGED=false EXPECT_MIN_COMMAND_CACHE_CLEARS=1 EXPECT_MIN_JBR_EFFECT_HANDLE_DEFINES=2 EXPECT_MIN_JBR_EFFECT_HANDLE_CACHE_HITS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_POPUP_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_POPUP_WINDOW_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_MENU_STRESS=true EXPECT_MIN_POPUP_FRAMES=5 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true EXPECT_MIN_IMAGE_REFS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands JBR_SKIA_NATIVE_TEXT=true MAGIC_JEWEL_UNSUPPORTED_TEXT=true MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_RUNTIME_EFFECT_COLOR_FILTER_CHILD=true MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_EXPECTED_ABI_ID_FOR_TEST=999 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=abi-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_EXPECTED_NATIVE_ABI_VERSION_FOR_TEST=999 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=native-abi-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_REQUIRED_COMMAND_CAPABILITIES_HIGH_FOR_TEST=-1 EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-capability-mismatch SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
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

The matrix runs the command-mode happy path plus forced `abi-mismatch`, `native-abi-mismatch`, broad low/high-word `command-capability-mismatch`, exact low-word capability removals for native text font-family metadata, descriptor color filters, and saveLayer/image color-filter refs, exact high-word capability removals for image filters, shader descriptors, RuntimeEffect color filters, path effects, concat matrices, direct shadows, shader color filters, draw points, transformed shader descriptors, and `public-api-missing` fallbacks. It validates that happy path gets JBR command frames, while each forced mismatch emits one structured fallback marker and produces no JBR command frames. Results are written to `matrix.tsv` with stable case, status, fallback, command-frame, and report columns.

Launch-level artifact matrix smoke:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-artifact-matrix.sh
```

The artifact matrix uses named local artifact roots instead of test-only mismatch properties. The required `current-all` row validates the current JBR desktop patch, public API shim, native dylib, Skiko version, and CMP output root together; the CMP root defaults to the sibling `../cmp/out/compose-multiplatform-core`. `missing-public-api` validates one real missing-artifact fallback. Optional rows run only when `OLD_JBR_API_SHIM`, `OLD_JBR_SKIA_LIB`, `OLD_DESKTOP_PATCH`, `OLD_SKIKO_VERSION`, or `OLD_CMP_OUT` are provided, or when `OLD_ARTIFACT_BUNDLE` points at a bundle manifest created by:

```bash
./scripts/package-jbr-skia-artifact-bundle.sh
```

The bundle helper captures the current patched `java.desktop` output, public API shim, native bridge dylib, Skiko version, and CMP output pointer into `out/jbr-skia-artifact-bundles/<timestamp>/manifest.properties`. It also writes `use-as-old.env`, which can be sourced or inspected to replay that bundle later:

```bash
OLD_ARTIFACT_BUNDLE=/path/to/bundle SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-artifact-matrix.sh
```

Set `REQUIRE_OLD_ARTIFACT_ROWS=true` in CI when old bundles are expected; the matrix then fails if any optional row is skipped. When a bundle captures the same artifacts as the current run, override the optional expected reasons to `none` for a self-check. Results are written to `matrix.tsv` with stable columns for row status, expected fallback, actual fallback count, JBR command frames, and report path.

For a real incompatible old-Skiko row, publish the old Skiko checkout under a separate Maven version such as
`0.0.0-abi99-SNAPSHOT` and pass it with `OLD_SKIKO_VERSION`; do not overwrite the current `0.0.0-SNAPSHOT` artifact.
The full required matrix can then combine old JBR API/native/desktop paths, `OLD_SKIKO_VERSION`, and `OLD_CMP_OUT` with
the expected fallback reasons set per row.

Command rendering probe suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-command-probe-suite.sh
```

The suite groups the manual command-mode probes into repeatable cases for live animation preservation, core primitives, drawPoints line/polygon replay, drawPoints point-dot replay, gradient surfaces, gradient paths, glass-pane popup layering, real popup-window capture, Swing menu popup layering, text-as-image replay, native text opt-in, forced-context native text replay, forced-context dynamic image-cache replay, image-shader rendering, image-shader-plus-color-filter descriptor rendering, composite linear/radial shader descriptor rendering, composite shader-plus-color-filter descriptor rendering, transformed shader descriptor rendering, RuntimeEffect/SKSL shader descriptor rendering, raw RuntimeEffect shader fallback, RuntimeEffect shader-plus-color-filter descriptor rendering, linear-gradient shader-plus-color-filter descriptor rendering, RuntimeEffect color-filter descriptor rendering, raw RuntimeEffect color-filter fallback, raw blend color-filter fallback, linear-gradient stroked-rect rendering, tint color-filter rendering, color-matrix descriptor rendering, lighting descriptor rendering, descriptor handle eviction, descriptor redefine after resize/context change, Plus/Multiply/Screen/Overlay/Darken/Lighten/Difference/Exclusion/ColorDodge/ColorBurn/Hardlight/Softlight/Hue/Saturation/Color/Luminosity blend-mode rendering, dashed line/rectangle/rounded-rectangle/arbitrary-path plus corner/stamped/chained path-effect rendering, raw discrete path-effect fallback, graphics-layer command replay, graphics-layer ModulateAlpha/Offscreen replay, rectangular/rounded/generic-path clipped graphics-layer command replay, graphics-layer blend-mode replay, graphics-layer tint color-filter replay, graphics-layer color-matrix descriptor replay, graphics-layer blur/offset/chained render-effect descriptor replay, graphics-layer render-effect resize/context redefinition, graphics-layer raw Skia-backed render-effect fallback, graphics-layer render-effect/color-filter/blend-mode descriptor combinations including offset/chained image-filter trees and near-camera 3D transforms, graphics-layer rectangular/rounded/generic-path shadow replay, graphics-layer combined blend/tint replay, image-filter/saveLayer-filter fallback, invalid descriptor use/version fallback, opaque shader fallback, composite-with-opaque-child shader fallback, noise shader fallback, picture shader fallback, and invalid-gradient fallback. Use `CASES="commands-live-animation commands-core-primitives commands-popup"` to run a subset. It writes `suite.tsv` with one row per case, including validation status, fallback count, unsupported reasons, picture/command frame counts, command FPS, and report path. The per-run `summary.properties` also exposes `jbr_shadow_commands_max`; shadow rows set `EXPECT_MIN_JBR_SHADOW_COMMANDS=1` so they fail unless JBR reports a direct native shadow replay in `JBR_SKIA_INTEROP_COMMAND_TIMING`.

Window-only old/new screenshot parity:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-screenshot-parity.sh
```

The parity script freezes animation phase, frame ticks, and Swing timer movement so the old SwingGraphics renderer and new JBR Skia command renderer can be captured at the same deterministic point. It captures only the `MagicJewelJbrSkiaWindow` window without the macOS window shadow, runs the strict command screenshot oracle for the new renderer, then compares `old-window.png` and `new-window.png` with `scripts/compare-jbr-skia-window-screenshots.sh`. The comparison writes `parity-diff.png`, appends whole-window and ownership-region metrics to the report even when thresholds fail, and mirrors scalar `screenshot_parity_*` keys into `summary.properties`. Use `MAGIC_JEWEL_FIXED_ANIMATION_PHASE`, `MAGIC_JEWEL_FIXED_FRAME_TICKS`, and `MAGIC_JEWEL_PAUSE_SWING_ANIMATION=false` to override the default deterministic setup. Region gates default to `MAX_HEADER_CONTROLS_BAD_PIXEL_RATIO=0.04`, `MAX_COMPOSE_CANVAS_BAD_PIXEL_RATIO=0.08`, `MAX_SWING_ISLAND_BAD_PIXEL_RATIO=0.03`, and `MAX_RIGHT_PROBE_STRIP_BAD_PIXEL_RATIO=0.05`; the full-window bad-pixel ratio defaults to `MAX_BAD_PIXEL_RATIO=0.06`. Tune these per case as text/font drift is isolated from geometry drift. The comparator also emits Compose subregions for `composeBackdropLeft`, `composeCenterAnimation`, `composeBottomLabels`, `composePurpleRect`, `composeTopProgress`, and `composeBottomSwatches`. The last three can be hard-gated with `MAX_COMPOSE_PURPLE_RECT_BAD_PIXEL_RATIO`, `MAX_COMPOSE_TOP_PROGRESS_BAD_PIXEL_RATIO`, and `MAX_COMPOSE_BOTTOM_SWATCHES_BAD_PIXEL_RATIO`; `parity-geometry-clean` uses those smaller geometry/color gates while leaving broad text/AA-heavy regions looser. A frozen parity window is expected not to animate; use a normal `jbr-skia-interop-report.sh` command-mode run for animation/FPS smoke checks.

Named old/new screenshot parity suite:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-screenshot-parity-suite.sh
```

The parity suite runs deterministic old/new window captures for the rich baseline scene plus focused native-text, forced-context native-text, forced-context cached-image refs, point-dot, path-effect, image draw color-filter, shader-plus-color-filter, transformed shader descriptors, RuntimeEffect, graphics-layer effect, graphics-layer render-effect/color-filter/blend-mode descriptor combinations including offset/chained image-filter trees and near-camera 3D transforms, graphics-layer Offscreen, graphics-layer rotationX/rotationY/combined rotation, near-camera and off-center-pivot 3D graphics-layer rotation, and rectangular/rounded/generic-path graphics-layer shadow scenes. Image draw color-filter coverage includes tint and color-matrix rows. Shader-plus-color-filter coverage includes image, composite, linear-gradient, and RuntimeEffect rows. RuntimeEffect coverage also includes pure-color, uniform-only, child-only, combined child+uniform, RuntimeEffect color-filter, and RuntimeEffect child color-filter rows. Use `CASES="parity-rich parity-runtime-effect-pure-color"` to run a subset. It writes `suite.tsv` with one row per case, including fallback count, JBR picture/command frame counts, whole-window, Compose-canvas, text-heavy bottom-label, core Compose geometry, and shader-probe bad-pixel ratios plus the report and diff image paths.

`parity-geometry-clean` disables Compose text and the embedded Swing island with `MAGIC_JEWEL_COMPOSE_TEXT=false` and `MAGIC_JEWEL_SWING_ISLAND=false`. It is useful as a text/Swing-free geometry baseline while the stricter region masks are still being tuned.
The shader-plus-color-filter parity rows use local probe-region gates in addition to the broad whole-window and Compose-canvas gates: `MAX_COMPOSE_SHADER_IMAGE_BAD_PIXEL_RATIO`, `MAX_COMPOSE_SHADER_COMPOSITE_BAD_PIXEL_RATIO`, and `MAX_COMPOSE_SHADER_LINEAR_BAD_PIXEL_RATIO`.
`parity-transformed-shader` enables `MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true` and requires JBR shader handle define/use markers while comparing the transformed gradient wrapper against old SwingGraphics.
`parity-native-text` enables `JBR_SKIA_NATIVE_TEXT=true`, requires simple and paragraph text commands, disables the image-ref expectation, and uses text-aware whole-window, Compose-canvas, and bottom-label thresholds because native text is expected to differ slightly from the default text-as-image fidelity path. The command probe's `commands-native-text` row has the same simple-text gate so the ABI 101 font-family/style metadata path stays covered by both live and visual suites.
`parity-forced-context-image-refs` freezes the image-cache workload for deterministic screenshots while requiring cached image refs, a forced `contextChanged=true` marker, command-cache clearing, and zero whole-cache clears. The live `commands-forced-context-dynamic-images` row remains the eviction/churn guard.
`parity-point-dots` enables `MAGIC_JEWEL_COMPOSE_POINT_DOTS=true` to compare `drawPoints(PointMode.Points)` dot/cap rendering between old SwingGraphics and JBR-owned command replay.
`parity-path-effect` isolates dash, corner, stamped, and chained path-effect drawing by disabling unrelated blend/filter/gradient probes while keeping the mixed old/new window comparison.

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
Set `EXPECT_MIN_APP_NEW_FRAMES=5` on a normal command-mode report to fail if the new renderer stops producing `MAGIC_JEWEL_COMPOSE_FRAME` markers. The `commands-live-animation` suite case uses this as the cheap automated guard that the non-frozen sample is still moving. It also sets `SKIKO_FORCE_TINY_FULL_SCENE_ONCE_FOR_TEST=true` and `EXPECT_MIN_TINY_FULL_SCENE_INJECTIONS=1`, which exercises the Skiko preservation branch that replays the last meaningful frame when one tiny test-only `FullScene` command stream is injected.

Each report directory includes `report.md` for humans and `summary.properties` for automation. The properties file uses stable `key=value` entries such as `validation_status`, `fallback_new_count`, `host_cpu_count`, `host_load_1m`, `old_avg_cpu`, `new_avg_cpu`, `cmp_unsupported_reasons`, `cmp_frame_kind_full_scene`, `cmp_frame_kind_interop_only`, `skiko_command_frames`, `jbr_command_frames`, `jbr_command_fps`, `jbr_runtime_effect_compile_failures`, `jbr_runtime_effect_build_failures`, `jbr_effect_handle_define_frames`, `jbr_shader_handle_define_frames`, `app_new_fps`, `skiko_surface_change_markers`, `skiko_tiny_full_scene_injections`, `screenshot_parity_avgDelta`, `screenshot_parity_region_composeCanvas_badPixelRatio`, and scalar screenshot counters like `screenshot_paragraphCentered`, `screenshot_probeRightDark`, or `screenshot_probeRightShadow`.

RuntimeEffect compile failures are reported with stable single-line markers:
`JBR_SKIA_INTEROP_RUNTIME_EFFECT_COMPILE_FAILED hash=0x... skslLength=... uniforms=... children=... errorLength=... errorHash=0x...`.
RuntimeEffect builder failures are reported with stable single-line markers:
`JBR_SKIA_INTEROP_RUNTIME_EFFECT_BUILD_FAILED hash=0x... stage=missing-child|child-type|uniform-set|make-shader [nameHash=0x...] skslLength=... uniforms=... children=... namedUniforms=... namedChildren=...`.
`MAGIC_JEWEL_CORRUPT_DESCRIPTOR_VERSION=true` asks Skiko to corrupt one shader descriptor version after recording; the `commands-invalid-descriptor-version-fallback` row asserts JBR rejects that stream with the structured `command-stream-invalid` fallback. `MAGIC_JEWEL_CORRUPT_DESCRIPTOR_USE_AFTER_EVICT=true` inserts a shader-handle eviction immediately before a matching use; the `commands-invalid-descriptor-use-after-evict-fallback` row guards stale/use-after-free handle rejection.
The RuntimeEffect command suite can run the combined shader probe (`commands-runtime-effect-shader`), the shader-plus-color-filter probe (`commands-runtime-effect-shader-color-filter`), or narrower conformance probes: `commands-runtime-effect-pure-color`, `commands-runtime-effect-uniform-only`, `commands-runtime-effect-child-only`, `commands-runtime-effect-color-filter`, `commands-runtime-effect-color-filter-child`, `commands-runtime-effect-build-fallback`, and `commands-runtime-effect-child-type-fallback`. Raw Skia-owned RuntimeEffect objects are guarded separately by `commands-raw-runtime-effect-shader-fallback` and `commands-raw-runtime-effect-color-filter-fallback`. The broader wrapped-shader path is also probed by `commands-linear-gradient-shader-color-filter`.
`commands-raw-blend-color-filter-fallback` enables `MAGIC_JEWEL_COMPOSE_RAW_BLEND_COLOR_FILTER=true` and asserts a raw Skia `ColorFilter.makeBlend(...).asComposeColorFilter()` stays on structured `colorFilter` fallback, while metadata-backed Compose tint descriptors continue through command replay.
`commands-opaque-shader-fallback` enables `MAGIC_JEWEL_COMPOSE_OPAQUE_SHADER=true` and asserts the strict recorder keeps raw, non-descriptor Skia shaders on structured `shader` fallback instead of guessing at replay semantics.
`commands-composite-opaque-shader-fallback` enables `MAGIC_JEWEL_COMPOSE_COMPOSITE_OPAQUE_SHADER=true` and asserts a composite shader tree with one opaque raw-Skia child stays on structured `shader` fallback instead of serializing only the known child.
`commands-noise-shader-fallback` enables `MAGIC_JEWEL_COMPOSE_NOISE_SHADER=true` and asserts Skia Perlin/noise shaders stay on structured `shader` fallback until JBR owns an explicit descriptor for that family.
`commands-picture-shader-fallback` enables `MAGIC_JEWEL_COMPOSE_PICTURE_SHADER=true` and asserts Skia picture shaders stay on structured `shader` fallback until JBR owns an explicit descriptor for recorded-picture shader content.
`commands-transformed-shader` enables `MAGIC_JEWEL_COMPOSE_TRANSFORMED_SHADER=true` and asserts transform-aware shader descriptor replay through JBR-owned child shader handles and local matrices.
`commands-raw-discrete-path-effect-fallback` enables `MAGIC_JEWEL_COMPOSE_RAW_DISCRETE_PATH_EFFECT=true` and asserts raw Skia discrete path effects stay on structured `pathEffect` fallback, while Compose-created dash/corner/stamped/chained descriptors continue through command replay.

The descriptor lifecycle probe (`commands-descriptor-eviction`) enables `MAGIC_JEWEL_COMPOSE_DESCRIPTOR_EVICTION=true` and `MAGIC_JEWEL_COMPOSE_COLOR_FILTER_HANDLE=true`, then draws enough unique effect and composite-shader descriptors to exceed CMP's 1,024-entry handle caches. It asserts both define and evict markers in the full JBR log.

Stable descriptor rows also assert reuse with max-count gates: tint/color-matrix/lighting/image color-filter rows expect a single effect-handle define, `commands-runtime-effect-pure-color` expects a single shader-handle define, and `commands-composite-shader` expects exactly the three shader handles for its dst/src/composite tree. RuntimeEffect descriptor rows additionally assert JBR-side handle use markers, proving the handles were consumed by replay and not only defined.
Graphics-layer render-effect rows assert JBR effect-handle lifecycle markers too: blur and offset rows require define/use/cache-hit markers, and the chained row requires two effect-handle defines plus use/cache-hit markers for the nested image-filter descriptor tree. `commands-resize-graphics-layer-render-effect` and `commands-forced-context-graphics-layer-render-effect` additionally require command-cache clearing, effect-handle redefinition, and cache-hit recovery after same-context resize or forced destination-context migration. `commands-graphics-layer-raw-image-filter-effect-fallback` keeps raw Skia-backed `RenderEffect` instances on structured `graphicsLayer:renderEffect` picture fallback.

Surface identity changes are reported with `SKIKO_JBR_INTEROP_SURFACE_CHANGED oldContextId=... newContextId=... contextChanged=... surfaceChanged=... oldSurfaceId=... newSurfaceId=... oldMetalTexture=... newMetalTexture=...`. A non-zero `skiko_surface_change_markers` count means Skiko observed a different JBR destination surface during the run and discarded cached state tied to the previous surface. `contextChanged=false surfaceChanged=true` means a same-context surface replacement, such as resize. The `commands-resize-descriptor-redefine` row also requires `SKIKO_JBR_INTEROP_COMMAND_CACHES_CLEARED reason=...` and a second JBR effect-handle define after resize, proving the CMP recorder cache was invalidated before the new surface reused descriptor refs. `commands-resize-shader-descriptor-redefine` and `commands-resize-graphics-layer-render-effect` apply the same assertion to RuntimeEffect shader handles and graphics-layer image-filter handles. `commands-forced-context-descriptor-redefine`, `commands-forced-context-shader-descriptor-redefine`, and `commands-forced-context-graphics-layer-render-effect` use `MAGIC_JEWEL_FORCE_CONTEXT_CHANGE=true` to exercise the context-change invalidation path without depending on a physical multi-monitor migration.
`commands-forced-context-dynamic-images` applies the same forced context-change hook to dynamic cached-image refs. It requires command-cache clearing, positive image refs, CMP/JBR single-key image-cache evictions, and zero whole-cache clears so destination-context migration does not silently retain or globally flush image objects.

If Skiko cannot reach the CMP command-cache clear hook after a surface change, it emits `SKIKO_JBR_INTEROP_FALLBACK reason=command-cache-clear-unavailable`; the report validator treats that as a structured compatibility fallback.

The report validator also has explicit compatibility-matrix fixtures. A new Skiko build running against an old/pre-native-metadata JBR must emit `SKIKO_JBR_INTEROP_FALLBACK reason=native-abi-mismatch` and produce no command frames. An old or otherwise uninstrumented Skiko-style log that produces neither command frames nor a structured fallback marker is treated as a validation failure instead of a successful fallback.

Async-profiler collection is optional and off by default:

```bash
ENABLE_ASPROF=true ASPROF=/path/to/asprof ASPROF_EVENT=cpu JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

When enabled and available, the report directory contains `old-asprof-<event>.html` and `new-asprof-<event>.html`; otherwise the report records `disabled` or `unavailable` and continues.

The window title is `MagicJewelJbrSkiaWindow`, which is stable for screenshot/report scripts.
