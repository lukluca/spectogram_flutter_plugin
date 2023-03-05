package it.lukluca.spectogram

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import it.lukluca.spectogram.Misc.getFftResolution
import it.lukluca.spectogram.Misc.getSamplingRate
import kotlin.properties.Delegates


/** SpectogramPlugin */
class SpectogramPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var fftResolution by Delegates.notNull<Int>()
  private var bufferStack // Store trunks of buffers
          : ArrayList<ShortArray> = ArrayList()

  private lateinit var fftBuffer: ShortArray

  private var frequencyView: FrequencyView? = null
  private var continuousRecord: ContinuousRecord? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    fftResolution = getFftResolution(flutterPluginBinding.applicationContext)
    fftBuffer = ShortArray(fftResolution)

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
      "stop" -> print("x == 2")
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

  private fun setProperties(binding: ActivityPluginBinding) {
    frequencyView = binding.activity.findViewById(R.id.frequency_view)
    val context = binding.activity.applicationContext
    continuousRecord = ContinuousRecord(getSamplingRate(context), context)

    continuousRecord?.let {
      val n = fftResolution
      val l: Int = it.bufferLength / (n / 2)
      for (i in 0 until l + 1) { //+1 because the last one has to be used again and sent to first position
        bufferStack.add(ShortArray(n / 2)) // preallocate to avoid new within processing loop
      }
    }
  }

  private fun resetProperties() {
    frequencyView = null
    continuousRecord = null
  }

  private fun startRecording() {
    continuousRecord?.start { recordBuffer: ShortArray? ->
      if (recordBuffer != null) {
        this.getTrunks(recordBuffer)
      }
    }
  }

  private fun stopRecording() {
    continuousRecord?.stop()
  }

  private fun getTrunks(recordBuffer: ShortArray) {
    val n = fftResolution

    // Trunks are consecutive n/2 length samples
    for (i in 0 until (bufferStack.size.minus(1)))
      bufferStack[i + 1].let {
        System.arraycopy(
          recordBuffer,
          n / 2 * i,
           it,
          0,
          n / 2
      )
    }

    // Build n length buffers for processing
    // Are build from consecutive trunks
    for (i in 0 until (bufferStack.size.minus(1))) {
      bufferStack[i].let { System.arraycopy(it, 0, fftBuffer, 0, n / 2) }
      bufferStack[i + 1].let { System.arraycopy(it, 0, fftBuffer, n / 2, n / 2) }
      process()
    }

    // Last item has not yet fully be used (only its first half)
    // Move it to first position in arraylist so that its last half is used
    val first: ShortArray = bufferStack[0]
    val last: ShortArray = bufferStack[bufferStack.size - 1]
    System.arraycopy(last, 0, first, 0, n / 2)
  }

  private fun process() {

  }
}
