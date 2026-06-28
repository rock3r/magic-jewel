package com.magicjewel.idebenchmark

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.openapi.wm.ToolWindowManager
import dev.sebastiano.spectre.core.AutomatorNode
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking

class MagicJewelBenchmarkStartupActivity : ProjectActivity {
    override suspend fun execute(project: Project) {
        if (System.getProperty("magic.jewel.benchmark.autorun") != "true") return
        val mode = BenchmarkMode.from(System.getProperty("magic.jewel.benchmark.mode"))
        println("MAGIC_JEWEL_IDE_BENCHMARK status=project-opened project=${project.name} mode=$mode")
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

    private companion object {
        const val POLL_BUDGET_MS: Long = 30_000
        const val POLL_INTERVAL_MS: Long = 50
        const val NANOS_PER_MILLI: Long = 1_000_000
    }
}
