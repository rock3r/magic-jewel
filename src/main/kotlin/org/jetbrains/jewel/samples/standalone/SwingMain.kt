package org.jetbrains.jewel.samples.standalone

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.awt.ComposePanel
import java.awt.BorderLayout
import java.awt.Dimension
import javax.swing.JFrame
import javax.swing.SwingUtilities
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
            setLocationRelativeTo(null)
            isVisible = true
            SpectreStressController.startIfRequested(this)
        }
    }
}
