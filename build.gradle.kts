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
    .orElse("/Users/rock3r/src/cmp-jbr-skia-poc/out/compose-multiplatform-core")
val jbrSkiaJvmArgs = providers.gradleProperty("jbrSkiaInteropJvmArgs")
val jbrSkiaRenderMode = providers.gradleProperty("jbrSkiaRenderMode")
    .orElse(providers.environmentVariable("JBR_SKIA_RENDER_MODE"))
    .orElse("picture")

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
