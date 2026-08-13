package org.jetbrains.jewel.samples.standalone

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.awt.ComposePanel
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.GraphicsEnvironment
import javax.swing.JFrame
import javax.swing.SwingUtilities
import javax.swing.Timer
import kotlin.system.exitProcess
import org.jetbrains.jewel.foundation.LocalComponent
import org.jetbrains.jewel.foundation.enableNewSwingCompositing
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.intui.markdown.standalone.ProvideMarkdownStyling
import org.jetbrains.jewel.intui.standalone.theme.IntUiTheme
import org.jetbrains.jewel.intui.standalone.theme.createDefaultTextStyle
import org.jetbrains.jewel.intui.standalone.theme.createEditorTextStyle
import org.jetbrains.jewel.intui.standalone.theme.darkThemeDefinition
import org.jetbrains.jewel.intui.standalone.theme.default
import org.jetbrains.jewel.intui.standalone.theme.lightThemeDefinition
import org.jetbrains.jewel.samples.standalone.viewmodel.MainViewModel
import org.jetbrains.jewel.ui.ComponentStyling

@OptIn(ExperimentalLayoutApi::class)
public fun main() {
    enableNewSwingCompositing()
    SwingUtilities.invokeLater {
        val requestedWindowWidth = System.getProperty("jewel.standalone.windowWidth")?.toIntOrNull() ?: 1280
        val requestedWindowHeight = System.getProperty("jewel.standalone.windowHeight")?.toIntOrNull() ?: 840
        val targetDisplayWidth = System.getProperty("jewel.standalone.targetDisplayWidth")?.toIntOrNull()
        val targetDisplayHeight = System.getProperty("jewel.standalone.targetDisplayHeight")?.toIntOrNull()
        val targetDisplay =
            GraphicsEnvironment.getLocalGraphicsEnvironment().screenDevices.firstOrNull { device ->
                device.displayMode.width == targetDisplayWidth && device.displayMode.height == targetDisplayHeight
            }
        val maximizeWindow = java.lang.Boolean.getBoolean("jewel.standalone.maximizeWindow") ||
            java.lang.Boolean.getBoolean("jewel.standalone.maximized")
        val targetInternalDisplay = System.getProperty("jewel.standalone.displayTarget") == "internal"
        val internalDisplay =
            GraphicsEnvironment.getLocalGraphicsEnvironment().screenDevices.firstOrNull { device ->
                device.getIDstring().contains("built-in", ignoreCase = true) ||
                    device.getIDstring().contains("internal", ignoreCase = true)
            }
        val selectedDisplay = targetDisplay ?: if (targetInternalDisplay) internalDisplay else null
        val window =
            selectedDisplay?.defaultConfiguration?.let { graphicsConfiguration ->
                JFrame("JewelStandaloneJbrSkiaWindow", graphicsConfiguration)
            } ?: JFrame("JewelStandaloneJbrSkiaWindow")
        window.apply {
            defaultCloseOperation = JFrame.EXIT_ON_CLOSE
            minimumSize = Dimension(1100, 760)
            preferredSize = Dimension(requestedWindowWidth, requestedWindowHeight)
            contentPane.layout = BorderLayout()
            val composePanel =
                ComposePanel().apply {
                    setContent {
                        CompositionLocalProvider(LocalComponent provides this) {
                            val textStyle = JewelTheme.createDefaultTextStyle()
                            val editorStyle = JewelTheme.createEditorTextStyle()
                            val themeDefinition =
                                if (MainViewModel.theme.isDark()) {
                                    JewelTheme.darkThemeDefinition(
                                        defaultTextStyle = textStyle,
                                        editorTextStyle = editorStyle,
                                    )
                                } else {
                                    JewelTheme.lightThemeDefinition(
                                        defaultTextStyle = textStyle,
                                        editorTextStyle = editorStyle,
                                    )
                                }

                            IntUiTheme(
                                theme = themeDefinition,
                                styling = ComponentStyling.default(),
                                swingCompatMode = MainViewModel.swingCompat,
                            ) {
                                LaunchedEffect(MainViewModel.currentView.title) {
                                    println("JEWEL_STANDALONE_READY view=${MainViewModel.currentView.title}")
                                }
                                ProvideMarkdownStyling {
                                    MainViewModel.currentView.content()
                                }
                            }
                        }
                    }
                }
            contentPane.add(
                composePanel,
                BorderLayout.CENTER,
            )
            pack()
            selectedDisplay?.defaultConfiguration?.bounds?.let { bounds ->
                if (targetInternalDisplay) setLocation(bounds.x + 40, bounds.y + 40) else setLocation(bounds.x, bounds.y)
            } ?: setLocationRelativeTo(null)
            if (maximizeWindow) extendedState = JFrame.MAXIMIZED_BOTH
            isVisible = true
            Timer(250) {
                val transform = graphicsConfiguration.defaultTransform
                val pixelWidth = (width * transform.scaleX).toInt()
                val pixelHeight = (height * transform.scaleY).toInt()
                println(
                    "JEWEL_STANDALONE status=started pid=${ProcessHandle.current().pid()} " +
                        "view=${MainViewModel.currentView.title} width=$width height=$height " +
                        "backingScaleX=${transform.scaleX} backingScaleY=${transform.scaleY} " +
                        "pixelWidth=$pixelWidth pixelHeight=$pixelHeight pixelArea=${pixelWidth * pixelHeight} " +
                        "display=${graphicsConfiguration.device.getIDstring()}",
                )
                Thread {
                    repeat(100) {
                        val painterIdentity = System.getProperty("skiko.swing.painterIdentity")
                        val renderMode = System.getProperty("skiko.swing.renderMode")
                        if (painterIdentity != null && renderMode != null) {
                            println(
                                "MAGIC_JEWEL_PHASE0 status=started logicalWidth=${composePanel.width} logicalHeight=${composePanel.height} " +
                                    "backingScale=${transform.scaleX} pixelWidth=$pixelWidth pixelHeight=$pixelHeight " +
                                    "pixelArea=${pixelWidth.toLong() * pixelHeight} painterIdentity=$painterIdentity " +
                                    "renderMode=$renderMode requestedWindowWidth=$requestedWindowWidth " +
                                    "requestedWindowHeight=$requestedWindowHeight maximizeWindow=$maximizeWindow localSkikoSha256=" +
                                    System.getProperty("magic.jewel.localSkikoSha256", "unknown"),
                            )
                            return@Thread
                        }
                        Thread.sleep(50)
                    }
                }.apply {
                    isDaemon = true
                    name = "magic-jewel-phase0-identity-probe"
                    start()
                }
                SpectreStressController.startIfRequested(this)
                System.getProperty("jewel.standalone.autoExitSeconds")
                    ?.toIntOrNull()
                    ?.takeIf { it > 0 }
                    ?.let { seconds -> Timer(seconds * 1_000) { println("JEWEL_STANDALONE status=auto-exit seconds=$seconds"); exitProcess(0) }.apply { isRepeats = false; start() } }
            }.apply { isRepeats = false; start() }
        }
    }
}
