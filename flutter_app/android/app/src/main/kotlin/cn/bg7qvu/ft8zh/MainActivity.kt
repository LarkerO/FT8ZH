package cn.bg7qvu.ft8zh

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformSummary" -> {
                    result.success(
                        mapOf(
                            "platform" to "android",
                            "brand" to Build.BRAND,
                            "device" to Build.DEVICE,
                            "manufacturer" to Build.MANUFACTURER,
                            "model" to Build.MODEL,
                            "sdkInt" to Build.VERSION.SDK_INT,
                            "release" to Build.VERSION.RELEASE,
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL_NAME = "cn.bg7qvu.ft8zh/native"
    }
}
