package studio.novikov.battery

import android.content.*
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


private const val CHANNEL_NAME = "battery"
private const val METHOD_POWER_CHANGE_NOTIFY = "power_change_notify"
private const val METHOD_GET_POWER = "get_percents"

/** BatteryPlugin */
class BatteryPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var levelChangedReceiver: BroadcastReceiver

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        // Subscribe to battery level changing
        levelChangedReceiver = createLevelChangedReceiver()
        applicationContext.registerReceiver(
            levelChangedReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Unsubscribe handlers
        channel.setMethodCallHandler(null)
        applicationContext.unregisterReceiver(levelChangedReceiver)
    }

    /** Client's methods handler **/
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == METHOD_GET_POWER) {
            onGetPower(result)
        } else {
            result.notImplemented()
        }
    }

    /** GetPower method handler **/
    private fun onGetPower(@NonNull result: Result) {
        val batteryLevel = getBatteryLevel()

        if (batteryLevel != -1) {
            result.success(batteryLevel)
        } else {
            result.error("UNAVAILABLE", "Battery level not available.", null)
        }
    }

    /** Get battery level (0-100) **/
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int = if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager =
                applicationContext.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext)
                .registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intentToLevel(intent)
        }
        return batteryLevel
    }

    /** Battery level changing handler **/
    private fun createLevelChangedReceiver(): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val level = intentToLevel(intent)
                channel.invokeMethod(METHOD_POWER_CHANGE_NOTIFY, level)
            }
        }
    }

    /** Convert intent data to battery level **/
    private fun intentToLevel(intent: Intent?): Int {
        return (intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100
                / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1))
    }
}
