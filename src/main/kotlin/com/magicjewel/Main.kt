package com.magicjewel

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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.awt.ComposePanel
import androidx.compose.ui.unit.dp
import java.awt.Dimension
import javax.swing.JFrame
import javax.swing.SwingUtilities
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlinx.coroutines.delay
import org.jetbrains.jewel.foundation.theme.JewelTheme
import org.jetbrains.jewel.intui.standalone.theme.IntUiTheme
import org.jetbrains.jewel.ui.component.DefaultButton
import org.jetbrains.jewel.ui.component.OutlinedButton
import org.jetbrains.jewel.ui.component.Text

private const val WindowTitle = "MagicJewelJbrSkiaWindow"

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
    }
}

@Composable
private fun MagicJewelApp() {
    var ticks by remember { mutableIntStateOf(0) }
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
            Text("Magic Jewel")
            Spacer(Modifier.width(16.dp))
            Text("Swing ComposePanel / JBR Skia interop sample")
        }

        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            DefaultButton(onClick = { ticks++ }) { Text("Pulse") }
            OutlinedButton(onClick = { ticks = 0 }) { Text("Reset") }
            Text("frames=$ticks", modifier = Modifier.align(Alignment.CenterVertically))
        }

        Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val stripeHeight = size.height / 5f
                drawRect(Color(0xFF2DA44E), size = Size(size.width, stripeHeight * 2f))
                drawRect(
                    color = Color(0xFF0969DA),
                    topLeft = Offset(0f, stripeHeight * 2f),
                    size = Size(size.width, stripeHeight * 3f),
                )
                drawRect(
                    color = Color(0xFF8250DF),
                    topLeft = Offset(48f, 56f),
                    size = Size(220f, 120f),
                )
                drawCircle(
                    color = Color(0xFFFFD33D),
                    radius = 42f,
                    center = Offset(size.width - 112f, 96f),
                )
                val phase = ticks * 0.38
                val center = Offset(size.width * 0.52f, size.height * 0.55f)
                repeat(18) { index ->
                    val angle = phase + index * (PI * 2.0 / 18.0)
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
            }
            Column(
                modifier = Modifier.align(Alignment.BottomStart).padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text("Deterministic color fields plus an animated Skia-heavy spoke test")
                Text("Window title: $WindowTitle")
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
