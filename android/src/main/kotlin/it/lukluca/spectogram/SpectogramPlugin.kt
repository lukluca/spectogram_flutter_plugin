package it.lukluca.spectogram

import android.app.Activity
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/** SpectogramPlugin */
class SpectogramPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener, SpectogramViewHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var controller: SpectogramController
  private lateinit var factory : SpectogramViewFactory

  private var frequencyView: FrequencyView? = null

  private var activity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    controller = SpectogramController(flutterPluginBinding.applicationContext)

    factory = SpectogramViewFactory()

    factory.setSpectogramViewHandler(this)

    flutterPluginBinding.platformViewRegistry.registerViewFactory("SpectogramView", factory)

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "spectogram")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    factory.setSpectogramViewHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "configureWhiteBackground" -> configureWhiteBackground(result)
      "configureBlackBackground" -> configureBlackBackground(result)
      "setWidget" -> setWidget(result)
      "start" -> start(result)
      "stop" -> stop(result)
      "reset" -> reset(result)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun configureWhiteBackground(result: Result) {
    Log.v("SpectogramPlugin", "configureWhiteBackground")
    sendNullResult(result)
  }

  private fun configureBlackBackground(result: Result) {
    Log.v("SpectogramPlugin", "configureBlackBackground")
    sendNullResult(result)
  }

  private fun setWidget(result: Result) {
    Log.v("SpectogramPlugin", "setWidget")
    sendNullResult(result)
  }

  override fun onCreateView() {
    Log.v("SpectogramPlugin", "onCreateView")
    setFrequencyViewIfNotNull()
  }

  private fun setFrequencyViewIfNotNull() {
    if (frequencyView != null) {
      return
    }

    frequencyView = activity?.findViewById(R.id.frequency_view)

    Executors.newSingleThreadScheduledExecutor().schedule({
      setFrequencyViewIfNotNull()
    }, 0.2.toLong(), TimeUnit.SECONDS)
  }

  private fun start(result: Result) {
    Log.v("SpectogramPlugin", "start")
    startRecording()
    sendNullResult(result)
  }

  private fun stop(result: Result) {
    stopRecording()
    sendNullResult(result)
  }

  private fun reset(result: Result) {
    Log.v("SpectogramPlugin", "reset")
    sendNullResult(result)
  }

  private fun sendNullResult(result: Result) {
    result.success(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.v("SpectogramPlugin", "onAttachedToActivity")
    setProperties(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    resetProperties()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.v("SpectogramPlugin", "onReattachedToActivityForConfigChanges")
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
    binding.addRequestPermissionsResultListener(this)
    setProperties(binding.activity)
  }

  private fun setProperties(activity: Activity) {
    this.activity = activity
    val context = activity.applicationContext
    controller.setProperties(activity, context)
  }

  private fun resetProperties() {
    activity = null
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
