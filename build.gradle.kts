plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.jetbrains.compose)
    application
}

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
        vendor.set(JvmVendorSpec.JETBRAINS)
    }
}

val localSkikoVersion = providers.environmentVariable("SKIKO_VERSION")
val localCmpOut = providers.gradleProperty("localCmpOut")
    .orElse(providers.environmentVariable("LOCAL_CMP_OUT"))
    .orElse("/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core")
val jbrSkiaJvmArgs = providers.gradleProperty("jbrSkiaInteropJvmArgs")
val jbrSkiaRenderMode = providers.gradleProperty("jbrSkiaRenderMode")
    .orElse(providers.environmentVariable("JBR_SKIA_RENDER_MODE"))
    .orElse("picture")
val composeTextEnabled = providers.gradleProperty("magicJewelComposeText")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_TEXT"))
    .orElse("true")
val composeImageEnabled = providers.gradleProperty("magicJewelComposeImage")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_IMAGE"))
    .orElse("false")
val composeImageShaderEnabled = providers.gradleProperty("magicJewelComposeImageShader")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_IMAGE_SHADER"))
    .orElse("false")
val composeTransformEnabled = providers.gradleProperty("magicJewelComposeTransform")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_TRANSFORM"))
    .orElse("false")
val composeSaveLayerEnabled = providers.gradleProperty("magicJewelComposeSaveLayer")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_SAVELAYER"))
    .orElse("false")
val composeClipEnabled = providers.gradleProperty("magicJewelComposeClip")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_CLIP"))
    .orElse("false")
val composeClipOutEnabled = providers.gradleProperty("magicJewelComposeClipOut")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_CLIP_OUT"))
    .orElse("false")
val composeClipPathEnabled = providers.gradleProperty("magicJewelComposeClipPath")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_CLIP_PATH"))
    .orElse("false")
val composeDrawPathEnabled = providers.gradleProperty("magicJewelComposeDrawPath")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_DRAW_PATH"))
    .orElse("false")
val composeDrawArcEnabled = providers.gradleProperty("magicJewelComposeDrawArc")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_DRAW_ARC"))
    .orElse("false")
val composeDrawRoundRectEnabled = providers.gradleProperty("magicJewelComposeDrawRoundRect")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT"))
    .orElse("false")
val composeLinearGradientEnabled = providers.gradleProperty("magicJewelComposeLinearGradient")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT"))
    .orElse("false")
val composeLinearGradientRoundRectEnabled = providers.gradleProperty("magicJewelComposeLinearGradientRoundRect")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT"))
    .orElse("false")
val composeLinearGradientPathEnabled = providers.gradleProperty("magicJewelComposeLinearGradientPath")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH"))
    .orElse("false")
val composeRadialGradientEnabled = providers.gradleProperty("magicJewelComposeRadialGradient")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT"))
    .orElse("false")
val composeRadialGradientRoundRectEnabled = providers.gradleProperty("magicJewelComposeRadialGradientRoundRect")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT"))
    .orElse("false")
val composeRadialGradientPathEnabled = providers.gradleProperty("magicJewelComposeRadialGradientPath")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH"))
    .orElse("false")
val composeSweepGradientEnabled = providers.gradleProperty("magicJewelComposeSweepGradient")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT"))
    .orElse("false")
val composeSweepGradientRoundRectEnabled = providers.gradleProperty("magicJewelComposeSweepGradientRoundRect")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT"))
    .orElse("false")
val composeSweepGradientPathEnabled = providers.gradleProperty("magicJewelComposeSweepGradientPath")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH"))
    .orElse("false")
val unsupportedTextEnabled = providers.gradleProperty("magicJewelUnsupportedText")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_UNSUPPORTED_TEXT"))
    .orElse("false")
val paragraphLayoutTextEnabled = providers.gradleProperty("magicJewelParagraphLayoutText")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT"))
    .orElse("false")
val imageCacheChurnEnabled = providers.gradleProperty("magicJewelImageCacheChurn")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_IMAGE_CACHE_CHURN"))
    .orElse("false")
val stableImageCacheChurnEnabled = providers.gradleProperty("magicJewelStableImageCacheChurn")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_STABLE_IMAGE_CACHE_CHURN"))
    .orElse("false")
val invalidSweepGradientEnabled = providers.gradleProperty("magicJewelInvalidSweepGradient")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_INVALID_SWEEP_GRADIENT"))
    .orElse("false")
val autoResizeEnabled = providers.gradleProperty("magicJewelAutoResize")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_AUTO_RESIZE"))
    .orElse("false")
val popupStressEnabled = providers.gradleProperty("magicJewelPopupStress")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_POPUP_STRESS"))
    .orElse("false")
val popupWindowStressEnabled = providers.gradleProperty("magicJewelPopupWindowStress")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_POPUP_WINDOW_STRESS"))
    .orElse("false")
val menuStressEnabled = providers.gradleProperty("magicJewelMenuStress")
    .orElse(providers.environmentVariable("MAGIC_JEWEL_MENU_STRESS"))
    .orElse("false")

configurations.configureEach {
    resolutionStrategy.eachDependency {
        if (requested.group == "androidx.compose.runtime") {
            useVersion("1.11.0-beta02")
            because("Match the Compose runtime API expected by the patched CMP UI jars")
        }
        localSkikoVersion.orNull?.takeIf { it.isNotBlank() }?.let { version ->
            if (requested.group == "org.jetbrains.skiko") {
                useVersion(version)
                because("Exercise the locally patched Skiko/JBR interop runtime")
            }
        }
    }
}

