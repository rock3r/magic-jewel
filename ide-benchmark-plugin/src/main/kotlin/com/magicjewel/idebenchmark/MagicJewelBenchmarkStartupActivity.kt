package com.magicjewel.idebenchmark

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.openapi.wm.ToolWindowManager
import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import dev.sebastiano.spectre.recording.AutoScreenshotter
import dev.sebastiano.spectre.recording.screencapturekit.asTitledWindow
import java.awt.Frame
import java.awt.Component
import java.awt.Container
import java.awt.Rectangle
import java.awt.image.BufferedImage
import java.nio.file.Path
import java.util.Locale
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import javax.imageio.ImageIO
import javax.swing.SwingUtilities
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking

class MagicJewelBenchmarkStartupActivity : ProjectActivity {
    override suspend fun execute(project: Project) {
        if (System.getProperty("magic.jewel.benchmark.autorun") != "true") return
        val mode = BenchmarkMode.from(System.getProperty("magic.jewel.benchmark.mode"))
        println("MAGIC_JEWEL_IDE_BENCHMARK status=project-opened project=${project.name} mode=$mode")
        println(
            "MAGIC_JEWEL_IDE_BENCHMARK_INTEROP_PROBE " +
                "composeSwing=${System.getProperty("compose.swing.render.on.graphics")} " +
                "composeJbrSkia=${System.getProperty("compose.swing.render.on.jbr.skia")} " +
                "renderCommands=${System.getProperty("skiko.jbr.interop.renderCommands")} " +
                "renderPicture=${System.getProperty("skiko.jbr.interop.renderPicture")} " +
                "sunInterop=${System.getProperty("sun.java2d.skia.interop")} " +
                "sunInteropLibrary=${System.getProperty("sun.java2d.skia.interop.library")} " +
                "commandLogOpCounts=${System.getProperty("compose.jbr.skia.command.logOpCounts")} " +
                "commandStrict=${System.getProperty("compose.jbr.skia.command.strict")} " +
                "skikoLayerSource=${classSource("org.jetbrains.skiko.SkiaLayer")} " +
                "composeSceneSource=${classSource("androidx.compose.ui.scene.ComposeScene")}",
        )
        delay(2_000)
        activateBenchmarkToolWindow(project, mode)
    }

    private suspend fun activateBenchmarkToolWindow(project: Project, mode: BenchmarkMode) {
        val manager = ToolWindowManager.getInstance(project)
        repeat(30) {
            val toolWindow = manager.getToolWindow("JBR Skia Benchmark")
            if (toolWindow != null) {
                ApplicationManager.getApplication().invokeLater {
                    toolWindow.activate(
                        {
                            println("MAGIC_JEWEL_IDE_BENCHMARK status=tool-window-activated")
                            maybeStartPaintProbe(project, mode)
                            ApplicationManager.getApplication().executeOnPooledThread { driveBenchmarkUi(mode) }
                        },
                        true,
                        true,
                    )
                }
                return
            }
            delay(500)
        }
        println("MAGIC_JEWEL_IDE_BENCHMARK status=tool-window-missing")
    }

