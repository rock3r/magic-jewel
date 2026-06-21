// Copyright 2000-2025 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.jewel.samples.showcase.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
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
import org.jetbrains.jewel.ui.component.DefaultButton
import org.jetbrains.jewel.ui.component.OutlinedButton
import org.jetbrains.jewel.ui.component.Text

@Composable
internal fun Hypnotoad() {
    var intensity by remember { mutableIntStateOf(0) }
    val transition = rememberInfiniteTransition(label = "hypnotoad")
    val phase by
        transition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(tween(durationMillis = 3600, easing = LinearEasing)),
            label = "phase",
        )
    val pulse by
        transition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec =
                infiniteRepeatable(
                    tween(durationMillis = 900, easing = LinearEasing),
                    repeatMode = RepeatMode.Reverse,
                ),
            label = "pulse",
        )

    Box(Modifier.fillMaxSize().testTag("jewel.page.hypnotoad")) {
        Canvas(Modifier.fillMaxWidth().height(720.dp)) {
            val w = size.width
            val h = size.height
            val center = Offset(w / 2f, h / 2f)
            val short = min(w, h)
            drawRect(Color(0xFF090014), size = size)

            repeat(9) { ring ->
                val radius = short * (0.08f + ring * 0.052f + pulse * 0.01f + intensity * 0.004f)
                drawCircle(
                    color = palette[(ring + (phase * 20f).toInt()) % palette.size],
                    radius = radius,
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
                    drawPath(
                        path = path,
                        color =
                            listOf(
                                Color(0xFFFF2FD6),
                                Color(0xFF35FFF6),
                                Color(0xFFFFF857),
                                Color(0xFF7D4DFF),
                                Color(0xFF61FF7A),
                            )[layer],
                        style = Stroke(width = 3f + layer),
                        alpha = 0.78f,
                    )
                }
            }

            drawCircle(
                color = palette[((phase + pulse) * 18f).toInt() % palette.size],
                radius = short * 0.2f,
                center = center,
                alpha = 0.92f,
            )
            drawCircle(Color(0xFF05000A), radius = short * 0.065f, center = center)
            drawCircle(Color(0xFFFFFFFF), radius = short * (0.024f + pulse * 0.011f), center = center)

            println("JEWEL_STANDALONE_FRAME page=Hypnotoad phase=$phase intensity=$intensity")
        }

        Row(
            modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 24.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            OutlinedButton(
                onClick = { intensity = (intensity + 1).coerceAtMost(4) },
                modifier = Modifier.testTag("jewel.hypnotoad.warp"),
            ) {
                Text("Warp")
            }
            DefaultButton(
                onClick = { intensity = 0 },
                modifier = Modifier.testTag("jewel.hypnotoad.reset"),
            ) {
                Text("Reset")
            }
            OutlinedButton(
                onClick = { intensity = (intensity - 1).coerceAtLeast(0) },
                modifier = Modifier.testTag("jewel.hypnotoad.calm"),
            ) {
                Text("Calm")
            }
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
