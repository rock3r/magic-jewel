package com.magicjewel.idebenchmark

import java.lang.management.ManagementFactory
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

internal class NamedThreadCpuSampler private constructor(
    private val intervalSeconds: Long,
) : AutoCloseable {
    private val threadBean = ManagementFactory.getThreadMXBean()
    private val executor = Executors.newSingleThreadScheduledExecutor { runnable ->
        Thread(runnable, "magic-jewel-thread-cpu-sampler").apply { isDaemon = true }
    }
    private var previousCpuNanos = emptyMap<Long, Long>()

    fun start(): NamedThreadCpuSampler {
        if (!threadBean.isThreadCpuTimeSupported) {
            println("MAGIC_JEWEL_IDE_BENCHMARK_THREAD_CPU status=unsupported")
            return this
        }
        if (!threadBean.isThreadCpuTimeEnabled) {
            threadBean.isThreadCpuTimeEnabled = true
        }
        previousCpuNanos = currentCpuNanos()
        executor.scheduleAtFixedRate(
            ::sample,
            intervalSeconds,
            intervalSeconds,
            TimeUnit.SECONDS,
        )
        return this
    }

    private fun sample() {
        runCatching {
            val ids = threadBean.allThreadIds
            val names = threadBean.getThreadInfo(ids).mapNotNull { info ->
                info?.let { it.threadId to it.threadName.toReasonToken() }
            }.toMap()
            val current = currentCpuNanos(ids)
            val deltas = current.mapNotNull { (id, cpuNanos) ->
                val previous = previousCpuNanos[id] ?: return@mapNotNull null
                val delta = cpuNanos - previous
                if (delta <= 0L) null else ThreadCpuDelta(id, names[id] ?: "unknown", delta)
            }
            previousCpuNanos = current
            val top = deltas.sortedByDescending(ThreadCpuDelta::cpuNanos).take(TOP_THREAD_COUNT)
            println(
                "MAGIC_JEWEL_IDE_BENCHMARK_THREAD_CPU status=sampled intervalMs=${intervalSeconds * 1000} " +
                    "totalCpuNanos=${deltas.sumOf(ThreadCpuDelta::cpuNanos)} " +
                    "top=${top.joinToString(",") { "${it.name}#${it.id}:${it.cpuNanos}" }}",
            )
        }.onFailure { error ->
            println(
                "MAGIC_JEWEL_IDE_BENCHMARK_THREAD_CPU status=failed " +
                    "error=${error::class.simpleName}:${error.message?.toReasonToken()}",
            )
        }
    }

    private fun currentCpuNanos(ids: LongArray = threadBean.allThreadIds): Map<Long, Long> =
        buildMap {
            ids.forEach { id ->
            val cpuNanos = threadBean.getThreadCpuTime(id)
                if (cpuNanos >= 0L) {
                    put(id, cpuNanos)
                }
            }
        }

    override fun close() {
        executor.shutdownNow()
    }

    private fun String.toReasonToken(): String = replace("[^A-Za-z0-9_.-]".toRegex(), "_")

    private data class ThreadCpuDelta(
        val id: Long,
        val name: String,
        val cpuNanos: Long,
    )

    companion object {
        private const val TOP_THREAD_COUNT = 8

        fun start(intervalSeconds: Long = 5): NamedThreadCpuSampler =
            NamedThreadCpuSampler(intervalSeconds).start()
    }
}
