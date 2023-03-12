/**
 * Spectrogram Android application
 * Copyright (c) 2013 Guillaume Adam  http://www.galmiza.net/
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it freely,
 * subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */
package it.lukluca.spectogram

import android.content.Context
import androidx.preference.PreferenceManager

/**
 * Various useful methods for the application
 */
object Misc {

    // PREFERENCES

    @JvmStatic
    fun getPreference(context: Context, key: String?, def: String?): String? {
        return PreferenceManager.getDefaultSharedPreferences(context).getString(key, def)
    }

    @JvmStatic
    fun getPreference(context: Context, key: String?, def: Int): Int {
        return PreferenceManager.getDefaultSharedPreferences(context).getInt(key, def)
    }

    fun getFftResolution(context: Context): Int {
        return getPreference(
            context,
            "fft_resolution",
            context.resources.getInteger(R.integer.preferences_fft_resolution_default_value)
        )
    }

    fun getSamplingRate(context: Context): Int {
        return getPreference(
            context,
            "sampling_rate",
            context.resources.getInteger(R.integer.preferences_sampling_rate_default_value)
        )
    }

    fun getWindowType(context: Context): String? {
        return getPreference(
            context,
            "window_type",
            context.getString(R.string.preferences_window_type_default_value))
    }
}