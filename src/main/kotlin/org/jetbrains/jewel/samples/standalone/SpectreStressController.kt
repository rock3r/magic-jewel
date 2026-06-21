package org.jetbrains.jewel.samples.standalone

import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import javax.swing.JFrame
import kotlin.concurrent.thread
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking

internal object SpectreStressController {
    fun startIfRequested(frame: JFrame) {
        if (!java.lang.Boolean.getBoolean("jewel.standalone.spectreStress")) return

        val intervalMillis =
            System.getProperty("jewel.standalone.spectreStressIntervalMillis")?.toLongOrNull()
                ?.coerceAtLeast(50L)
                ?: 350L

        thread(name = "jewel-standalone-spectre-stress", isDaemon = true) {
            runBlocking {
                val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.synthetic(frame))
                automator.waitForNode(tag = "jewel.page.hypnotoad", timeout = 10.seconds)
                println("JEWEL_STANDALONE_SPECTRE status=started intervalMillis=$intervalMillis")

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
}
