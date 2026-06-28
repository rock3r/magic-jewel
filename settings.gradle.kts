import org.jetbrains.intellij.platform.gradle.extensions.intellijPlatform

rootProject.name = "magic-jewel"

pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
        maven("https://www.jetbrains.com/intellij-repository/releases")
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
    id("org.jetbrains.intellij.platform.settings") version "2.10.1"
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenLocal()
        google()
        mavenCentral()
        intellijPlatform { defaultRepositories() }
        maven("https://www.jetbrains.com/intellij-repository/releases")
        maven("https://cache-redirector.jetbrains.com/intellij-dependencies")
        maven("https://packages.jetbrains.team/maven/p/jewel/maven")
    }
}

include(":ide-benchmark-plugin")
