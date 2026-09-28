package com.yellowtech.yellowconnect

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var initialUri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initialUri = launchUri(intent)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialUri") {
                    result.success(initialUri)
                    initialUri = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        launchUri(intent)?.let { channel?.invokeMethod("onUri", it) }
    }

    /** A `yellowconnect://` link from a widget, ignoring relaunches from Recents. */
    private fun launchUri(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        return intent.dataString?.takeIf { it.startsWith("$SCHEME://") }
    }

    companion object {
        const val CHANNEL = "yellowconnect/launch_action"
        const val SCHEME = "yellowconnect"
    }
}
