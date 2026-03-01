package com.xirigo.ecommerce

import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber
import android.app.Application

@HiltAndroidApp
class XGApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        initTimber()
    }

    private fun initTimber() {
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
    }
}
