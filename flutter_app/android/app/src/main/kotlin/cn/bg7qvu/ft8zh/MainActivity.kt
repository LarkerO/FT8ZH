package cn.bg7qvu.ft8zh

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

/**
 * Flutter host activity that bridges between the Flutter UI and the
 * native FT8 engine (currently via demo data; real JNI integration
 * will replace the demo generators).
 *
 * Channels:
 *   Method:  cn.bg7qvu.ft8zh/native
 *   Events:  cn.bg7qvu.ft8zh/timer
 *            cn.bg7qvu.ft8zh/state
 *            cn.bg7qvu.ft8zh/decode
 *            cn.bg7qvu.ft8zh/spectrum
 */
class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var timerSink: EventChannel.EventSink? = null
    private var stateSink: EventChannel.EventSink? = null
    private var decodeSink: EventChannel.EventSink? = null
    private var spectrumSink: EventChannel.EventSink? = null
    private var timerRunnable: Runnable? = null
    private var spectrumRunnable: Runnable? = null
    private var decodeRunnable: Runnable? = null

    private var isListening = false
    private var isTransmitting = false
    private var isDecoding = false

    // Persisted config (in-memory; a real implementation would use SharedPreferences / SQLite)
    private var config = mutableMapOf<String, Any?>(
        "myCallsign" to "",
        "myMaidenGrid" to "",
        "toModifier" to "",
        "transmitFrequencyHz" to 1500,
        "transmitDelay" to 500,
        "launchSupervisionMs" to 600000,
        "noReplyLimit" to 0,
        "connectMode" to 0,
        "controlMode" to 0,
        "instructionSet" to 0,
        "civAddress" to 0xA4,
        "baudRate" to 19200,
        "serialDataBits" to 8,
        "serialParity" to 0,
        "serialStopBits" to 1,
        "pttDelay" to 100,
        "bandHz" to 14_074_000,
        "synFrequency" to true,
        "deepDecode" to false,
        "saveSWLMessages" to false,
        "enableCloudlog" to false,
        "cloudlogAddress" to "",
        "cloudlogApiKey" to "",
        "cloudlogStationId" to "",
        "enableQrz" to false,
        "qrzApiKey" to "",
        "excludedCallsigns" to "",
        "volumePercent" to 0.5,
        "rigName" to "",
        "icomIp" to "255.255.255.255",
        "icomPort" to 50001,
        "icomUser" to "ic705",
        "icomPassword" to "",
    )

    // Demo QSO log records
    private val demoLogRecords = mutableListOf<Map<String, Any?>>(
        mapOf(
            "id" to 1,
            "startTime" to (System.currentTimeMillis() - 3600_000),
            "endTime" to (System.currentTimeMillis() - 3500_000),
            "myCallsign" to "BG7QVU",
            "toCallsign" to "JA1ABC",
            "myMaidenGrid" to "OL72",
            "toMaidenGrid" to "PM95",
            "reportSent" to -12,
            "reportReceived" to -9,
            "mode" to "FT8",
            "frequencyHz" to 14_074_000,
            "band" to "20m",
            "isConfirmed" to true,
        ),
        mapOf(
            "id" to 2,
            "startTime" to (System.currentTimeMillis() - 7200_000),
            "endTime" to (System.currentTimeMillis() - 7100_000),
            "myCallsign" to "BG7QVU",
            "toCallsign" to "VK2XYZ",
            "myMaidenGrid" to "OL72",
            "toMaidenGrid" to "QF56",
            "reportSent" to -6,
            "reportReceived" to -15,
            "mode" to "FT8",
            "frequencyHz" to 7_074_000,
            "band" to "40m",
            "isConfirmed" to false,
        ),
        mapOf(
            "id" to 3,
            "startTime" to (System.currentTimeMillis() - 86400_000),
            "endTime" to (System.currentTimeMillis() - 86300_000),
            "myCallsign" to "BG7QVU",
            "toCallsign" to "K1TEST",
            "myMaidenGrid" to "OL72",
            "toMaidenGrid" to "FN31",
            "reportSent" to -3,
            "reportReceived" to -18,
            "mode" to "FT8",
            "frequencyHz" to 21_074_000,
            "band" to "15m",
            "isConfirmed" to true,
        ),
    )
    private var nextLogId = 4

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ------------------------------------------------------------------
        // Method channel
        // ------------------------------------------------------------------
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NATIVE,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformSummary" -> result.success(platformSummary())
                "getInitialSnapshot" -> result.success(initialSnapshot())

                "startListening" -> {
                    isListening = true
                    isDecoding = true
                    pushRigState()
                    result.success(null)
                }

                "stopListening" -> {
                    isListening = false
                    isDecoding = false
                    isTransmitting = false
                    pushRigState()
                    result.success(null)
                }

                "startTransmit" -> {
                    isTransmitting = true
                    pushRigState()
                    result.success(null)
                }

                "stopTransmit" -> {
                    isTransmitting = false
                    pushRigState()
                    result.success(null)
                }

                "clearMessages" -> {
                    pushDecodeMessages(emptyList())
                    result.success(null)
                }

                "callStation" -> {
                    val callsign = call.argument<String>("callsign") ?: ""
                    // In real implementation, this would initiate a call sequence
                    isTransmitting = true
                    pushRigState()
                    result.success(null)
                }

                "saveConfig" -> {
                    @Suppress("UNCHECKED_CAST")
                    val incoming = call.arguments as? Map<String, Any?> ?: emptyMap()
                    config.putAll(incoming)
                    result.success(null)
                }

                "loadConfig" -> result.success(config.toMap())

                "setBand" -> {
                    val freq = call.argument<Int>("frequencyHz") ?: 14_074_000
                    config["bandHz"] = freq
                    pushRigState()
                    result.success(null)
                }

                "setTransmitFrequency" -> {
                    val offset = call.argument<Int>("offsetHz") ?: 1500
                    config["transmitFrequencyHz"] = offset
                    result.success(null)
                }

                "queryLogs" -> {
                    val callsign = call.argument<String>("callsign")
                    val limit = call.argument<Int>("limit") ?: 50
                    val offset = call.argument<Int>("offset") ?: 0
                    var filtered = demoLogRecords.toList()
                    if (!callsign.isNullOrBlank()) {
                        filtered = filtered.filter {
                            val to = it["toCallsign"] as? String ?: ""
                            val my = it["myCallsign"] as? String ?: ""
                            to.contains(callsign, ignoreCase = true) ||
                                    my.contains(callsign, ignoreCase = true)
                        }
                    }
                    val paged = filtered.drop(offset).take(limit)
                    result.success(paged)
                }

                "getLogCount" -> result.success(demoLogRecords.size)

                "deleteLog" -> {
                    val id = call.argument<Int>("id") ?: -1
                    demoLogRecords.removeAll { (it["id"] as? Int) == id }
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // ------------------------------------------------------------------
        // Timer event channel
        // ------------------------------------------------------------------
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_TIMER,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    timerSink = events
                    startTimerFeed()
                }

                override fun onCancel(arguments: Any?) {
                    timerSink = null
                    stopTimerFeed()
                }
            },
        )

        // ------------------------------------------------------------------
        // Rig state event channel
        // ------------------------------------------------------------------
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_STATE,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    stateSink = events
                    pushRigState()
                }

                override fun onCancel(arguments: Any?) {
                    stateSink = null
                }
            },
        )

        // ------------------------------------------------------------------
        // Decode messages event channel
        // ------------------------------------------------------------------
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_DECODE,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    decodeSink = events
                    startDecodeFeed()
                }

                override fun onCancel(arguments: Any?) {
                    decodeSink = null
                    stopDecodeFeed()
                }
            },
        )

        // ------------------------------------------------------------------
        // Spectrum data event channel
        // ------------------------------------------------------------------
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_SPECTRUM,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    spectrumSink = events
                    startSpectrumFeed()
                }

                override fun onCancel(arguments: Any?) {
                    spectrumSink = null
                    stopSpectrumFeed()
                }
            },
        )
    }

    // ======================================================================
    // Snapshot builders
    // ======================================================================

    private fun platformSummary(): Map<String, Any?> =
        mapOf(
            "platform" to "android",
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "sdkInt" to Build.VERSION.SDK_INT,
            "release" to Build.VERSION.RELEASE,
        )

    private fun initialSnapshot(): Map<String, Any?> =
        mapOf(
            "rigState" to currentRigState(),
            "timerState" to currentTimerState(),
            "messages" to generateDecodeMessages(),
            "config" to config.toMap(),
        )

    private fun currentRigState(): Map<String, Any?> {
        val bandHz = (config["bandHz"] as? Number)?.toInt() ?: 14_074_000
        return mapOf(
            "connectionLabel" to when {
                isTransmitting -> "正在发射"
                isListening -> "监听中"
                else -> "待机"
            },
            "isConnected" to true,
            "isListening" to isListening,
            "isTransmitting" to isTransmitting,
            "isDecoding" to isDecoding,
            "isRecording" to isListening,
            "mode" to "FT8",
            "frequencyHz" to bandHz,
            "audioSource" to if (isListening) "MIC" else "IDLE",
            "platform" to "android",
            "connectMode" to ((config["connectMode"] as? Number)?.toInt() ?: 0),
            "rigName" to ((config["rigName"] as? String) ?: ""),
        )
    }

    private fun currentTimerState(nowMs: Long = System.currentTimeMillis()): Map<String, Any> {
        val slotLengthSeconds = 15
        val slotMillis = slotLengthSeconds * 1000L
        val slotProgress = (nowMs % slotMillis).toDouble() / slotMillis.toDouble()
        val sequential = ((nowMs / 1000L) / slotLengthSeconds % 2).toInt()
        return mapOf(
            "utcMillis" to nowMs,
            "slotProgress" to slotProgress,
            "sequential" to sequential,
            "slotLengthSeconds" to slotLengthSeconds,
        )
    }

    // ======================================================================
    // Decode message generation (demo – will be replaced by real JNI decode)
    // ======================================================================

    private val demoCalls = listOf(
        Triple("CQ BG7QVU OL72", "BG7QVU", true),
        Triple("JA1ABC BG7QVU -09", "JA1ABC", false),
        Triple("CQ DX K1TEST FN31", "K1TEST", true),
        Triple("VK2XYZ BG7QVU R-12", "VK2XYZ", false),
        Triple("CQ POTA W5ABC EM10", "W5ABC", true),
        Triple("UA3XYZ BG7QVU RR73", "UA3XYZ", false),
        Triple("BG7QVU JA1ABC R-06", "BG7QVU", false),
        Triple("CQ BV2AAA PL04", "BV2AAA", true),
        Triple("HL5BMX BG7QVU -15", "HL5BMX", false),
        Triple("CQ DU1XX PK04", "DU1XX", true),
    )

    private fun generateDecodeMessages(nowMs: Long = System.currentTimeMillis()): List<Map<String, Any>> {
        if (!isListening) return emptyList()
        val phase = ((nowMs / 1000L) % 15).toInt()
        val count = 3 + (phase % 5)
        return demoCalls.take(count).mapIndexed { i, (text, from, isCQ) ->
            val snr = -20 + Random.nextInt(30)
            val offsetHz = 200 + i * 180 + Random.nextInt(60)
            mapOf(
                "text" to text,
                "snr" to snr,
                "offsetHz" to offsetHz,
                "isWeakSignal" to (snr < -15),
                "utcTime" to nowMs,
                "timeSec" to (phase.toDouble() + i * 0.1),
                "freqHz" to offsetHz.toDouble(),
                "callsignFrom" to from,
                "callsignTo" to if (isCQ) "" else "BG7QVU",
                "extraInfo" to if (isCQ) "" else "${if (snr >= 0) "+" else ""}$snr",
                "modifier" to if (text.contains("POTA")) "POTA" else "",
                "i3" to 1,
                "n3" to 0,
                "isCQ" to isCQ,
                "isQslCallsign" to false,
                "signalFormat" to 0,
                "sequence" to (phase % 2),
                "maidenGrid" to "",
            )
        }
    }

    // ======================================================================
    // Spectrum generation (demo – will be replaced by real FFT data)
    // ======================================================================

    private fun generateSpectrum(): List<Double> {
        val now = System.currentTimeMillis()
        val seed = now / 1000.0
        return List(48) { i ->
            val x = i / 48.0
            val wave = sin(x * 6.28318 * 3 + seed * 0.5)
            val shimmer = cos(seed / 3 + i * 0.37)
            val baseline = if (isListening) 0.45 else 0.15
            val noise = Random.nextDouble() * 0.08
            (baseline + wave * 0.18 + shimmer * 0.06 + noise).coerceIn(0.05, 0.95)
        }
    }

    // ======================================================================
    // Event feeds
    // ======================================================================

    private fun pushRigState() {
        stateSink?.success(currentRigState())
    }

    private fun pushDecodeMessages(messages: List<Map<String, Any>>) {
        decodeSink?.success(messages)
    }

    private fun startTimerFeed() {
        if (timerRunnable != null) return
        timerRunnable = object : Runnable {
            override fun run() {
                timerSink?.success(currentTimerState())
                mainHandler.postDelayed(this, 1000L)
            }
        }
        mainHandler.post(timerRunnable!!)
    }

    private fun stopTimerFeed() {
        timerRunnable?.let(mainHandler::removeCallbacks)
        timerRunnable = null
    }

    private fun startDecodeFeed() {
        if (decodeRunnable != null) return
        decodeRunnable = object : Runnable {
            override fun run() {
                decodeSink?.success(generateDecodeMessages())
                mainHandler.postDelayed(this, 15_000L) // every slot
            }
        }
        // First push immediately, then every 15 s
        decodeSink?.success(generateDecodeMessages())
        mainHandler.postDelayed(decodeRunnable!!, 15_000L)
    }

    private fun stopDecodeFeed() {
        decodeRunnable?.let(mainHandler::removeCallbacks)
        decodeRunnable = null
    }

    private fun startSpectrumFeed() {
        if (spectrumRunnable != null) return
        spectrumRunnable = object : Runnable {
            override fun run() {
                spectrumSink?.success(generateSpectrum())
                mainHandler.postDelayed(this, 200L) // 5 fps
            }
        }
        mainHandler.post(spectrumRunnable!!)
    }

    private fun stopSpectrumFeed() {
        spectrumRunnable?.let(mainHandler::removeCallbacks)
        spectrumRunnable = null
    }

    override fun onDestroy() {
        stopTimerFeed()
        stopDecodeFeed()
        stopSpectrumFeed()
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_NATIVE = "cn.bg7qvu.ft8zh/native"
        private const val CHANNEL_TIMER = "cn.bg7qvu.ft8zh/timer"
        private const val CHANNEL_STATE = "cn.bg7qvu.ft8zh/state"
        private const val CHANNEL_DECODE = "cn.bg7qvu.ft8zh/decode"
        private const val CHANNEL_SPECTRUM = "cn.bg7qvu.ft8zh/spectrum"
    }
}
