# Magic Jewel

Standalone Jewel-on-Compose sample for the JBR Skia interop PoC. The app is intentionally hosted in a Swing `JFrame` with a `ComposePanel` so it exercises the Compose Multiplatform Swing rendering path instead of the direct Compose window path.

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

Old/new process and marker report:

```bash
SKIKO_VERSION=0.0.0-SNAPSHOT ./scripts/jbr-skia-interop-report.sh
```

The window title is `MagicJewelJbrSkiaWindow`, which is stable for screenshot/report scripts.
