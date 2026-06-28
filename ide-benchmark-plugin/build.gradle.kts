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
val magicJewelBenchmarkProjectPath =
    providers.gradleProperty("magicJewelBenchmarkProjectPath")
        .orElse(providers.environmentVariable("MAGIC_JEWEL_BENCHMARK_PROJECT_PATH"))

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
        vendor.set(JvmVendorSpec.JETBRAINS)
    }
}

dependencies {
    implementation(libs.spectre.core) {
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
    }
    compileOnly(libs.kotlinx.coroutines.core)

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
    compileOnly(libs.jewel.markdown.core) {
        exclude(group = "org.jetbrains.compose")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
        exclude(group = "org.jetbrains.jewel", module = "jewel-foundation")
        exclude(group = "org.jetbrains.jewel", module = "jewel-ui")
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
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-core")
        exclude(group = "org.jetbrains.kotlinx", module = "kotlinx-coroutines-swing")
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
    magicJewelBenchmarkProjectPath.orNull?.let {
        args(it)
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

val ideBenchmarkSmokeSourceSet =
    sourceSets.create("ideBenchmarkSmoke") {
        java.srcDir("src/ideBenchmarkSmoke/kotlin")
        resources.srcDir("src/ideBenchmarkSmoke/resources")
        compileClasspath += sourceSets["main"].output
        runtimeClasspath += sourceSets["main"].output
    }

val ideBenchmarkSmokeImplementation by
    configurations.getting {
        extendsFrom(configurations["implementation"])
    }

val ideBenchmarkSmokeRuntimeOnly by
    configurations.getting {
        extendsFrom(configurations["runtimeOnly"])
    }

dependencies {
    "ideBenchmarkSmokeImplementation"(libs.junit5.api)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.squashed)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.junit5)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.driver)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.driver.client)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.driver.sdk)
    "ideBenchmarkSmokeImplementation"(libs.ide.starter.driver.model)
    "ideBenchmarkSmokeImplementation"(libs.kotlinx.coroutines.core)
    "ideBenchmarkSmokeRuntimeOnly"(libs.junit5.engine)
    "ideBenchmarkSmokeRuntimeOnly"("org.junit.platform:junit-platform-launcher")
}

val buildPluginTask = tasks.named<Zip>("buildPlugin")
val pluginZipProvider = buildPluginTask.flatMap { it.archiveFile }

val ideBenchmarkSmokeProjectPath =
    providers.gradleProperty("magicJewelBenchmarkProjectPath")
        .orElse(providers.environmentVariable("MAGIC_JEWEL_BENCHMARK_PROJECT_PATH"))
        .orElse("/Users/rock3r/src/uel")

tasks.register<Test>("ideBenchmarkSmoke") {
    group = "verification"
    description =
        "Starter-backed smoke for the IDE benchmark plugin. Boots IU, opens a project, " +
            "installs the plugin, shows the benchmark tool window, and lets Spectre drive it."
    useJUnitPlatform()
    testClassesDirs = ideBenchmarkSmokeSourceSet.output.classesDirs
    classpath = ideBenchmarkSmokeSourceSet.runtimeClasspath
    dependsOn(buildPluginTask)
    systemProperty("path.to.build.plugin", pluginZipProvider.get().asFile.absolutePath)
    systemProperty("magic.jewel.benchmark.project.path", ideBenchmarkSmokeProjectPath.get())
}
