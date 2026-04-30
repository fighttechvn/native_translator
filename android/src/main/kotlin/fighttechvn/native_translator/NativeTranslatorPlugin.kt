package fighttechvn.native_translator

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** NativeTranslatorPlugin */
class NativeTranslatorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_translator")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "isSupported" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.success(false)
                    return
                }

                val intent = Intent().apply {
                    action = Intent.ACTION_PROCESS_TEXT
                    type = "text/plain"
                }

                val googleTranslateIntent = Intent(intent).apply {
                    setPackage("com.google.android.apps.translate")
                }

                val pm = currentActivity.packageManager
                val googleTranslateExists = googleTranslateIntent.resolveActivity(pm) != null
                val anyAppExists = intent.resolveActivity(pm) != null

                result.success(googleTranslateExists || anyAppExists)
            }
            "translateText" -> {
                val text = call.argument<String>("text")
                if (text == null) {
                    result.error("INVALID_ARGUMENTS", "Text argument is required", null)
                    return
                }

                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("UNAVAILABLE", "Could not find root activity", null)
                    return
                }

                val intent = Intent().apply {
                    action = Intent.ACTION_PROCESS_TEXT
                    type = "text/plain"
                    putExtra(Intent.EXTRA_PROCESS_TEXT, text)
                    putExtra(Intent.EXTRA_PROCESS_TEXT_READONLY, true)
                }

                // First try targeting Google Translate specifically
                val googleTranslateIntent = Intent(intent).apply {
                    setPackage("com.google.android.apps.translate")
                }

                try {
                    currentActivity.startActivity(googleTranslateIntent)
                    result.success(null)
                } catch (e: ActivityNotFoundException) {
                    // Fallback to general process text intent
                    try {
                        currentActivity.startActivity(intent)
                        result.success(null)
                    } catch (e2: ActivityNotFoundException) {
                        result.error("NOT_FOUND", "No application found to handle text translation", null)
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
