package com.magicjewel

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.shape.GenericShape
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
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.BlurEffect
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.ClipOp
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.graphics.ColorShader
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.CompositeShader
import androidx.compose.ui.graphics.ExperimentalGraphicsApi
import androidx.compose.ui.graphics.FractalNoiseShader
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.ImageShader
import androidx.compose.ui.graphics.LinearGradientShader
import androidx.compose.ui.graphics.Matrix
import androidx.compose.ui.graphics.OffsetEffect
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.PaintingStyle
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.PointMode
import androidx.compose.ui.graphics.RadialGradientShader
import androidx.compose.ui.graphics.RuntimeEffectChild
import androidx.compose.ui.graphics.RuntimeEffectColorFilter
import androidx.compose.ui.graphics.RuntimeEffectColorFilterChild
import androidx.compose.ui.graphics.RuntimeEffectShader
import androidx.compose.ui.graphics.RuntimeEffectUniform
import androidx.compose.ui.graphics.ShaderBrush
import androidx.compose.ui.graphics.StampedPathEffectStyle
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.SweepGradientShader
import androidx.compose.ui.graphics.TileMode
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.TurbulenceShader
import androidx.compose.ui.graphics.VertexMode
import androidx.compose.ui.graphics.Vertices
import androidx.compose.ui.graphics.asComposeColorFilter
import androidx.compose.ui.graphics.asComposePathEffect
import androidx.compose.ui.graphics.asComposeRenderEffect
import androidx.compose.ui.graphics.asComposeShader
import androidx.compose.ui.graphics.drawscope.clipRect
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.layer.drawLayer
import androidx.compose.ui.graphics.rememberGraphicsLayer
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import androidx.compose.ui.text.platform.Font as ComposeFont
import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Font
import java.awt.Graphics
import java.awt.Graphics2D
import java.awt.RenderingHints
import javax.swing.BorderFactory
import javax.swing.JComponent
import javax.swing.JDialog
import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.JPanel
import javax.swing.JPopupMenu
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
private const val ComposeImageBlendModeProperty = "magic.jewel.compose.imageBlendMode"
private const val ComposeImagePathEffectProperty = "magic.jewel.compose.imagePathEffect"
private const val ComposeImageShaderProperty = "magic.jewel.compose.imageShader"
private const val ComposeImageShaderBlendModeProperty = "magic.jewel.compose.imageShaderBlendMode"
private const val ComposeInvalidImageShaderImageProperty = "magic.jewel.compose.invalidImageShaderImage"
private const val ComposeRawImageShaderProperty = "magic.jewel.compose.rawImageShader"
private const val ComposeColorShaderProperty = "magic.jewel.compose.colorShader"
private const val ComposeColorShaderBlendModeProperty = "magic.jewel.compose.colorShaderBlendMode"
private const val ComposeDescriptorStrokeShaderProperty = "magic.jewel.compose.descriptorStrokeShader"
private const val ComposeOpaqueShaderProperty = "magic.jewel.compose.opaqueShader"
private const val ComposeCompositeOpaqueShaderProperty = "magic.jewel.compose.compositeOpaqueShader"
private const val ComposeNoiseShaderProperty = "magic.jewel.compose.noiseShader"
private const val ComposeTurbulenceShaderProperty = "magic.jewel.compose.turbulenceShader"
private const val ComposeGradientShadersProperty = "magic.jewel.compose.gradientShaders"
private const val ComposeRawLinearGradientShaderProperty = "magic.jewel.compose.rawLinearGradientShader"
private const val ComposeRawRadialGradientShaderProperty = "magic.jewel.compose.rawRadialGradientShader"
private const val ComposeRawSweepGradientShaderProperty = "magic.jewel.compose.rawSweepGradientShader"
private const val ComposeRawConicalGradientShaderProperty = "magic.jewel.compose.rawConicalGradientShader"
private const val ComposeRawNoiseShaderProperty = "magic.jewel.compose.rawNoiseShader"
private const val ComposeRawTurbulenceShaderProperty = "magic.jewel.compose.rawTurbulenceShader"
private const val ComposePictureShaderProperty = "magic.jewel.compose.pictureShader"
private const val ComposeTransformedShaderProperty = "magic.jewel.compose.transformedShader"
private const val ComposeImageShaderColorFilterProperty = "magic.jewel.compose.imageShaderColorFilter"
private const val ComposeCompositeShaderProperty = "magic.jewel.compose.compositeShader"
private const val ComposeCompositeNoiseShaderProperty = "magic.jewel.compose.compositeNoiseShader"
private const val ComposeCompositeShaderColorFilterProperty = "magic.jewel.compose.compositeShaderColorFilter"
private const val ComposeRuntimeEffectShaderProperty = "magic.jewel.compose.runtimeEffectShader"
private const val ComposeRawRuntimeEffectShaderProperty = "magic.jewel.compose.rawRuntimeEffectShader"
private const val ComposeRuntimeEffectShaderColorFilterProperty = "magic.jewel.compose.runtimeEffectShaderColorFilter"
private const val ComposeLinearGradientShaderColorFilterProperty = "magic.jewel.compose.linearGradientShaderColorFilter"
private const val ComposeRadialGradientShaderColorFilterProperty = "magic.jewel.compose.radialGradientShaderColorFilter"
private const val ComposeSweepGradientShaderColorFilterProperty = "magic.jewel.compose.sweepGradientShaderColorFilter"
private const val ComposeRuntimeEffectPureColorProperty = "magic.jewel.compose.runtimeEffectPureColor"
private const val ComposeRuntimeEffectUniformOnlyProperty = "magic.jewel.compose.runtimeEffectUniformOnly"
private const val ComposeRuntimeEffectChildOnlyProperty = "magic.jewel.compose.runtimeEffectChildOnly"
private const val ComposeRuntimeEffectInvalidUniformSchemaProperty =
    "magic.jewel.compose.runtimeEffectInvalidUniformSchema"
private const val ComposeRuntimeEffectInvalidChildSchemaProperty =
    "magic.jewel.compose.runtimeEffectInvalidChildSchema"
private const val ComposeRuntimeEffectInvalidNestedChildProperty =
    "magic.jewel.compose.runtimeEffectInvalidNestedChild"
private const val ComposeRuntimeEffectBadChildProperty = "magic.jewel.compose.runtimeEffectBadChild"
private const val ComposeRuntimeEffectColorFilterProperty = "magic.jewel.compose.runtimeEffectColorFilter"
private const val ComposeRuntimeEffectStableColorFilterProperty = "magic.jewel.compose.runtimeEffectStableColorFilter"
private const val ComposeRawRuntimeEffectColorFilterProperty = "magic.jewel.compose.rawRuntimeEffectColorFilter"
private const val ComposeRuntimeEffectColorFilterChildProperty = "magic.jewel.compose.runtimeEffectColorFilterChild"
private const val ComposeRuntimeEffectColorFilterBadChildProperty =
    "magic.jewel.compose.runtimeEffectColorFilterBadChild"
private const val ComposeRuntimeEffectColorFilterInvalidUniformSchemaProperty =
    "magic.jewel.compose.runtimeEffectColorFilterInvalidUniformSchema"
private const val ComposeRuntimeEffectColorFilterInvalidChildSchemaProperty =
    "magic.jewel.compose.runtimeEffectColorFilterInvalidChildSchema"
private const val ComposeRuntimeEffectColorFilterInvalidNestedChildProperty =
    "magic.jewel.compose.runtimeEffectColorFilterInvalidNestedChild"
private const val ComposeImageFilterProperty = "magic.jewel.compose.imageFilter"
private const val ComposeImageColorMatrixFilterProperty = "magic.jewel.compose.imageColorMatrixFilter"
private const val ComposeImageRawTableColorFilterProperty = "magic.jewel.compose.imageRawTableColorFilter"
private const val ComposeRawBlendColorFilterProperty = "magic.jewel.compose.rawBlendColorFilter"
private const val ComposeRawTableColorFilterProperty = "magic.jewel.compose.rawTableColorFilter"
private const val ComposeColorFilterProperty = "magic.jewel.compose.colorFilter"
private const val ComposeColorFilterBlendModeProperty = "magic.jewel.compose.colorFilterBlendMode"
private const val ComposeColorMatrixFilterProperty = "magic.jewel.compose.colorMatrixFilter"
private const val ComposeInvalidColorMatrixFilterProperty = "magic.jewel.compose.invalidColorMatrixFilter"
private const val ComposeLightingFilterProperty = "magic.jewel.compose.lightingFilter"
private const val ComposeDescriptorEvictionProperty = "magic.jewel.compose.descriptorEviction"
private const val ComposePathEffectProperty = "magic.jewel.compose.pathEffect"
private const val ComposePathEffectColorFilterProperty = "magic.jewel.compose.pathEffectColorFilter"
private const val ComposeRawDiscretePathEffectProperty = "magic.jewel.compose.rawDiscretePathEffect"
private const val ComposeBlendModeProperty = "magic.jewel.compose.blendMode"
private const val ComposeGraphicsLayerProperty = "magic.jewel.compose.graphicsLayer"
private const val ComposeGraphicsLayerClipProperty = "magic.jewel.compose.graphicsLayerClip"
private const val ComposeGraphicsLayerRoundClipProperty = "magic.jewel.compose.graphicsLayerRoundClip"
private const val ComposeGraphicsLayerPathClipProperty = "magic.jewel.compose.graphicsLayerPathClip"
private const val ComposeGraphicsLayerBlendModeProperty = "magic.jewel.compose.graphicsLayerBlendMode"
private const val ComposeGraphicsLayerInvalidBlendModeProperty =
    "magic.jewel.compose.graphicsLayerInvalidBlendMode"
private const val ComposeGraphicsLayerUnrecordedProperty = "magic.jewel.compose.graphicsLayerUnrecorded"
private const val ComposeGraphicsLayerInvalidSizeWidthProperty =
    "magic.jewel.compose.graphicsLayerInvalidSizeWidth"
private const val ComposeGraphicsLayerInvalidSizeHeightProperty =
    "magic.jewel.compose.graphicsLayerInvalidSizeHeight"
private const val ComposeGraphicsLayerColorFilterProperty = "magic.jewel.compose.graphicsLayerColorFilter"
private const val ComposeGraphicsLayerColorMatrixFilterProperty = "magic.jewel.compose.graphicsLayerColorMatrixFilter"
private const val ComposeGraphicsLayerRawColorFilterProperty = "magic.jewel.compose.graphicsLayerRawColorFilter"
private const val ComposeGraphicsLayerRawTableColorFilterProperty =
    "magic.jewel.compose.graphicsLayerRawTableColorFilter"
private const val ComposeGraphicsLayerChildUnsupportedProperty =
    "magic.jewel.compose.graphicsLayerChildUnsupported"
private const val ComposeGraphicsLayerRenderEffectProperty = "magic.jewel.compose.graphicsLayerRenderEffect"
private const val ComposeGraphicsLayerRawImageFilterEffectProperty =
    "magic.jewel.compose.graphicsLayerRawImageFilterEffect"
private const val ComposeGraphicsLayerOffsetEffectProperty = "magic.jewel.compose.graphicsLayerOffsetEffect"
private const val ComposeGraphicsLayerChainedRenderEffectProperty = "magic.jewel.compose.graphicsLayerChainedRenderEffect"
private const val ComposeGraphicsLayerBlurChainedRenderEffectProperty =
    "magic.jewel.compose.graphicsLayerBlurChainedRenderEffect"
private const val ComposeGraphicsLayerShadowProperty = "magic.jewel.compose.graphicsLayerShadow"
private const val ComposeGraphicsLayerInvalidAlphaProperty = "magic.jewel.compose.graphicsLayerInvalidAlpha"
private const val ComposeGraphicsLayerInvalidShadowElevationProperty =
    "magic.jewel.compose.graphicsLayerInvalidShadowElevation"
private const val ComposeGraphicsLayerInvalidShadowPathProperty =
    "magic.jewel.compose.graphicsLayerInvalidShadowPath"
private const val ComposeGraphicsLayerRotationXProperty = "magic.jewel.compose.graphicsLayerRotationX"
private const val ComposeGraphicsLayerRotationYProperty = "magic.jewel.compose.graphicsLayerRotationY"
private const val ComposeGraphicsLayerInvalidScaleXProperty = "magic.jewel.compose.graphicsLayerInvalidScaleX"
private const val ComposeGraphicsLayerInvalidScaleYProperty = "magic.jewel.compose.graphicsLayerInvalidScaleY"
private const val ComposeGraphicsLayerInvalidRotationZProperty =
    "magic.jewel.compose.graphicsLayerInvalidRotationZ"
private const val ComposeGraphicsLayerInvalidTranslationXProperty =
    "magic.jewel.compose.graphicsLayerInvalidTranslationX"
private const val ComposeGraphicsLayerInvalidTranslationYProperty =
    "magic.jewel.compose.graphicsLayerInvalidTranslationY"
private const val ComposeGraphicsLayerInvalidRotationXProperty =
    "magic.jewel.compose.graphicsLayerInvalidRotationX"
private const val ComposeGraphicsLayerInvalidRotationYProperty =
    "magic.jewel.compose.graphicsLayerInvalidRotationY"
private const val ComposeGraphicsLayerScaleTranslateProperty = "magic.jewel.compose.graphicsLayerScaleTranslate"
private const val ComposeGraphicsLayerNearCameraProperty = "magic.jewel.compose.graphicsLayerNearCamera"
private const val ComposeGraphicsLayerInvalidCameraDistanceProperty =
    "magic.jewel.compose.graphicsLayerInvalidCameraDistance"
private const val ComposeGraphicsLayerOffCenterPivotProperty = "magic.jewel.compose.graphicsLayerOffCenterPivot"
private const val ComposeGraphicsLayerOffscreenProperty = "magic.jewel.compose.graphicsLayerOffscreen"
private const val ComposeGraphicsLayerModulateAlphaProperty = "magic.jewel.compose.graphicsLayerModulateAlpha"
private const val ComposeTransformProperty = "magic.jewel.compose.transform"
private const val ComposeInvalidBlendLayerBoundsProperty = "magic.jewel.compose.invalidBlendLayerBounds"
private const val ComposeConcatTransformProperty = "magic.jewel.compose.concatTransform"
private const val ComposeInvalidConcatTransformProperty = "magic.jewel.compose.invalidConcatTransform"
private const val ComposeSkewTransformProperty = "magic.jewel.compose.skewTransform"
private const val ComposeVerticesProperty = "magic.jewel.compose.vertices"
private const val ComposeVerticesRawColorFilterProperty = "magic.jewel.compose.verticesRawColorFilter"
private const val ComposeVerticesInvalidBlendModeProperty = "magic.jewel.compose.verticesInvalidBlendMode"
private const val ComposeSaveLayerProperty = "magic.jewel.compose.saveLayer"
private const val ComposeSaveLayerFilterProperty = "magic.jewel.compose.saveLayerFilter"
private const val ComposeSaveLayerColorMatrixFilterProperty = "magic.jewel.compose.saveLayerColorMatrixFilter"
private const val ComposeSaveLayerBlendModeProperty = "magic.jewel.compose.saveLayerBlendMode"
private const val ComposeSaveLayerBlendColorFilterProperty = "magic.jewel.compose.saveLayerBlendColorFilter"
private const val ComposeSaveLayerRawColorFilterProperty = "magic.jewel.compose.saveLayerRawColorFilter"
private const val ComposeSaveLayerRawTableColorFilterProperty = "magic.jewel.compose.saveLayerRawTableColorFilter"
private const val ComposeClipProperty = "magic.jewel.compose.clip"
private const val ComposeClipOutProperty = "magic.jewel.compose.clipOut"
private const val ComposeClipPathProperty = "magic.jewel.compose.clipPath"
private const val ComposeInvalidClipPathProperty = "magic.jewel.compose.invalidClipPath"
private const val ComposeDrawPathProperty = "magic.jewel.compose.drawPath"
private const val ComposeInvalidDrawPathProperty = "magic.jewel.compose.invalidDrawPath"
private const val ComposeInvalidGradientPathProperty = "magic.jewel.compose.invalidGradientPath"
private const val ComposeDrawArcProperty = "magic.jewel.compose.drawArc"
private const val ComposeDrawRoundRectProperty = "magic.jewel.compose.drawRoundRect"
private const val ComposePointLinesProperty = "magic.jewel.compose.pointLines"
private const val ComposePointDotsProperty = "magic.jewel.compose.pointDots"
private const val ComposeInvalidPointDotsProperty = "magic.jewel.compose.invalidPointDots"
private const val ComposeLinearGradientProperty = "magic.jewel.compose.linearGradient"
private const val ComposeLinearGradientBlendModeProperty = "magic.jewel.compose.linearGradientBlendMode"
private const val ComposeInvalidLinearGradientStopsProperty = "magic.jewel.compose.invalidLinearGradientStops"
private const val ComposeInvalidLinearGradientPointsProperty = "magic.jewel.compose.invalidLinearGradientPoints"
private const val ComposeInvalidLinearGradientColorCountProperty =
    "magic.jewel.compose.invalidLinearGradientColorCount"
private const val ComposeLinearGradientStrokeProperty = "magic.jewel.compose.linearGradientStroke"
private const val ComposeInvalidLinearGradientStrokeWidthProperty =
    "magic.jewel.compose.invalidLinearGradientStrokeWidth"
private const val ComposeLinearGradientRoundRectProperty = "magic.jewel.compose.linearGradientRoundRect"
private const val ComposeInvalidLinearGradientRoundRectRadiusProperty =
    "magic.jewel.compose.invalidLinearGradientRoundRectRadius"
