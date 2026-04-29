package com.magicjewel

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.awt.ComposePanel
import androidx.compose.ui.awt.SwingPanel
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.ClipOp
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Font
import java.awt.Graphics
import java.awt.Graphics2D
import java.awt.RenderingHints
import javax.swing.BorderFactory
import javax.swing.JComponent
import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.JPanel
import javax.swing.SwingUtilities
import javax.swing.Timer
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlinx.coroutines.delay
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.intui.standalone.theme.IntUiTheme
import org.jetbrains.jewel.ui.component.DefaultButton
import org.jetbrains.jewel.ui.component.OutlinedButton
import org.jetbrains.jewel.ui.component.Text
import java.awt.Color as AwtColor
import java.util.concurrent.atomic.AtomicLong

private const val WindowTitle = "MagicJewelJbrSkiaWindow"
private const val FrameMarker = "MAGIC_JEWEL_COMPOSE_FRAME"
private const val SwingFrameMarker = "MAGIC_JEWEL_SWING_FRAME"
private const val ComposeTextProperty = "magic.jewel.compose.text"
private const val ComposeImageProperty = "magic.jewel.compose.image"
private const val ComposeImageShaderProperty = "magic.jewel.compose.imageShader"
private const val ComposeTransformProperty = "magic.jewel.compose.transform"
private const val ComposeSaveLayerProperty = "magic.jewel.compose.saveLayer"
private const val ComposeClipProperty = "magic.jewel.compose.clip"
private const val ComposeClipOutProperty = "magic.jewel.compose.clipOut"
private const val ComposeClipPathProperty = "magic.jewel.compose.clipPath"
private const val ComposeDrawPathProperty = "magic.jewel.compose.drawPath"
private const val ComposeDrawArcProperty = "magic.jewel.compose.drawArc"
private const val ComposeDrawRoundRectProperty = "magic.jewel.compose.drawRoundRect"
private const val ComposeLinearGradientProperty = "magic.jewel.compose.linearGradient"
private const val ComposeLinearGradientRoundRectProperty = "magic.jewel.compose.linearGradientRoundRect"
private const val ComposeLinearGradientPathProperty = "magic.jewel.compose.linearGradientPath"
private const val ComposeRadialGradientProperty = "magic.jewel.compose.radialGradient"
private const val ComposeRadialGradientRoundRectProperty = "magic.jewel.compose.radialGradientRoundRect"
private const val ComposeRadialGradientPathProperty = "magic.jewel.compose.radialGradientPath"
private const val ComposeSweepGradientProperty = "magic.jewel.compose.sweepGradient"
private const val ComposeSweepGradientRoundRectProperty = "magic.jewel.compose.sweepGradientRoundRect"
private const val ComposeSweepGradientPathProperty = "magic.jewel.compose.sweepGradientPath"
private const val UnsupportedTextProperty = "magic.jewel.unsupportedText"
private const val ParagraphLayoutTextProperty = "magic.jewel.paragraphLayoutText"
private const val ImageCacheChurnProperty = "magic.jewel.imageCacheChurn"
private const val InvalidSweepGradientProperty = "magic.jewel.invalidSweepGradient"
private const val AutoResizeProperty = "magic.jewel.autoResize"
private const val AutoResizeDelayMillisProperty = "magic.jewel.autoResizeDelayMillis"
private const val ResizeMarker = "MAGIC_JEWEL_WINDOW_RESIZE"
private val FrameCounter = AtomicLong()
private val SwingFrameCounter = AtomicLong()

fun main() {
    SwingUtilities.invokeLater(::showMagicJewel)
}

private fun showMagicJewel() {
    val panel =
        ComposePanel().apply {
            preferredSize = Dimension(980, 680)
            setContent {
                IntUiTheme {
                    MagicJewelApp()
                }
            }
        }

    JFrame(WindowTitle).apply {
        defaultCloseOperation = JFrame.EXIT_ON_CLOSE
        contentPane.add(panel)
        pack()
        setLocationRelativeTo(null)
        isVisible = true
        scheduleAutoResizeIfNeeded()
    }
}

