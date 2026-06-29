package com.magicjewel.idebenchmark

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.openapi.wm.ToolWindowManager
import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import java.awt.Component
import java.awt.Container
import java.awt.Rectangle
import java.awt.Robot
import java.awt.image.BufferedImage
import java.nio.file.Path
import java.util.Locale
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
                            maybeStartPaintProbe(project)
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
            val tag = if (mode == BenchmarkMode.Chat) "magic.benchmark.page.chat" else "magic.benchmark.page.hypnotoad"
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

    private fun maybeStartPaintProbe(project: Project) {
        if (System.getProperty("magic.jewel.benchmark.paintProbe") != "true") return
        val outDir = System.getProperty("magic.jewel.benchmark.out") ?: return
        ApplicationManager.getApplication().executeOnPooledThread {
            Thread.sleep(PAINT_PROBE_DELAY_MS)
            runCatching {
                    val capture =
                        runOnEdt {
                            val component =
                                ToolWindowManager.getInstance(project)
                                    .getToolWindow("JBR Skia Benchmark")
                                    ?.component
                            component?.takeIf { it.isShowing }?.let {
                                logComponentBounds("toolWindow", it, depth = 0, maxDepth = 4)
                                PaintProbeCaptures(
                                    toolWindow = captureComponent(it),
                                    window = SwingUtilities.getWindowAncestor(it)?.takeIf { window -> window.isShowing }?.let { window ->
                                        logComponentBounds("window", window, depth = 0, maxDepth = 2)
                                        captureComponent(window)
                                    },
                                )
                            }
                        }
                    if (capture == null) {
                        println("MAGIC_JEWEL_IDE_BENCHMARK_PAINT_PROBE status=missing-component")
                        return@runCatching
                    }
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
                "path=$path",
        )
    }

    private fun captureComponent(component: Component): PaintCapture {
        val width = component.width.coerceAtLeast(1)
        val height = component.height.coerceAtLeast(1)
        val location = component.locationOnScreen
        val image = Robot().createScreenCapture(Rectangle(location.x, location.y, width, height))
        return PaintCapture(image = image, stats = sampleImage(image))
    }

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

    private fun sampleImage(image: BufferedImage): PaintStats {
        val strideX = (image.width / PAINT_PROBE_TARGET_SAMPLES_PER_AXIS).coerceAtLeast(1)
        val strideY = (image.height / PAINT_PROBE_TARGET_SAMPLES_PER_AXIS).coerceAtLeast(1)
        val histogram = HashMap<Int, Int>()
        var samples = 0
        var y = 0
        while (y < image.height) {
            var x = 0
            while (x < image.width) {
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
        const val PAINT_PROBE_TARGET_SAMPLES_PER_AXIS: Int = 160
    }
}

private data class PaintCapture(
    val image: BufferedImage,
    private val stats: PaintStats,
) {
    val sampledPixels: Int = stats.sampledPixels
    val dominantRgb: Int = stats.dominantRgb
    val dominantRatio: Double = stats.dominantRatio
    val distinctColors: Int = stats.distinctColors
    val nonDominantPixels: Int = stats.nonDominantPixels
    val nonDominantRatio: Double = stats.nonDominantRatio
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