    private fun driveBenchmarkUi(mode: BenchmarkMode) {
        runBlocking {
            val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.headless())
            val tag = expectedPageTag(mode)
            val ready = pollOnEdt {
                automator.refreshWindows()
                automator.findOneByTestTag(tag) != null
            }
            if (!ready) {
                runOnEdt {
                    automator.refreshWindows()
                    println("MAGIC_JEWEL_IDE_BENCHMARK status=spectre-timeout surfaces=${automator.surfaceIds()}")
                    println("MAGIC_JEWEL_IDE_BENCHMARK tags=${automator.allNodes().mapNotNull(AutomatorNode::testTag)}")
                    println("MAGIC_JEWEL_IDE_BENCHMARK tree=${automator.printTree().lineSequence().take(80).joinToString(" | ")}")
                }
                return@runBlocking
            }
            println("MAGIC_JEWEL_IDE_BENCHMARK status=started mode=$mode")
            var cycle = 0
            while (true) {
                runOnEdt {
                    automator.refreshWindows()
                    if (mode == BenchmarkMode.Hypnotoad) {
                        val target =
                            when (cycle % 6) {
                                0, 1, 2, 3 -> "magic.benchmark.hypnotoad.warp"
                                4 -> "magic.benchmark.hypnotoad.calm"
                                else -> "magic.benchmark.hypnotoad.reset"
                            }
                        automator.findOneByTestTag(target)?.let { automator.performSemanticsClick(it) }
                    }
                }
                println("MAGIC_JEWEL_IDE_BENCHMARK phase=tick mode=$mode cycle=$cycle")
                cycle += 1
                delay(150)
            }
        }
    }

    private fun maybeStartPaintProbe(project: Project, mode: BenchmarkMode) {
        if (System.getProperty("magic.jewel.benchmark.paintProbe") != "true") return
        val outDir = System.getProperty("magic.jewel.benchmark.out") ?: return
        ApplicationManager.getApplication().executeOnPooledThread {
            Thread.sleep(PAINT_PROBE_DELAY_MS)
            runCatching {
                    val expectedTag = expectedPageTag(mode)
                    val target =
                        runOnEdt {
                            val component =
                                ToolWindowManager.getInstance(project)
                                    .getToolWindow("JBR Skia Benchmark")
                                    ?.component
                            component?.takeIf { it.isShowing }?.let {
                                val window = SwingUtilities.getWindowAncestor(it)?.takeIf { window -> window.isShowing }
                                val frame = window as? Frame
                                window?.toFront()
                                window?.requestFocus()
                                it.requestFocusInWindow()
                                Thread.sleep(PAINT_PROBE_FRONT_DELAY_MS)
                                logComponentBounds("toolWindow", it, depth = 0, maxDepth = 4)
                                val expectedNodePresent =
                                    runCatching {
                                            val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.headless())
                                            automator.refreshWindows()
                                            automator.findOneByTestTag(expectedTag) != null
                                        }
                                        .getOrDefault(false)
                                println(
                                    "MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE_EXPECTED_NODE " +
                                        "tag=$expectedTag present=$expectedNodePresent",
                                )
                                frame?.let { targetWindow -> logComponentBounds("window", targetWindow, depth = 0, maxDepth = 2) }
                                PaintProbeTarget(it, frame)
                            }
                        }
                    if (target == null) {
                        println("MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=missing-component")
                        return@runCatching
                    }
                    val capture =
                        PaintProbeCaptures(
                            toolWindow = captureComponentWithRetries(target.component, target.frame),
                            window = target.frame?.let { targetWindow ->
                                runCatching { captureWindowWithRetries(targetWindow) }
                                    .onFailure { error ->
                                        println(
                                            "MAGIC_JEWEL_IDE_BENCHMARK_WINDOW_PAINT_PROBE " +
                                                "status=failed error=${error::class.simpleName}:${error.message}",
                                        )
                                    }
                                    .getOrNull()
                            },
                        )
                    val path = Path.of(outDir, "toolwindow-paint-probe.png")
                    ImageIO.write(capture.toolWindow.image, "png", path.toFile())
                    logPaintCapture("MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE", capture.toolWindow, path)
                    capture.window?.let { windowCapture ->
                        val windowPath = Path.of(outDir, "window-paint-probe.png")
                        ImageIO.write(windowCapture.image, "png", windowPath.toFile())
                        logPaintCapture("MAGIC_JEWEL_IDE_BENCHMARK_WINDOW_PAINT_PROBE", windowCapture, windowPath)
                    }
                }
                .onFailure {
                    println("MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=failed error=${it::class.simpleName}:${it.message}")
                }
        }
    }

    private fun captureComponentWithRetries(component: Component, frame: Frame?): PaintCapture {
        return captureWithRetries("toolWindow") { captureComponent(component, frame) }
    }

    private fun captureWindowWithRetries(frame: Frame): PaintCapture =
        captureWithRetries("window") { captureWindow(frame) }

    private fun captureWithRetries(label: String, capture: () -> PaintCapture): PaintCapture {
        var lastError: Throwable? = null
        repeat(PAINT_PROBE_CAPTURE_ATTEMPTS) { index ->
            val attempt = index + 1
            runCatching { captureWithTimeout(capture) }
                .onSuccess {
                    if (attempt > 1) {
                        println(
                            "MAGIC_JEWEL_IDE_BENCHMARK_CAPTURE_ATTEMPT " +
                                "label=$label attempt=$attempt status=success",
                        )
                    }
                    return it
                }
                .onFailure { error ->
                    lastError = error
                    println(
                        "MAGIC_JEWEL_IDE_BENCHMARK_CAPTURE_ATTEMPT " +
                            "label=$label attempt=$attempt status=failed error=${error::class.simpleName}:${error.message}",
                    )
                    if (attempt < PAINT_PROBE_CAPTURE_ATTEMPTS) {
                        Thread.sleep(PAINT_PROBE_CAPTURE_RETRY_DELAY_MS)
                    }
                }
        }
        throw lastError ?: IllegalStateException("paint probe capture failed without an exception")
    }

    private fun captureWithTimeout(capture: () -> PaintCapture): PaintCapture {
        val executor = Executors.newSingleThreadExecutor()
        try {
            val future = executor.submit<PaintCapture> { capture() }
            return future.get(PAINT_PROBE_CAPTURE_TIMEOUT_MS, TimeUnit.MILLISECONDS)
        } catch (error: ExecutionException) {
            throw error.cause ?: error
        } catch (error: TimeoutException) {
            throw IllegalStateException("timed out after ${PAINT_PROBE_CAPTURE_TIMEOUT_MS}ms", error)
        } finally {
            executor.shutdownNow()
        }
    }

    private fun expectedPageTag(mode: BenchmarkMode): String =
        when (mode) {
            BenchmarkMode.Chat -> "magic.benchmark.page.chat"
            BenchmarkMode.Redraw -> "magic.benchmark.page.redraw"
            BenchmarkMode.Hypnotoad -> "magic.benchmark.page.hypnotoad"
        }

    private fun logPaintCapture(marker: String, capture: PaintCapture, path: Path) {
        println(
            "$marker " +
                "status=captured " +
                "width=${capture.image.width} " +
                "height=${capture.image.height} " +
                "sampled=${capture.sampledPixels} " +
                "dominantRgb=0x${capture.dominantRgb.toString(16).padStart(6, '0')} " +
                "dominantRatio=${String.format(Locale.US, "%.4f", capture.dominantRatio)} " +
                "distinct=${capture.distinctColors} " +
                "nonDominant=${capture.nonDominantPixels} " +
                "nonDominantRatio=${String.format(Locale.US, "%.4f", capture.nonDominantRatio)} " +
                "contentSampled=${capture.contentSampledPixels} " +
                "contentDominantRgb=0x${capture.contentDominantRgb.toString(16).padStart(6, '0')} " +
                "contentDominantRatio=${String.format(Locale.US, "%.4f", capture.contentDominantRatio)} " +
                "contentDistinct=${capture.contentDistinctColors} " +
                "contentNonDominant=${capture.contentNonDominantPixels} " +
                "contentNonDominantRatio=${String.format(Locale.US, "%.4f", capture.contentNonDominantRatio)} " +
                "path=$path",
        )
    }

    private fun captureComponent(component: Component, frame: Frame?): PaintCapture {
        val width = component.width.coerceAtLeast(1)
        val height = component.height.coerceAtLeast(1)
        val frameImage = frame?.let(::captureWindowImage)
        val image =
            if (frameImage != null) {
                val componentLocation = component.locationOnScreen
                val frameLocation = frame.locationOnScreen
                val scaleX = frameImage.width.toDouble() / frame.width.coerceAtLeast(1)
                val scaleY = frameImage.height.toDouble() / frame.height.coerceAtLeast(1)
                val crop =
                    Rectangle(
                        ((componentLocation.x - frameLocation.x) * scaleX).toInt(),
                        ((componentLocation.y - frameLocation.y) * scaleY).toInt(),
                        (width * scaleX).toInt().coerceAtLeast(1),
                        (height * scaleY).toInt().coerceAtLeast(1),
                    ).intersection(Rectangle(0, 0, frameImage.width, frameImage.height))
                frameImage.getSubimage(crop.x, crop.y, crop.width.coerceAtLeast(1), crop.height.coerceAtLeast(1))
            } else {
                throw IllegalStateException("Spectre window screenshot requires the toolwindow to have an AWT Frame ancestor")
            }
        return PaintCapture(
            image = image,
            stats = sampleImage(image),
            contentStats = sampleImage(
                image = image,
                region = Rectangle(width / 3, 0, width - width / 3, height),
            ),
        )
    }

    private fun captureWindow(frame: Frame): PaintCapture {
        val image = captureWindowImage(frame)
        return PaintCapture(
            image = image,
            stats = sampleImage(image),
            contentStats = sampleImage(
                image = image,
                region = Rectangle(image.width / 3, 0, image.width - image.width / 3, image.height),
            ),
        )
    }

    private fun captureWindowImage(frame: Frame): BufferedImage =
        AutoScreenshotter().captureWindow(frame.asTitledWindow())

    private fun logComponentBounds(label: String, component: Component, depth: Int, maxDepth: Int) {
        val location =
            runCatching { component.locationOnScreen }
                .getOrNull()
        println(
            "MAGIC_JEWEL_IDE_BENCHMARK_COMPONENT_BOUNDS " +
                "label=$label " +
                "depth=$depth " +
                "class=${component.javaClass.name} " +
                "x=${location?.x ?: -1} " +
                "y=${location?.y ?: -1} " +
                "width=${component.width} " +
                "height=${component.height} " +
                "showing=${component.isShowing}",
        )
        if (depth >= maxDepth || component !is Container) return
        component.components.forEachIndexed { index, child ->
            logComponentBounds("$label.$index", child, depth + 1, maxDepth)
        }
    }

    private fun sampleImage(
        image: BufferedImage,
        region: Rectangle = Rectangle(0, 0, image.width, image.height),
    ): PaintStats {
        val sampleRegion = region.intersection(Rectangle(0, 0, image.width, image.height))
        val strideX = (image.width / PAINT_PROBE_TARGET_SAMPLES_PER_AXIS).coerceAtLeast(1)
        val strideY = (image.height / PAINT_PROBE_TARGET_SAMPLES_PER_AXIS).coerceAtLeast(1)
        val histogram = HashMap<Int, Int>()
        var samples = 0
        var y = sampleRegion.y
        val maxY = sampleRegion.y + sampleRegion.height
        val maxX = sampleRegion.x + sampleRegion.width
        while (y < maxY) {
            var x = sampleRegion.x
            while (x < maxX) {
                val rgb = image.getRGB(x, y) and 0x00ffffff
                histogram[rgb] = (histogram[rgb] ?: 0) + 1
                samples += 1
                x += strideX
            }
            y += strideY
        }
        val dominant = histogram.maxByOrNull { it.value }
        val dominantRgb = dominant?.key ?: 0
        val dominantCount = dominant?.value ?: 0
        val nonDominant = samples - dominantCount
        return PaintStats(
            sampledPixels = samples,
            dominantRgb = dominantRgb,
            dominantRatio = dominantCount.toDouble() / samples.coerceAtLeast(1),
            distinctColors = histogram.size,
            nonDominantPixels = nonDominant,
            nonDominantRatio = nonDominant.toDouble() / samples.coerceAtLeast(1),
        )
    }

    private inline fun pollOnEdt(crossinline predicate: () -> Boolean): Boolean {
        check(!ApplicationManager.getApplication().isDispatchThread) {
            "pollOnEdt must not be called on the EDT"
        }
        val deadline = System.nanoTime() + POLL_BUDGET_MS * NANOS_PER_MILLI
        while (System.nanoTime() < deadline) {
            val matched = runOnEdt { runCatching { predicate() }.getOrDefault(false) }
            if (matched) return true
            Thread.sleep(POLL_INTERVAL_MS)
        }
        return false
    }

    private inline fun <T> runOnEdt(crossinline block: () -> T): T {
        if (ApplicationManager.getApplication().isDispatchThread) return block()
        var result: T? = null
        @Suppress("UNCHECKED_CAST")
        ApplicationManager.getApplication().invokeAndWait { result = block() }
        @Suppress("UNCHECKED_CAST")
        return result as T
    }

    private fun classSource(className: String): String =
        runCatching {
                val klass = Class.forName(className)
                val resourceName = className.replace('.', '/') + ".class"
                klass.classLoader?.getResource(resourceName)?.toString()
                    ?: klass.protectionDomain.codeSource?.location?.toString()
                    ?: "unknown"
            }
            .getOrElse { "missing:${it::class.simpleName}" }

    private companion object {
        const val POLL_BUDGET_MS: Long = 30_000
        const val POLL_INTERVAL_MS: Long = 50
        const val NANOS_PER_MILLI: Long = 1_000_000
        const val PAINT_PROBE_DELAY_MS: Long = 8_000
        const val PAINT_PROBE_FRONT_DELAY_MS: Long = 750
        const val PAINT_PROBE_CAPTURE_ATTEMPTS: Int = 4
        const val PAINT_PROBE_CAPTURE_RETRY_DELAY_MS: Long = 1_000
        const val PAINT_PROBE_CAPTURE_TIMEOUT_MS: Long = 5_000
        const val PAINT_PROBE_TARGET_SAMPLES_PER_AXIS: Int = 160
    }
}