private fun JFrame.scheduleAutoResizeIfNeeded() {
    if (!System.getProperty(AutoResizeProperty, "false").toBoolean()) return

    val delayMillis = System.getProperty(AutoResizeDelayMillisProperty, "2500").toIntOrNull() ?: 2500
    Timer(delayMillis) {
        val expanded = Dimension(width + 96, height + 64)
        size = expanded
        revalidate()
        repaint()
        System.err.println("$ResizeMarker width=${expanded.width} height=${expanded.height}")
    }.apply {
        isRepeats = false
        start()
    }
}

@Composable
private fun MagicJewelApp() {
    var ticks by remember { mutableIntStateOf(0) }
    val composeTextEnabled = remember {
        System.getProperty(ComposeTextProperty, "true").toBoolean()
    }
    val composeImageEnabled = remember {
        System.getProperty(ComposeImageProperty, "false").toBoolean()
    }
    val composeImageShaderEnabled = remember {
        System.getProperty(ComposeImageShaderProperty, "false").toBoolean()
    }
    val composeTransformEnabled = remember {
        System.getProperty(ComposeTransformProperty, "false").toBoolean()
    }
    val composeSaveLayerEnabled = remember {
        System.getProperty(ComposeSaveLayerProperty, "false").toBoolean()
    }
    val composeClipEnabled = remember {
        System.getProperty(ComposeClipProperty, "false").toBoolean()
    }
    val composeClipOutEnabled = remember {
        System.getProperty(ComposeClipOutProperty, "false").toBoolean()
    }
    val composeClipPathEnabled = remember {
        System.getProperty(ComposeClipPathProperty, "false").toBoolean()
    }
    val composeDrawPathEnabled = remember {
        System.getProperty(ComposeDrawPathProperty, "false").toBoolean()
    }
    val composeDrawArcEnabled = remember {
        System.getProperty(ComposeDrawArcProperty, "false").toBoolean()
    }
    val composeDrawRoundRectEnabled = remember {
        System.getProperty(ComposeDrawRoundRectProperty, "false").toBoolean()
    }
    val composeLinearGradientEnabled = remember {
        System.getProperty(ComposeLinearGradientProperty, "false").toBoolean()
    }
    val composeLinearGradientRoundRectEnabled = remember {
        System.getProperty(ComposeLinearGradientRoundRectProperty, "false").toBoolean()
    }
    val composeLinearGradientPathEnabled = remember {
        System.getProperty(ComposeLinearGradientPathProperty, "false").toBoolean()
    }
    val composeRadialGradientEnabled = remember {
        System.getProperty(ComposeRadialGradientProperty, "false").toBoolean()
    }
    val composeRadialGradientRoundRectEnabled = remember {
        System.getProperty(ComposeRadialGradientRoundRectProperty, "false").toBoolean()
    }
    val composeRadialGradientPathEnabled = remember {
        System.getProperty(ComposeRadialGradientPathProperty, "false").toBoolean()
    }
    val composeSweepGradientEnabled = remember {
        System.getProperty(ComposeSweepGradientProperty, "false").toBoolean()
    }
    val composeSweepGradientRoundRectEnabled = remember {
        System.getProperty(ComposeSweepGradientRoundRectProperty, "false").toBoolean()
    }
    val composeSweepGradientPathEnabled = remember {
        System.getProperty(ComposeSweepGradientPathProperty, "false").toBoolean()
    }
    val unsupportedTextEnabled = remember {
        System.getProperty(UnsupportedTextProperty, "false").toBoolean()
    }
    val paragraphLayoutTextEnabled = remember {
        System.getProperty(ParagraphLayoutTextProperty, "false").toBoolean()
    }
    val imageCacheChurnEnabled = remember {
        System.getProperty(ImageCacheChurnProperty, "false").toBoolean()
    }
    val invalidSweepGradientEnabled = remember {
        System.getProperty(InvalidSweepGradientProperty, "false").toBoolean()
    }
    val imageProbe = remember(composeImageEnabled) {
        if (composeImageEnabled || composeImageShaderEnabled) createImageProbe() else null
    }
    val infiniteTransition = rememberInfiniteTransition(label = "magic-jewel-busy-loop")
    val phase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 900, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "always-on-progress-phase",
    )

    LaunchedEffect(Unit) {
        while (true) {
            delay(250)
            ticks++
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().background(JewelTheme.globalColors.panelBackground).padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(18.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            MagicLabel("Magic Jewel", composeTextEnabled, width = 140.dp)
            Spacer(Modifier.width(16.dp))
            MagicLabel("Swing ComposePanel / JBR Skia interop sample", composeTextEnabled, width = 310.dp)
        }

        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            DefaultButton(onClick = { ticks++ }) { MagicLabel("Pulse", composeTextEnabled, width = 48.dp) }
            OutlinedButton(onClick = { ticks = 0 }) { MagicLabel("Reset", composeTextEnabled, width = 48.dp) }
            MagicLabel("frames=$ticks", composeTextEnabled, modifier = Modifier.align(Alignment.CenterVertically), width = 92.dp)
        }

        Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                System.err.println("$FrameMarker frame=${FrameCounter.incrementAndGet()}")
                val stripeHeight = size.height / 5f
                drawRect(Color(0xFF2DA44E), size = Size(size.width, stripeHeight * 2f))
                drawRect(
                    color = Color(0xFF0969DA),
                    topLeft = Offset(0f, stripeHeight * 2f),
                    size = Size(size.width, stripeHeight * 3f),
                )
                drawRect(
                    color = Color(0xFF824EDF),
                    topLeft = Offset(48f, 56f),
                    size = Size(220f, 120f),
                )
                drawCircle(
                    color = Color(0xFFFFD33D),
                    radius = 42f,
                    center = Offset(size.width - 112f, 96f),
                )
                val sweep = phase * size.width
                drawRect(
                    color = Color(0xFFFFA657),
                    topLeft = Offset((sweep % size.width) - size.width * 0.24f, 12f),
                    size = Size(size.width * 0.24f, 18f),
                )
                repeat(52) { index ->
                    val x = ((index * 43f) + phase * 860f) % (size.width + 120f) - 60f
                    drawLine(
                        color = Color.White.copy(alpha = 0.32f),
                        start = Offset(x, 38f),
                        end = Offset(x + 72f, size.height - 18f),
                        strokeWidth = 3f,
                    )
                }
                val spokePhase = ticks * 0.38 + phase * PI * 2.0
                val center = Offset(size.width * 0.52f, size.height * 0.55f)
                repeat(18) { index ->
                    val angle = spokePhase + index * (PI * 2.0 / 18.0)
                    val outer = Offset(
                        center.x + cos(angle).toFloat() * 180f,
                        center.y + sin(angle).toFloat() * 120f,
                    )
                    drawLine(
                        color = Color(0xFFFFA657),
                        start = center,
                        end = outer,
                        strokeWidth = 6f,
                    )
                    drawCircle(Color.White, radius = 10f, center = outer)
                }
                drawCircle(Color.White.copy(alpha = 0.55f), radius = 190f, center = center, style = Stroke(width = 5f))
                if (composeImageEnabled) {
                    imageProbe?.let {
                        drawImage(it, topLeft = Offset(size.width - 212f, size.height - 126f))
                    }
                }
                if (composeImageShaderEnabled) {
                    imageProbe?.let {
                        drawImage(it, topLeft = Offset(size.width - 206f, size.height - 210f))
                        markJbrSkiaUnsupported("shader")
                    }
                }
                if (imageCacheChurnEnabled) {
                    repeat(260) { index ->
                        drawImage(
                            createChurnImage(index, ticks),
                            topLeft = Offset(12f + (index % 26) * 4f, size.height - 22f - (index / 26) * 4f),
                        )
                    }
                }
                if (composeTransformEnabled) {
                    rotate(degrees = 18f, pivot = Offset(160f, size.height - 96f)) {
                        drawRect(
                            color = Color(0xFF22D3EE),
                            topLeft = Offset(112f, size.height - 128f),
                            size = Size(96f, 54f),
                        )
                    }
                }
                if (composeSaveLayerEnabled) {
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.6f)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(Rect(24f, size.height - 144f, 132f, size.height - 36f), layerPaint)
                        canvas.drawRect(44f, size.height - 124f, 112f, size.height - 56f, layerPaint)
                        canvas.restore()
                    }
                }
                if (composeClipEnabled) {
                    clipRect(left = 36f, top = 58f, right = 176f, bottom = 136f) {
                        drawRect(
                            color = Color(0xFF22D3EE),
                            topLeft = Offset(12f, 34f),
                            size = Size(188f, 126f),
                        )
                    }
                }
                if (composeClipOutEnabled) {
                    clipRect(left = 42f, top = 64f, right = 164f, bottom = 126f, clipOp = ClipOp.Difference) {
                        drawRect(
                            color = Color(0xFFE879F9),
                            topLeft = Offset(18f, 38f),
                            size = Size(176f, 120f),
                        )
                    }
                }
                if (composeClipPathEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 248f, size.height - 84f)
                        lineTo(size.width - 156f, size.height - 132f)
                        lineTo(size.width - 68f, size.height - 84f)
                        lineTo(size.width - 156f, size.height - 36f)
                        close()
                    }
                    clipPath(path) {
                        drawRect(
                            color = Color(0xFF22D3EE),
                            topLeft = Offset(size.width - 260f, size.height - 140f),
                            size = Size(208f, 116f),
                        )
                    }
                }
                if (composeDrawPathEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 304f, size.height - 170f)
                        lineTo(size.width - 260f, size.height - 222f)
                        lineTo(size.width - 208f, size.height - 166f)
                        lineTo(size.width - 246f, size.height - 152f)
                        close()
                    }
                    drawPath(path = path, color = Color(0xFFF59E0B))
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeDrawArcEnabled) {
                    drawArc(
                        color = Color(0xFF22D3EE),
                        startAngle = 210f,
                        sweepAngle = 290f,
                        useCenter = true,
                        topLeft = Offset(size.width - 132f, size.height - 222f),
                        size = Size(84f, 84f),
                    )
                    drawArc(
                        color = Color.White,
                        startAngle = 210f,
                        sweepAngle = 290f,
                        useCenter = true,
                        topLeft = Offset(size.width - 132f, size.height - 222f),
                        size = Size(84f, 84f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeDrawRoundRectEnabled) {
                    drawRoundRect(
                        color = Color(0xFF824EDF),
                        topLeft = Offset(size.width - 372f, size.height - 238f),
                        size = Size(96f, 64f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(18f, 10f),
                    )
                    drawRoundRect(
                        color = Color.White,
                        topLeft = Offset(size.width - 372f, size.height - 238f),
                        size = Size(96f, 64f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(18f, 10f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeLinearGradientEnabled) {
                    drawRect(
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFA855F7)),
                            start = Offset(size.width - 188f, size.height - 106f),
                            end = Offset(size.width - 48f, size.height - 34f),
                        ),
                        topLeft = Offset(size.width - 188f, size.height - 106f),
                        size = Size(140f, 72f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = Offset(size.width - 188f, size.height - 106f),
                        size = Size(140f, 72f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeLinearGradientRoundRectEnabled) {
                    drawRoundRect(
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF06B6D4)),
                            start = Offset(size.width - 348f, size.height - 112f),
                            end = Offset(size.width - 212f, size.height - 38f),
                        ),
                        topLeft = Offset(size.width - 348f, size.height - 112f),
                        size = Size(136f, 74f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(26f, 16f),
                    )
                    drawRoundRect(
                        color = Color.White,
                        topLeft = Offset(size.width - 348f, size.height - 112f),
                        size = Size(136f, 74f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(26f, 16f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeLinearGradientPathEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 342f, size.height - 320f)
                        cubicTo(
                            size.width - 310f,
                            size.height - 366f,
                            size.width - 246f,
                            size.height - 356f,
                            size.width - 222f,
                            size.height - 306f,
                        )
                        lineTo(size.width - 276f, size.height - 258f)
                        lineTo(size.width - 344f, size.height - 276f)
                        close()
                    }
                    drawPath(
                        path = path,
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFF14B8A6), Color(0xFFFDE047), Color(0xFFEC4899)),
                            start = Offset(size.width - 350f, size.height - 360f),
                            end = Offset(size.width - 216f, size.height - 254f),
                        ),
                    )
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeRadialGradientEnabled) {
                    val topLeft = Offset(size.width - 164f, size.height - 198f)
                    drawRect(
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFFFFF7ED), Color(0xFFF97316), Color(0xFF7C3AED)),
                            center = topLeft + Offset(64f, 48f),
                            radius = 72f,
                        ),
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeRadialGradientRoundRectEnabled) {
                    val topLeft = Offset(size.width - 164f, size.height - 304f)
                    drawRoundRect(
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFFECFEFF), Color(0xFF06B6D4), Color(0xFF4338CA)),
                            center = topLeft + Offset(64f, 48f),
                            radius = 78f,
                        ),
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                    )
                    drawRoundRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeRadialGradientPathEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 492f, size.height - 318f)
                        cubicTo(
                            size.width - 452f,
                            size.height - 366f,
                            size.width - 390f,
                            size.height - 344f,
                            size.width - 370f,
                            size.height - 294f,
                        )
                        lineTo(size.width - 434f, size.height - 250f)
                        lineTo(size.width - 500f, size.height - 276f)
                        close()
                    }
                    drawPath(
                        path = path,
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFFFFFBEB), Color(0xFFF97316), Color(0xFF7C3AED)),
                            center = Offset(size.width - 438f, size.height - 304f),
                            radius = 86f,
                        ),
                    )
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeSweepGradientEnabled) {
                    val topLeft = Offset(size.width - 518f, size.height - 126f)
                    drawRect(
                        brush = Brush.sweepGradient(
                            colors = listOf(Color(0xFFEF4444), Color(0xFFFDE047), Color(0xFF22C55E), Color(0xFF3B82F6)),
                            center = topLeft + Offset(72f, 42f),
                        ),
                        topLeft = topLeft,
                        size = Size(144f, 84f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(144f, 84f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeSweepGradientRoundRectEnabled) {
                    val topLeft = Offset(size.width - 520f, size.height - 236f)
                    drawRoundRect(
                        brush = Brush.sweepGradient(
                            colors = listOf(Color(0xFFDC2626), Color(0xFFFACC15), Color(0xFF0EA5E9), Color(0xFF9333EA)),
                            center = topLeft + Offset(72f, 46f),
                        ),
                        topLeft = topLeft,
                        size = Size(144f, 92f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                    )
                    drawRoundRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(144f, 92f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeSweepGradientPathEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 250f, size.height - 238f)
                        cubicTo(
                            size.width - 208f,
                            size.height - 282f,
                            size.width - 152f,
                            size.height - 256f,
                            size.width - 162f,
                            size.height - 198f,
                        )
                        lineTo(size.width - 214f, size.height - 158f)
                        lineTo(size.width - 280f, size.height - 186f)
                        close()
                    }
                    drawPath(
                        path = path,
                        brush = Brush.sweepGradient(
                            colors = listOf(Color(0xFFEF4444), Color(0xFFF59E0B), Color(0xFF22D3EE), Color(0xFF7C3AED)),
                            center = Offset(size.width - 216f, size.height - 212f),
                        ),
                    )
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (invalidSweepGradientEnabled) {
                    drawRect(
                        brush = Brush.sweepGradient(
                            0.5f to Color.Red,
                            0.5f to Color.Blue,
                            center = Offset(size.width - 100f, size.height - 100f),
                        ),
                        topLeft = Offset(size.width - 172f, size.height - 142f),
                        size = Size(144f, 84f),
                    )
                }
            }

            SwingPanel(
                factory = ::createSwingStatusPanel,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .offset(x = (-28).dp, y = 34.dp)
                    .size(width = 300.dp, height = 118.dp)
                    .zIndex(1f),
            )

            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .offset(x = (-52).dp, y = 128.dp)
                    .size(width = 142.dp, height = 34.dp)
                    .background(Color(0xCC824EDF))
                    .zIndex(2f),
                contentAlignment = Alignment.Center,
            ) {
                MagicLabel("Compose overlay", composeTextEnabled, width = 116.dp)
            }

            Column(
                modifier = Modifier.align(Alignment.BottomStart).padding(24.dp).zIndex(2f),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                MagicLabel("Deterministic color fields, Swing island, and always-on animation", composeTextEnabled, width = 470.dp)
                MagicLabel("Window title: $WindowTitle", composeTextEnabled, width = 330.dp)
                MagicLabel("Latin-1 text: Caf\u00e9", composeTextEnabled, width = 150.dp)
                if (unsupportedTextEnabled) {
                    MagicLabel("Unsupported text: \uD83D\uDE80", composeTextEnabled, width = 180.dp)
                }
                if (paragraphLayoutTextEnabled) {
                    MagicLabel(
                        "Centered bold \uD83D\uDE80 paragraph",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 18.sp,
                            lineHeight = 30.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center,
                        ),
                    )
                    MagicLabel(
                        "Italic right aligned \uD83D\uDE80",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontStyle = FontStyle.Italic,
                            textAlign = TextAlign.Right,
                        ),
                    )
                    MagicLabel(
                        "\u0633\u0644\u0627\u0645 RTL paragraph",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            textAlign = TextAlign.End,
                            textDirection = TextDirection.Rtl,
                        ),
                    )
                    MagicLabel(
                        "Overflow \uD83D\uDE80 paragraph text that must ellipsize at the edge",
                        composeTextEnabled,
                        width = 180.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            textAlign = TextAlign.Left,
                        ),
                        overflow = TextOverflow.Ellipsis,
                    )
                    MagicLabel(
                        "Decorated \uD83D\uDE80 paragraph line",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            background = Color(0x33FFE05C),
                            fontSize = 17.sp,
                            letterSpacing = 1.5.sp,
                            textDecoration = TextDecoration.Underline + TextDecoration.LineThrough,
                        ),
                    )
                }
            }
        }

        val swatches = listOf(
            Color(0xFFDBEAFE),
            Color(0xFFBFDBFE),
            Color(0xFF93C5FD),
            Color(0xFF60A5FA),
            Color(0xFF2563EB),
        )
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.height(32.dp)) {
            swatches.forEachIndexed { index, color ->
                Box(
                    modifier = Modifier.size(width = (72 + index * 18).dp, height = 18.dp)
                        .background(color),
                )
            }
        }
    }
}

