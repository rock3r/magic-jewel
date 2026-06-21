// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
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
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.testTag

@Composable
internal fun IdleRedraw() {
    val logFrames = remember { !java.lang.Boolean.getBoolean("jewel.standalone.idleRedraw.disableFrameLogs") }
    var frame by remember { mutableLongStateOf(0L) }
    LaunchedEffect(Unit) {
        while (true) {
            withFrameNanos { frame += 1 }
        }
    }

    Canvas(Modifier.fillMaxSize().testTag("jewel.page.idle-redraw")) {
        frame
        drawRect(Color(0xFFF4F4F5), size = size)
        drawRect(Color(0xFFFFFFFF), topLeft = Offset(56f, 56f), size = Size(size.width - 112f, size.height - 112f))
        drawRect(
            color = Color(0xFF6B7280),
            topLeft = Offset(56f, 56f),
            size = Size(size.width - 112f, size.height - 112f),
            style = Stroke(width = 2f),
        )
        drawCircle(Color(0xFF3B82F6), radius = 36f, center = Offset(size.width * 0.5f, size.height * 0.5f))
        drawRect(
            color = Color(0xFF10B981),
            topLeft = Offset(size.width * 0.5f - 96f, size.height * 0.5f + 72f),
            size = Size(192f, 24f),
        )
        if (logFrames) {
            println("JEWEL_STANDALONE_FRAME page=IdleRedraw frame=$frame")
        }
    }
}
