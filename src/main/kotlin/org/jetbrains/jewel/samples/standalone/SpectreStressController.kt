package org.jetbrains.jewel.samples.standalone

import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import java.awt.Robot
import java.util.concurrent.atomic.AtomicBoolean
import javax.swing.JFrame
import javax.swing.SwingUtilities
import kotlin.concurrent.thread
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import org.jetbrains.jewel.samples.standalone.viewmodel.MainViewModel

internal object SpectreStressController {
    private val TourWaitTimeout = 60.seconds
    private val started = AtomicBoolean(false)

    fun startIfRequested(frame: JFrame) {
        if (!java.lang.Boolean.getBoolean("jewel.standalone.spectreStress")) return
        if (!started.compareAndSet(false, true)) return

        val intervalMillis =
            System.getProperty("jewel.standalone.spectreStressIntervalMillis")?.toLongOrNull()
                ?.coerceAtLeast(50L)
                ?: 350L
        val mode = SpectreStressMode.from(System.getProperty("jewel.standalone.spectreStressMode", "hypnotoad"))
        val componentSlice = System.getProperty("jewel.standalone.spectreComponents", "")
            .split(',')
            .map { it.trim() }
            .filter { it.isNotEmpty() }

        thread(name = "jewel-standalone-spectre-stress", isDaemon = true) {
            runBlocking {
                val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.synthetic(frame))
                val startupTag =
                    when (mode) {
                        SpectreStressMode.IdleRedraw -> "jewel.page.idle-redraw"
                        SpectreStressMode.MarkdownWheel -> "jewel.page.markdown"
                        SpectreStressMode.TooltipHover -> "jewel.tooltip.hoverTarget"
                        SpectreStressMode.MenuPopup -> "jewel.menu.basic"
                        else -> "jewel.page.hypnotoad"
                    }
                automator.waitForNode(tag = startupTag, timeout = 10.seconds)
                println("JEWEL_STANDALONE_SPECTRE status=started mode=$mode intervalMillis=$intervalMillis")
                when (mode) {
                    SpectreStressMode.IdleRedraw -> Unit
                    SpectreStressMode.TourThenHypnotoad,
                    SpectreStressMode.FullShowcaseThenHypnotoad -> {
                        runCatching { automator.runShowcaseTour(componentSlice) }
                            .onFailure { println("JEWEL_STANDALONE_SPECTRE status=tour-error message=${it.message}") }
                        selectTopLevelView("Hypnotoad")
                        automator.waitForNode(tag = "jewel.page.hypnotoad", timeout = 5.seconds)
                    }
                    SpectreStressMode.MarkdownWheel -> {
                        selectTopLevelView("Markdown")
                        automator.waitForNode(tag = "jewel.page.markdown", timeout = TourWaitTimeout)
                        println("JEWEL_STANDALONE_SPECTRE phase=focused-view target=Markdown")
                    }
                    SpectreStressMode.TooltipHover -> {
                        selectTopLevelView("Components")
                        selectComponentView("Tooltips")
                        automator.waitForNode(tag = "jewel.tooltip.hoverTarget", timeout = TourWaitTimeout)
                        println("JEWEL_STANDALONE_SPECTRE phase=focused-component target=Tooltips")
                    }
                    SpectreStressMode.MenuPopup -> {
                        selectTopLevelView("Components")
                        selectComponentView("Menus")
                        automator.waitForNode(tag = "jewel.menu.basic", timeout = TourWaitTimeout)
                        println("JEWEL_STANDALONE_SPECTRE phase=focused-component target=Menus")
                    }
                    SpectreStressMode.Hypnotoad -> Unit
                }

                var cycle = 0
                while (true) {
                    runCatching { automator.stressOnce(mode, cycle) }
                        .onFailure { println("JEWEL_STANDALONE_SPECTRE status=error message=${it.message}") }
                    cycle += 1
                    delay(intervalMillis.milliseconds)
                }
            }
        }
    }

    private suspend fun ComposeAutomator.runShowcaseTour(componentSlice: List<String>) {
        selectTopLevelView("Welcome")
        waitForNode(tag = "jewel.page.welcome", timeout = TourWaitTimeout)
        println("JEWEL_STANDALONE_SPECTRE phase=tour-view target=Welcome")
        delay(500.milliseconds)

        val allComponentTourStops = MainViewModel.componentsViewModel.getViews().map { it.title }
        val includeMarkdown = componentSlice.any { it == "Markdown" }
        val componentTourStops =
            if (componentSlice.isEmpty()) {
                allComponentTourStops
            } else {
                componentSlice.filter { it in allComponentTourStops }
            }
        if (componentSlice.isEmpty() || componentTourStops.isNotEmpty()) {
            selectTopLevelView("Components")
            waitForNode(text = "Buttons", timeout = TourWaitTimeout)
            componentTourStops.forEach { title ->
                selectComponentView(title)
                waitForNode(text = title, timeout = TourWaitTimeout)
                println("JEWEL_STANDALONE_SPECTRE phase=tour-component target=$title")
                delay(500.milliseconds)
            }
        }

        if (componentSlice.isEmpty() || includeMarkdown) {
            selectTopLevelView("Markdown")
            println("JEWEL_STANDALONE_SPECTRE phase=tour-view target=Markdown")
            delay(2.seconds)
        }

        selectTopLevelView("Hypnotoad")
        waitForNode(tag = "jewel.page.hypnotoad", timeout = TourWaitTimeout)
        println("JEWEL_STANDALONE_SPECTRE phase=tour-view target=Hypnotoad")
        println("JEWEL_STANDALONE_SPECTRE status=tour-complete")
    }

    private fun selectTopLevelView(title: String) {
        onEdt {
            MainViewModel.currentView = MainViewModel.views.first { it.title == title }
        }
    }

    private fun selectComponentView(title: String) {
        onEdt {
            val view = MainViewModel.componentsViewModel.getViews().first { it.title == title }
            MainViewModel.componentsViewModel.setCurrentView(view)
        }
    }

    private suspend fun ComposeAutomator.stressOnce(mode: SpectreStressMode, cycle: Int) {
        refreshWindows()
        when (mode) {
            SpectreStressMode.IdleRedraw -> Unit
            SpectreStressMode.MarkdownWheel -> scrollMarkdownOnce(cycle)
            SpectreStressMode.TooltipHover -> hoverTooltipOnce(cycle)
            SpectreStressMode.MenuPopup -> openMenuOnce(cycle)
            else ->
                when (cycle % 6) {
                    0, 1, 2, 3 -> clickIfPresent("jewel.hypnotoad.warp", "hypnotoad-warp", cycle)
                    4 -> clickIfPresent("jewel.hypnotoad.calm", "hypnotoad-calm", cycle)
                    else -> clickIfPresent("jewel.hypnotoad.reset", "hypnotoad-reset", cycle)
                }
        }
    }

    private suspend fun ComposeAutomator.scrollMarkdownOnce(cycle: Int) {
        val node = findOneByTestTag("jewel.page.markdown") ?: return
        val ticks = if ((cycle / 10) % 2 == 0) 7 else -7
        scrollWheel(node, ticks)
        println("JEWEL_STANDALONE_SPECTRE phase=markdown-scroll cycle=$cycle ticks=$ticks")
    }

    private suspend fun ComposeAutomator.hoverTooltipOnce(cycle: Int) {
        val node = findOneByTestTag("jewel.tooltip.hoverTarget") ?: return
        val center = node.centerOnScreen
        Robot().mouseMove(center.x, center.y)
        delay(250.milliseconds)
        println("JEWEL_STANDALONE_SPECTRE phase=tooltip-hover cycle=$cycle")
    }

    private suspend fun ComposeAutomator.openMenuOnce(cycle: Int) {
        if (cycle > 0) return
        val node: AutomatorNode = findOneByTestTag("jewel.menu.basic") ?: return
        val center = node.centerOnScreen
        Robot().mouseMove(center.x, center.y)
        click(node)
        delay(250.milliseconds)
        println("JEWEL_STANDALONE_SPECTRE phase=menu-popup cycle=$cycle target=basic")
    }

    private suspend fun ComposeAutomator.clickIfPresent(tag: String, phase: String, cycle: Int) {
        val node: AutomatorNode = findOneByTestTag(tag) ?: return
        performSemanticsClick(node)
        println("JEWEL_STANDALONE_SPECTRE phase=$phase cycle=$cycle")
    }

    private fun onEdt(action: () -> Unit) {
        if (SwingUtilities.isEventDispatchThread()) {
            action()
        } else {
            SwingUtilities.invokeAndWait(action)
        }
    }

    private enum class SpectreStressMode {
        IdleRedraw,
        Hypnotoad,
        MarkdownWheel,
        TooltipHover,
        MenuPopup,
        TourThenHypnotoad,
        FullShowcaseThenHypnotoad;

        companion object {
            fun from(value: String): SpectreStressMode =
                when (value) {
                    "idleRedraw" -> IdleRedraw
                    "markdownScroll", "markdownWheel" -> MarkdownWheel
                    "tooltipHover" -> TooltipHover
                    "menuPopup" -> MenuPopup
                    "tourThenHypnotoad" -> TourThenHypnotoad
                    "fullShowcaseThenHypnotoad" -> FullShowcaseThenHypnotoad
                    else -> Hypnotoad
                }
        }
    }
}