private fun createImageProbe(): ImageBitmap {
    val bitmap = ImageBitmap(72, 72)
    val canvas = androidx.compose.ui.graphics.Canvas(bitmap)
    val paint = Paint()

    paint.color = Color(0xFFE879F9)
    canvas.drawRect(0f, 0f, 72f, 72f, paint)
    paint.color = Color(0xFF111827)
    canvas.drawRect(12f, 12f, 60f, 60f, paint)
    paint.color = Color(0xFF22D3EE)
    canvas.drawCircle(Offset(36f, 36f), 20f, paint)

    return bitmap
}

private fun markJbrSkiaUnsupported(reason: String) {
    runCatching {
        val type = Class.forName("androidx.compose.ui.graphics.JbrSkiaCommandRecorder")
        val instance = type.getField("INSTANCE").get(null)
        type.getMethod("markUnsupportedDraw", String::class.java).invoke(instance, reason)
    }
}

private fun createChurnImage(index: Int, ticks: Int): ImageBitmap {
    val bitmap = ImageBitmap(1, 1)
    val canvas = androidx.compose.ui.graphics.Canvas(bitmap)
    val paint = Paint().apply {
        color = Color(0xff000000.toInt() or ((ticks and 0xff) shl 16) or ((index * 37) and 0xffff))
    }
    canvas.drawRect(0f, 0f, 1f, 1f, paint)
    return bitmap
}

