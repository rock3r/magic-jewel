package org.jetbrains.jewel.samples.standalone.markdown

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.ScrollableState
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import coil3.compose.LocalPlatformContext
import java.awt.Desktop.getDesktop
import java.net.URI.create
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import kotlin.time.Duration.Companion.milliseconds
import org.jetbrains.jewel.foundation.code.highlighting.NoOpCodeHighlighter
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.intui.markdown.standalone.ProvideMarkdownStyling
import org.jetbrains.jewel.intui.markdown.standalone.dark
import org.jetbrains.jewel.intui.markdown.standalone.light
import org.jetbrains.jewel.intui.markdown.standalone.styling.dark
import org.jetbrains.jewel.intui.markdown.standalone.styling.extensions.github.alerts.dark
import org.jetbrains.jewel.intui.markdown.standalone.styling.extensions.github.alerts.light
import org.jetbrains.jewel.intui.markdown.standalone.styling.extensions.github.tables.dark
import org.jetbrains.jewel.intui.markdown.standalone.styling.extensions.github.tables.light
import org.jetbrains.jewel.intui.markdown.standalone.styling.light
import org.jetbrains.jewel.markdown.LazyMarkdown
import org.jetbrains.jewel.markdown.MarkdownBlock
import org.jetbrains.jewel.markdown.extensions.autolink.AutolinkProcessorExtension
import org.jetbrains.jewel.markdown.extensions.github.alerts.AlertStyling
import org.jetbrains.jewel.markdown.extensions.github.alerts.GitHubAlertProcessorExtension
import org.jetbrains.jewel.markdown.extensions.github.alerts.GitHubAlertRendererExtension
import org.jetbrains.jewel.markdown.extensions.github.strikethrough.GitHubStrikethroughProcessorExtension
import org.jetbrains.jewel.markdown.extensions.github.strikethrough.GitHubStrikethroughRendererExtension
import org.jetbrains.jewel.markdown.extensions.github.tables.GfmTableStyling
import org.jetbrains.jewel.markdown.extensions.github.tables.GitHubTableProcessorExtension
import org.jetbrains.jewel.markdown.extensions.github.tables.GitHubTableRendererExtension
import org.jetbrains.jewel.markdown.extensions.images.Coil3ImageRendererExtension
import org.jetbrains.jewel.markdown.processing.MarkdownProcessor
import org.jetbrains.jewel.markdown.rendering.MarkdownBlockRenderer
import org.jetbrains.jewel.markdown.rendering.MarkdownStyling
import org.jetbrains.jewel.ui.component.VerticallyScrollableContainer
import org.jetbrains.jewel.ui.component.scrollbarContentSafePadding

