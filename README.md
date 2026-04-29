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
Command mode currently supports Magic Jewel text through a temporary text-as-inline-ARGB bridge: CMP rasterizes Skia Paragraph output into the existing image command so the sample stays on JBR command replay. This is useful for mixed-content validation, but it is not the final JBR-owned font/typeface solution.
To validate deliberate fallback paths, run with `EXPECT_COMMAND_FALLBACK=true` and set `EXPECT_COMMAND_FALLBACK_REASON` to the unsupported operation being probed.

Old/new process and marker report:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_COMPOSE_IMAGE=true MAGIC_JEWEL_COMPOSE_TRANSFORM=true MAGIC_JEWEL_COMPOSE_SAVELAYER=true MAGIC_JEWEL_COMPOSE_CLIP=true MAGIC_JEWEL_COMPOSE_CLIP_OUT=true SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_IMAGE_CACHE_CHURN=true EXPECT_MIN_IMAGE_CACHE_CLEARS=1 EXPECT_MIN_JBR_IMAGE_CACHE_CLEARS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=1 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_UNSUPPORTED_TEXT=true MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT=true EXPECT_MIN_PARAGRAPH_TEXT_COMMANDS=4 SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
JBR_SKIA_RENDER_MODE=commands MAGIC_JEWEL_CORRUPT_COMMAND_STREAM=true EXPECT_COMMAND_FALLBACK=true EXPECT_COMMAND_FALLBACK_REASON=command-stream-invalid SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

The window title is `MagicJewelJbrSkiaWindow`, which is stable for screenshot/report scripts.