@Composable
private fun MagicLabel(
    text: String,
    composeTextEnabled: Boolean,
    modifier: Modifier = Modifier,
    width: androidx.compose.ui.unit.Dp,
    style: TextStyle = TextStyle(color = Color.Black),
    overflow: TextOverflow = TextOverflow.Clip,
) {
    if (composeTextEnabled) {
        Text(
            text = text,
            modifier = modifier.width(width),
            maxLines = 1,
            overflow = overflow,
            style = JewelTheme.defaultTextStyle.merge(style),
        )
    } else {
        Box(
            modifier = modifier
                .size(width = width, height = 16.dp)
                .background(Color.White.copy(alpha = 0.72f))
        )
    }
}

private fun createSwingStatusPanel(): JPanel {
    val title = JLabel("Swing island").apply {
        font = Font(Font.SANS_SERIF, Font.BOLD, 13)
        foreground = AwtColor(255, 255, 255)
    }
    val counter = JLabel("ticks=0").apply {
        foreground = AwtColor(220, 240, 255)
    }
    val progress = MovingSwingProgressBar()
    var swingTicks = 0
    Timer(80) {
        swingTicks++
        counter.text = "Swing timer ticks=$swingTicks"
    }.start()

    return JPanel(BorderLayout(10, 8)).apply {
        name = "MagicJewelSwingIsland"
        background = AwtColor(28, 47, 72)
        border = BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(AwtColor(255, 211, 61), 3, true),
            BorderFactory.createEmptyBorder(10, 12, 10, 12),
        )
        add(title, BorderLayout.NORTH)
        add(counter, BorderLayout.CENTER)
        add(progress, BorderLayout.SOUTH)
    }
}

