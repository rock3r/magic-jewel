// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
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
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.layer.drawLayer
import androidx.compose.ui.graphics.rememberGraphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

/**
 * Probe for the retained-layers "multi-parent shared layer" gap: ONE explicit
 * [rememberGraphicsLayer] whose content is animated (a circle whose position depends on the frame),
 * drawn at TWO sites, each wrapped in its own static `graphicsLayer` container.
 *
 * - Site 1 reads `frame` and RE-RECORDS the shared layer, then draws it, so site 1's container is
 *   dirty every frame.
 * - Site 2 does NOT read `frame`; it only DRAWS the same shared layer. Its container content is
 *   static, so under retained layers (subtree-dirty) it is a candidate to be skipped.
 *
 * If, in retained mode, site 2's circle stays FROZEN while site 1's moves, the shared-layer gap is
 * real (site 2's cached stream embedded a stale copy of the shared layer). If both move, Compose's
 * own layer-dependency invalidation already dirties site 2 and the gap is not reachable.
 */
@Composable
internal fun SharedLayerProbe() {
    var frame by remember { mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        while (true) {
            withFrameNanos { frame += 1 }
        }
    }
    val shared = rememberGraphicsLayer()

    Row(Modifier.fillMaxSize().background(Color(0xFFF4F4F5)).padding(24.dp).testTag("jewel.page.shared-layer")) {
        // Site 1: records the shared layer with frame-driven content, then draws it.
        Box(
            Modifier.padding(8.dp)
                .size(160.dp)
                .graphicsLayer()
                .background(Color(0xFFFFF3CD))
                .drawWithContent {
                    drawContent()
                    val f = frame // read here -> site 1 container invalidates every frame
                    shared.record {
                        val phase = (f % 60L) / 60f
                        drawCircle(
                            color = Color(0xFF1D4ED8),
                            radius = 16f,
                            center = Offset(16f + (size.width - 32f) * phase, size.height * 0.5f),
                        )
                    }
                    drawLayer(shared)
                }
        )
        // Site 2: static container, draws the SAME shared layer only (never reads frame, never records).
        Box(
            Modifier.padding(8.dp)
                .size(160.dp)
                .graphicsLayer()
                .background(Color(0xFFFFFFFF))
                .drawWithContent {
                    drawContent()
                    drawLayer(shared)
                }
        )
    }
}
