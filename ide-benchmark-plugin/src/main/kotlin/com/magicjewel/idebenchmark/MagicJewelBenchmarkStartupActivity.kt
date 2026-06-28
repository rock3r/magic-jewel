package com.magicjewel.idebenchmark

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.openapi.wm.ToolWindowManager
import dev.sebastiano.spectre.core.ComposeAutomator
import dev.sebastiano.spectre.core.RobotDriver
import kotlin.concurrent.thread
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking

class MagicJewelBenchmarkStartupActivity : ProjectActivity {
    override suspend fun execute(project: Project) {
        if (System.getProperty("magic.jewel.benchmark.autorun") != "true") return
        val mode = BenchmarkMode.from(System.getProperty("magic.jewel.benchmark.mode"))
        println("MAGIC_JEWEL_IDE_BENCHMARK status=project-opened project=${project.name} mode=$mode")
        delay(2_000)
        activateBenchmarkToolWindow(project)
        thread(name = "magic-jewel-ide-benchmark-spectre", isDaemon = true) {
            runBlocking {
                delay(2_000)
                val frame = com.intellij.openapi.wm.WindowManager.getInstance().getFrame(project) ?: return@runBlocking
                val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.synthetic(frame))
                val tag = if (mode == BenchmarkMode.Chat) "magic.benchmark.page.chat" else "magic.benchmark.page.hypnotoad"
                automator.waitForNode(tag = tag, timeout = 30.seconds)
                println("MAGIC_JEWEL_IDE_BENCHMARK status=started mode=$mode")
                var cycle = 0
                while (true) {
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
                    println("MAGIC_JEWEL_IDE_BENCHMARK phase=tick mode=$mode cycle=$cycle")
                    cycle += 1
                    delay(150)
                }
            }
        }
    }

    private suspend fun activateBenchmarkToolWindow(project: Project) {
        val manager = ToolWindowManager.getInstance(project)
        repeat(30) {
            val toolWindow = manager.getToolWindow("JBR Skia Benchmark")
            if (toolWindow != null) {
                ApplicationManager.getApplication().invokeLater {
                    toolWindow.activate(null)
                    println("MAGIC_JEWEL_IDE_BENCHMARK status=tool-window-activated")
                }
                return
            }
            delay(500)
        }
        println("MAGIC_JEWEL_IDE_BENCHMARK status=tool-window-missing")
    }
}
