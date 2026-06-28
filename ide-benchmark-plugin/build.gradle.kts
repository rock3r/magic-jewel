plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.compose)
    id("org.jetbrains.intellij.platform")
}

val jbrSkiaInteropEnabled =
    providers.gradleProperty("jbrSkiaInterop")
        .orElse(providers.environmentVariable("JBR_SKIA_INTEROP"))
        .orElse("false")
val jbrSkiaJvmArgs =
    providers.gradleProperty("jbrSkiaInteropJvmArgs")
        .orElse(providers.environmentVariable("JBR_SKIA_INTEROP_JVM_ARGS"))
        .orElse("")
val jbrSkiaRenderMode =
    providers.gradleProperty("jbrSkiaRenderMode")
        .orElse(providers.environmentVariable("JBR_SKIA_RENDER_MODE"))
        .orElse("commands")

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
        vendor.set(JvmVendorSpec.JETBRAINS)
    }
}

dependencies {
    implementation(libs.spectre.core)
    implementation(libs.kotlinx.coroutines.core)

    compileOnly(libs.compose.runtime)
    compileOnly(libs.compose.foundation)
    compileOnly(libs.compose.ui)
    compileOnly(libs.jewel.ide.laf.bridge) {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
    }
    compileOnly(libs.jewel.ui) {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
    }
    implementation(libs.jewel.markdown.core) {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
    }
    implementation(libs.jewel.markdown.int.ui.standalone.styling) {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
    }
    compileOnly(libs.kotlinx.coroutines.swing)

    intellijPlatform {
        intellijIdea(libs.versions.intellijIdea.get())
        @Suppress("UnstableApiUsage") composeUI()
        bundledModule("intellij.platform.jewel.foundation")
        bundledModule("intellij.platform.jewel.ui")
        bundledModule("intellij.platform.jewel.ideLafBridge")
        bundledModule("intellij.platform.jewel.markdown.core")
        bundledModule("intellij.platform.jewel.markdown.ideLafBridgeStyling")
    }
}

configurations
    .matching { it.name == "runtimeClasspath" || it.name.startsWith("intellijPlatform") }
    .configureEach {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.compose.runtime")
        exclude(group = "org.jetbrains.compose.foundation")
        exclude(group = "org.jetbrains.compose.ui")
        exclude(group = "org.jetbrains.skiko")
    }

intellijPlatform {
    pluginConfiguration {
        id = "com.magicjewel.jbrskia.benchmark"
        name = "Magic Jewel JBR Skia Benchmark"
        version = "0.0.0-DEV"
        description = "Local benchmark plugin for JBR Skia zero-copy validation."
        vendor { name = "Magic Jewel" }
    }
}

tasks.named<JavaExec>("runIde") {
    group = "verification"
    systemProperty("idea.is.internal", "true")
    systemProperty("compose.swing.render.on.graphics", "true")
    if (providers.gradleProperty("magicJewelBenchmarkAutorun").isPresent) {
        systemProperty("magic.jewel.benchmark.autorun", "true")
    }
    providers.gradleProperty("magicJewelBenchmarkMode").orNull?.let {
        systemProperty("magic.jewel.benchmark.mode", it)
    }
    providers.gradleProperty("magicJewelBenchmarkOut").orNull?.let {
        systemProperty("magic.jewel.benchmark.out", it)
    }
    if (jbrSkiaInteropEnabled.get().toBoolean()) {
        systemProperty("compose.swing.render.on.jbr.skia", "true")
        systemProperty("skiko.jbr.interop.debugOverlay", "true")
        when (jbrSkiaRenderMode.get()) {
            "commands" -> systemProperty("skiko.jbr.interop.renderCommands", "true")
            "diagnostic" -> systemProperty("skiko.jbr.interop.renderDiagnostic", "true")
            "auto" -> Unit
            else -> systemProperty("skiko.jbr.interop.renderPicture", "true")
        }
        jbrSkiaJvmArgs.get()
            .split(Regex("\\s+"))
            .filter { it.isNotBlank() }
            .let(::jvmArgs)
    }
}

tasks.named("buildSearchableOptions") { enabled = false }
