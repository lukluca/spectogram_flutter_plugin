package it.lukluca.spectogram

import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** SpectogramPlugin */
class SpectogramPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var controller: SpectogramController

  private var frequencyView: FrequencyView? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    controller = SpectogramController(flutterPluginBinding.applicationContext)

    flutterPluginBinding.platformViewRegistry.registerViewFactory("SpectogramView", SpectogramViewFactory())
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "spectogram")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "configureWhiteBackground" -> print("x == 1")
      "configureBlackBackground" -> print("x == 2")
      "setWidget" -> setWidget(result)
      "start" -> start(result)
      "stop" -> stop(result)
      "reset" -> print("x == 2")
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun setWidget(result: Result) {
    sendNullResult(result)
  }

  private fun start(result: Result) {
    startRecording()
    sendNullResult(result)
  }

  private fun stop(result: Result) {
    stopRecording()
    sendNullResult(result)
  }

  private fun sendNullResult(result: Result) {
    result.success(null)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    setProperties(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    resetProperties()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    setProperties(binding)
  }

  override fun onDetachedFromActivity() {
    resetProperties()
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
  ): Boolean {

    when (requestCode) {
      SpectogramController.MY_PERMISSIONS_REQUEST_RECORD_AUDIO -> {

        if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                  controller.loadEngine()
        }

        return true
      }
    }
    return false
  }

  private fun setProperties(binding: ActivityPluginBinding) {
    frequencyView = binding.activity.findViewById(R.id.frequency_view)
    binding.addRequestPermissionsResultListener(this)
    val context = binding.activity.applicationContext
    controller.setProperties(binding.activity, context)
  }

  private fun resetProperties() {
    frequencyView = null
    controller.resetProperties()
  }

  private fun startRecording() {
    frequencyView?.let {
      controller.start(it)
    }
  }

  private fun stopRecording() {
    controller.stop()
  }
}
