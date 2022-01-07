package money.nala.banked

import android.util.Log
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** BankedPlugin */
class BankedPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    private var activity: FragmentActivity? = null

    private val resultsMap: MutableMap<String, Result> = mutableMapOf()

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "banked")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        result.notImplemented()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) = onAttached(binding = binding)

    override fun onDetachedFromActivity() = onDetached()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttached(binding = binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetached()

    private fun onAttached(binding: ActivityPluginBinding) {
        activity = binding.activity as FragmentActivity
    }

    private fun onDetached() {
        activity = null
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "banked")
            channel.setMethodCallHandler(BankedPlugin().apply {
                activity = registrar.activity() as FragmentActivity
            })
        }
    }
}