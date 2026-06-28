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
        delay(2_000)
        ApplicationManager.getApplication().invokeLater {
            ToolWindowManager.getInstance(project).getToolWindow("JBR Skia Benchmark")?.activate(null)
        }
        thread(name = "magic-jewel-ide-benchmark-spectre", isDaemon = true) {
            runBlocking {
                delay(2_000)
                val frame = com.intellij.openapi.wm.WindowManager.getInstance().getFrame(project) ?: return@runBlocking
                val automator = ComposeAutomator.inProcess(robotDriver = RobotDriver.synthetic(frame))
                val mode = BenchmarkMode.from(System.getProperty("magic.jewel.benchmark.mode"))
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
}