private const val ComposeInvalidLinearGradientStrokeRoundRectRadiusProperty =
    "magic.jewel.compose.invalidLinearGradientStrokeRoundRectRadius"
private const val ComposeLinearGradientPathProperty = "magic.jewel.compose.linearGradientPath"
private const val ComposeLinearGradientPathBlendModeProperty = "magic.jewel.compose.linearGradientPathBlendMode"
private const val ComposeRadialGradientProperty = "magic.jewel.compose.radialGradient"
private const val ComposeInvalidRadialGradientStopsProperty = "magic.jewel.compose.invalidRadialGradientStops"
private const val ComposeInvalidRadialGradientGeometryProperty = "magic.jewel.compose.invalidRadialGradientGeometry"
private const val ComposeInvalidRadialGradientColorCountProperty =
    "magic.jewel.compose.invalidRadialGradientColorCount"
private const val ComposeInvalidRadialGradientStrokeWidthProperty =
    "magic.jewel.compose.invalidRadialGradientStrokeWidth"
private const val ComposeRadialGradientRoundRectProperty = "magic.jewel.compose.radialGradientRoundRect"
private const val ComposeInvalidRadialGradientRoundRectRadiusProperty =
    "magic.jewel.compose.invalidRadialGradientRoundRectRadius"
private const val ComposeInvalidRadialGradientStrokeRoundRectRadiusProperty =
    "magic.jewel.compose.invalidRadialGradientStrokeRoundRectRadius"
private const val ComposeRadialGradientStrokeBlendModeProperty =
    "magic.jewel.compose.radialGradientStrokeBlendMode"
private const val ComposeRadialGradientPathProperty = "magic.jewel.compose.radialGradientPath"
private const val ComposeSweepGradientProperty = "magic.jewel.compose.sweepGradient"
private const val ComposeInvalidSweepGradientColorCountProperty = "magic.jewel.compose.invalidSweepGradientColorCount"
private const val ComposeInvalidSweepGradientGeometryProperty = "magic.jewel.compose.invalidSweepGradientGeometry"
private const val ComposeInvalidSweepGradientStrokeWidthProperty =
    "magic.jewel.compose.invalidSweepGradientStrokeWidth"
private const val ComposeSweepGradientRoundRectProperty = "magic.jewel.compose.sweepGradientRoundRect"
private const val ComposeInvalidSweepGradientRoundRectRadiusProperty =
    "magic.jewel.compose.invalidSweepGradientRoundRectRadius"
private const val ComposeInvalidSweepGradientStrokeRoundRectRadiusProperty =
    "magic.jewel.compose.invalidSweepGradientStrokeRoundRectRadius"
private const val ComposeSweepGradientRoundRectBlendModeProperty =
    "magic.jewel.compose.sweepGradientRoundRectBlendMode"
private const val ComposeSweepGradientPathProperty = "magic.jewel.compose.sweepGradientPath"
private const val ComposeGradientPathStrokeProperty = "magic.jewel.compose.gradientPathStroke"
private const val UnsupportedTextProperty = "magic.jewel.unsupportedText"
private const val ParagraphLayoutTextProperty = "magic.jewel.paragraphLayoutText"
private const val GenericFontTextProperty = "magic.jewel.genericFontText"
private const val LoadedFontDataTextProperty = "magic.jewel.loadedFontDataText"
private const val ResourceFontTextProperty = "magic.jewel.resourceFontText"
private const val SystemFontTextProperty = "magic.jewel.systemFontText"
private const val ImageCacheChurnProperty = "magic.jewel.imageCacheChurn"
private const val StableImageCacheChurnProperty = "magic.jewel.stableImageCacheChurn"
private const val InvalidSweepGradientProperty = "magic.jewel.invalidSweepGradient"
private const val AutoResizeProperty = "magic.jewel.autoResize"
private const val AutoResizeDelayMillisProperty = "magic.jewel.autoResizeDelayMillis"
private const val PopupStressProperty = "magic.jewel.popupStress"
private const val PopupStressDelayMillisProperty = "magic.jewel.popupStressDelayMillis"
private const val PopupWindowStressProperty = "magic.jewel.popupWindowStress"
private const val PopupWindowStressDelayMillisProperty = "magic.jewel.popupWindowStressDelayMillis"
private const val MenuStressProperty = "magic.jewel.menuStress"
private const val MenuStressDelayMillisProperty = "magic.jewel.menuStressDelayMillis"
private const val FixedAnimationPhaseProperty = "magic.jewel.fixedAnimationPhase"
private const val FixedFrameTicksProperty = "magic.jewel.fixedFrameTicks"
private const val PauseSwingAnimationProperty = "magic.jewel.pauseSwingAnimation"
private const val SwingIslandProperty = "magic.jewel.swingIsland"
private const val BackgroundWindowProperty = "magic.jewel.backgroundWindow"
private const val ResizeMarker = "MAGIC_JEWEL_WINDOW_RESIZE"
private const val PopupShownMarker = "MAGIC_JEWEL_POPUP_SHOWN"
private const val PopupWindowTitle = "MagicJewelPopupWindow"
private const val PopupWindowShownMarker = "MAGIC_JEWEL_POPUP_WINDOW_SHOWN"
private const val MenuShownMarker = "MAGIC_JEWEL_MENU_SHOWN"
private const val PopupFrameMarker = "MAGIC_JEWEL_POPUP_FRAME"
private const val DescriptorEvictionChurnCount = 1032
private val FrameCounter = AtomicLong()
private val SwingFrameCounter = AtomicLong()
private val PopupFrameCounter = AtomicLong()

private fun churnColor(index: Int): Color {
    val rgb = (index * 1103515245 + 12345) and 0x00ffffff
    return Color(0xff000000.toInt() or rgb)
}

private fun invalidGradientColors(): List<Color> = List(17, ::churnColor)

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
        applyAutomationWindowFocusPolicy()
        contentPane.add(panel)
        pack()
        setLocationRelativeTo(null)
        isVisible = true
        panel.schedulePopupStressIfNeeded()
        panel.scheduleMenuStressIfNeeded()
        schedulePopupWindowStressIfNeeded()
        scheduleAutoResizeIfNeeded()
    }
}

private fun ComposePanel.schedulePopupStressIfNeeded() {
    if (!System.getProperty(PopupStressProperty, "false").toBoolean()) return

    val delayMillis = System.getProperty(PopupStressDelayMillisProperty, "1600").toIntOrNull() ?: 1600
    Timer(delayMillis) {
        val panel = PopupStressPanel().apply {
            name = "MagicJewelPopupStress"
            bounds = java.awt.Rectangle(96, 214, 266, 88)
        }
        val rootPane = SwingUtilities.getRootPane(this) ?: return@Timer
        val glassPane = JPanel(null).apply {
            isOpaque = false
            add(panel)
        }
        rootPane.glassPane = glassPane
        glassPane.isVisible = true
        glassPane.revalidate()
        glassPane.repaint(panel.bounds)
        System.err.println("$PopupShownMarker x=96 y=214 width=${panel.width} height=${panel.height}")
    }.apply {
        isRepeats = false
        start()
    }
}

private fun ComposePanel.scheduleMenuStressIfNeeded() {
    if (!System.getProperty(MenuStressProperty, "false").toBoolean()) return

    val delayMillis = System.getProperty(MenuStressDelayMillisProperty, "1650").toIntOrNull() ?: 1650
    Timer(delayMillis) {
        val menu = JPopupMenu("MagicJewelMenuStress").apply {
            name = "MagicJewelMenuStress"
            isLightWeightPopupEnabled = true
            border = BorderFactory.createLineBorder(AwtColor(255, 211, 61), 3)
            add(PopupStressPanel())
        }
        val x = (width - 372).coerceAtLeast(80)
        val y = 156
        menu.show(this, x, y)
        menu.revalidate()
        menu.repaint()
        System.err.println("$MenuShownMarker x=$x y=$y width=${menu.width} height=${menu.height}")
    }.apply {
        isRepeats = false
        start()
    }
}

private fun JFrame.schedulePopupWindowStressIfNeeded() {
    if (!System.getProperty(PopupWindowStressProperty, "false").toBoolean()) return

    val delayMillis = System.getProperty(PopupWindowStressDelayMillisProperty, "1700").toIntOrNull() ?: 1700
    Timer(delayMillis) {
        val dialog = JDialog(this, PopupWindowTitle).apply {
            isUndecorated = true
            applyAutomationWindowFocusPolicy()
            contentPane.add(PopupStressPanel())
            pack()
            val anchor = location
            setLocation(anchor.x + 96, anchor.y + 214)
            isVisible = true
        }
        System.err.println(
            "$PopupWindowShownMarker x=${dialog.x} y=${dialog.y} width=${dialog.width} height=${dialog.height}",
        )
    }.apply {
        isRepeats = false
        start()
    }
}