@Composable
internal fun MarkdownPreview(rawMarkdown: CharSequence, modifier: Modifier = Modifier) {
    val isDark = JewelTheme.isDark
    val instanceUuid = JewelTheme.instanceUuid

    val markdownStyling = remember(instanceUuid) { if (isDark) MarkdownStyling.dark() else MarkdownStyling.light() }

    var markdownBlocks by remember { mutableStateOf(emptyList<MarkdownBlock>()) }

    // We are doing this here for the sake of simplicity.
    // In a real-world scenario you would be doing this outside your Composables,
    // potentially involving ViewModels, dependency injection, etc.
    val processor = remember {
        MarkdownProcessor(
            listOf(
                AutolinkProcessorExtension,
                GitHubAlertProcessorExtension,
                GitHubStrikethroughProcessorExtension(),
                GitHubTableProcessorExtension,
            )
        )
    }

    val coilContext = LocalPlatformContext.current
    val coil3ImageRendererExtension = remember(coilContext) { Coil3ImageRendererExtension.withDefaultLoader(coilContext) }

    LaunchedEffect(rawMarkdown) {
        // TODO you may want to debounce or drop on backpressure, in real usages. You should also
        // not do this
        //  in the UI to begin with.
        @Suppress("InjectDispatcher") // This should never go in the composable IRL
        markdownBlocks =
            withContext(Dispatchers.Default) {
                processor.processMarkdownDocument(rawMarkdown.toString().withStableBadgeLinks())
            }
    }

    val blockRenderer =
        remember(markdownStyling) {
            if (isDark) {
                MarkdownBlockRenderer.dark(
                    styling = markdownStyling,
                    rendererExtensions =
                        listOf(
                            coil3ImageRendererExtension,
                            GitHubAlertRendererExtension(AlertStyling.dark(), markdownStyling),
                            GitHubStrikethroughRendererExtension,
                            GitHubTableRendererExtension(GfmTableStyling.dark(), markdownStyling),
                        ),
                )
            } else {
                MarkdownBlockRenderer.light(
                    styling = markdownStyling,
                    rendererExtensions =
                        listOf(
                            coil3ImageRendererExtension,
                            GitHubAlertRendererExtension(AlertStyling.light(), markdownStyling),
                            GitHubStrikethroughRendererExtension,
                            GitHubTableRendererExtension(GfmTableStyling.light(), markdownStyling),
                        ),
                )
            }
        }

    // Using the values from the GitHub rendering to ensure contrast
    val background = remember(instanceUuid) { if (isDark) Color(0xff0d1117) else Color.White }

    ProvideMarkdownStyling(markdownStyling, blockRenderer, NoOpCodeHighlighter) {
        val lazyListState = rememberLazyListState()
        val autoScroll = remember {
            java.lang.Boolean.getBoolean("jewel.standalone.markdownAutoScroll") ||
                System.getProperty("jewel.standalone.spectreStressMode") == "markdownAutoScroll"
        }
        LaunchedEffect(autoScroll, markdownBlocks.size) {
            if (autoScroll && markdownBlocks.isNotEmpty()) {
                var index = 0
                var direction = 1
                while (true) {
                    lazyListState.animateScrollToItem(index)
                    println("JEWEL_STANDALONE_MARKDOWN_AUTO_SCROLL index=$index")
                    delay(120.milliseconds)
                    val lastIndex = (markdownBlocks.size - 1).coerceAtLeast(0)
                    if (index >= lastIndex) direction = -1
                    if (index <= 0) direction = 1
                    index = (index + direction * 3).coerceIn(0, lastIndex)
                }
            }
        }
        VerticallyScrollableContainer(lazyListState as ScrollableState, modifier.background(background)) {
            LazyMarkdown(
                blocks = markdownBlocks,
                modifier = Modifier.background(background),
                contentPadding =
                    PaddingValues(start = 8.dp, top = 8.dp, end = 8.dp + scrollbarContentSafePadding(), bottom = 8.dp),
                state = lazyListState,
                selectable = true,
                onUrlClick = { url: String -> getDesktop().browse(create(url)) },
            )
        }
    }
}

internal fun String.withStableBadgeLinks(): String =
    withoutReadmeBadgeImages()
        .withoutEmbeddedBadgeLogoDataUrls()
        .withoutReadmeHtmlLayoutHints()
        .replace(Regex("""\[!\[([^]]+)]\((https://img\.shields\.io/[^)]*)\)]\(([^)]*)\)""")) {
            "[${it.groupValues[1]}](${it.groupValues[3]})"
        }
        .replace(Regex("""!\[([^]]+)]\((https://img\.shields\.io/[^)]*)\)""")) {
            "[${it.groupValues[1]}](${it.groupValues[2]})"
        }

internal fun String.withoutReadmeBadgeImages(): String =
    lineSequence()
        .map { line ->
            if (line.contains("https://img.shields.io/")) "" else line
        }
        .joinToString("\n")

private fun String.withoutReadmeHtmlLayoutHints(): String = replace(Regex("""<br\s+clear="left"\s*/>"""), "")

private fun String.withoutEmbeddedBadgeLogoDataUrls(): String =
    replace(Regex("""([?&])logo=data(?::|%3A)[^)\s&]+""")) { match ->
        if (match.groupValues[1] == "?") "?" else ""
    }
        .replace("?&", "?")
        .replace(Regex("""\?(?=\))"""), "")