private class MovingSwingProgressBar : JComponent() {
    private val timer = Timer(33) {
        repaint()
        parent?.repaint()
    }.apply {
        isRepeats = true
        start()
    }

    init {
        preferredSize = Dimension(220, 18)
        minimumSize = Dimension(120, 18)
        background = AwtColor(21, 35, 54)
        foreground = AwtColor(255, 166, 87)
        isOpaque = false
    }

    override fun removeNotify() {
        timer.stop()
        super.removeNotify()
    }

    override fun paintComponent(g: Graphics) {
        val g2 = g.create() as Graphics2D
        try {
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
            g2.color = AwtColor(236, 240, 245)
            g2.fillRoundRect(0, 3, width, height - 6, 9, 9)
            g2.color = AwtColor(218, 224, 232)
            g2.drawRoundRect(0, 3, width - 1, height - 7, 9, 9)

            System.err.println("$SwingFrameMarker frame=${SwingFrameCounter.incrementAndGet()}")
            val blockWidth = (width * 0.34).toInt().coerceAtLeast(48)
            val x = movingProgressX(width, blockWidth, System.nanoTime())
            g2.color = AwtColor(255, 166, 87)
            g2.fillRoundRect(x, 4, blockWidth, height - 8, 8, 8)
            g2.color = AwtColor(255, 211, 61, 180)
            g2.fillRoundRect(x + blockWidth / 3, 5, blockWidth / 3, height - 10, 7, 7)
        } finally {
            g2.dispose()
        }
    }
}

private fun movingProgressX(width: Int, blockWidth: Int, nowNanos: Long): Int {
    val travel = (width + blockWidth).coerceAtLeast(1)
    val periodNanos = 900_000_000L
    val phase = (nowNanos.floorMod(periodNanos)).toDouble() / periodNanos.toDouble()
    return (phase * travel).toInt() - blockWidth
}

private fun Long.floorMod(modulus: Long): Long {
    val value = this % modulus
    return if (value >= 0) value else value + modulus
}
