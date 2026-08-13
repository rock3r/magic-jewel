// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameNanos
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/**
 * A controlled scene for sizing the graphicsLayer "caching win": a grid of many cells,
 * each wrapped in its OWN `Modifier.graphicsLayer` (so each is a separate OwnedLayer with
 * its own JBR command stream). All cells but one draw fixed content and never change, so
 * their layers stay clean frame-to-frame. Exactly ONE cell reads an animation counter and
 * is therefore dirty every frame.
 *
 * With the current force-re-record behaviour, every frame re-records all N cells even
 * though N-1 are unchanged. With a retained "skip clean layers" recorder, only the single
 * animating cell re-records. Comparing the CMP_JBR_FRAME_PERF layerRecords/cleanLayerRecords
 * and buildMicros between the two modes on this scene sizes the win directly.
 *
 * Grid size is configurable via `jewel.standalone.layerGrid.count` (default 96); the cell
 * count is what the "clean skip" applies to.
 */
@Composable
internal fun LayerGrid() {
    val cellCount =
        remember {
            System.getProperty("jewel.standalone.layerGrid.count")?.toIntOrNull()?.coerceIn(1, 1024) ?: 96
        }
    val columns = remember { System.getProperty("jewel.standalone.layerGrid.columns")?.toIntOrNull()?.coerceIn(1, 64) ?: 12 }
    val nestedAnimation = remember { java.lang.Boolean.getBoolean("jewel.standalone.layerGrid.nestedAnimation") }
    val rows = remember { (cellCount + columns - 1) / columns }

    var frame by remember { mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        while (true) {
            withFrameNanos { frame += 1 }
        }
    }

    Column(Modifier.fillMaxSize().background(Color(0xFFF4F4F5)).padding(8.dp).testTag("jewel.page.layer-grid")) {
        for (row in 0 until rows) {
            Row {
                for (col in 0 until columns) {
                    val index = row * columns + col
                    if (index >= cellCount) break
                    if (index == 0) {
                        if (nestedAnimation) {
                            // A MOVING inner layer nested under an intermediate layer whose own
                            // content is static (so the outer layer stays clean). This is the case
                            // that can expose stale-embedded-child ghosting in the retained prototype.
                            NestedMovingCell(frameProvider = { frame })
                        } else {
                            // The single animating cell: its own leaf layer, dirty every frame.
                            AnimatingCell(frameProvider = { frame })
                        }
                    } else {
                        StaticCell(index = index)
                    }
                }
            }
        }
    }
}

@Composable
private fun StaticCell(index: Int) {
    val hue = (index * 47) % 360
    Box(
        Modifier.padding(3.dp)
            .size(72.dp)
            .graphicsLayer()
            .background(Color(0xFFFFFFFF))
            .drawBehind {
                // A handful of ops so a re-record is non-trivial (fixed content -> layer stays clean).
                drawRect(hsv(hue.toFloat(), 0.25f, 0.95f), size = size)
                drawRect(Color(0xFF6B7280), size = size, style = Stroke(width = 2f))
                for (i in 0 until 6) {
                    val t = i / 6f
                    drawCircle(
                        color = hsv(((hue + i * 20) % 360).toFloat(), 0.6f, 0.85f),
                        radius = 6f + i * 2f,
                        center = Offset(size.width * (0.2f + 0.12f * i), size.height * (0.3f + 0.08f * i)),
                    )
                }
                drawRect(
                    color = hsv(hue.toFloat(), 0.7f, 0.6f),
                    topLeft = Offset(8f, size.height - 18f),
                    size = Size(size.width - 16f, 8f),
                )
            }
    )
}

@Composable
private fun AnimatingCell(frameProvider: () -> Long) {
    Box(
        Modifier.padding(3.dp)
            .size(72.dp)
            .graphicsLayer()
            .background(Color(0xFFFFF3CD))
            .drawBehind {
                val f = frameProvider() // read inside the layer -> only this layer invalidates
                drawRect(Color(0xFFFFF3CD), size = size)
                drawRect(Color(0xFFB45309), size = size, style = Stroke(width = 2f))
                val phase = (f % 60L) / 60f
                drawCircle(
                    color = Color(0xFFF59E0B),
                    radius = 14f,
                    center = Offset(size.width * phase, size.height * 0.5f),
                )
            }
    )
}

@Composable
private fun NestedMovingCell(frameProvider: () -> Long) {
    // Outer layer: static content only (a border) -> stays clean frame-to-frame.
    Box(
        Modifier.padding(3.dp)
            .size(72.dp)
            .graphicsLayer()
            .background(Color(0xFFFFFFFF))
            .drawBehind {
                drawRect(Color(0xFFFFFFFF), size = size)
                drawRect(Color(0xFFB45309), size = size, style = Stroke(width = 2f))
            }
    ) {
        // Inner layer: its CONTENT moves (a circle whose position depends on the frame,
        // drawn INSIDE its own layer). Only the inner layer is dirtied; the outer is not.
        // In a retained recorder that embeds child defines, the outer's cached stream replays
        // the inner at its OLD position while the fresh inner draws at the NEW position -> a
        // ghost trail, if stale-embedded-child is not eliminated by hoisting.
        Box(
            Modifier.size(72.dp)
                .graphicsLayer()
                .drawBehind {
                    val f = frameProvider()
                    val phase = (f % 60L) / 60f
                    drawCircle(
                        color = Color(0xFF1D4ED8),
                        radius = 8f,
                        center = Offset(8f + (size.width - 16f) * phase, size.height * 0.5f),
                    )
                }
        )
    }
}

private fun hsv(h: Float, s: Float, v: Float): Color {
    val c = v * s
    val x = c * (1f - kotlin.math.abs((h / 60f) % 2f - 1f))
    val m = v - c
    val (r, g, b) =
        when {
            h < 60f -> Triple(c, x, 0f)
            h < 120f -> Triple(x, c, 0f)
            h < 180f -> Triple(0f, c, x)
            h < 240f -> Triple(0f, x, c)
            h < 300f -> Triple(x, 0f, c)
            else -> Triple(c, 0f, x)
        }
    return Color(r + m, g + m, b + m)
}
