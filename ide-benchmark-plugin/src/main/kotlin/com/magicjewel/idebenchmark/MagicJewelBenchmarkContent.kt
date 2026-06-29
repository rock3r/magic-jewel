package com.magicjewel.idebenchmark

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.withTransform
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.min
import kotlin.math.sin
import org.jetbrains.jewel.foundation.ExperimentalJewelApi
import org.jetbrains.jewel.intui.markdown.bridge.create
import org.jetbrains.jewel.intui.markdown.bridge.styling.create
import org.jetbrains.jewel.markdown.LazyMarkdown
import org.jetbrains.jewel.markdown.rendering.MarkdownBlockRenderer
import org.jetbrains.jewel.markdown.rendering.MarkdownStyling
import org.jetbrains.jewel.ui.component.DefaultButton
import org.jetbrains.jewel.ui.component.OutlinedButton
import org.jetbrains.jewel.ui.component.Text

@Composable
internal fun MagicJewelBenchmarkContent() {
    val presenter =
        remember {
            MagicJewelBenchmarkPresenter(BenchmarkMode.from(System.getProperty("magic.jewel.benchmark.mode")))
        }
    DisposableEffect(presenter) {
        onDispose { presenter.close() }
    }
    val state by presenter.state.collectAsState()
    Column(Modifier.fillMaxSize().testTag("magic.benchmark.root")) {
        Row(Modifier.fillMaxWidth().padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            DefaultButton(
                onClick = { presenter.setMode(BenchmarkMode.Hypnotoad) },
                modifier = Modifier.testTag("magic.benchmark.hypnotoad"),
            ) {
                Text("Hypnotoad")
            }
            DefaultButton(
                onClick = { presenter.setMode(BenchmarkMode.Chat) },
                modifier = Modifier.testTag("magic.benchmark.chat"),
            ) {
                Text("Streaming chat")
            }
            DefaultButton(
                onClick = { presenter.setMode(BenchmarkMode.Redraw) },
                modifier = Modifier.testTag("magic.benchmark.redraw"),
            ) {
                Text("Simple redraw")
            }
        }
        when (state.mode) {
            BenchmarkMode.Hypnotoad -> IdeHypnotoad(
                intensity = state.hypnotoadIntensity,
                onWarp = presenter::increaseHypnotoadIntensity,
                onReset = presenter::resetHypnotoadIntensity,
                onCalm = presenter::decreaseHypnotoadIntensity,
            )
            BenchmarkMode.Chat -> StreamingMarkdownChat(state)
            BenchmarkMode.Redraw -> SimpleRedraw(state)
        }
    }
}

@Composable
private fun IdeHypnotoad(
    intensity: Int,
    onWarp: () -> Unit,
    onReset: () -> Unit,
    onCalm: () -> Unit,
) {
    val transition = rememberInfiniteTransition(label = "ide-hypnotoad")
    val phase by transition.animateFloat(0f, 1f, infiniteRepeatable(tween(3600, easing = LinearEasing)), label = "phase")
    val pulse by
        transition.animateFloat(
            0f,
            1f,
            infiniteRepeatable(tween(900, easing = LinearEasing), repeatMode = RepeatMode.Reverse),
            label = "pulse",
        )

    Box(Modifier.fillMaxSize().testTag("magic.benchmark.page.hypnotoad")) {
        Canvas(Modifier.fillMaxWidth().height(720.dp)) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val short = min(size.width, size.height)
            drawRect(Color(0xFF090014), size = size)
            repeat(9) { ring ->
                drawCircle(
                    color = palette[(ring + (phase * 20f).toInt()) % palette.size],
                    radius = short * (0.08f + ring * 0.052f + pulse * 0.01f + intensity * 0.004f),
                    center = center,
                    style = Stroke(width = 18f + ring * 1.7f, cap = StrokeCap.Round),
                    alpha = 0.72f,
                )
            }
            repeat(42 + intensity * 4) { index ->
                val t = phase * 2f * PI.toFloat() + index * 0.37f
                val orbit = short * (0.09f + (index % 11) * 0.027f)
                val p = Offset(center.x + cos(t) * orbit, center.y + sin(t * 1.21f) * orbit * 0.72f)
                rotate(degrees = phase * 360f + index * 23f, pivot = p) {
                    drawOval(
                        color = palette[(index + (phase * 30f).toInt()) % palette.size],
                        topLeft = Offset(p.x - 80f, p.y - 24f),
                        size = Size(160f, 48f),
                        alpha = 0.46f,
                    )
                }
            }
            repeat(5) { layer ->
                val path = Path()
                val points = 180
                for (i in 0..points) {
                    val angle = i / points.toFloat() * 2f * PI.toFloat()
                    val wave = sin(angle * (3 + layer) + phase * 2f * PI.toFloat() * (1f + layer * 0.13f))
                    val radius = short * (0.16f + layer * 0.052f) + wave * short * 0.026f
                    val p = Offset(center.x + cos(angle) * radius, center.y + sin(angle) * radius)
                    if (i == 0) path.moveTo(p.x, p.y) else path.lineTo(p.x, p.y)
                }
                path.close()
                withTransform({ rotate(phase * 180f * (layer + 1), center) }) {
                    drawPath(path, palette[layer], style = Stroke(width = 3f + layer), alpha = 0.78f)
                }
            }
        }
        Row(Modifier.align(Alignment.BottomCenter).padding(bottom = 24.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton(onWarp, Modifier.testTag("magic.benchmark.hypnotoad.warp")) { Text("Warp") }
            DefaultButton(onReset, Modifier.testTag("magic.benchmark.hypnotoad.reset")) { Text("Reset") }
            OutlinedButton(onCalm, Modifier.testTag("magic.benchmark.hypnotoad.calm")) { Text("Calm") }
        }
    }
}

