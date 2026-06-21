package org.jetbrains.jewel.samples.standalone.view

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.isTraversalGroup
import androidx.compose.ui.semantics.semantics
import org.jetbrains.jewel.foundation.modifier.trackActivation
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.markdown.MarkdownMode
import org.jetbrains.jewel.markdown.WithMarkdownMode
import org.jetbrains.jewel.samples.standalone.markdown.JewelReadme
import org.jetbrains.jewel.samples.standalone.markdown.MarkdownCatalog
import org.jetbrains.jewel.samples.standalone.markdown.MarkdownEditor
import org.jetbrains.jewel.samples.standalone.markdown.MarkdownPreview
import org.jetbrains.jewel.ui.Orientation
import org.jetbrains.jewel.ui.component.Divider

private val InitialMarkdown: String =
    when (System.getProperty("jewel.standalone.markdownContent", "readme80")) {
        "readme20" -> JewelReadme.lineSequence().take(20).joinToString("\n")
        "readme40" -> JewelReadme.lineSequence().take(40).joinToString("\n")
        "readme160" -> JewelReadme.lineSequence().take(160).joinToString("\n")
        "catalog" -> MarkdownCatalog
        "catalogHead" -> MarkdownCatalog.lineSequence().take(120).joinToString("\n")
        else -> JewelReadme.lineSequence().take(80).joinToString("\n")
    }

@Composable
internal fun MarkdownDemo() {
    val modifier =
        Modifier.trackActivation()
            .fillMaxSize()
            .testTag("jewel.page.markdown")
            .background(JewelTheme.globalColors.panelBackground)
            .semantics { isTraversalGroup = true }

    WithMarkdownMode(MarkdownMode.EditorPreview(scrollingSynchronizer = null)) {
        val editorState = rememberTextFieldState(InitialMarkdown)
        if (java.lang.Boolean.getBoolean("jewel.standalone.markdownPreviewOnly")) {
            Box(modifier) {
                MarkdownPreview(modifier = Modifier.fillMaxSize(), rawMarkdown = editorState.text)
            }
            return@WithMarkdownMode
        }

        Row(modifier) {
            MarkdownEditor(state = editorState, modifier = Modifier.fillMaxHeight().weight(1f))

            Divider(Orientation.Vertical, Modifier.fillMaxHeight())

            MarkdownPreview(modifier = Modifier.fillMaxHeight().weight(1f), rawMarkdown = editorState.text)
        }
    }
}
