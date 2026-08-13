// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.foundation.Image
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/**
 * Image-eviction stress scene for hoisting's pinning. Each cell draws a DISTINCT [ImageBitmap] and
 * sits in its own `graphicsLayer`; exactly one cell animates. Run with a small
 * `-Dcompose.jbr.maxImageKeys=N` to force the image cache to evict: under hoisting the static image
 * cells are skipped (not re-referenced), so without pinning their images get evicted and the cells
 * go blank; with pinning they stay. Compare `-Dcompose.jbr.disableLayerImagePin=true` (blank) vs
 * default (rendered).
 */
@Composable
internal fun ImageGrid() {
    val cellCount = remember {
        System.getProperty("jewel.standalone.imageGrid.count")?.toIntOrNull()?.coerceIn(1, 512) ?: 60
    }
    val columns = 10
    val rows = (cellCount + columns - 1) / columns

    // One distinct 24x24 image per cell (distinct pixels -> distinct cache key).
    val painters = remember {
        (0 until cellCount).map { i -> BitmapPainter(makeDistinctImage(i)) }
    }

    var frame by remember { mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        while (true) {
            withFrameNanos { frame += 1 }
        }
    }

    Column(Modifier.fillMaxSize().background(Color(0xFFF4F4F5)).padding(8.dp).testTag("jewel.page.image-grid")) {
        for (row in 0 until rows) {
            Row {
                for (col in 0 until columns) {
                    val index = row * columns + col
                    if (index >= cellCount) break
                    Box(
                        Modifier.padding(2.dp).size(64.dp).graphicsLayer().background(Color(0xFFFFFFFF))
                    ) {
                        Image(painter = painters[index], contentDescription = null, modifier = Modifier.size(64.dp))
                        if (index == 0) {
                            // The single animating cell (its layer is dirty each frame).
                            Box(Modifier.size(64.dp).drawBehind {
                                val phase = (frame % 60L) / 60f
                                drawCircle(Color(0xFFF59E0B), radius = 8f, center = Offset(size.width * phase, size.height * 0.5f))
                                drawRect(Color(0xFFB45309), size = size, style = Stroke(width = 2f))
                            })
                        }
                    }
                }
            }
        }
    }
}

// Build a small image with a per-index unique pixel pattern so each has a distinct content hash/key.
private fun makeDistinctImage(index: Int): ImageBitmap {
    val size = 24
    val bmp = ImageBitmap(size, size)
    val canvas = androidx.compose.ui.graphics.Canvas(bmp)
    val paint = androidx.compose.ui.graphics.Paint()
    val r = (index * 53) % 256
    val g = (index * 97) % 256
    val b = (index * 193) % 256
    paint.color = Color(r / 255f, g / 255f, b / 255f)
    canvas.drawRect(0f, 0f, size.toFloat(), size.toFloat(), paint)
    // A unique diagonal marker per index so pixels genuinely differ.
    paint.color = Color(((index * 211) % 256) / 255f, 0.2f, 0.8f)
    val n = 4 + (index % 8)
    for (i in 0 until n) {
        canvas.drawRect(i * 2f, i * 2f, i * 2f + 2f, size.toFloat(), paint)
    }
    return bmp
}