dependencies {
    implementation(compose.desktop.currentOs) {
        exclude(group = "org.jetbrains.compose.material")
    }
    implementation(libs.jewel.int.ui.standalone)
    implementation(libs.jewel.int.ui.decorated.window)
    implementation(libs.kotlinx.coroutines.swing)
}

application {
    mainClass.set("com.magicjewel.MainKt")
}

fun Project.patchedComposeRuntimeJars(): FileCollection {
    val root = file(localCmpOut.get())
    if (!root.isDirectory) return files()
    return files(
        fileTree(root) {
            include("annotation/annotation/build/libs/annotation-jvm-9999.0.0-SNAPSHOT.jar")
            include("collection/collection/build/libs/collection-jvm-9999.0.0-SNAPSHOT.jar")
            include("compose/**/build/libs/*-desktop-9999.0.0-SNAPSHOT.jar")
            include("compose/desktop/desktop/build/libs/desktop-jvm-9999.0.0-SNAPSHOT.jar")
        }
    )
}

fun JavaExec.configureMagicJewelJvm(interoperable: Boolean) {
    systemProperty("compose.swing.render.on.graphics", "true")
    systemProperty("apple.awt.application.name", "Magic Jewel")
    systemProperty("magic.jewel.compose.text", composeTextEnabled.get())
    systemProperty("magic.jewel.compose.image", composeImageEnabled.get())
    systemProperty("magic.jewel.compose.imageShader", composeImageShaderEnabled.get())
    systemProperty("magic.jewel.compose.transform", composeTransformEnabled.get())
    systemProperty("magic.jewel.compose.saveLayer", composeSaveLayerEnabled.get())
    systemProperty("magic.jewel.compose.clip", composeClipEnabled.get())
    systemProperty("magic.jewel.compose.clipOut", composeClipOutEnabled.get())
    systemProperty("magic.jewel.compose.clipPath", composeClipPathEnabled.get())
    systemProperty("magic.jewel.compose.drawPath", composeDrawPathEnabled.get())
    systemProperty("magic.jewel.compose.drawArc", composeDrawArcEnabled.get())
    systemProperty("magic.jewel.compose.drawRoundRect", composeDrawRoundRectEnabled.get())
    systemProperty("magic.jewel.compose.linearGradient", composeLinearGradientEnabled.get())
    systemProperty("magic.jewel.compose.linearGradientRoundRect", composeLinearGradientRoundRectEnabled.get())
    systemProperty("magic.jewel.compose.linearGradientPath", composeLinearGradientPathEnabled.get())
    systemProperty("magic.jewel.compose.radialGradient", composeRadialGradientEnabled.get())
    systemProperty("magic.jewel.compose.radialGradientRoundRect", composeRadialGradientRoundRectEnabled.get())
    systemProperty("magic.jewel.compose.radialGradientPath", composeRadialGradientPathEnabled.get())
    systemProperty("magic.jewel.compose.sweepGradient", composeSweepGradientEnabled.get())
    systemProperty("magic.jewel.compose.sweepGradientRoundRect", composeSweepGradientRoundRectEnabled.get())
    systemProperty("magic.jewel.compose.sweepGradientPath", composeSweepGradientPathEnabled.get())
    systemProperty("magic.jewel.unsupportedText", unsupportedTextEnabled.get())
    systemProperty("magic.jewel.paragraphLayoutText", paragraphLayoutTextEnabled.get())
    systemProperty("magic.jewel.imageCacheChurn", imageCacheChurnEnabled.get())
    systemProperty("magic.jewel.stableImageCacheChurn", stableImageCacheChurnEnabled.get())
    systemProperty("magic.jewel.invalidSweepGradient", invalidSweepGradientEnabled.get())
    systemProperty("magic.jewel.autoResize", autoResizeEnabled.get())
    systemProperty("magic.jewel.popupStress", popupStressEnabled.get())
    systemProperty("magic.jewel.popupWindowStress", popupWindowStressEnabled.get())
    systemProperty("magic.jewel.menuStress", menuStressEnabled.get())
    if (interoperable) {
        systemProperty("compose.swing.render.on.jbr.skia", "true")
        systemProperty("skiko.jbr.interop.debugOverlay", "true")
        when (jbrSkiaRenderMode.get()) {
            "commands" -> systemProperty("skiko.jbr.interop.renderCommands", "true")
            "diagnostic" -> systemProperty("skiko.jbr.interop.renderDiagnostic", "true")
            else -> systemProperty("skiko.jbr.interop.renderPicture", "true")
        }
    }
    jbrSkiaJvmArgs.orNull
        ?.split(Regex("\\s+"))
        ?.filter { it.isNotBlank() }
        ?.let(::jvmArgs)
}

tasks.named<JavaExec>("run") {
    val patchedCompose = patchedComposeRuntimeJars()
    classpath = patchedCompose + sourceSets.main.get().runtimeClasspath
    configureMagicJewelJvm(interoperable = false)
    doFirst {
        logger.lifecycle("Prepending ${patchedCompose.files.size} patched CMP jars from ${localCmpOut.get()}")
    }
}

tasks.register<JavaExec>("runJbrSkiaInterop") {
    group = ApplicationPlugin.APPLICATION_GROUP
    description = "Run Magic Jewel through SwingGraphics with the JBR Skia interop fast path enabled."
    val patchedCompose = patchedComposeRuntimeJars()
    classpath = patchedCompose + sourceSets.main.get().runtimeClasspath
    mainClass.set("com.magicjewel.MainKt")
    configureMagicJewelJvm(interoperable = true)
    doFirst {
        logger.lifecycle("Prepending ${patchedCompose.files.size} patched CMP jars from ${localCmpOut.get()}")
    }
}
