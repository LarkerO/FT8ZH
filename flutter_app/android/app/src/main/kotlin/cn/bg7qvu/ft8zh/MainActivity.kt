package cn.bg7qvu.ft8zh

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var timerSink: EventChannel.EventSink? = null
    private var stateSink: EventChannel.EventSink? = null
    private var timerRunnable: Runnable? = null
    private var isListening = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NATIVE,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformSummary" -> result.success(platformSummary())
                "getInitialSnapshot" -> result.success(initialSnapshot())
                "startListening" -> {
                    isListening = true
                    pushRigState()
                    result.success(null)
                }

                "stopListening" -> {
                    isListening = false
                    pushRigState()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

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
    }

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
            "messages" to demoMessages(),
        )

    private fun currentRigState(): Map<String, Any?> =
        mapOf(
            "connectionLabel" to if (isListening) "桥接已连" else "桥接待机",
            "isConnected" to true,
            "isListening" to isListening,
            "mode" to "FT8",
            "frequencyHz" to 14_074_000,
            "audioSource" to if (isListening) "NATIVE BRIDGE" else "IDLE",
            "platform" to "android",
        )

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

    private fun demoMessages(nowMs: Long = System.currentTimeMillis()): List<Map<String, Any>> {
        val phase = ((nowMs / 1000L) % 15).toInt()
        val offsetBase = if (isListening) 420 else 120
        return listOf(
            mapOf(
                "text" to "CQ BG7QVU OL72",
                "snr" to (-12 + phase % 5),
                "offsetHz" to offsetBase,
                "isWeakSignal" to false,
            ),
            mapOf(
                "text" to "JA1ABC BG7QVU -09",
                "snr" to (-9 + phase % 3),
                "offsetHz" to offsetBase + 180,
                "isWeakSignal" to true,
            ),
        )
    }

    private fun pushRigState() {
        stateSink?.success(currentRigState())
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

    override fun onDestroy() {
        stopTimerFeed()
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_NATIVE = "cn.bg7qvu.ft8zh/native"
        private const val CHANNEL_TIMER = "cn.bg7qvu.ft8zh/timer"
        private const val CHANNEL_STATE = "cn.bg7qvu.ft8zh/state"
    }
}