@Composable
@OptIn(ExperimentalJewelApi::class)
private fun StreamingMarkdownChat(state: MagicJewelBenchmarkUiState) {
    val listState = rememberLazyListState()
    val markdownStyling = remember { MarkdownStyling.create() }
    val markdownRenderer = remember(markdownStyling) { MarkdownBlockRenderer.create(styling = markdownStyling) }
    LaunchedEffect(state.streamingMarkdownBlocks.size, state.streamingToken) {
        if (state.streamingMarkdownBlocks.isNotEmpty()) {
            listState.animateScrollToItem((state.streamingMarkdownBlocks.size - 1).coerceAtLeast(0))
        }
    }
    Box(
        Modifier.fillMaxSize().background(Color(0xFF111318)).padding(12.dp).testTag("magic.benchmark.page.chat")
    ) {
        LazyMarkdown(
            markdownBlocks = state.streamingMarkdownBlocks,
            modifier = Modifier.fillMaxWidth(),
            contentPadding = PaddingValues(8.dp),
            state = listState,
            selectable = true,
            markdownStyling = markdownStyling,
            blockRenderer = markdownRenderer,
            onUrlClick = {},
        )
    }
}

@Composable
private fun SimpleRedraw(state: MagicJewelBenchmarkUiState) {
    Column(
        Modifier.fillMaxSize()
            .background(Color(0xFF111318))
            .padding(16.dp)
            .testTag("magic.benchmark.page.redraw"),
    ) {
        Text("Simple redraw ${state.redrawFrame}")
        Spacer(Modifier.height(12.dp))
        Canvas(Modifier.fillMaxWidth().height(360.dp)) {
            val phase = (state.redrawFrame % 120) / 120f
            val center = Offset(size.width / 2f, size.height / 2f)
            drawRect(Color(0xFF171A21), size = size)
            drawRoundRect(
                color = Color(0xFF2F6FED),
                topLeft = Offset(24f + phase * 96f, 40f),
                size = Size(size.width * 0.42f, 88f),
                cornerRadius = androidx.compose.ui.geometry.CornerRadius(18f, 18f),
                alpha = 0.86f,
            )
            drawCircle(
                color = Color(0xFFFFC857),
                radius = 34f,
                center = Offset(center.x + sin(phase * PI.toFloat() * 2f) * 72f, center.y),
            )
            drawLine(
                color = Color(0xFF7CE2D1),
                start = Offset(28f, size.height - 56f),
                end = Offset(size.width - 28f, size.height - 56f),
                strokeWidth = 6f,
                cap = StrokeCap.Round,
            )
        }
    }
}

internal enum class BenchmarkMode {
    Hypnotoad,
    Chat,
    Redraw;

    companion object {
        fun from(value: String?): BenchmarkMode =
            when (value) {
                "chat", "markdownStreaming" -> Chat
                "redraw", "simpleRedraw" -> Redraw
                else -> Hypnotoad
            }
    }
}

private val palette =
    listOf(
        Color(0xFFFF2FD6),
        Color(0xFF35FFF6),
        Color(0xFFFFF857),
        Color(0xFF7D4DFF),
        Color(0xFF61FF7A),
        Color(0xFFFF7A18),
    )
