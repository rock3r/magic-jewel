package com.magicjewel.idebenchmark.smoke

import com.intellij.driver.sdk.waitForIndicators
import com.intellij.driver.sdk.waitForProjectOpen
import com.intellij.ide.starter.driver.engine.runIdeWithDriver
import com.intellij.ide.starter.ide.IdeProductProvider
import com.intellij.ide.starter.junit5.hyphenateWithClass
import com.intellij.ide.starter.models.TestCase
import com.intellij.ide.starter.plugins.PluginConfigurator
import com.intellij.ide.starter.project.LocalProjectInfo
import com.intellij.ide.starter.runner.CurrentTestMethod
import com.intellij.ide.starter.runner.IDERunContext
import com.intellij.ide.starter.runner.Starter
import java.nio.file.Path
import java.util.concurrent.atomic.AtomicReference
import kotlin.io.path.exists
import kotlin.io.path.readText
import kotlin.time.Duration.Companion.minutes
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class MagicJewelBenchmarkIdeSmokeTest {

    @Test
    fun starterLaunchesProjectAndPluginSpectreDrivesBenchmarkUi() {
        val pluginPath = pluginZipPath()
        val projectPath = benchmarkProjectPath()
        val capturedRunContext = AtomicReference<IDERunContext>()

        Starter.newContext(
                CurrentTestMethod.hyphenateWithClass(),
                TestCase(
                    IdeProductProvider.IU.copy(
                        buildType = "release",
                        buildNumber = IDE_BUILD_NUMBER,
                    ),
                    LocalProjectInfo(projectPath),
                ),
            )
            .apply { PluginConfigurator(this).installPluginFromPath(pluginPath) }
            .applyVMOptionsPatch {
                addSystemProperty("idea.trust.all.projects", true)
                addSystemProperty("jetbrainsd.discovery.enabled", false)
                addSystemProperty("jetbrainsd.uri.handling.enabled", false)
                addSystemProperty("magic.jewel.benchmark.autorun", true)
                addSystemProperty("magic.jewel.benchmark.mode", "chat")
                setIdeStartupDialogEnabled(false)
                setNeverShowInitConfigModal()
                disableNewUsersOnboardingDialogue()
                addSystemProperty("ide.experimental.ui.onboarding", false)
            }
            .skipIndicesInitialization()
            .runIdeWithDriver(configure = { capturedRunContext.set(this) })
            .useDriverAndCloseIde {
                val ideLog =
                    requireNotNull(capturedRunContext.get()) {
                            "IDERunContext was not captured before the IDE process started"
                        }
                        .logsDir
                        .resolve("idea.log")

                waitForProjectOpen(timeout = PROJECT_OPEN_TIMEOUT)
                waitForIndicators(timeout = INDICATOR_QUIESCENCE_TIMEOUT)

                val captured = waitForBenchmarkLog(ideLog)
                EXPECTED_MARKERS.forEach { marker ->
                    assertTrue(captured.any { it.contains(marker) }) {
                        "Expected marker `$marker` in $ideLog but did not find it. Captured:\n" +
                            captured.joinToString("\n")
                    }
                }
            }
    }

    private fun pluginZipPath(): Path {
        val raw =
            requireNotNull(System.getProperty("path.to.build.plugin")) {
                "System property `path.to.build.plugin` is not set"
            }
        return Path.of(raw).also { path ->
            require(path.exists()) { "Plugin zip does not exist: $path" }
        }
    }

    private fun benchmarkProjectPath(): Path {
        val raw =
            requireNotNull(System.getProperty("magic.jewel.benchmark.project.path")) {
                "System property `magic.jewel.benchmark.project.path` is not set"
            }
        return Path.of(raw).toRealPath()
    }

    private fun waitForBenchmarkLog(logPath: Path): List<String> {
        val deadline = System.currentTimeMillis() + LOG_POLL_DEADLINE_MS
        var captured: List<String> = emptyList()
        while (System.currentTimeMillis() < deadline) {
            captured =
                if (logPath.exists()) {
                    logPath.readText().lineSequence().filter { it.contains("MAGIC_JEWEL_IDE_BENCHMARK") }.toList()
                } else {
                    emptyList()
                }
            if (EXPECTED_MARKERS.all { marker -> captured.any { it.contains(marker) } }) {
                return captured
            }
            Thread.sleep(POLL_INTERVAL_MS)
        }
        return captured
    }

    private companion object {
        const val IDE_BUILD_NUMBER = "261.23567.138"
        const val LOG_POLL_DEADLINE_MS: Long = 60_000
        const val POLL_INTERVAL_MS: Long = 250
        val PROJECT_OPEN_TIMEOUT = 5.minutes
        val INDICATOR_QUIESCENCE_TIMEOUT = 3.minutes
        val EXPECTED_MARKERS =
            listOf(
                "status=project-opened",
                "status=tool-window-activated",
                "status=started",
                "phase=tick",
            )
    }
}
