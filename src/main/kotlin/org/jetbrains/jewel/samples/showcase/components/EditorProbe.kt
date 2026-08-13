// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/**
 * "Big layer, small localized change" probe — the exact pattern draw-node granularity targets and that
 * per-layer hoisting cannot help. A SINGLE graphicsLayer whose content is a large, static body (many
 * lines) drawn in one Canvas, plus a small blinking cursor that reads the frame counter. The cursor blink
 * dirties the whole layer, so it re-records the entire body every blink even though only the cursor moved.
 *
 * Watch CMP_JBR_FRAME_PERF (via -Dcompose.jbr.debug.layerperf=true): maxLayerWords large but
 * maxLayerChangedWords tiny => a draw-node candidate. Line count via jewel.standalone.editor.lines.
 */
@Composable
internal fun EditorProbe() {
    val lines = remember { System.getProperty("jewel.standalone.editor.lines")?.toIntOrNull()?.coerceIn(1, 400) ?: 120 }
    var frame by remember { mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        while (true) {
            withFrameNanos { frame += 1 }
        }
    }

    // One layer, one Canvas: a large static body + a small blinking cursor.
    Box(Modifier.fillMaxSize().padding(12.dp).graphicsLayer().testTag("jewel.page.editor")) {
        Canvas(Modifier.fillMaxSize()) {
            drawRect(Color(0xFF1E1E1E), size = size)
            val lineH = 16f
            // Static "text": each line is a run of word-like bars (many ops -> a large layer stream).
            for (line in 0 until lines) {
                val y = 8f + line * lineH
                if (y > size.height) break
                var x = 12f
                val words = 6 + (line * 7) % 9
                for (w in 0 until words) {
                    val wlen = 18f + ((line * 31 + w * 13) % 60)
                    drawRect(
                        color = lineColor((line + w) % 6),
                        topLeft = Offset(x, y),
                        size = Size(wlen, 9f),
                    )
                    x += wlen + 8f
                    if (x > size.width - 40f) break
                }
            }
            // Small blinking cursor: reads `frame` -> dirties THIS (whole) layer each blink.
            val blinkOn = (frame / 30L) % 2L == 0L
            if (blinkOn) {
                val cursorLine = 5
                drawRect(
                    color = Color(0xFFEAEAEA),
                    topLeft = Offset(12f, 8f + cursorLine * lineH),
                    size = Size(2f, 11f),
                )
            }
        }
    }
}

private fun lineColor(i: Int): Color =
    when (i) {
        0 -> Color(0xFF9CDCFE)
        1 -> Color(0xFFCE9178)
        2 -> Color(0xFFC586C0)
        3 -> Color(0xFFDCDCAA)
        4 -> Color(0xFF4EC9B0)
        else -> Color(0xFF808080)
    }