private fun java.awt.Window.applyAutomationWindowFocusPolicy() {
    if (!System.getProperty(BackgroundWindowProperty, "false").toBoolean()) return

    setFocusableWindowState(false)
    setAutoRequestFocus(false)
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
@OptIn(ExperimentalGraphicsApi::class, ExperimentalTextApi::class)
private fun MagicJewelApp() {
    val fixedFrameTicks = remember {
        System.getProperty(FixedFrameTicksProperty)?.toIntOrNull()
    }
    var ticks by remember { mutableIntStateOf(fixedFrameTicks ?: 0) }
    var repaintPulse by remember { mutableIntStateOf(0) }
    val composeTextEnabled = remember {
        System.getProperty(ComposeTextProperty, "true").toBoolean()
    }
    val composeImageEnabled = remember {
        System.getProperty(ComposeImageProperty, "false").toBoolean()
    }
    val composeImageBlendModeEnabled = remember {
        System.getProperty(ComposeImageBlendModeProperty, "false").toBoolean()
    }
    val composeImagePathEffectEnabled = remember {
        System.getProperty(ComposeImagePathEffectProperty, "false").toBoolean()
    }
    val composeImageShaderEnabled = remember {
        System.getProperty(ComposeImageShaderProperty, "false").toBoolean()
    }
    val composeImageShaderBlendModeEnabled = remember {
        System.getProperty(ComposeImageShaderBlendModeProperty, "false").toBoolean()
    }
    val composeInvalidImageShaderImageEnabled = remember {
        System.getProperty(ComposeInvalidImageShaderImageProperty, "false").toBoolean()
    }
    val composeRawImageShaderEnabled = remember {
        System.getProperty(ComposeRawImageShaderProperty, "false").toBoolean()
    }
    val composeColorShaderEnabled = remember {
        System.getProperty(ComposeColorShaderProperty, "false").toBoolean()
    }
    val composeColorShaderBlendModeEnabled = remember {
        System.getProperty(ComposeColorShaderBlendModeProperty, "false").toBoolean()
    }
    val composeDescriptorStrokeShaderEnabled = remember {
        System.getProperty(ComposeDescriptorStrokeShaderProperty, "false").toBoolean()
    }
    val composeOpaqueShaderEnabled = remember {
        System.getProperty(ComposeOpaqueShaderProperty, "false").toBoolean()
    }
    val composeCompositeOpaqueShaderEnabled = remember {
        System.getProperty(ComposeCompositeOpaqueShaderProperty, "false").toBoolean()
    }
    val composeNoiseShaderEnabled = remember {
        System.getProperty(ComposeNoiseShaderProperty, "false").toBoolean()
    }
    val composeTurbulenceShaderEnabled = remember {
        System.getProperty(ComposeTurbulenceShaderProperty, "false").toBoolean()
    }
    val composeGradientShadersEnabled = remember {
        System.getProperty(ComposeGradientShadersProperty, "false").toBoolean()
    }
    val composeRawLinearGradientShaderEnabled = remember {
        System.getProperty(ComposeRawLinearGradientShaderProperty, "false").toBoolean()
    }
    val composeRawRadialGradientShaderEnabled = remember {
        System.getProperty(ComposeRawRadialGradientShaderProperty, "false").toBoolean()
    }
    val composeRawSweepGradientShaderEnabled = remember {
        System.getProperty(ComposeRawSweepGradientShaderProperty, "false").toBoolean()
    }
    val composeRawConicalGradientShaderEnabled = remember {
        System.getProperty(ComposeRawConicalGradientShaderProperty, "false").toBoolean()
    }
    val composeRawNoiseShaderEnabled = remember {
        System.getProperty(ComposeRawNoiseShaderProperty, "false").toBoolean()
    }
    val composeRawTurbulenceShaderEnabled = remember {
        System.getProperty(ComposeRawTurbulenceShaderProperty, "false").toBoolean()
    }
    val composePictureShaderEnabled = remember {
        System.getProperty(ComposePictureShaderProperty, "false").toBoolean()
    }
    val composeTransformedShaderEnabled = remember {
        System.getProperty(ComposeTransformedShaderProperty, "false").toBoolean()
    }
    val composeImageShaderColorFilterEnabled = remember {
        System.getProperty(ComposeImageShaderColorFilterProperty, "false").toBoolean()
    }
    val composeCompositeShaderEnabled = remember {
        System.getProperty(ComposeCompositeShaderProperty, "false").toBoolean()
    }
    val composeCompositeNoiseShaderEnabled = remember {
        System.getProperty(ComposeCompositeNoiseShaderProperty, "false").toBoolean()
    }
    val composeCompositeShaderColorFilterEnabled = remember {
        System.getProperty(ComposeCompositeShaderColorFilterProperty, "false").toBoolean()
    }
    val composeRuntimeEffectShaderEnabled = remember {
        System.getProperty(ComposeRuntimeEffectShaderProperty, "false").toBoolean()
    }
    val composeRawRuntimeEffectShaderEnabled = remember {
        System.getProperty(ComposeRawRuntimeEffectShaderProperty, "false").toBoolean()
    }
    val composeRuntimeEffectShaderColorFilterEnabled = remember {
        System.getProperty(ComposeRuntimeEffectShaderColorFilterProperty, "false").toBoolean()
    }
    val composeLinearGradientShaderColorFilterEnabled = remember {
        System.getProperty(ComposeLinearGradientShaderColorFilterProperty, "false").toBoolean()
    }
    val composeRadialGradientShaderColorFilterEnabled = remember {
        System.getProperty(ComposeRadialGradientShaderColorFilterProperty, "false").toBoolean()
    }
    val composeSweepGradientShaderColorFilterEnabled = remember {
        System.getProperty(ComposeSweepGradientShaderColorFilterProperty, "false").toBoolean()
    }
    val composeRuntimeEffectPureColorEnabled = remember {
        System.getProperty(ComposeRuntimeEffectPureColorProperty, "false").toBoolean()
    }
    val composeRuntimeEffectUniformOnlyEnabled = remember {
        System.getProperty(ComposeRuntimeEffectUniformOnlyProperty, "false").toBoolean()
    }
    val composeRuntimeEffectChildOnlyEnabled = remember {
        System.getProperty(ComposeRuntimeEffectChildOnlyProperty, "false").toBoolean()
    }
    val composeRuntimeEffectInvalidUniformSchemaEnabled = remember {
        System.getProperty(ComposeRuntimeEffectInvalidUniformSchemaProperty, "false").toBoolean()
    }
    val composeRuntimeEffectInvalidChildSchemaEnabled = remember {
        System.getProperty(ComposeRuntimeEffectInvalidChildSchemaProperty, "false").toBoolean()
    }
    val composeRuntimeEffectInvalidNestedChildEnabled = remember {
        System.getProperty(ComposeRuntimeEffectInvalidNestedChildProperty, "false").toBoolean()
    }
    val composeRuntimeEffectBadChildEnabled = remember {
        System.getProperty(ComposeRuntimeEffectBadChildProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterProperty, "false").toBoolean()
    }
    val composeRuntimeEffectStableColorFilterEnabled = remember {
        System.getProperty(ComposeRuntimeEffectStableColorFilterProperty, "false").toBoolean()
    }
    val composeRawRuntimeEffectColorFilterEnabled = remember {
        System.getProperty(ComposeRawRuntimeEffectColorFilterProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterChildEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterChildProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterBadChildEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterBadChildProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterInvalidUniformSchemaEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterInvalidUniformSchemaProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterInvalidChildSchemaEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterInvalidChildSchemaProperty, "false").toBoolean()
    }
    val composeRuntimeEffectColorFilterInvalidNestedChildEnabled = remember {
        System.getProperty(ComposeRuntimeEffectColorFilterInvalidNestedChildProperty, "false").toBoolean()
    }
    val composeImageFilterEnabled = remember {
        System.getProperty(ComposeImageFilterProperty, "false").toBoolean()
    }
    val composeImageColorMatrixFilterEnabled = remember {
        System.getProperty(ComposeImageColorMatrixFilterProperty, "false").toBoolean()
    }
    val composeImageRawTableColorFilterEnabled = remember {
        System.getProperty(ComposeImageRawTableColorFilterProperty, "false").toBoolean()
    }
    val composeRawBlendColorFilterEnabled = remember {
        System.getProperty(ComposeRawBlendColorFilterProperty, "false").toBoolean()
    }
    val composeRawTableColorFilterEnabled = remember {
        System.getProperty(ComposeRawTableColorFilterProperty, "false").toBoolean()
    }
    val composeColorFilterEnabled = remember {
        System.getProperty(ComposeColorFilterProperty, "false").toBoolean()
    }
    val composeColorFilterBlendModeEnabled = remember {
        System.getProperty(ComposeColorFilterBlendModeProperty, "false").toBoolean()
    }
    val composeColorMatrixFilterEnabled = remember {
        System.getProperty(ComposeColorMatrixFilterProperty, "false").toBoolean()
    }
    val composeInvalidColorMatrixFilterEnabled = remember {
        System.getProperty(ComposeInvalidColorMatrixFilterProperty, "false").toBoolean()
    }
    val composeLightingFilterEnabled = remember {
        System.getProperty(ComposeLightingFilterProperty, "false").toBoolean()
    }
    val composeDescriptorEvictionEnabled = remember {
        System.getProperty(ComposeDescriptorEvictionProperty, "false").toBoolean()
    }
    val composePathEffectEnabled = remember {
        System.getProperty(ComposePathEffectProperty, "false").toBoolean()
    }
    val composePathEffectColorFilterEnabled = remember {
        System.getProperty(ComposePathEffectColorFilterProperty, "false").toBoolean()
    }
    val composeRawDiscretePathEffectEnabled = remember {
        System.getProperty(ComposeRawDiscretePathEffectProperty, "false").toBoolean()
    }
    val composeBlendModeEnabled = remember {
        System.getProperty(ComposeBlendModeProperty, "false").toBoolean()
    }
    val composeGraphicsLayerEnabled = remember {
        System.getProperty(ComposeGraphicsLayerProperty, "false").toBoolean()
    }
    val composeGraphicsLayerClipEnabled = remember {
        System.getProperty(ComposeGraphicsLayerClipProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRoundClipEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRoundClipProperty, "false").toBoolean()
    }
    val composeGraphicsLayerPathClipEnabled = remember {
        System.getProperty(ComposeGraphicsLayerPathClipProperty, "false").toBoolean()
    }
    val composeGraphicsLayerBlendModeEnabled = remember {
        System.getProperty(ComposeGraphicsLayerBlendModeProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidBlendModeEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidBlendModeProperty, "false").toBoolean()
    }
    val composeGraphicsLayerUnrecordedEnabled = remember {
        System.getProperty(ComposeGraphicsLayerUnrecordedProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidSizeWidthEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidSizeWidthProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidSizeHeightEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidSizeHeightProperty, "false").toBoolean()
    }
    val composeGraphicsLayerColorFilterEnabled = remember {
        System.getProperty(ComposeGraphicsLayerColorFilterProperty, "false").toBoolean()
    }
    val composeGraphicsLayerColorMatrixFilterEnabled = remember {
        System.getProperty(ComposeGraphicsLayerColorMatrixFilterProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRawColorFilterEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRawColorFilterProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRawTableColorFilterEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRawTableColorFilterProperty, "false").toBoolean()
    }
    val composeGraphicsLayerChildUnsupportedEnabled = remember {
        System.getProperty(ComposeGraphicsLayerChildUnsupportedProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRenderEffectEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRenderEffectProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRawImageFilterEffectEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRawImageFilterEffectProperty, "false").toBoolean()
    }
    val composeGraphicsLayerOffsetEffectEnabled = remember {
        System.getProperty(ComposeGraphicsLayerOffsetEffectProperty, "false").toBoolean()
    }
    val composeGraphicsLayerChainedRenderEffectEnabled = remember {
        System.getProperty(ComposeGraphicsLayerChainedRenderEffectProperty, "false").toBoolean()
    }
    val composeGraphicsLayerBlurChainedRenderEffectEnabled = remember {
        System.getProperty(ComposeGraphicsLayerBlurChainedRenderEffectProperty, "false").toBoolean()
    }
    val composeGraphicsLayerShadowEnabled = remember {
        System.getProperty(ComposeGraphicsLayerShadowProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidAlphaEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidAlphaProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidShadowElevationEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidShadowElevationProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidShadowPathEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidShadowPathProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRotationXEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRotationXProperty, "false").toBoolean()
    }
    val composeGraphicsLayerRotationYEnabled = remember {
        System.getProperty(ComposeGraphicsLayerRotationYProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidScaleXEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidScaleXProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidScaleYEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidScaleYProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidRotationZEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidRotationZProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidTranslationXEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidTranslationXProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidTranslationYEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidTranslationYProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidRotationXEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidRotationXProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidRotationYEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidRotationYProperty, "false").toBoolean()
    }
    val composeGraphicsLayerScaleTranslateEnabled = remember {
        System.getProperty(ComposeGraphicsLayerScaleTranslateProperty, "false").toBoolean()
    }
    val composeGraphicsLayerNearCameraEnabled = remember {
        System.getProperty(ComposeGraphicsLayerNearCameraProperty, "false").toBoolean()
    }
    val composeGraphicsLayerInvalidCameraDistanceEnabled = remember {
        System.getProperty(ComposeGraphicsLayerInvalidCameraDistanceProperty, "false").toBoolean()
    }
    val composeGraphicsLayerOffCenterPivotEnabled = remember {
        System.getProperty(ComposeGraphicsLayerOffCenterPivotProperty, "false").toBoolean()
    }
    val composeGraphicsLayerOffscreenEnabled = remember {
        System.getProperty(ComposeGraphicsLayerOffscreenProperty, "false").toBoolean()
    }
    val composeGraphicsLayerModulateAlphaEnabled = remember {
        System.getProperty(ComposeGraphicsLayerModulateAlphaProperty, "false").toBoolean()
    }
    val swingIslandEnabled = remember {
        System.getProperty(SwingIslandProperty, "true").toBoolean()
    }
    val composeTransformEnabled = remember {
        System.getProperty(ComposeTransformProperty, "false").toBoolean()
    }
    val composeInvalidBlendLayerBoundsEnabled = remember {
        System.getProperty(ComposeInvalidBlendLayerBoundsProperty, "false").toBoolean()
    }
    val composeConcatTransformEnabled = remember {
        System.getProperty(ComposeConcatTransformProperty, "false").toBoolean()
    }
    val composeInvalidConcatTransformEnabled = remember {
        System.getProperty(ComposeInvalidConcatTransformProperty, "false").toBoolean()
    }
    val composeSkewTransformEnabled = remember {
        System.getProperty(ComposeSkewTransformProperty, "false").toBoolean()
    }
    val composeVerticesEnabled = remember {
        System.getProperty(ComposeVerticesProperty, "false").toBoolean()
    }
    val composeVerticesRawColorFilterEnabled = remember {
        System.getProperty(ComposeVerticesRawColorFilterProperty, "false").toBoolean()
    }
    val composeVerticesInvalidBlendModeEnabled = remember {
        System.getProperty(ComposeVerticesInvalidBlendModeProperty, "false").toBoolean()
    }
    val composeSaveLayerEnabled = remember {
        System.getProperty(ComposeSaveLayerProperty, "false").toBoolean()
    }
    val composeSaveLayerFilterEnabled = remember {
        System.getProperty(ComposeSaveLayerFilterProperty, "false").toBoolean()
    }
    val composeSaveLayerColorMatrixFilterEnabled = remember {
        System.getProperty(ComposeSaveLayerColorMatrixFilterProperty, "false").toBoolean()
    }
    val composeSaveLayerBlendModeEnabled = remember {
        System.getProperty(ComposeSaveLayerBlendModeProperty, "false").toBoolean()
    }
    val composeSaveLayerBlendColorFilterEnabled = remember {
        System.getProperty(ComposeSaveLayerBlendColorFilterProperty, "false").toBoolean()
    }
    val composeSaveLayerRawColorFilterEnabled = remember {
        System.getProperty(ComposeSaveLayerRawColorFilterProperty, "false").toBoolean()
    }
    val composeSaveLayerRawTableColorFilterEnabled = remember {
        System.getProperty(ComposeSaveLayerRawTableColorFilterProperty, "false").toBoolean()
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
    val composeInvalidClipPathEnabled = remember {
        System.getProperty(ComposeInvalidClipPathProperty, "false").toBoolean()
    }
    val composeDrawPathEnabled = remember {
        System.getProperty(ComposeDrawPathProperty, "false").toBoolean()
    }
    val composeInvalidDrawPathEnabled = remember {
        System.getProperty(ComposeInvalidDrawPathProperty, "false").toBoolean()
    }
    val composeInvalidGradientPathEnabled = remember {
        System.getProperty(ComposeInvalidGradientPathProperty, "false").toBoolean()
    }
    val composeDrawArcEnabled = remember {
        System.getProperty(ComposeDrawArcProperty, "false").toBoolean()
    }
    val composeDrawRoundRectEnabled = remember {
        System.getProperty(ComposeDrawRoundRectProperty, "false").toBoolean()
    }
    val composePointLinesEnabled = remember {
        System.getProperty(ComposePointLinesProperty, "false").toBoolean()
    }
    val composePointDotsEnabled = remember {
        System.getProperty(ComposePointDotsProperty, "false").toBoolean()
    }
    val composeInvalidPointDotsEnabled = remember {
        System.getProperty(ComposeInvalidPointDotsProperty, "false").toBoolean()
    }
    val composeLinearGradientEnabled = remember {
        System.getProperty(ComposeLinearGradientProperty, "false").toBoolean()
    }
    val composeLinearGradientBlendModeEnabled = remember {
        System.getProperty(ComposeLinearGradientBlendModeProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientStopsEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientStopsProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientPointsEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientPointsProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientColorCountEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientColorCountProperty, "false").toBoolean()
    }
    val composeLinearGradientStrokeEnabled = remember {
        System.getProperty(ComposeLinearGradientStrokeProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientStrokeWidthEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientStrokeWidthProperty, "false").toBoolean()
    }
    val composeLinearGradientRoundRectEnabled = remember {
        System.getProperty(ComposeLinearGradientRoundRectProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeInvalidLinearGradientStrokeRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidLinearGradientStrokeRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeLinearGradientPathEnabled = remember {
        System.getProperty(ComposeLinearGradientPathProperty, "false").toBoolean()
    }
    val composeLinearGradientPathBlendModeEnabled = remember {
        System.getProperty(ComposeLinearGradientPathBlendModeProperty, "false").toBoolean()
    }
    val composeRadialGradientEnabled = remember {
        System.getProperty(ComposeRadialGradientProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientStopsEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientStopsProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientGeometryEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientGeometryProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientColorCountEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientColorCountProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientStrokeWidthEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientStrokeWidthProperty, "false").toBoolean()
    }
    val composeRadialGradientRoundRectEnabled = remember {
        System.getProperty(ComposeRadialGradientRoundRectProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeInvalidRadialGradientStrokeRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidRadialGradientStrokeRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeRadialGradientStrokeBlendModeEnabled = remember {
        System.getProperty(ComposeRadialGradientStrokeBlendModeProperty, "false").toBoolean()
    }
    val composeRadialGradientPathEnabled = remember {
        System.getProperty(ComposeRadialGradientPathProperty, "false").toBoolean()
    }
    val composeSweepGradientEnabled = remember {
        System.getProperty(ComposeSweepGradientProperty, "false").toBoolean()
    }
    val composeInvalidSweepGradientColorCountEnabled = remember {
        System.getProperty(ComposeInvalidSweepGradientColorCountProperty, "false").toBoolean()
    }
    val composeInvalidSweepGradientGeometryEnabled = remember {
        System.getProperty(ComposeInvalidSweepGradientGeometryProperty, "false").toBoolean()
    }
    val composeInvalidSweepGradientStrokeWidthEnabled = remember {
        System.getProperty(ComposeInvalidSweepGradientStrokeWidthProperty, "false").toBoolean()
    }
    val composeSweepGradientRoundRectEnabled = remember {
        System.getProperty(ComposeSweepGradientRoundRectProperty, "false").toBoolean()
    }
    val composeInvalidSweepGradientRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidSweepGradientRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeInvalidSweepGradientStrokeRoundRectRadiusEnabled = remember {
        System.getProperty(ComposeInvalidSweepGradientStrokeRoundRectRadiusProperty, "false").toBoolean()
    }
    val composeSweepGradientRoundRectBlendModeEnabled = remember {
        System.getProperty(ComposeSweepGradientRoundRectBlendModeProperty, "false").toBoolean()
    }
    val composeSweepGradientPathEnabled = remember {
        System.getProperty(ComposeSweepGradientPathProperty, "false").toBoolean()
    }
    val composeGradientPathStrokeEnabled = remember {
        System.getProperty(ComposeGradientPathStrokeProperty, "false").toBoolean()
    }
    val unsupportedTextEnabled = remember {
        System.getProperty(UnsupportedTextProperty, "false").toBoolean()
    }
    val paragraphLayoutTextEnabled = remember {
        System.getProperty(ParagraphLayoutTextProperty, "false").toBoolean()
    }
    val genericFontTextEnabled = remember {
        System.getProperty(GenericFontTextProperty, "false").toBoolean()
    }
    val loadedFontDataTextEnabled = remember {
        System.getProperty(LoadedFontDataTextProperty, "false").toBoolean()
    }
    val loadedFontDataFamily = remember(loadedFontDataTextEnabled) {
        if (loadedFontDataTextEnabled) {
            FontFamily(ComposeFont("magic-jewel-loaded-font-data", loadMagicJewelFontResourceBytes()))
        } else {
            null
        }
    }
    val resourceFontTextEnabled = remember {
        System.getProperty(ResourceFontTextProperty, "false").toBoolean()
    }
    val systemFontTextEnabled = remember {
        System.getProperty(SystemFontTextProperty, "false").toBoolean()
    }
    val imageCacheChurnEnabled = remember {
        System.getProperty(ImageCacheChurnProperty, "false").toBoolean()
    }
    val stableImageCacheChurnEnabled = remember {
        System.getProperty(StableImageCacheChurnProperty, "false").toBoolean()
    }
    val invalidSweepGradientEnabled = remember {
        System.getProperty(InvalidSweepGradientProperty, "false").toBoolean()
    }
    val imageProbe = remember(
        composeImageEnabled,
        composeImageBlendModeEnabled,
        composeImagePathEffectEnabled,
        composeImageShaderEnabled,
        composeImageShaderBlendModeEnabled,
        composeInvalidImageShaderImageEnabled,
        composeRawImageShaderEnabled,
        composeImageShaderColorFilterEnabled,
        composeImageFilterEnabled,
        composeImageColorMatrixFilterEnabled,
        composeImageRawTableColorFilterEnabled,
    ) {
        if (composeImageEnabled ||
            composeImageBlendModeEnabled ||
            composeImagePathEffectEnabled ||
            composeImageShaderEnabled ||
            composeImageShaderBlendModeEnabled ||
            composeInvalidImageShaderImageEnabled ||
            composeRawImageShaderEnabled ||
            composeDescriptorStrokeShaderEnabled ||
            composeImageShaderColorFilterEnabled ||
            composeImageFilterEnabled ||
            composeImageColorMatrixFilterEnabled ||
            composeImageRawTableColorFilterEnabled
        ) {
            createImageProbe(oversized = composeInvalidImageShaderImageEnabled)
        } else {
            null
        }
    }
    val rawImageShader = remember(composeGraphicsLayerChildUnsupportedEnabled) {
        if (composeGraphicsLayerChildUnsupportedEnabled) {
            createRawSkiaImageShader().asComposeShader()
        } else {
            null
        }
    }
    val infiniteTransition = rememberInfiniteTransition(label = "magic-jewel-busy-loop")
    val animatedPhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 900, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "always-on-progress-phase",
    )
    val phase = fixedAnimationPhase() ?: animatedPhase

    LaunchedEffect(fixedFrameTicks) {
        if (fixedFrameTicks == null) {
            while (true) {
                delay(250)
                ticks++
            }
        } else {
            while (true) {
                delay(33)
                repaintPulse++
            }
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
            DefaultButton(onClick = { ticks++ }) {
                ButtonLabel("Pulse", color = Color.White)
            }
            OutlinedButton(onClick = { ticks = 0 }) {
                ButtonLabel("Reset")
            }
            MagicLabel("frames=$ticks", composeTextEnabled, modifier = Modifier.align(Alignment.CenterVertically), width = 92.dp)
        }

        Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
            Canvas(
                modifier = Modifier.fillMaxSize().drawWithContent {
                    repaintPulse.hashCode()
                    drawContent()
                }
            ) {
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
                if (composeImageBlendModeEnabled) {
                    imageProbe?.let {
                        drawIntoCanvas { canvas ->
                            canvas.drawImageRect(
                                image = it,
                                srcOffset = IntOffset.Zero,
                                srcSize = IntSize(it.width, it.height),
                                dstOffset = IntOffset((size.width - 640f).toInt(), (size.height - 126f).toInt()),
                                dstSize = IntSize(104, 104),
                                paint = Paint().apply {
                                    blendMode = BlendMode.Plus
                                },
                            )
                        }
                    }
                }
                if (composeImagePathEffectEnabled) {
                    imageProbe?.let {
                        drawIntoCanvas { canvas ->
                            canvas.drawImageRect(
                                image = it,
                                srcOffset = IntOffset.Zero,
                                srcSize = IntSize(it.width, it.height),
                                dstOffset = IntOffset((size.width - 332f).toInt(), (size.height - 126f).toInt()),
                                dstSize = IntSize(96, 96),
                                paint = Paint().apply {
                                    pathEffect = PathEffect.dashPathEffect(floatArrayOf(8f, 4f), 0f)
                                },
                            )
                        }
                    }
                }
                if (composeImageShaderEnabled) {
                    imageProbe?.let {
                        drawRect(
                            brush = ShaderBrush(ImageShader(it, TileMode.Repeated, TileMode.Mirror)),
                            topLeft = Offset(size.width - 224f, size.height - 224f),
                            size = Size(140f, 116f),
                            alpha = 0.92f,
                        )
                    }
                }
                if (composeImageShaderBlendModeEnabled) {
                    imageProbe?.let {
                        drawRect(
                            brush = ShaderBrush(ImageShader(it, TileMode.Repeated, TileMode.Mirror)),
                            topLeft = Offset(size.width - 704f, size.height - 378f),
                            size = Size(140f, 116f),
                            alpha = 0.92f,
                            blendMode = BlendMode.Plus,
                        )
                    }
                }
                if (composeRawImageShaderEnabled) {
                    imageProbe?.let { image ->
                        val topLeft = Offset(size.width - 300f, size.height - 488f)
                        drawIntoCanvas { canvas ->
                            canvas.drawRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 140f,
                                bottom = topLeft.y + 116f,
                                paint = Paint().apply {
                                    shader = ImageShader(image, TileMode.Repeated, TileMode.Mirror)
                                },
                            )
                        }
                    }
                }
                if (composeColorShaderEnabled) {
                    drawRect(
                        brush = ShaderBrush(ColorShader(Color(0xFF22C55E))),
                        topLeft = Offset(size.width - 356f, size.height - 350f),
                        size = Size(112f, 78f),
                        alpha = 0.92f,
                    )
                }
                if (composeColorShaderBlendModeEnabled) {
                    drawRect(
                        brush = ShaderBrush(ColorShader(Color(0xFFFACC15))),
                        topLeft = Offset(size.width - 704f, size.height - 502f),
                        size = Size(112f, 78f),
                        alpha = 0.92f,
                        blendMode = BlendMode.Plus,
                    )
                }
                if (composeDescriptorStrokeShaderEnabled) {
                    val topLeft = Offset(size.width - 356f, size.height - 228f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 112f,
                            bottom = topLeft.y + 78f,
                            paint = Paint().apply {
                                style = PaintingStyle.Stroke
                                strokeWidth = 12f
                                shader = ColorShader(Color(0xFF22C55E))
                            },
                        )
                    }
                    imageProbe?.let {
                        val imageShaderTopLeft = topLeft + Offset(132f, 0f)
                        drawIntoCanvas { canvas ->
                            canvas.drawRect(
                                left = imageShaderTopLeft.x,
                                top = imageShaderTopLeft.y,
                                right = imageShaderTopLeft.x + 112f,
                                bottom = imageShaderTopLeft.y + 78f,
                                paint = Paint().apply {
                                    style = PaintingStyle.Stroke
                                    strokeWidth = 12f
                                    shader = ImageShader(it, TileMode.Repeated, TileMode.Mirror)
                                },
                            )
                        }
                    }
                }
                if (composeOpaqueShaderEnabled) {
                    val topLeft = Offset(size.width - 224f, size.height - 360f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = org.jetbrains.skia.Shader.makeColor(Color(0xFFEF4444).toArgb()).asComposeShader()
                            },
                        )
                    }
                }
                if (composeCompositeOpaqueShaderEnabled) {
                    val topLeft = Offset(size.width - 224f, size.height - 616f)
                    val shader = CompositeShader(
                        dst = LinearGradientShader(
                            from = topLeft,
                            to = topLeft + Offset(140f, 116f),
                            colors = listOf(Color(0xFF22D3EE), Color(0xFF312E81)),
                            colorStops = listOf(0f, 1f),
                            tileMode = TileMode.Clamp,
                        ),
                        src = org.jetbrains.skia.Shader.makeColor(Color(0xCCF97316).toArgb()).asComposeShader(),
                        blendMode = BlendMode.SrcOver,
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(140f, 116f),
                    )
                }
                if (composeNoiseShaderEnabled) {
                    val topLeft = Offset(size.width - 596f, size.height - 616f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = FractalNoiseShader(
                                    baseFrequencyX = 0.04f,
                                    baseFrequencyY = 0.06f,
                                    numOctaves = 4,
                                    seed = 3.5f,
                                )
                            },
                        )
                    }
                }
                if (composeTurbulenceShaderEnabled) {
                    val topLeft = Offset(size.width - 596f, size.height - 488f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = TurbulenceShader(
                                    baseFrequencyX = 0.035f,
                                    baseFrequencyY = 0.055f,
                                    numOctaves = 3,
                                    seed = 7.25f,
                                )
                            },
                        )
                    }
                }
                if (composeGradientShadersEnabled) {
                    val linearTopLeft = Offset(size.width - 740f, size.height - 616f)
                    drawRect(
                        brush = ShaderBrush(
                            LinearGradientShader(
                                from = linearTopLeft,
                                to = linearTopLeft + Offset(140f, 116f),
                                colors = listOf(Color(0xFF06B6D4), Color(0xFFFDE047), Color(0xFFEF4444)),
                                colorStops = listOf(0f, 0.46f, 1f),
                                tileMode = TileMode.Clamp,
                            )
                        ),
                        topLeft = linearTopLeft,
                        size = Size(140f, 116f),
                    )
                    val radialTopLeft = Offset(size.width - 740f, size.height - 488f)
                    drawRect(
                        brush = ShaderBrush(
                            RadialGradientShader(
                                center = radialTopLeft + Offset(92f, 42f),
                                radius = 88f,
                                colors = listOf(Color(0xFFFFFFFF), Color(0xAA8B5CF6), Color(0x00000000)),
                                colorStops = listOf(0f, 0.56f, 1f),
                                tileMode = TileMode.Clamp,
                            )
                        ),
                        topLeft = radialTopLeft,
                        size = Size(140f, 116f),
                    )
                    val sweepTopLeft = Offset(size.width - 740f, size.height - 232f)
                    drawRect(
                        brush = ShaderBrush(
                            SweepGradientShader(
                                center = sweepTopLeft + Offset(70f, 58f),
                                colors = listOf(Color(0xFF22D3EE), Color(0xFFFDE047), Color(0xFFEF4444), Color(0xFF22D3EE)),
                                colorStops = listOf(0f, 0.34f, 0.72f, 1f),
                            )
                        ),
                        topLeft = sweepTopLeft,
                        size = Size(140f, 116f),
                    )
                }
                if (composeRawLinearGradientShaderEnabled) {
                    val topLeft = Offset(size.width - 448f, size.height - 232f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = LinearGradientShader(
                                    from = topLeft,
                                    to = topLeft + Offset(140f, 116f),
                                    colors = RawGradientComposeColors,
                                    colorStops = RawGradientStops.toList(),
                                    tileMode = TileMode.Clamp,
                                )
                            },
                        )
                    }
                }
                if (composeRawRadialGradientShaderEnabled) {
                    val topLeft = Offset(size.width - 300f, size.height - 232f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = RadialGradientShader(
                                    center = topLeft + Offset(70f, 58f),
                                    radius = 76f,
                                    colors = RawGradientComposeColors,
                                    colorStops = RawGradientStops.toList(),
                                    tileMode = TileMode.Clamp,
                                )
                            },
                        )
                    }
                }
                if (composeRawSweepGradientShaderEnabled) {
                    val topLeft = Offset(size.width - 596f, size.height - 232f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = SweepGradientShader(
                                    center = topLeft + Offset(70f, 58f),
                                    colors = RawGradientComposeColors,
                                    colorStops = RawGradientStops.toList(),
                                )
                            },
                        )
                    }
                }
                if (composeRawConicalGradientShaderEnabled) {
                    val topLeft = Offset(size.width - 744f, size.height - 232f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = makeRawSkiaConicalGradientShader(
                                    topLeft.x + 28f,
                                    topLeft.y + 24f,
                                    12f,
                                    topLeft.x + 112f,
                                    topLeft.y + 92f,
                                    86f,
                                    RawGradientColors,
                                    RawGradientStops,
                                ).asComposeShader()
                            },
                        )
                    }
                }
                if (composeRawNoiseShaderEnabled) {
                    val topLeft = Offset(size.width - 448f, size.height - 488f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = FractalNoiseShader(
                                    baseFrequencyX = 0.04f,
                                    baseFrequencyY = 0.06f,
                                    numOctaves = 4,
                                    seed = 3.5f,
                                )
                            },
                        )
                    }
                }
                if (composeRawTurbulenceShaderEnabled) {
                    val topLeft = Offset(size.width - 448f, size.height - 360f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = TurbulenceShader(
                                    baseFrequencyX = 0.035f,
                                    baseFrequencyY = 0.055f,
                                    numOctaves = 3,
                                    seed = 7.25f,
                                )
                            },
                        )
                    }
                }
                if (composePictureShaderEnabled) {
                    val topLeft = Offset(size.width - 448f, size.height - 616f)
                    val picture = org.jetbrains.skia.PictureRecorder().let { recorder ->
                        val pictureCanvas = recorder.beginRecording(org.jetbrains.skia.Rect(0f, 0f, 48f, 48f))
                        pictureCanvas.drawRect(
                            org.jetbrains.skia.Rect(0f, 0f, 48f, 48f),
                            org.jetbrains.skia.Paint().apply { color = Color(0xFF0F172A).toArgb() },
                        )
                        pictureCanvas.drawCircle(
                            24f,
                            24f,
                            16f,
                            org.jetbrains.skia.Paint().apply { color = Color(0xFF38BDF8).toArgb() },
                        )
                        recorder.finishRecordingAsPicture()
                    }
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 140f,
                            bottom = topLeft.y + 116f,
                            paint = Paint().apply {
                                shader = picture.makeShader(
                                    org.jetbrains.skia.FilterTileMode.REPEAT,
                                    org.jetbrains.skia.FilterTileMode.REPEAT,
                                    org.jetbrains.skia.FilterMode.NEAREST,
                                ).asComposeShader()
                            },
                        )
                    }
                }
                if (composeTransformedShaderEnabled) {
                    val topLeft = Offset(size.width - 224f, size.height - 488f)
                    val shader = LinearGradientShader(
                        from = topLeft,
                        to = topLeft + Offset(140f, 116f),
                        colors = listOf(Color(0xFF06B6D4), Color(0xFFFDE047)),
                        colorStops = listOf(0f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    val brush = ShaderBrush(shader).apply {
                        transform = Matrix().apply { translate(x = 18f, y = 0f) }
                    }
                    drawRect(
                        brush = brush,
                        topLeft = topLeft,
                        size = Size(140f, 116f),
                    )
                }
                if (composeImageShaderColorFilterEnabled) {
                    imageProbe?.let {
                        val topLeft = Offset(size.width - 596f, size.height - 224f)
                        drawIntoCanvas { canvas ->
                            canvas.drawRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 140f,
                                bottom = topLeft.y + 116f,
                                paint = Paint().apply {
                                    shader = ImageShader(it, TileMode.Repeated, TileMode.Mirror)
                                    colorFilter = ColorFilter.tint(Color(0xFFFFD166), BlendMode.SrcIn)
                                    alpha = 0.92f
                                },
                            )
                        }
                        drawRect(color = Color.White, topLeft = topLeft, size = Size(140f, 116f), style = Stroke(width = 3f))
                    }
                }
                if (composeCompositeShaderEnabled) {
                    val topLeft = Offset(size.width - 372f, size.height - 360f)
                    val shader = CompositeShader(
                        dst = LinearGradientShader(
                            from = topLeft,
                            to = topLeft + Offset(152f, 112f),
                            colors = listOf(Color(0xFF06B6D4), Color(0xFFFDE047), Color(0xFFEF4444)),
                            colorStops = listOf(0f, 0.46f, 1f),
                            tileMode = TileMode.Clamp,
                        ),
                        src = RadialGradientShader(
                            center = topLeft + Offset(112f, 38f),
                            radius = 92f,
                            colors = listOf(Color(0xFFFFFFFF), Color(0xAA8B5CF6), Color(0x00000000)),
                            colorStops = listOf(0f, 0.54f, 1f),
                            tileMode = TileMode.Clamp,
                        ),
                        blendMode = BlendMode.SrcOver,
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeCompositeNoiseShaderEnabled) {
                    val topLeft = Offset(size.width - 372f, size.height - 360f)
                    val shader = CompositeShader(
                        dst = FractalNoiseShader(
                            baseFrequencyX = 0.035f,
                            baseFrequencyY = 0.052f,
                            numOctaves = 3,
                            seed = 5.5f,
                            tileWidth = 96,
                            tileHeight = 80,
                        ),
                        src = TurbulenceShader(
                            baseFrequencyX = 0.055f,
                            baseFrequencyY = 0.032f,
                            numOctaves = 2,
                            seed = 12.75f,
                            tileWidth = 80,
                            tileHeight = 96,
                        ),
                        blendMode = BlendMode.SrcOver,
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeCompositeShaderColorFilterEnabled) {
                    val topLeft = Offset(size.width - 736f, size.height - 488f)
                    val shader = CompositeShader(
                        dst = LinearGradientShader(
                            from = topLeft,
                            to = topLeft + Offset(152f, 112f),
                            colors = listOf(Color(0xFF06B6D4), Color(0xFFFDE047), Color(0xFFEF4444)),
                            colorStops = listOf(0f, 0.46f, 1f),
                            tileMode = TileMode.Clamp,
                        ),
                        src = RadialGradientShader(
                            center = topLeft + Offset(112f, 38f),
                            radius = 92f,
                            colors = listOf(Color(0xFFFFFFFF), Color(0xAA8B5CF6), Color(0x00000000)),
                            colorStops = listOf(0f, 0.54f, 1f),
                            tileMode = TileMode.Clamp,
                        ),
                        blendMode = BlendMode.SrcOver,
                    )
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 112f,
                            paint = Paint().apply {
                                this.shader = shader
                                colorFilter = ColorFilter.tint(Color(0xFFFDE047), BlendMode.SrcIn)
                            },
                        )
                    }
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRuntimeEffectPureColorEnabled) {
                    val topLeft = Offset(size.width - 740f, size.height - 360f)
                    val shader = RuntimeEffectShader(
                        sksl = """
                            half4 main(float2 p) {
                                float stripe = step(0.5, fract((p.x + p.y) * 0.025));
                                return half4(mix(half3(0.10, 0.65, 0.95), half3(0.95, 0.20, 0.55), stripe), 1.0);
                            }
                        """.trimIndent(),
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRawRuntimeEffectShaderEnabled) {
                    val topLeft = Offset(size.width - 740f, size.height - 104f)
                    val shader = org.jetbrains.skia.RuntimeEffect.makeForShader(
                        """
                            half4 main(float2 p) {
                                float stripe = step(0.5, fract((p.x * 0.06) + (p.y * 0.03)));
                                return half4(mix(half3(0.94, 0.38, 0.18), half3(0.18, 0.82, 0.74), stripe), 1.0);
                            }
                        """.trimIndent(),
                    ).makeShader(null, null, null).asComposeShader()
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 72f),
                    )
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 72f), style = Stroke(width = 3f))
                }
                if (composeRuntimeEffectUniformOnlyEnabled) {
                    val topLeft = Offset(size.width - 740f, size.height - 232f)
                    val shader = RuntimeEffectShader(
                        sksl = """
                            uniform float phase;
                            half4 main(float2 p) {
                                float wave = 0.5 + 0.5 * sin(p.x * 0.08 + phase * 6.28318);
                                return half4(wave, 0.28, 1.0 - wave, 1.0);
                            }
                        """.trimIndent(),
                        uniforms = floatArrayOf(phase),
                        uniformSchema = listOf(
                            RuntimeEffectUniform(
                                if (composeRuntimeEffectInvalidUniformSchemaEnabled) "1phase" else "phase",
                                0,
                                1,
                            )
                        ),
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRuntimeEffectChildOnlyEnabled) {
                    val topLeft = Offset(size.width - 372f, size.height - 232f)
                    val child = RadialGradientShader(
                        center = topLeft + Offset(82f, 54f),
                        radius = 92f,
                        colors = listOf(Color(0xFFFFF7AD), Color(0xFF38BDF8), Color(0xFF312E81)),
                        colorStops = listOf(0f, 0.52f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    val accentChild = LinearGradientShader(
                        from = topLeft,
                        to = topLeft + Offset(152f, 112f),
                        colors = listOf(Color(0xFF7C3AED), Color(0xFF14B8A6), Color(0xFFFFF7AD)),
                        colorStops = listOf(0f, 0.46f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    val shader = RuntimeEffectShader(
                        sksl = """
                            uniform shader content;
                            uniform shader accent;
                            half4 main(float2 p) {
                                half4 base = content.eval(p);
                                half4 glow = accent.eval(p);
                                return half4(mix(base.bgr, glow.rgb, 0.28), 1.0);
                            }
                        """.trimIndent(),
                        namedChildren = listOf(
                            RuntimeEffectChild(
                                if (composeRuntimeEffectInvalidChildSchemaEnabled) "1content" else "content",
                                if (composeRuntimeEffectInvalidNestedChildEnabled) {
                                    RuntimeEffectShader(
                                        sksl = """
                                            uniform float phase;
                                            half4 main(float2 p) {
                                                return half4(phase, 0.25, 0.75, 1.0);
                                            }
                                        """.trimIndent(),
                                        uniforms = floatArrayOf(phase),
                                        uniformSchema = listOf(RuntimeEffectUniform("1phase", 0, 1)),
                                    )
                                } else {
                                    child
                                },
                            ),
                            RuntimeEffectChild("accent", accentChild),
                        ),
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRuntimeEffectShaderColorFilterEnabled) {
                    val topLeft = Offset(size.width - 556f, size.height - 488f)
                    val shader = RuntimeEffectShader(
                        sksl = """
                            uniform float phase;
                            half4 main(float2 p) {
                                float wave = 0.5 + 0.5 * sin((p.x + p.y) * 0.045 + phase * 6.28318);
                                return half4(wave, 0.22, 1.0 - wave, 1.0);
                            }
                        """.trimIndent(),
                        uniforms = floatArrayOf(phase),
                        uniformSchema = listOf(RuntimeEffectUniform("phase", 0, 1)),
                    )
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 112f,
                            paint = Paint().apply {
                                this.shader = shader
                                colorFilter = ColorFilter.tint(Color(0xFFFFD166), BlendMode.SrcIn)
                            },
                        )
                    }
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeLinearGradientShaderColorFilterEnabled) {
                    val topLeft = Offset(size.width - 376f, size.height - 488f)
                    val shader = LinearGradientShader(
                        from = topLeft,
                        to = topLeft + Offset(152f, 112f),
                        colors = listOf(Color(0xFF22D3EE), Color(0xFFFDE047), Color(0xFFEC4899)),
                        colorStops = listOf(0f, 0.52f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 112f,
                            paint = Paint().apply {
                                this.shader = shader
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE), BlendMode.SrcIn)
                            },
                        )
                    }
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeSweepGradientShaderColorFilterEnabled) {
                    val topLeft = Offset(size.width - 376f, size.height - 360f)
                    val shader = SweepGradientShader(
                        center = topLeft + Offset(76f, 56f),
                        colors = listOf(Color(0xFF22D3EE), Color(0xFFFDE047), Color(0xFFEC4899), Color(0xFF22D3EE)),
                        colorStops = listOf(0f, 0.38f, 0.74f, 1f),
                    )
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 112f,
                            paint = Paint().apply {
                                this.shader = shader
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE), BlendMode.SrcIn)
                            },
                        )
                    }
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRadialGradientShaderColorFilterEnabled) {
                    val topLeft = Offset(size.width - 196f, size.height - 360f)
                    val shader = RadialGradientShader(
                        center = topLeft + Offset(76f, 56f),
                        radius = 88f,
                        colors = listOf(Color(0xFFF97316), Color(0xFF22D3EE), Color(0xFF312E81)),
                        colorStops = listOf(0f, 0.48f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 112f,
                            paint = Paint().apply {
                                this.shader = shader
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE), BlendMode.SrcIn)
                            },
                        )
                    }
                    drawRect(color = Color.White, topLeft = topLeft, size = Size(152f, 112f), style = Stroke(width = 3f))
                }
                if (composeRuntimeEffectShaderEnabled) {
                    val topLeft = Offset(size.width - 556f, size.height - 360f)
                    val child = LinearGradientShader(
                        from = topLeft,
                        to = topLeft + Offset(152f, 112f),
                        colors = listOf(Color(0xFF22D3EE), Color(0xFFFDE047), Color(0xFFEC4899)),
                        colorStops = listOf(0f, 0.48f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    val accentChild = RadialGradientShader(
                        center = topLeft + Offset(74f, 50f),
                        radius = 96f,
                        colors = listOf(Color(0xFF0F172A), Color(0xFF38BDF8), Color(0xFFF8FAFC)),
                        colorStops = listOf(0f, 0.58f, 1f),
                        tileMode = TileMode.Clamp,
                    )
                    val shader = RuntimeEffectShader(
                        sksl = """
                            uniform shader content;
                            uniform shader accent;
                            uniform float phase;
                            half4 main(float2 p) {
                                half4 base = content.eval(p);
                                half4 glow = accent.eval(p);
                                float wave = 0.5 + 0.5 * sin(p.x * 0.045 + phase * 6.28318);
                                float band = smoothstep(0.15, 0.85, wave);
                                half3 tint = mix(half3(band, 0.18 + p.y * 0.003, 1.0 - band), glow.rgb, 0.25);
                                return half4(mix(base.rgb, tint, 0.55), 1.0);
                            }
                        """.trimIndent(),
                        uniforms = floatArrayOf(phase),
                        uniformSchema = listOf(RuntimeEffectUniform("phase", 0, 1)),
                        namedChildren = listOf(
                            RuntimeEffectChild(if (composeRuntimeEffectBadChildEnabled) "missingContent" else "content", child),
                            RuntimeEffectChild("accent", accentChild),
                        ),
                    )
                    drawRect(
                        brush = ShaderBrush(shader),
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(152f, 112f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeImageFilterEnabled) {
                    imageProbe?.let {
                        drawImage(
                            image = it,
                            topLeft = Offset(size.width - 332f, size.height - 210f),
                            colorFilter = ColorFilter.tint(Color(0xFF22D3EE)),
                        )
                    }
                }
                if (composeImageColorMatrixFilterEnabled) {
                    imageProbe?.let {
                        val matrix = ColorMatrix().apply {
                            this[0, 4] = 64f
                            this[1, 1] = 0.85f
                            this[2, 2] = 1.2f
                        }
                        drawImage(
                            image = it,
                            topLeft = Offset(size.width - 444f, size.height - 210f),
                            colorFilter = ColorFilter.colorMatrix(matrix),
                        )
                    }
                }
                if (composeImageRawTableColorFilterEnabled) {
                    imageProbe?.let {
                        val table = ByteArray(256) { index -> (index / 2).toByte() }
                        val colorFilter = org.jetbrains.skia.ColorFilter.makeTable(table).asComposeColorFilter()
                        drawImage(
                            image = it,
                            topLeft = Offset(size.width - 552f, size.height - 210f),
                            colorFilter = colorFilter,
                        )
                    }
                }
                if (composeColorFilterEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 380f,
                            top = 34f,
                            right = size.width - 268f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFFE879F9)
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE))
                            },
                        )
                    }
                }
                if (composeColorFilterBlendModeEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 380f,
                            top = 124f,
                            right = size.width - 268f,
                            bottom = 202f,
                            paint = Paint().apply {
                                color = Color(0xFFE879F9)
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE))
                                blendMode = BlendMode.Plus
                            },
                        )
                    }
                }
                if (composeRuntimeEffectColorFilterEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 244f,
                            top = 34f,
                            right = size.width - 132f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFFFFD166)
                                colorFilter = RuntimeEffectColorFilter(
                                    sksl = """
                                        uniform float phase;
                                        half4 main(half4 inColor) {
                                            return half4(inColor.r, inColor.g * phase, 1.0 - inColor.b * 0.35, inColor.a);
                                        }
                                    """.trimIndent(),
                                    uniforms = floatArrayOf(phase),
                                    uniformSchema = listOf(
                                        RuntimeEffectUniform(
                                            if (composeRuntimeEffectColorFilterInvalidUniformSchemaEnabled) "1phase"
                                            else "phase",
                                            0,
                                            1,
                                        )
                                    ),
                                )
                            },
                        )
                    }
                }
                if (composeRuntimeEffectStableColorFilterEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 372f,
                            top = 34f,
                            right = size.width - 260f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFF38BDF8)
                                colorFilter = RuntimeEffectColorFilter(
                                    sksl = """
                                        half4 main(half4 inColor) {
                                            return half4(1.0 - inColor.r * 0.35, inColor.g * 0.75, 0.95, inColor.a);
                                        }
                                    """.trimIndent(),
                                )
                            },
                        )
                    }
                }
                if (composeRawRuntimeEffectColorFilterEnabled) {
                    val colorFilter = org.jetbrains.skia.RuntimeEffect.makeForColorFilter(
                        """
                            half4 main(half4 color) {
                                return half4(color.b, color.r * 0.72, color.g, color.a);
                            }
                        """.trimIndent(),
                    ).let { effect ->
                        val method = effect.javaClass.getMethod(
                            "makeColorFilter",
                            org.jetbrains.skia.Data::class.java,
                            Array<org.jetbrains.skia.ColorFilter?>::class.java,
                        )
                        method.invoke(effect, null, null) as org.jetbrains.skia.ColorFilter
                    }.asComposeColorFilter()
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 556f,
                            top = 34f,
                            right = size.width - 444f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFF38BDF8)
                                this.colorFilter = colorFilter
                            },
                        )
                    }
                }
                if (composeRawBlendColorFilterEnabled) {
                    val colorFilter = org.jetbrains.skia.ColorFilter.makeBlend(
                        Color(0xFF22D3EE).toArgb(),
                        org.jetbrains.skia.BlendMode.SRC_IN,
                    ).asComposeColorFilter()
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 692f,
                            top = 34f,
                            right = size.width - 580f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFFE879F9)
                                this.colorFilter = colorFilter
                            },
                        )
                    }
                }
                if (composeRawTableColorFilterEnabled) {
                    val table = ByteArray(256) { index -> (255 - index).toByte() }
                    val colorFilter = org.jetbrains.skia.ColorFilter.makeTable(table).asComposeColorFilter()
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 820f,
                            top = 34f,
                            right = size.width - 708f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFF34D399)
                                this.colorFilter = colorFilter
                            },
                        )
                    }
                }
                if (composeRuntimeEffectColorFilterChildEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 124f,
                            top = 34f,
                            right = size.width - 24f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFFFFD166)
                                colorFilter = RuntimeEffectColorFilter(
                                    sksl = """
                                        uniform colorFilter content;
                                        uniform colorFilter accent;
                                        uniform float phase;
                                        half4 main(half4 inColor) {
                                            half4 base = content.eval(inColor);
                                            half4 glow = accent.eval(inColor);
                                            return half4(base.r, base.g * phase, mix(base.b, glow.b, 0.35), base.a);
                                        }
                                    """.trimIndent(),
                                    uniforms = floatArrayOf(phase),
                                    uniformSchema = listOf(RuntimeEffectUniform("phase", 0, 1)),
                                    namedChildren =
                                        if (composeRuntimeEffectColorFilterBadChildEnabled) {
                                            emptyList()
                                        } else {
                                            listOf(
                                                RuntimeEffectColorFilterChild(
                                                    if (composeRuntimeEffectColorFilterInvalidChildSchemaEnabled) {
                                                        "1content"
                                                    } else {
                                                        "content"
                                                    },
                                                    if (composeRuntimeEffectColorFilterInvalidNestedChildEnabled) {
                                                        RuntimeEffectColorFilter(
                                                            sksl = """
                                                                uniform float phase;
                                                                half4 main(half4 inColor) {
                                                                    return half4(
                                                                        inColor.r * phase,
                                                                        inColor.g,
                                                                        inColor.b,
                                                                        inColor.a
                                                                    );
                                                                }
                                                            """.trimIndent(),
                                                            uniforms = floatArrayOf(phase),
                                                            uniformSchema = listOf(RuntimeEffectUniform("1phase", 0, 1)),
                                                        )
                                                    } else {
                                                        ColorFilter.tint(Color(0xFFEF476F), BlendMode.SrcIn)
                                                    },
                                                ),
                                                RuntimeEffectColorFilterChild(
                                                    "accent",
                                                    ColorFilter.tint(Color(0xFF118AB2), BlendMode.SrcIn),
                                                ),
                                            )
                                        },
                                )
                            },
                        )
                    }
                }
                if (composeColorMatrixFilterEnabled || composeInvalidColorMatrixFilterEnabled) {
                    val matrix = ColorMatrix().apply {
                        this[0, 0] = if (composeInvalidColorMatrixFilterEnabled) Float.NaN else this[0, 0]
                        this[0, 4] = 64f
                        this[1, 1] = 0.78f
                        this[2, 2] = 1.14f
                    }
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 516f,
                            top = 34f,
                            right = size.width - 404f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFF38BDF8)
                                colorFilter = ColorFilter.colorMatrix(matrix)
                            },
                        )
                    }
                }
                if (composeLightingFilterEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 652f,
                            top = 34f,
                            right = size.width - 540f,
                            bottom = 112f,
                            paint = Paint().apply {
                                color = Color(0xFFF97316)
                                colorFilter = ColorFilter.lighting(
                                    multiply = Color(0xFFB0D0FF),
                                    add = Color(0xFF101820),
                                )
                            },
                        )
                    }
                }
                if (composeDescriptorEvictionEnabled) {
                    drawIntoCanvas { canvas ->
                        repeat(DescriptorEvictionChurnCount) { index ->
                            val column = index % 86
                            val row = index / 86
                            val left = 18f + column * 2f
                            val top = 154f + row * 2f
                            canvas.drawRect(
                                left = left,
                                top = top,
                                right = left + 1.5f,
                                bottom = top + 1.5f,
                                paint = Paint().apply {
                                    color = churnColor(index)
                                    colorFilter = ColorFilter.tint(churnColor(index + 2048))
                                },
                            )
                        }
                    }
                    repeat(DescriptorEvictionChurnCount) { index ->
                        val column = index % 86
                        val row = index / 86
                        val topLeft = Offset(220f + column * 2f, 154f + row * 2f)
                        val shader = CompositeShader(
                            dst = LinearGradientShader(
                                from = topLeft,
                                to = topLeft + Offset(1.5f, 1.5f),
                                colors = listOf(churnColor(index + 4096), churnColor(index + 8192)),
                                colorStops = listOf(0f, 1f),
                                tileMode = TileMode.Clamp,
                            ),
                            src = RadialGradientShader(
                                center = topLeft + Offset(0.75f, 0.75f),
                                radius = 1.25f,
                                colors = listOf(churnColor(index + 12288), churnColor(index + 16384)),
                                colorStops = listOf(0f, 1f),
                                tileMode = TileMode.Clamp,
                            ),
                            blendMode = BlendMode.SrcOver,
                        )
                        drawRect(
                            brush = ShaderBrush(shader),
                            topLeft = topLeft,
                            size = Size(1.5f, 1.5f),
                        )
                    }
                }
                if (composePathEffectEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawLine(
                            p1 = Offset(size.width - 404f, 142f),
                            p2 = Offset(size.width - 236f, 142f),
                            paint = Paint().apply {
                                color = Color(0xFFFFFFFF)
                                strokeWidth = 8f
                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(16f, 10f), 0f)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 408f,
                            top = 154f,
                            right = size.width - 238f,
                            bottom = 206f,
                            paint = Paint().apply {
                                color = Color(0xFFFFFFFF)
                                style = PaintingStyle.Stroke
                                strokeWidth = 6f
                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(18f, 8f), 2f)
                            },
                        )
                        canvas.drawRoundRect(
                            left = size.width - 408f,
                            top = 218f,
                            right = size.width - 238f,
                            bottom = 272f,
                            radiusX = 18f,
                            radiusY = 18f,
                            paint = Paint().apply {
                                color = Color(0xFFFFFFFF)
                                style = PaintingStyle.Stroke
                                strokeWidth = 6f
                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 9f), 4f)
                            },
                        )
                        val dashedPath = Path().apply {
                            moveTo(size.width - 414f, 300f)
                            cubicTo(size.width - 364f, 260f, size.width - 318f, 346f, size.width - 262f, 306f)
                            lineTo(size.width - 236f, 348f)
                        }
                        canvas.drawPath(
                            path = dashedPath,
                            paint = Paint().apply {
                                color = Color(0xFFFFFFFF)
                                style = PaintingStyle.Stroke
                                strokeWidth = 5f
                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(18f, 7f), 3f)
                            },
                        )
                        val corneredPath = Path().apply {
                            moveTo(size.width - 188f, 296f)
                            lineTo(size.width - 112f, 296f)
                            lineTo(size.width - 112f, 356f)
                            lineTo(size.width - 188f, 356f)
                            close()
                        }
                        canvas.drawPath(
                            path = corneredPath,
                            paint = Paint().apply {
                                color = Color(0xFFFFD54A)
                                style = PaintingStyle.Stroke
                                strokeWidth = 6f
                                pathEffect = PathEffect.cornerPathEffect(18f)
                            },
                        )
                        val stampedShape = Path().apply {
                            moveTo(0f, -5f)
                            lineTo(5f, 5f)
                            lineTo(-5f, 5f)
                            close()
                        }
                        val stampedPath = Path().apply {
                            moveTo(size.width - 188f, 390f)
                            cubicTo(size.width - 152f, 352f, size.width - 102f, 430f, size.width - 68f, 388f)
                        }
                        canvas.drawPath(
                            path = stampedPath,
                            paint = Paint().apply {
                                color = Color(0xFFFFFFFF)
                                style = PaintingStyle.Stroke
                                strokeWidth = 2f
                                pathEffect = PathEffect.stampedPathEffect(
                                    shape = stampedShape,
                                    advance = 18f,
                                    phase = 0f,
                                    style = StampedPathEffectStyle.Rotate,
                                )
                            },
                        )
                        val chainedPath = Path().apply {
                            moveTo(size.width - 188f, 456f)
                            lineTo(size.width - 70f, 456f)
                        }
                        canvas.drawPath(
                            path = chainedPath,
                            paint = Paint().apply {
                                color = Color(0xFFFFD54A)
                                style = PaintingStyle.Stroke
                                strokeWidth = 6f
                                pathEffect = PathEffect.chainPathEffect(
                                    outer = PathEffect.cornerPathEffect(10f),
                                    inner = PathEffect.stampedPathEffect(
                                        shape = stampedShape,
                                        advance = 22f,
                                        phase = 2f,
                                        style = StampedPathEffectStyle.Rotate,
                                    ),
                                )
                            },
                        )
                    }
                }
                if (composePathEffectColorFilterEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 520f, 392f)
                        cubicTo(size.width - 472f, 348f, size.width - 412f, 436f, size.width - 356f, 388f)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.drawPath(
                            path = path,
                            paint = Paint().apply {
                                color = Color(0xFFFFD54A)
                                style = PaintingStyle.Stroke
                                strokeWidth = 8f
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE), BlendMode.SrcIn)
                                pathEffect = PathEffect.cornerPathEffect(14f)
                            },
                        )
                    }
                }
                if (composeRawDiscretePathEffectEnabled) {
                    val pathEffect = org.jetbrains.skia.PathEffect.makeDiscrete(
                        segLength = 10f,
                        dev = 4f,
                        seed = 7,
                    ).asComposePathEffect()
                    val rawEffectPath = Path().apply {
                        moveTo(size.width - 738f, 326f)
                        cubicTo(size.width - 694f, 284f, size.width - 640f, 366f, size.width - 588f, 324f)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.drawPath(
                            path = rawEffectPath,
                            paint = Paint().apply {
                                color = Color(0xFFFFD54A)
                                style = PaintingStyle.Stroke
                                strokeWidth = 6f
                                this.pathEffect = pathEffect
                            },
                        )
                    }
                }
                if (composeBlendModeEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = size.width - 750f,
                            top = 54f,
                            right = size.width - 662f,
                            bottom = 118f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 730f,
                            top = 42f,
                            right = size.width - 640f,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                                blendMode = BlendMode.Screen
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 624f,
                            top = 54f,
                            right = size.width - 536f,
                            bottom = 118f,
                            paint = Paint().apply {
                                color = Color(0xFFFFD166)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 604f,
                            top = 42f,
                            right = size.width - 514f,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Multiply
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 520f,
                            top = 42f,
                            right = size.width - 430f,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFF14B8A6)
                                blendMode = BlendMode.Plus
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 412f,
                            top = 54f,
                            right = size.width - 324f,
                            bottom = 118f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 392f,
                            top = 42f,
                            right = size.width - 302f,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Overlay
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 412f,
                            top = 154f,
                            right = size.width - 324f,
                            bottom = 218f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 392f,
                            top = 142f,
                            right = size.width - 302f,
                            bottom = 228f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Darken
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 296f,
                            top = 154f,
                            right = size.width - 208f,
                            bottom = 218f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 276f,
                            top = 142f,
                            right = size.width - 186f,
                            bottom = 228f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                                blendMode = BlendMode.Lighten
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 180f,
                            top = 54f,
                            right = size.width - 92f,
                            bottom = 118f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 160f,
                            top = 42f,
                            right = size.width - 70f,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Difference
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 54f,
                            right = size.width - 4f,
                            bottom = 118f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 42f,
                            right = size.width,
                            bottom = 128f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                                blendMode = BlendMode.Exclusion
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 154f,
                            right = size.width - 4f,
                            bottom = 218f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 142f,
                            right = size.width,
                            bottom = 228f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.ColorDodge
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 254f,
                            right = size.width - 4f,
                            bottom = 318f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 242f,
                            right = size.width,
                            bottom = 328f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.ColorBurn
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 354f,
                            right = size.width - 4f,
                            bottom = 418f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 342f,
                            right = size.width,
                            bottom = 428f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Hardlight
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 454f,
                            right = size.width - 4f,
                            bottom = 518f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 442f,
                            right = size.width,
                            bottom = 528f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Softlight
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 554f,
                            right = size.width - 4f,
                            bottom = 618f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 542f,
                            right = size.width,
                            bottom = 628f,
                            paint = Paint().apply {
                                color = Color(0xFF7C3AED)
                                blendMode = BlendMode.Hue
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 654f,
                            right = size.width - 4f,
                            bottom = 718f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 642f,
                            right = size.width,
                            bottom = 728f,
                            paint = Paint().apply {
                                color = Color(0xFF9CA3AF)
                                blendMode = BlendMode.Saturation
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 754f,
                            right = size.width - 4f,
                            bottom = 818f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 742f,
                            right = size.width,
                            bottom = 828f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                                blendMode = BlendMode.Color
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 64f,
                            top = 854f,
                            right = size.width - 4f,
                            bottom = 918f,
                            paint = Paint().apply {
                                color = Color(0xFFFDE047)
                            },
                        )
                        canvas.drawRect(
                            left = size.width - 54f,
                            top = 842f,
                            right = size.width,
                            bottom = 928f,
                            paint = Paint().apply {
                                color = Color(0xFF1D4ED8)
                                blendMode = BlendMode.Luminosity
                            },
                        )
                    }
                }
                if (imageCacheChurnEnabled) {
                    repeat(260) { index ->
                        val imageTicks = if (stableImageCacheChurnEnabled) 0 else ticks
                        drawImage(
                            createChurnImage(index, imageTicks),
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
                if (composeConcatTransformEnabled) {
                    drawIntoCanvas { canvas ->
                        val matrix = Matrix().apply {
                            values[Matrix.ScaleX] = 1f
                            values[Matrix.SkewX] = 0.22f
                            values[Matrix.TranslateX] = size.width - 238f
                            values[Matrix.SkewY] = 0.04f
                            values[Matrix.ScaleY] = 1f
                            values[Matrix.TranslateY] = size.height - 172f
                        }
                        canvas.save()
                        canvas.concat(matrix)
                        canvas.drawRect(
                            left = 0f,
                            top = 0f,
                            right = 104f,
                            bottom = 46f,
                            paint = Paint().apply { color = Color(0xFF22D3EE) },
                        )
                        canvas.restore()
                    }
                }
                if (composeInvalidConcatTransformEnabled) {
                    drawIntoCanvas { canvas ->
                        val matrix = Matrix().apply {
                            values[Matrix.ScaleX] = 1f
                            values[Matrix.TranslateX] = Float.NaN
                            values[Matrix.ScaleY] = 1f
                            values[Matrix.TranslateY] = size.height - 172f
                        }
                        canvas.save()
                        canvas.concat(matrix)
                        canvas.drawRect(
                            left = 0f,
                            top = 0f,
                            right = 104f,
                            bottom = 46f,
                            paint = Paint().apply { color = Color(0xFFF97316) },
                        )
                        canvas.restore()
                    }
                }
                if (composeSkewTransformEnabled) {
                    drawIntoCanvas { canvas ->
                        canvas.save()
                        canvas.translate(size.width - 372f, size.height - 154f)
                        canvas.skew(0.32f, -0.08f)
                        canvas.drawRect(
                            left = 0f,
                            top = 0f,
                            right = 104f,
                            bottom = 46f,
                            paint = Paint().apply { color = Color(0xFFFDE047) },
                        )
                        canvas.restore()
                    }
                }
                if (composeVerticesEnabled) {
                    drawIntoCanvas { canvas ->
                        val topLeft = Offset(size.width - 216f, size.height - 154f)
                        canvas.drawVertices(
                            vertices = Vertices(
                                vertexMode = VertexMode.Triangles,
                                positions = listOf(
                                    topLeft,
                                    topLeft + Offset(112f, 12f),
                                    topLeft + Offset(32f, 88f),
                                ),
                                textureCoordinates = listOf(Offset.Zero, Offset(1f, 0f), Offset(0f, 1f)),
                                colors = listOf(Color(0xFFF97316), Color(0xFF22D3EE), Color(0xFFFDE047)),
                                indices = listOf(0, 1, 2),
                            ),
                            blendMode = BlendMode.SrcOver,
                            paint = Paint().apply {
                                if (composeVerticesRawColorFilterEnabled) {
                                    colorFilter = org.jetbrains.skia.ColorFilter.makeBlend(
                                        org.jetbrains.skia.Color.makeARGB(255, 34, 211, 238),
                                        org.jetbrains.skia.BlendMode.SRC_IN,
                                    ).asComposeColorFilter()
                                }
                            },
                        )
                    }
                }
                if (composeVerticesInvalidBlendModeEnabled) {
                    drawIntoCanvas { canvas ->
                        val topLeft = Offset(size.width - 216f, size.height - 154f)
                        canvas.drawVertices(
                            vertices = Vertices(
                                vertexMode = VertexMode.Triangles,
                                positions = listOf(
                                    topLeft,
                                    topLeft + Offset(112f, 12f),
                                    topLeft + Offset(32f, 88f),
                                ),
                                textureCoordinates = listOf(Offset.Zero, Offset(1f, 0f), Offset(0f, 1f)),
                                colors = listOf(Color(0xFFF97316), Color(0xFF22D3EE), Color(0xFFFDE047)),
                                indices = listOf(0, 1, 2),
                            ),
                            blendMode = BlendMode.Clear,
                            paint = Paint(),
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
                if (composeSaveLayerFilterEnabled) {
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.72f)
                        colorFilter = ColorFilter.tint(Color(0xFF22D3EE))
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFFF97316)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(size.width - 166f, size.height - 278f, size.width - 58f, size.height - 170f),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = size.width - 146f,
                            top = size.height - 258f,
                            right = size.width - 78f,
                            bottom = size.height - 190f,
                            paint = contentPaint,
                        )
                        canvas.restore()
                    }
                }
                if (composeSaveLayerColorMatrixFilterEnabled) {
                    val matrix = ColorMatrix().apply {
                        this[0, 0] = 1.1f
                        this[1, 1] = 0.82f
                        this[2, 2] = 1.18f
                        this[0, 4] = 18f
                    }
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.72f)
                        colorFilter = ColorFilter.colorMatrix(matrix)
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFFF97316)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(size.width - 424f, size.height - 278f, size.width - 316f, size.height - 170f),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = size.width - 404f,
                            top = size.height - 258f,
                            right = size.width - 336f,
                            bottom = size.height - 190f,
                            paint = contentPaint,
                        )
                        canvas.restore()
                    }
                }
                if (composeSaveLayerBlendModeEnabled) {
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.7f)
                        blendMode = BlendMode.Plus
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFF22D3EE)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(154f, size.height - 144f, 262f, size.height - 36f),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = 174f,
                            top = size.height - 124f,
                            right = 242f,
                            bottom = size.height - 56f,
                            paint = contentPaint,
                        )
                        canvas.restore()
                    }
                }
                if (composeSaveLayerBlendColorFilterEnabled) {
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.7f)
                        blendMode = BlendMode.Plus
                        colorFilter = ColorFilter.tint(Color(0xFF22D3EE))
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFFF97316)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(284f, size.height - 144f, 392f, size.height - 36f),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = 304f,
                            top = size.height - 124f,
                            right = 372f,
                            bottom = size.height - 56f,
                            paint = contentPaint,
                        )
                        canvas.restore()
                    }
                }
                if (composeSaveLayerRawColorFilterEnabled) {
                    val rawColorFilter = org.jetbrains.skia.ColorFilter.makeBlend(
                        Color(0xFF22D3EE).toArgb(),
                        org.jetbrains.skia.BlendMode.SRC_IN,
                    ).asComposeColorFilter()
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.72f)
                        colorFilter = rawColorFilter
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFFF97316)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(
                                size.width - 294f,
                                size.height - 278f,
                                size.width - 186f,
                                size.height - 170f,
                            ),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = size.width - 274f,
                            top = size.height - 258f,
                            right = size.width - 206f,
                            bottom = size.height - 190f,
                            paint = contentPaint,
                        )
                        canvas.restore()
                    }
                }
                if (composeSaveLayerRawTableColorFilterEnabled) {
                    val table = ByteArray(256) { index -> (255 - index).toByte() }
                    val rawColorFilter = org.jetbrains.skia.ColorFilter.makeTable(table).asComposeColorFilter()
                    val layerPaint = Paint().apply {
                        color = Color.White.copy(alpha = 0.72f)
                        colorFilter = rawColorFilter
                    }
                    val contentPaint = Paint().apply {
                        color = Color(0xFF34D399)
                    }
                    drawIntoCanvas { canvas ->
                        canvas.saveLayer(
                            Rect(
                                size.width - 164f,
                                size.height - 278f,
                                size.width - 56f,
                                size.height - 170f,
                            ),
                            layerPaint,
                        )
                        canvas.drawOval(
                            left = size.width - 144f,
                            top = size.height - 258f,
                            right = size.width - 76f,
                            bottom = size.height - 190f,
                            paint = contentPaint,
                        )
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
                if (composeInvalidBlendLayerBoundsEnabled) {
                    drawLine(
                        color = Color(0xFFF97316),
                        start = Offset(Float.NaN, size.height - 118f),
                        end = Offset(122f, size.height - 48f),
                        strokeWidth = 8f,
                        blendMode = BlendMode.Plus,
                    )
                }
                if (composeClipPathEnabled) {
                    val path = Path().apply {
                        if (composeInvalidClipPathEnabled) {
                            moveTo(Float.NaN, size.height - 84f)
                        } else {
                            moveTo(size.width - 248f, size.height - 84f)
                        }
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
                        if (composeInvalidDrawPathEnabled) {
                            moveTo(Float.NaN, size.height - 170f)
                        } else {
                            moveTo(size.width - 304f, size.height - 170f)
                        }
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
                if (composePointLinesEnabled) {
                    val topLeft = Offset(size.width - 540f, size.height - 112f)
                    drawIntoCanvas { canvas ->
                        canvas.drawPoints(
                            pointMode = PointMode.Lines,
                            points = listOf(
                                topLeft,
                                topLeft + Offset(48f, -30f),
                                topLeft + Offset(64f, 0f),
                                topLeft + Offset(118f, -42f),
                                topLeft + Offset(134f, 0f),
                                topLeft + Offset(188f, -28f),
                            ),
                            paint = Paint().apply {
                                color = Color(0xFFFFD166)
                                strokeWidth = 8f
                            },
                        )
                        canvas.drawPoints(
                            pointMode = PointMode.Polygon,
                            points = listOf(
                                topLeft + Offset(0f, 26f),
                                topLeft + Offset(44f, 48f),
                                topLeft + Offset(90f, 28f),
                                topLeft + Offset(138f, 52f),
                                topLeft + Offset(188f, 30f),
                            ),
                            paint = Paint().apply {
                                color = Color.White
                                strokeWidth = 5f
                            },
                        )
                    }
                }
                if (composePointDotsEnabled) {
                    val topLeft = Offset(size.width - 300f, size.height - 112f)
                    drawIntoCanvas { canvas ->
                        canvas.drawPoints(
                            pointMode = PointMode.Points,
                            points = listOf(
                                topLeft,
                                topLeft + Offset(24f, -18f),
                                topLeft + Offset(48f, 0f),
                                topLeft + Offset(72f, -28f),
                                topLeft + Offset(96f, -4f),
                                topLeft + Offset(120f, -22f),
                            ),
                            paint = Paint().apply {
                                color = Color(0xFFFB7185)
                                strokeWidth = 14f
                                strokeCap = StrokeCap.Round
                            },
                        )
                    }
                }
                if (composeInvalidPointDotsEnabled) {
                    val topLeft = Offset(size.width - 300f, size.height - 112f)
                    drawIntoCanvas { canvas ->
                        canvas.drawPoints(
                            pointMode = PointMode.Points,
                            points = listOf(
                                topLeft,
                                Offset(Float.NaN, topLeft.y - 18f),
                                topLeft + Offset(48f, 0f),
                            ),
                            paint = Paint().apply {
                                color = Color(0xFFF97316)
                                strokeWidth = 14f
                                strokeCap = StrokeCap.Round
                            },
                        )
                    }
                }
                if (composeLinearGradientEnabled) {
                    drawRect(
                        brush = if (composeInvalidLinearGradientStopsEnabled) {
                            Brush.linearGradient(
                                0.5f to Color(0xFF10B981),
                                0.5f to Color(0xFF3B82F6),
                                start = Offset(size.width - 188f, size.height - 106f),
                                end = Offset(size.width - 48f, size.height - 34f),
                            )
                        } else if (composeInvalidLinearGradientPointsEnabled) {
                            Brush.linearGradient(
                                colors = listOf(Color(0xFF10B981), Color(0xFF3B82F6)),
                                start = Offset(Float.NaN, size.height - 106f),
                                end = Offset(size.width - 48f, size.height - 34f),
                            )
                        } else if (composeInvalidLinearGradientColorCountEnabled) {
                            Brush.linearGradient(
                                colors = invalidGradientColors(),
                                start = Offset(size.width - 188f, size.height - 106f),
                                end = Offset(size.width - 48f, size.height - 34f),
                            )
                        } else {
                            Brush.linearGradient(
                                colors = listOf(Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFA855F7)),
                                start = Offset(size.width - 188f, size.height - 106f),
                                end = Offset(size.width - 48f, size.height - 34f),
                            )
                        },
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
                if (composeLinearGradientBlendModeEnabled) {
                    drawRect(
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFF0EA5E9), Color(0xFFFACC15), Color(0xFFEC4899)),
                            start = Offset(size.width - 524f, size.height - 106f),
                            end = Offset(size.width - 384f, size.height - 34f),
                        ),
                        topLeft = Offset(size.width - 524f, size.height - 106f),
                        size = Size(140f, 72f),
                        blendMode = BlendMode.Plus,
                    )
                    drawRect(
                        color = Color.White,
                        topLeft = Offset(size.width - 524f, size.height - 106f),
                        size = Size(140f, 72f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeLinearGradientStrokeEnabled) {
                    drawRect(
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                            start = Offset(size.width - 244f, size.height - 146f),
                            end = Offset(size.width - 92f, size.height - 42f),
                        ),
                        topLeft = Offset(size.width - 244f, size.height - 146f),
                        size = Size(152f, 104f),
                        style = Stroke(width = 12f),
                    )
                }
                if (composeInvalidLinearGradientStrokeWidthEnabled) {
                    val topLeft = Offset(size.width - 244f, size.height - 146f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 152f,
                            bottom = topLeft.y + 104f,
                            paint = Paint().apply {
                                style = PaintingStyle.Stroke
                                strokeWidth = 0f
                                shader = LinearGradientShader(
                                    from = topLeft,
                                    to = topLeft + Offset(152f, 104f),
                                    colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                                    colorStops = listOf(0.25f, 0.75f),
                                    tileMode = TileMode.Clamp,
                                )
                            },
                        )
                    }
                }
                if (composeLinearGradientRoundRectEnabled) {
                    val invalidRadius = composeInvalidLinearGradientRoundRectRadiusEnabled
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
                        brush = Brush.linearGradient(
                            colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                            start = Offset(size.width - 348f, size.height - 112f),
                            end = Offset(size.width - 212f, size.height - 38f),
                        ),
                        topLeft = Offset(size.width - 348f, size.height - 112f),
                        size = Size(136f, 74f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(26f, 16f),
                        style = Stroke(width = 6f),
                    )
                    if (invalidRadius) {
                        val topLeft = Offset(size.width - 348f, size.height - 112f)
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 136f,
                                bottom = topLeft.y + 74f,
                                radiusX = -6f,
                                radiusY = 16f,
                                paint = Paint().apply {
                                    shader = LinearGradientShader(
                                        from = topLeft,
                                        to = topLeft + Offset(136f, 74f),
                                        colors = listOf(Color(0xFFF97316), Color(0xFF06B6D4)),
                                        colorStops = listOf(0.25f, 0.75f),
                                        tileMode = TileMode.Clamp,
                                    )
                                },
                            )
                        }
                    }
                    if (composeInvalidLinearGradientStrokeRoundRectRadiusEnabled) {
                        val topLeft = Offset(size.width - 348f, size.height - 112f)
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 136f,
                                bottom = topLeft.y + 74f,
                                radiusX = 26f,
                                radiusY = -6f,
                                paint = Paint().apply {
                                    style = PaintingStyle.Stroke
                                    strokeWidth = 6f
                                    shader = LinearGradientShader(
                                        from = topLeft,
                                        to = topLeft + Offset(136f, 74f),
                                        colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                                        colorStops = listOf(0.25f, 0.75f),
                                        tileMode = TileMode.Clamp,
                                    )
                                },
                            )
                        }
                    }
                }
                if (composeLinearGradientPathEnabled) {
                    val path = Path().apply {
                        if (composeInvalidGradientPathEnabled) {
                            moveTo(Float.NaN, size.height - 320f)
                        } else {
                            moveTo(size.width - 342f, size.height - 320f)
                        }
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
                    val brush = Brush.linearGradient(
                        colors = listOf(Color(0xFF14B8A6), Color(0xFFFDE047), Color(0xFFEC4899)),
                        start = Offset(size.width - 350f, size.height - 360f),
                        end = Offset(size.width - 216f, size.height - 254f),
                    )
                    if (composeGradientPathStrokeEnabled) {
                        drawPath(path = path, brush = brush, style = Stroke(width = 8f))
                    } else {
                        drawPath(path = path, brush = brush)
                    }
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeLinearGradientPathBlendModeEnabled) {
                    val path = Path().apply {
                        moveTo(size.width - 524f, size.height - 260f)
                        cubicTo(
                            size.width - 486f,
                            size.height - 312f,
                            size.width - 414f,
                            size.height - 292f,
                            size.width - 394f,
                            size.height - 232f,
                        )
                        lineTo(size.width - 448f, size.height - 206f)
                        lineTo(size.width - 524f, size.height - 222f)
                        close()
                    }
                    val brush = Brush.linearGradient(
                        colors = listOf(Color(0xFF0F766E), Color(0xFFFDE047), Color(0xFFDB2777)),
                        start = Offset(size.width - 528f, size.height - 312f),
                        end = Offset(size.width - 390f, size.height - 204f),
                    )
                    drawPath(path = path, brush = brush, blendMode = BlendMode.Plus)
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeRadialGradientEnabled) {
                    val topLeft = Offset(size.width - 164f, size.height - 198f)
                    drawRect(
                        brush = if (composeInvalidRadialGradientStopsEnabled) {
                            Brush.radialGradient(
                                0.5f to Color(0xFFFFF7ED),
                                0.5f to Color(0xFFF97316),
                                center = topLeft + Offset(64f, 48f),
                                radius = 72f,
                            )
                        } else if (composeInvalidRadialGradientGeometryEnabled) {
                            Brush.radialGradient(
                                colors = listOf(Color(0xFFFFF7ED), Color(0xFFF97316)),
                                center = topLeft + Offset(64f, 48f),
                                radius = Float.NaN,
                            )
                        } else if (composeInvalidRadialGradientColorCountEnabled) {
                            Brush.radialGradient(
                                colors = invalidGradientColors(),
                                center = topLeft + Offset(64f, 48f),
                                radius = 72f,
                            )
                        } else {
                            Brush.radialGradient(
                                colors = listOf(Color(0xFFFFF7ED), Color(0xFFF97316), Color(0xFF7C3AED)),
                                center = topLeft + Offset(64f, 48f),
                                radius = 72f,
                            )
                        },
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                    )
                    drawRect(
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                            center = topLeft + Offset(10f, 10f),
                            radius = 180f,
                        ),
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                        style = Stroke(width = 8f),
                    )
                }
                if (composeInvalidRadialGradientStrokeWidthEnabled) {
                    val topLeft = Offset(size.width - 164f, size.height - 198f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 128f,
                            bottom = topLeft.y + 96f,
                            paint = Paint().apply {
                                style = PaintingStyle.Stroke
                                strokeWidth = 0f
                                shader = RadialGradientShader(
                                    center = topLeft + Offset(64f, 48f),
                                    radius = 72f,
                                    colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                                    colorStops = listOf(0.25f, 0.75f),
                                    tileMode = TileMode.Clamp,
                                )
                            },
                        )
                    }
                }
                if (composeRadialGradientStrokeBlendModeEnabled) {
                    val topLeft = Offset(size.width - 696f, size.height - 150f)
                    drawRect(
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFFBAE6FD), Color(0xFF0EA5E9), Color(0xFF7C3AED)),
                            center = topLeft + Offset(76f, 52f),
                            radius = 96f,
                        ),
                        topLeft = topLeft,
                        size = Size(152f, 104f),
                        style = Stroke(width = 12f),
                        blendMode = BlendMode.Plus,
                    )
                }
                if (composeRadialGradientRoundRectEnabled) {
                    val invalidRadius = composeInvalidRadialGradientRoundRectRadiusEnabled
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
                        brush = Brush.radialGradient(
                            colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                            center = topLeft + Offset(10f, 10f),
                            radius = 180f,
                        ),
                        topLeft = topLeft,
                        size = Size(128f, 96f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        style = Stroke(width = 8f),
                    )
                    if (invalidRadius) {
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 128f,
                                bottom = topLeft.y + 96f,
                                radiusX = 28f,
                                radiusY = -6f,
                                paint = Paint().apply {
                                    shader = RadialGradientShader(
                                        center = topLeft + Offset(64f, 48f),
                                        radius = 78f,
                                        colors = listOf(Color(0xFFECFEFF), Color(0xFF4338CA)),
                                        colorStops = listOf(0.25f, 0.75f),
                                        tileMode = TileMode.Clamp,
                                    )
                                },
                            )
                        }
                    }
                    if (composeInvalidRadialGradientStrokeRoundRectRadiusEnabled) {
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 128f,
                                bottom = topLeft.y + 96f,
                                radiusX = -6f,
                                radiusY = 18f,
                                paint = Paint().apply {
                                    style = PaintingStyle.Stroke
                                    strokeWidth = 8f
                                    shader = RadialGradientShader(
                                        center = topLeft + Offset(64f, 48f),
                                        radius = 78f,
                                        colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316)),
                                        colorStops = listOf(0.25f, 0.75f),
                                        tileMode = TileMode.Clamp,
                                    )
                                },
                            )
                        }
                    }
                }
                if (composeRadialGradientPathEnabled) {
                    val path = Path().apply {
                        if (composeInvalidGradientPathEnabled) {
                            moveTo(Float.NaN, size.height - 318f)
                        } else {
                            moveTo(size.width - 492f, size.height - 318f)
                        }
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
                    val brush = Brush.radialGradient(
                        colors = listOf(Color(0xFFFFFBEB), Color(0xFFF97316), Color(0xFF7C3AED)),
                        center = Offset(size.width - 438f, size.height - 304f),
                        radius = 86f,
                    )
                    if (composeGradientPathStrokeEnabled) {
                        drawPath(path = path, brush = brush, style = Stroke(width = 8f))
                    } else {
                        drawPath(path = path, brush = brush)
                    }
                    drawPath(path = path, color = Color.White, style = Stroke(width = 3f))
                }
                if (composeSweepGradientEnabled) {
                    val topLeft = Offset(size.width - 518f, size.height - 126f)
                    drawRect(
                        brush = Brush.sweepGradient(
                            colors = if (composeInvalidSweepGradientColorCountEnabled) {
                                invalidGradientColors()
                            } else {
                                listOf(Color(0xFFEF4444), Color(0xFFFDE047), Color(0xFF22C55E), Color(0xFF3B82F6))
                            },
                            center = if (composeInvalidSweepGradientGeometryEnabled) {
                                Offset(Float.NaN, topLeft.y + 42f)
                            } else {
                                topLeft + Offset(72f, 42f)
                            },
                        ),
                        topLeft = topLeft,
                        size = Size(144f, 84f),
                    )
                    drawRect(
                        brush = Brush.sweepGradient(
                            colors =
                                listOf(
                                    Color(0xFF22D3EE),
                                    Color(0xFFF97316),
                                    Color(0xFF22C55E),
                                    Color(0xFF8B5CF6),
                                ),
                            center = topLeft + Offset(72f, 42f),
                        ),
                        topLeft = topLeft,
                        size = Size(144f, 84f),
                        style = Stroke(width = 8f),
                    )
                }
                if (composeInvalidSweepGradientStrokeWidthEnabled) {
                    val topLeft = Offset(size.width - 518f, size.height - 126f)
                    drawIntoCanvas { canvas ->
                        canvas.drawRect(
                            left = topLeft.x,
                            top = topLeft.y,
                            right = topLeft.x + 144f,
                            bottom = topLeft.y + 84f,
                            paint = Paint().apply {
                                style = PaintingStyle.Stroke
                                strokeWidth = 0f
                                shader = SweepGradientShader(
                                    center = topLeft + Offset(72f, 42f),
                                    colors = listOf(Color(0xFF22D3EE), Color(0xFFF97316), Color(0xFF8B5CF6)),
                                    colorStops = listOf(0.1f, 0.5f, 0.9f),
                                )
                            },
                        )
                    }
                }
                if (composeSweepGradientRoundRectEnabled) {
                    val invalidRadius = composeInvalidSweepGradientRoundRectRadiusEnabled
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
                        brush = Brush.sweepGradient(
                            colors =
                                listOf(
                                    Color(0xFF22D3EE),
                                    Color(0xFFF97316),
                                    Color(0xFFFACC15),
                                    Color(0xFF9333EA),
                                ),
                            center = topLeft + Offset(72f, 46f),
                        ),
                        topLeft = topLeft,
                        size = Size(144f, 92f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        style = Stroke(width = 8f),
                    )
                    if (invalidRadius) {
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 144f,
                                bottom = topLeft.y + 92f,
                                radiusX = -6f,
                                radiusY = -8f,
                                paint = Paint().apply {
                                    shader = SweepGradientShader(
                                        center = topLeft + Offset(72f, 46f),
                                        colors = listOf(
                                            Color(0xFFDC2626),
                                            Color(0xFFFACC15),
                                            Color(0xFF0EA5E9),
                                            Color(0xFF9333EA),
                                        ),
                                    )
                                },
                            )
                        }
                    }
                    if (composeInvalidSweepGradientStrokeRoundRectRadiusEnabled) {
                        drawIntoCanvas { canvas ->
                            canvas.drawRoundRect(
                                left = topLeft.x,
                                top = topLeft.y,
                                right = topLeft.x + 144f,
                                bottom = topLeft.y + 92f,
                                radiusX = 28f,
                                radiusY = -8f,
                                paint = Paint().apply {
                                    style = PaintingStyle.Stroke
                                    strokeWidth = 8f
                                    shader = SweepGradientShader(
                                        center = topLeft + Offset(72f, 46f),
                                        colors = listOf(
                                            Color(0xFF22D3EE),
                                            Color(0xFFF97316),
                                            Color(0xFFFACC15),
                                            Color(0xFF9333EA),
                                        ),
                                    )
                                },
                            )
                        }
                    }
                }
                if (composeSweepGradientRoundRectBlendModeEnabled) {
                    val topLeft = Offset(size.width - 704f, size.height - 268f)
                    drawRoundRect(
                        brush = Brush.sweepGradient(
                            colors = listOf(Color(0xFFEF4444), Color(0xFFFDE047), Color(0xFF22C55E), Color(0xFF3B82F6)),
                            center = topLeft + Offset(76f, 50f),
                        ),
                        topLeft = topLeft,
                        size = Size(152f, 100f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        blendMode = BlendMode.Plus,
                    )
                    drawRoundRect(
                        color = Color.White,
                        topLeft = topLeft,
                        size = Size(152f, 100f),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(28f, 18f),
                        style = Stroke(width = 3f),
                    )
                }
                if (composeSweepGradientPathEnabled) {
                    val path = Path().apply {
                        if (composeInvalidGradientPathEnabled) {
                            moveTo(Float.NaN, size.height - 238f)
                        } else {
                            moveTo(size.width - 250f, size.height - 238f)
                        }
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
                    val brush = Brush.sweepGradient(
                        colors = listOf(Color(0xFFEF4444), Color(0xFFF59E0B), Color(0xFF22D3EE), Color(0xFF7C3AED)),
                        center = Offset(size.width - 216f, size.height - 212f),
                    )
                    if (composeGradientPathStrokeEnabled) {
                        drawPath(path = path, brush = brush, style = Stroke(width = 8f))
                    } else {
                        drawPath(path = path, brush = brush)
                    }
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

            if (swingIslandEnabled) {
                SwingPanel(
                    factory = ::createSwingStatusPanel,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .offset(x = (-28).dp, y = 34.dp)
                        .size(width = 300.dp, height = 118.dp)
                        .zIndex(1f),
                )
            }

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

            if (composeGraphicsLayerEnabled) {
                if (composeGraphicsLayerUnrecordedEnabled) {
                    val unrecordedLayer = rememberGraphicsLayer()
                    Canvas(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .offset(x = (-228).dp, y = (-72).dp)
                            .size(width = 52.dp, height = 52.dp),
                    ) {
                        drawLayer(unrecordedLayer)
                    }
                }
                if (composeGraphicsLayerInvalidSizeWidthEnabled) {
                    val invalidSizeLayer = rememberGraphicsLayer()
                    LaunchedEffect(invalidSizeLayer) {
                        invalidSizeLayer.record(Density(1f), LayoutDirection.Ltr, IntSize(-1, 52)) {
                            drawRect(Color(0xFFEF4444))
                        }
                    }
                    Canvas(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .offset(x = (-228).dp, y = (-72).dp)
                            .size(width = 52.dp, height = 52.dp),
                    ) {
                        drawLayer(invalidSizeLayer)
                    }
                }
                if (composeGraphicsLayerInvalidSizeHeightEnabled) {
                    val invalidSizeLayer = rememberGraphicsLayer()
                    LaunchedEffect(invalidSizeLayer) {
                        invalidSizeLayer.record(Density(1f), LayoutDirection.Ltr, IntSize(52, -1)) {
                            drawRect(Color(0xFFEF4444))
                        }
                    }
                    Canvas(
                        modifier = Modifier
                            .align(Alignment.BottomEnd)
                            .offset(x = (-228).dp, y = (-72).dp)
                            .size(width = 52.dp, height = 52.dp),
                    ) {
                        drawLayer(invalidSizeLayer)
                    }
                }
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(x = (-72).dp, y = (-72).dp)
                        .size(width = 132.dp, height = 72.dp)
                        .graphicsLayer {
                            alpha = 0.64f
                            if (composeGraphicsLayerInvalidAlphaEnabled) {
                                alpha = 1.5f
                            }
                            rotationZ = -4f
                            if (composeGraphicsLayerBlendModeEnabled) {
                                blendMode = BlendMode.Plus
                            }
                            if (composeGraphicsLayerInvalidBlendModeEnabled) {
                                blendMode = BlendMode.Clear
                            }
                            if (composeGraphicsLayerShadowEnabled) {
                                shadowElevation = 18f
                                spotShadowColor = Color(0xFF111827)
                                ambientShadowColor = Color(0xFF111827)
                            }
                            if (composeGraphicsLayerInvalidShadowElevationEnabled) {
                                shadowElevation = -1f
                            }
                            if (composeGraphicsLayerInvalidShadowPathEnabled) {
                                shadowElevation = 18f
                                spotShadowColor = Color(0xFF111827)
                                ambientShadowColor = Color(0xFF111827)
                            }
                            if (composeGraphicsLayerRotationXEnabled) {
                                rotationX = 28f
                            }
                            if (composeGraphicsLayerRotationYEnabled) {
                                rotationY = -24f
                            }
                            if (composeGraphicsLayerInvalidScaleXEnabled) {
                                scaleX = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidScaleYEnabled) {
                                scaleY = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidRotationZEnabled) {
                                rotationZ = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidTranslationXEnabled) {
                                translationX = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidTranslationYEnabled) {
                                translationY = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidRotationXEnabled) {
                                rotationX = Float.NaN
                            }
                            if (composeGraphicsLayerInvalidRotationYEnabled) {
                                rotationY = Float.NaN
                            }
                            if (composeGraphicsLayerScaleTranslateEnabled) {
                                scaleX = 1.18f
                                scaleY = 0.82f
                                translationX = -18f
                                translationY = 14f
                            }
                            if (composeGraphicsLayerNearCameraEnabled) {
                                cameraDistance = 180f
                            }
                            if (composeGraphicsLayerInvalidCameraDistanceEnabled) {
                                cameraDistance = 0f
                            }
                            if (composeGraphicsLayerOffCenterPivotEnabled) {
                                transformOrigin = TransformOrigin(0.18f, 0.82f)
                            }
                            if (composeGraphicsLayerOffscreenEnabled) {
                                compositingStrategy = CompositingStrategy.Offscreen
                            } else if (composeGraphicsLayerModulateAlphaEnabled) {
                                compositingStrategy = CompositingStrategy.ModulateAlpha
                            }
                            if (composeGraphicsLayerColorFilterEnabled) {
                                colorFilter = ColorFilter.tint(Color(0xFF22D3EE))
                            }
                            if (composeGraphicsLayerColorMatrixFilterEnabled) {
                                colorFilter = ColorFilter.colorMatrix(
                                    ColorMatrix().apply {
                                        this[0, 0] = 1.08f
                                        this[1, 1] = 0.78f
                                        this[2, 2] = 1.24f
                                        this[0, 4] = 24f
                                    }
                                )
                            }
                            if (composeGraphicsLayerRawColorFilterEnabled) {
                                colorFilter = org.jetbrains.skia.ColorFilter.makeBlend(
                                    Color(0xFF22D3EE).toArgb(),
                                    org.jetbrains.skia.BlendMode.SRC_IN,
                                ).asComposeColorFilter()
                            }
                            if (composeGraphicsLayerRawTableColorFilterEnabled) {
                                val table = ByteArray(256) { index -> (255 - index).toByte() }
                                colorFilter = org.jetbrains.skia.ColorFilter.makeTable(table).asComposeColorFilter()
                            }
                            when {
                                composeGraphicsLayerRawImageFilterEffectEnabled -> {
                                    renderEffect = org.jetbrains.skia.ImageFilter.makeDropShadow(
                                        dx = 10f,
                                        dy = 8f,
                                        sigmaX = 3f,
                                        sigmaY = 3f,
                                        color = Color(0xAA0F172A).toArgb(),
                                        crop = null,
                                    ).asComposeRenderEffect()
                                }
                                composeGraphicsLayerChainedRenderEffectEnabled -> {
                                    renderEffect = OffsetEffect(
                                        renderEffect = BlurEffect(radiusX = 7f, radiusY = 5f),
                                        offset = Offset(13f, -9f),
                                    )
                                }
                                composeGraphicsLayerBlurChainedRenderEffectEnabled -> {
                                    renderEffect = BlurEffect(
                                        renderEffect = OffsetEffect(offsetX = 13f, offsetY = -9f),
                                        radiusX = 7f,
                                        radiusY = 5f,
                                    )
                                }
                                composeGraphicsLayerOffsetEffectEnabled -> {
                                    renderEffect = OffsetEffect(offsetX = 13f, offsetY = -9f)
                                }
                                composeGraphicsLayerRenderEffectEnabled -> {
                                    renderEffect = BlurEffect(radiusX = 7f, radiusY = 5f)
                                }
                            }
                            clip = composeGraphicsLayerClipEnabled ||
                                composeGraphicsLayerRoundClipEnabled ||
                                composeGraphicsLayerPathClipEnabled
                            when {
                                composeGraphicsLayerInvalidShadowPathEnabled -> {
                                    shape = GenericShape { outlineSize, _ ->
                                        moveTo(Float.NaN, 0f)
                                        lineTo(outlineSize.width, 0f)
                                        lineTo(outlineSize.width, outlineSize.height)
                                        close()
                                    }
                                }
                                composeGraphicsLayerPathClipEnabled -> {
                                    shape = GenericShape { outlineSize, _ ->
                                        moveTo(0f, 0f)
                                        lineTo(outlineSize.width, 0f)
                                        lineTo(outlineSize.width * 0.82f, outlineSize.height)
                                        lineTo(0f, outlineSize.height * 0.78f)
                                        close()
                                    }
                                }
                                composeGraphicsLayerRoundClipEnabled -> {
                                    shape = RoundedCornerShape(20.dp)
                                }
                            }
                        }
                        .background(Color(0xFFE879F9))
                        .zIndex(2f),
                ) {
                    if (composeGraphicsLayerClipEnabled ||
                        composeGraphicsLayerRoundClipEnabled ||
                        composeGraphicsLayerPathClipEnabled
                    ) {
                        Box(
                            modifier = Modifier
                                .offset(x = (-24).dp, y = (-14).dp)
                                .size(width = 180.dp, height = 96.dp)
                                .background(Color(0xFF22D3EE)),
                        )
                    }
                    if (composeGraphicsLayerChildUnsupportedEnabled) {
                        Canvas(
                            modifier = Modifier
                                .offset(x = 16.dp, y = 12.dp)
                                .size(width = 80.dp, height = 48.dp),
                        ) {
                            rawImageShader?.let { shader ->
                                drawIntoCanvas { canvas ->
                                    canvas.drawRect(
                                        left = 0f,
                                        top = 0f,
                                        right = size.width,
                                        bottom = size.height,
                                        paint = Paint().apply {
                                            this.shader = shader
                                        },
                                    )
                                }
                            }
                        }
                    }
                }
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
                if (genericFontTextEnabled) {
                    MagicLabel(
                        "Sans-serif generic label",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = FontFamily.SansSerif,
                        ),
                    )
                    MagicLabel(
                        "Monospace 0123456789",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                        ),
                    )
                    MagicLabel(
                        "Serif \uD83D\uDE80 paragraph",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = FontFamily.Serif,
                            fontStyle = FontStyle.Italic,
                        ),
                    )
                    MagicLabel(
                        "Cursive generic label",
                        composeTextEnabled,
                        width = 260.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = FontFamily.Cursive,
                        ),
                    )
                }
                if (loadedFontDataTextEnabled) {
                    MagicLabel(
                        "Loaded font-data label",
                        composeTextEnabled,
                        width = 300.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = loadedFontDataFamily,
                        ),
                    )
                }
                if (resourceFontTextEnabled) {
                    MagicLabel(
                        "Classpath resource font label",
                        composeTextEnabled,
                        width = 320.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = FontFamily(
                                ComposeFont("magicjewel-fonts/MagicJewelResourceFont.ttf"),
                            ),
                        ),
                    )
                }
                if (systemFontTextEnabled) {
                    MagicLabel(
                        "Named system font Menlo 012345",
                        composeTextEnabled,
                        width = 320.dp,
                        style = TextStyle(
                            color = Color.Black,
                            fontSize = 17.sp,
                            fontFamily = androidx.compose.ui.text.font.FontFamily("Menlo"),
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

private val RawGradientColors = intArrayOf(
    Color(0xFF06B6D4).toArgb(),
    Color(0xFFFDBA2D).toArgb(),
    Color(0xFFEF1C24).toArgb(),
)
private val RawGradientComposeColors = RawGradientColors.map(::Color)
private val RawGradientStops = floatArrayOf(0f, 0.5f, 1f)

private fun makeRawSkiaLinearGradientShader(
    x0: Float,
    y0: Float,
    x1: Float,
    y1: Float,
    colors: IntArray,
    positions: FloatArray,
): org.jetbrains.skia.Shader {
    val companion = org.jetbrains.skia.Shader.Companion
    val oldStyleMethod = companion.javaClass.methods.firstOrNull { method ->
        method.name == "makeLinearGradient" &&
            method.parameterTypes.size == 7 &&
            method.parameterTypes[4] == IntArray::class.java &&
            method.parameterTypes[5] == FloatArray::class.java
    }
    if (oldStyleMethod != null) {
        val styleCompanion = Class.forName("org.jetbrains.skia.GradientStyle").getField("Companion").get(null)
        val defaultStyle = styleCompanion.javaClass.getMethod("getDEFAULT").invoke(styleCompanion)
        return oldStyleMethod.invoke(companion, x0, y0, x1, y1, colors, positions, defaultStyle) as org.jetbrains.skia.Shader
    }

    val gradient = makeRawSkiaGradient(colors, positions)
    val newStyleMethod = companion.javaClass.methods.first { method ->
        method.name == "makeLinearGradient" &&
            method.parameterTypes.size == 6 &&
            method.parameterTypes[4].name == "org.jetbrains.skia.Gradient"
    }
    return newStyleMethod.invoke(companion, x0, y0, x1, y1, gradient, null) as org.jetbrains.skia.Shader
}

private fun makeRawSkiaRadialGradientShader(
    centerX: Float,
    centerY: Float,
    radius: Float,
    colors: IntArray,
    positions: FloatArray,
): org.jetbrains.skia.Shader {
    val companion = org.jetbrains.skia.Shader.Companion
    val oldStyleMethod = companion.javaClass.methods.firstOrNull { method ->
        method.name == "makeRadialGradient" &&
            method.parameterTypes.size == 6 &&
            method.parameterTypes[3] == IntArray::class.java &&
            method.parameterTypes[4] == FloatArray::class.java
    }
    if (oldStyleMethod != null) {
        return oldStyleMethod.invoke(
            companion,
            centerX,
            centerY,
            radius,
            colors,
            positions,
            defaultSkiaGradientStyle(),
        ) as org.jetbrains.skia.Shader
    }

    val gradient = makeRawSkiaGradient(colors, positions)
    val newStyleMethod = companion.javaClass.methods.first { method ->
        method.name == "makeRadialGradient" &&
            method.parameterTypes.size == 5 &&
            method.parameterTypes[3].name == "org.jetbrains.skia.Gradient"
    }
    return newStyleMethod.invoke(companion, centerX, centerY, radius, gradient, null) as org.jetbrains.skia.Shader
}

private fun makeRawSkiaSweepGradientShader(
    centerX: Float,
    centerY: Float,
    colors: IntArray,
    positions: FloatArray,
): org.jetbrains.skia.Shader {
    val companion = org.jetbrains.skia.Shader.Companion
    val oldStyleMethod = companion.javaClass.methods.firstOrNull { method ->
        method.name == "makeSweepGradient" &&
            method.parameterTypes.size == 5 &&
            method.parameterTypes[2] == IntArray::class.java &&
            method.parameterTypes[3] == FloatArray::class.java
    }
    if (oldStyleMethod != null) {
        return oldStyleMethod.invoke(companion, centerX, centerY, colors, positions, defaultSkiaGradientStyle())
            as org.jetbrains.skia.Shader
    }

    val gradient = makeRawSkiaGradient(colors, positions)
    val newStyleMethod = companion.javaClass.methods.first { method ->
        method.name == "makeSweepGradient" &&
            method.parameterTypes.size == 4 &&
            method.parameterTypes[2].name == "org.jetbrains.skia.Gradient"
    }
    return newStyleMethod.invoke(companion, centerX, centerY, gradient, null) as org.jetbrains.skia.Shader
}

private fun makeRawSkiaConicalGradientShader(
    x0: Float,
    y0: Float,
    r0: Float,
    x1: Float,
    y1: Float,
    r1: Float,
    colors: IntArray,
    positions: FloatArray,
): org.jetbrains.skia.Shader {
    val companion = org.jetbrains.skia.Shader.Companion
    val gradient = makeRawSkiaGradient(colors, positions)
    val method = companion.javaClass.methods.first { method ->
        method.name == "makeTwoPointConicalGradient" &&
            method.parameterTypes.size == 8 &&
            method.parameterTypes[6].name == "org.jetbrains.skia.Gradient"
    }
    return method.invoke(companion, x0, y0, r0, x1, y1, r1, gradient, null) as org.jetbrains.skia.Shader
}

private fun defaultSkiaGradientStyle(): Any {
    val styleCompanion = Class.forName("org.jetbrains.skia.GradientStyle").getField("Companion").get(null)
    return styleCompanion.javaClass.getMethod("getDEFAULT").invoke(styleCompanion)
}

private fun makeRawSkiaGradient(colors: IntArray, positions: FloatArray): Any {
    val tileModeClass = Class.forName("org.jetbrains.skia.FilterTileMode")
    val clampTileMode = tileModeClass.enumConstants.first { (it as Enum<*>).name == "CLAMP" }
    val color4fs = colors.map { argb ->
        val color = Color(argb)
        org.jetbrains.skia.Color4f(color.red, color.green, color.blue, color.alpha)
    }.toTypedArray()
    val colorsClass = Class.forName("org.jetbrains.skia.Gradient\$Colors")
    val gradientColors = colorsClass.constructors.first { constructor ->
        constructor.parameterTypes.size == 4
    }.newInstance(color4fs, positions, clampTileMode, null)
    val gradientClass = Class.forName("org.jetbrains.skia.Gradient")
    val gradient = gradientClass.constructors.first { constructor ->
        constructor.parameterTypes.size == 4
    }.newInstance(gradientColors, null, 2, null)
    return gradient
}

private fun createRawSkiaImageShader(): org.jetbrains.skia.Shader {
    val surface = org.jetbrains.skia.Surface.makeRasterN32Premul(32, 32)
    val canvas = surface.canvas
    canvas.clear(Color(0xFF0F172A).toArgb())
    canvas.drawRect(
        org.jetbrains.skia.Rect(0f, 0f, 18f, 32f),
        org.jetbrains.skia.Paint().apply { color = Color(0xFF22D3EE).toArgb() },
    )
    canvas.drawCircle(
        22f,
        16f,
        9f,
        org.jetbrains.skia.Paint().apply { color = Color(0xFFFFD166).toArgb() },
    )
    return surface.makeImageSnapshot().makeShader(
        org.jetbrains.skia.FilterTileMode.REPEAT,
        org.jetbrains.skia.FilterTileMode.MIRROR,
        org.jetbrains.skia.SamplingMode.DEFAULT,
        null,
    )
}

private fun createImageProbe(oversized: Boolean = false): ImageBitmap {
    val width = if (oversized) 2049 else 72
    val height = if (oversized) 1 else 72
    val bitmap = ImageBitmap(width, height)
    val canvas = androidx.compose.ui.graphics.Canvas(bitmap)
    val paint = Paint()

    paint.color = Color(0xFFE879F9)
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
    if (oversized) return bitmap
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
private fun ButtonLabel(text: String, color: Color = Color.Unspecified) {
    Box(
        modifier = Modifier.size(width = 48.dp, height = 22.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            color = color,
            maxLines = 1,
            textAlign = TextAlign.Center,
        )
    }
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

private fun loadMagicJewelFontResourceBytes(): ByteArray {
    val resource = "magicjewel-fonts/MagicJewelResourceFont.ttf"
    val stream = Thread.currentThread().contextClassLoader?.getResourceAsStream(resource)
        ?: ClassLoader.getSystemResourceAsStream(resource)
        ?: error("Missing Magic Jewel font resource: $resource")
    return stream.use { it.readBytes() }
}

private fun createSwingStatusPanel(): JPanel {
    val pauseSwingAnimation = System.getProperty(PauseSwingAnimationProperty, "false").toBoolean()
    val title = JLabel("Swing island").apply {
        font = Font(Font.SANS_SERIF, Font.BOLD, 13)
        foreground = AwtColor(255, 255, 255)
    }
    val counter = JLabel("ticks=0").apply {
        foreground = AwtColor(220, 240, 255)
    }
    val progress = MovingSwingProgressBar()
    var swingTicks = 0
    if (pauseSwingAnimation) {
        counter.text = "Swing timer ticks=fixed"
    } else {
        Timer(80) {
            swingTicks++
            counter.text = "Swing timer ticks=$swingTicks"
        }.start()
    }

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
    private val pauseAnimation = System.getProperty(PauseSwingAnimationProperty, "false").toBoolean()
    private val timer = Timer(33) {
        repaint()
        parent?.repaint()
    }.apply {
        isRepeats = true
        if (!pauseAnimation) {
            start()
        }
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

private class PopupStressPanel : JPanel(BorderLayout(8, 6)) {
    private val progress = PopupPulseBar()

    init {
        name = "MagicJewelPopupStressPanel"
        background = AwtColor(255, 255, 255)
        border = BorderFactory.createEmptyBorder(10, 12, 10, 12)
        preferredSize = Dimension(260, 82)
        add(
            JLabel("Swing popup over Compose").apply {
                foreground = AwtColor(17, 24, 39)
                font = Font(Font.SANS_SERIF, Font.BOLD, 13)
            },
            BorderLayout.NORTH,
        )
        add(progress, BorderLayout.CENTER)
    }
}

private class PopupPulseBar : JComponent() {
    private val timer = Timer(33) {
        repaint()
        parent?.repaint()
    }.apply {
        isRepeats = true
        start()
    }

    init {
        preferredSize = Dimension(220, 28)
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
            g2.color = AwtColor(219, 234, 254)
            g2.fillRoundRect(0, 6, width, height - 12, 12, 12)
            g2.color = AwtColor(236, 72, 153)
            val blockWidth = (width * 0.28).toInt().coerceAtLeast(42)
            val x = movingProgressX(width, blockWidth, System.nanoTime())
            g2.fillRoundRect(x, 7, blockWidth, height - 14, 11, 11)
            g2.color = AwtColor(34, 211, 238, 210)
            g2.fillOval(width - 34, 2, 28, 28)
            System.err.println("$PopupFrameMarker frame=${PopupFrameCounter.incrementAndGet()}")
        } finally {
            g2.dispose()
        }
    }
}

private fun movingProgressX(width: Int, blockWidth: Int, nowNanos: Long): Int {
    val travel = (width + blockWidth).coerceAtLeast(1)
    val periodNanos = 900_000_000L
    val phase = fixedAnimationPhase()?.toDouble() ?: ((nowNanos.floorMod(periodNanos)).toDouble() / periodNanos.toDouble())
    return (phase * travel).toInt() - blockWidth
}

private fun fixedAnimationPhase(): Float? =
    System.getProperty(FixedAnimationPhaseProperty)
        ?.toFloatOrNull()
        ?.coerceIn(0f, 1f)

private fun Long.floorMod(modulus: Long): Long {
    val value = this % modulus
    return if (value >= 0) value else value + modulus
}
