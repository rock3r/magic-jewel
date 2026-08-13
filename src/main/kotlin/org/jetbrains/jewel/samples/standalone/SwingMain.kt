package org.jetbrains.jewel.samples.standalone

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.awt.ComposePanel
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.GraphicsEnvironment
import javax.swing.Timer
import javax.swing.JFrame
import javax.swing.SwingUtilities
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
        JFrame("JewelStandaloneJbrSkiaWindow").apply {
            defaultCloseOperation = JFrame.EXIT_ON_CLOSE
            minimumSize = Dimension(1100, 760)
            preferredSize = Dimension(1280, 840)
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
            val targetInternalDisplay = System.getProperty("jewel.standalone.displayTarget") == "internal"
            if (targetInternalDisplay) {
                GraphicsEnvironment.getLocalGraphicsEnvironment().screenDevices
                    .firstOrNull { it.getIDstring().contains("built-in", ignoreCase = true) || it.getIDstring().contains("internal", ignoreCase = true) }
                    ?.defaultConfiguration
                    ?.bounds
                    ?.let { bounds -> setLocation(bounds.x + 40, bounds.y + 40) }
            }
            if (!targetInternalDisplay) setLocationRelativeTo(null)
            isVisible = true
            if (java.lang.Boolean.getBoolean("jewel.standalone.maximized")) extendedState = JFrame.MAXIMIZED_BOTH
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
                SpectreStressController.startIfRequested(this)
                System.getProperty("jewel.standalone.autoExitSeconds")
                    ?.toIntOrNull()
                    ?.takeIf { it > 0 }
                    ?.let { seconds -> Timer(seconds * 1_000) { println("JEWEL_STANDALONE status=auto-exit seconds=$seconds"); exitProcess(0) }.apply { isRepeats = false; start() } }
            }.apply { isRepeats = false; start() }
        }
    }
}
