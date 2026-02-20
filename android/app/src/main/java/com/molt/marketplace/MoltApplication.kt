package com.molt.marketplace

import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber
import android.app.Application

@HiltAndroidApp
class MoltApplication : Application() {

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
