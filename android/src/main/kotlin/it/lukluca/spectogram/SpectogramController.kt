package it.lukluca.spectogram

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import it.lukluca.spectogram.Misc.getFftResolution
import it.lukluca.spectogram.Misc.getSamplingRate
import it.lukluca.spectogram.Misc.getWindowType
import kotlin.math.ln


class SpectogramController(context: Context) {

    private var fftResolution: Int
    private var bufferStack // Store trunks of buffers
            : ArrayList<ShortArray> = ArrayList()

    private var fftBuffer: ShortArray

    private var continuousRecord: ContinuousRecord? = null
    private var nativeLib: SoundEngine? = null

    private var re // buffer holding real part during fft process
            : FloatArray? = null
    private var im // buffer holding imaginary part during fft process
            : FloatArray? = null

    private var activity: Activity? = null
    private var context: Context? = null

    init {
        fftResolution = getFftResolution(context)
        fftBuffer = ShortArray(fftResolution)
    }

    fun setProperties(activity: Activity, context: Context) {

        Log.v("SpectogramController", "setProperties")

        this.activity = activity
        this.context = context

        continuousRecord = ContinuousRecord(getSamplingRate(context), context)

        continuousRecord?.let {
            val n = fftResolution
            val l: Int = it.bufferLength / (n / 2)
            for (i in 0 until l + 1) { //+1 because the last one has to be used again and sent to first position
                bufferStack.add(ShortArray(n / 2)) // preallocate to avoid new within processing loop
            }
        }

        // JNI interface
        nativeLib = SoundEngine()
        nativeLib?.initFSin()

        val permission = Manifest.permission.RECORD_AUDIO

        when {

            ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED -> {
                // You can use the API that requires the permission.
                Log.i("SpectogramController", "PERMISSION_GRANTED")
                loadEngine()
            }

            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission) -> {

                val builder: AlertDialog.Builder = activity.let {
                    AlertDialog.Builder(it)
                }

                builder.setMessage(R.string.dialog_request_audio_permission_title)
                    .setTitle(R.string.dialog_request_audio_permission_message)

                builder.setCancelable(true)
                builder.setNeutralButton(android.R.string.ok
                ) { dialog, _ -> dialog.cancel() }

                val dialog: AlertDialog = builder.create()

                dialog.show()

            } else -> {
                Log.i("SpectogramController", "requestPermissions")
                // You can directly ask for the permission.
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.RECORD_AUDIO),
                    MY_PERMISSIONS_REQUEST_RECORD_AUDIO
                )
            }
        }
    }

    fun resetProperties() {
        continuousRecord = null
    }

    fun start(view: FrequencyView) {
        continuousRecord?.start { recordBuffer: ShortArray ->
            this.getTrunks(recordBuffer, view)
        }
    }

    private fun getTrunks(recordBuffer: ShortArray, view: FrequencyView) {
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
            activity?.let { activity ->
                context?.let { context ->
                    process(activity, context, view)
                }
            }
        }

        // Last item has not yet fully be used (only its first half)
        // Move it to first position in arraylist so that its last half is used
        val first: ShortArray = bufferStack[0]
        val last: ShortArray = bufferStack[bufferStack.size - 1]
        System.arraycopy(last, 0, first, 0, n / 2)
    }

    fun stop() {
        continuousRecord?.stop()
    }

    fun loadEngine() {
        // Stop and release recorder if running


        // Stop and release recorder if running
        continuousRecord?.stop()
        continuousRecord?.release()

        // Prepare recorder

        // Prepare recorder
        continuousRecord?.prepare(fftResolution) // Record buffer size if forced to be a multiple of the fft resolution


        // Build buffers for runtime

        // Build buffers for runtime
        val n = fftResolution
        fftBuffer = ShortArray(n)
        re = FloatArray(n)
        im = FloatArray(n)
        bufferStack = java.util.ArrayList()
        continuousRecord?.let {
            val l: Int = it.bufferLength / (n / 2)
            for (i in 0 until l + 1) { //+1 because the last one has to be used again and sent to first position
                bufferStack.add(ShortArray(n / 2)) // preallocate to avoid new within processing loop
            }
        }
    }

    private fun process(activity: Activity, context: Context, view: FrequencyView) {
        val n = fftResolution
        val log2 = (ln(n.toDouble()) / ln(2.0)).toInt()
        nativeLib?.shortToFloat(fftBuffer, re, n)
        nativeLib?.clearFloat(im, n) // Clear imaginary part

        getWindowType(context)?.let {
            when (it) {
                "Rectangular" -> nativeLib?.windowRectangular(re, n)
                "Triangular" -> nativeLib?.windowTriangular(re, n)
                "Welch" -> nativeLib?.windowWelch(re, n)
                "Hanning" -> nativeLib?.windowHanning(re, n)
                "Hamming" -> nativeLib?.windowHamming(re, n)
                "Blackman" -> nativeLib?.windowBlackman(re, n)
                "Nuttall" -> nativeLib?.windowNuttall(re, n)
                "Blackman-Nuttall" -> nativeLib?.windowBlackmanNuttall(re, n)
                "Blackman-Harris" -> nativeLib?.windowBlackmanHarris(re, n)
                else -> {}
            }
        }
        nativeLib?.fft(re, im, log2, 0) // Move into frequency domain
        nativeLib?.toPolar(re, im, n) // Move to polar base
        re?.let {
            view.setMagnitudes(it)
        }

        activity.runOnUiThread {
            view.invalidate()
        }
    }

    companion object {
        const val MY_PERMISSIONS_REQUEST_RECORD_AUDIO = 0
    }
}