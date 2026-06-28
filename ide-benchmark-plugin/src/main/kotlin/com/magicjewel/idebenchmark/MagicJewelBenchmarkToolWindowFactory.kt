package com.magicjewel.idebenchmark

import com.intellij.openapi.project.Project
import com.intellij.openapi.wm.ToolWindow
import com.intellij.openapi.wm.ToolWindowFactory
import org.jetbrains.jewel.bridge.addComposeTab

class MagicJewelBenchmarkToolWindowFactory : ToolWindowFactory {
    override fun createToolWindowContent(project: Project, toolWindow: ToolWindow) {
        toolWindow.addComposeTab(tabDisplayName = "Benchmark") {
            MagicJewelBenchmarkContent()
        }
    }

    override fun shouldBeAvailable(project: Project): Boolean = true
}
