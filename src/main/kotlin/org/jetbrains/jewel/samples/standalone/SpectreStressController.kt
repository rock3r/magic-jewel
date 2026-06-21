package org.jetbrains.jewel.samples.standalone

import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
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
                automator.waitForNode(tag = "jewel.page.hypnotoad", timeout = 10.seconds)
                println("JEWEL_STANDALONE_SPECTRE status=started mode=$mode intervalMillis=$intervalMillis")
                if (mode.runsTour) {
                    runCatching { automator.runShowcaseTour(componentSlice) }
                        .onFailure { println("JEWEL_STANDALONE_SPECTRE status=tour-error message=${it.message}") }
                    selectTopLevelView("Hypnotoad")
                    automator.waitForNode(tag = "jewel.page.hypnotoad", timeout = 5.seconds)
                }

                var cycle = 0
                while (true) {
                    runCatching { automator.stressOnce(cycle) }
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

    private suspend fun ComposeAutomator.stressOnce(cycle: Int) {
        refreshWindows()
        when (cycle % 6) {
            0, 1, 2, 3 -> clickIfPresent("jewel.hypnotoad.warp", "hypnotoad-warp", cycle)
            4 -> clickIfPresent("jewel.hypnotoad.calm", "hypnotoad-calm", cycle)
            else -> clickIfPresent("jewel.hypnotoad.reset", "hypnotoad-reset", cycle)
        }
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

    private enum class SpectreStressMode(val runsTour: Boolean) {
        Hypnotoad(runsTour = false),
        TourThenHypnotoad(runsTour = true),
        FullShowcaseThenHypnotoad(runsTour = true);

        companion object {
            fun from(value: String): SpectreStressMode =
                when (value) {
                    "tourThenHypnotoad" -> TourThenHypnotoad
                    "fullShowcaseThenHypnotoad" -> FullShowcaseThenHypnotoad
                    else -> Hypnotoad
                }
        }
    }
}
