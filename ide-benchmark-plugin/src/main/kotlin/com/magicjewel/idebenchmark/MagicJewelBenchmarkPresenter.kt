package com.magicjewel.idebenchmark

import java.io.Closeable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.jetbrains.jewel.markdown.MarkdownBlock
import org.jetbrains.jewel.markdown.processing.MarkdownProcessor

internal data class MagicJewelBenchmarkUiState(
    val mode: BenchmarkMode = BenchmarkMode.Hypnotoad,
    val hypnotoadIntensity: Int = 0,
    val hypnotoadFrame: Int = 0,
    val streamingToken: Int = 0,
    val streamingMarkdownBlocks: List<MarkdownBlock> = emptyList(),
)

internal class MagicJewelBenchmarkPresenter(
    initialMode: BenchmarkMode,
    private val presenterJob: Job = SupervisorJob(),
) : Closeable {
    private val scope = CoroutineScope(presenterJob + Dispatchers.Default)
    private val processor = MarkdownProcessor(emptyList())
    private val chunks = ArrayDeque<String>()
    private var streamingJob: Job? = null
    private var hypnotoadJob: Job? = null
    private val _state = MutableStateFlow(MagicJewelBenchmarkUiState(mode = initialMode))
    val state: StateFlow<MagicJewelBenchmarkUiState> = _state.asStateFlow()

    init {
        if (initialMode == BenchmarkMode.Chat) {
            startStreaming()
        } else {
            startHypnotoadFrames()
        }
    }

    fun setMode(mode: BenchmarkMode) {
        _state.update { it.copy(mode = mode) }
        if (mode == BenchmarkMode.Chat) {
            hypnotoadJob?.cancel()
            hypnotoadJob = null
            startStreaming()
        } else {
            streamingJob?.cancel()
            streamingJob = null
            startHypnotoadFrames()
        }
    }

    fun increaseHypnotoadIntensity() {
        _state.update { it.copy(hypnotoadIntensity = (it.hypnotoadIntensity + 1).coerceAtMost(4)) }
    }

    fun decreaseHypnotoadIntensity() {
        _state.update { it.copy(hypnotoadIntensity = (it.hypnotoadIntensity - 1).coerceAtLeast(0)) }
    }

    fun resetHypnotoadIntensity() {
        _state.update { it.copy(hypnotoadIntensity = 0) }
    }

    private fun startStreaming() {
        if (streamingJob?.isActive == true) return
        streamingJob =
            scope.launch {
                var token = _state.value.streamingToken
                while (true) {
                    val blocks = appendAndParseMarkdown(token)
                    _state.update {
                        it.copy(
                            mode = BenchmarkMode.Chat,
                            streamingToken = token,
                            streamingMarkdownBlocks = blocks,
                        )
                    }
                    println("MAGIC_JEWEL_IDE_BENCHMARK_FRAME mode=chat token=$token chunks=${chunks.size}")
                    token += 1
                    delay(80)
                }
            }
    }

    private fun startHypnotoadFrames() {
        if (hypnotoadJob?.isActive == true) return
        hypnotoadJob =
            scope.launch {
                var frame = _state.value.hypnotoadFrame
                while (true) {
                    _state.update {
                        it.copy(
                            mode = BenchmarkMode.Hypnotoad,
                            hypnotoadFrame = frame,
                        )
                    }
                    println(
                        "MAGIC_JEWEL_IDE_BENCHMARK_FRAME " +
                            "mode=hypnotoad frame=$frame intensity=${_state.value.hypnotoadIntensity}",
                    )
                    frame += 1
                    delay(80)
                }
            }
    }

    private suspend fun appendAndParseMarkdown(token: Int): List<MarkdownBlock> =
        withContext(Dispatchers.Default) {
            chunks += markdownChunk(token)
            while (chunks.size > MaxChunks) chunks.removeFirst()
            processor.processMarkdownDocument(chunks.joinToString(separator = "\n\n---\n\n"))
        }

    override fun close() {
        presenterJob.cancel()
    }

    private companion object {
        const val MaxChunks = 180
    }
}

private fun markdownChunk(token: Int): String =
    buildString {
        append("### Assistant update ")
        append(token)
        append("\n\nStreaming **Jewel Markdown** sample token ")
        append(token)
        append(". ")
        if (token % 3 == 0) append("`CommandStreamWriter` appends a compact record. ")
        if (token % 5 == 0) append("\n\n- bullet with a link-shaped span https://sebastiano.dev")
        if (token % 7 == 0) append("\n\n> block quote pressure with wrapping text and repaint churn.")
        if (token % 11 == 0) {
            append("\n\n```kotlin\n")
            append("presenter.appendToken(")
            append(token)
            append(")\n")
            append("```")
        }
    }