private data class PaintProbeTarget(
    val component: Component,
    val frame: Frame?,
)

private data class PaintCapture(
    val image: BufferedImage,
    private val stats: PaintStats,
    private val contentStats: PaintStats,
) {
    val sampledPixels: Int = stats.sampledPixels
    val dominantRgb: Int = stats.dominantRgb
    val dominantRatio: Double = stats.dominantRatio
    val distinctColors: Int = stats.distinctColors
    val nonDominantPixels: Int = stats.nonDominantPixels
    val nonDominantRatio: Double = stats.nonDominantRatio
    val contentSampledPixels: Int = contentStats.sampledPixels
    val contentDominantRgb: Int = contentStats.dominantRgb
    val contentDominantRatio: Double = contentStats.dominantRatio
    val contentDistinctColors: Int = contentStats.distinctColors
    val contentNonDominantPixels: Int = contentStats.nonDominantPixels
    val contentNonDominantRatio: Double = contentStats.nonDominantRatio
}

private data class PaintProbeCaptures(
    val toolWindow: PaintCapture,
    val window: PaintCapture?,
)

private data class PaintStats(
    val sampledPixels: Int,
    val dominantRgb: Int,
    val dominantRatio: Double,
    val distinctColors: Int,
    val nonDominantPixels: Int,
    val nonDominantRatio: Double,
)
