package it.lukluca.spectogram

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import it.lukluca.spectogram.Misc.getFftResolution
import it.lukluca.spectogram.Misc.getSamplingRate

internal class SpectogramView(context: Context) : PlatformView {

    private val frequencyView: FrequencyView

    override fun getView(): View {
        return frequencyView
    }

    override fun dispose() {}

    init {

        frequencyView = FrequencyView(context)
        frequencyView.id = R.id.frequency_view
        frequencyView.setFFTResolution(getFftResolution(context))
        frequencyView.setSamplingRate(getSamplingRate(context))
    }
}