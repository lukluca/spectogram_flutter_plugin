package it.lukluca.spectogram

import android.content.Context
import androidx.annotation.UiThread
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

interface SpectogramViewHandler {
    @UiThread
    fun onCreateView()
}

class SpectogramViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private var handler: SpectogramViewHandler? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val view = SpectogramView(context)
        handler?.onCreateView()
        return view
    }

    @UiThread
    fun setSpectogramViewHandler(handler: SpectogramViewHandler?) {
        this.handler = handler
    }
}