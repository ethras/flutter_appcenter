package com.example.flutterappcenter

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.support.v7.app.AlertDialog
import android.util.Log
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.AppCenterService
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.distribute.Distribute
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterAppcenterPlugin(private val registrar: Registrar) : MethodCallHandler {
    private var isConfigured = false
    private var appSecret: String = ""

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "flutter_appcenter")
            val plugin = FlutterAppcenterPlugin(registrar)
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        val method = call.method
        when (method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "start" -> {
                val appSecret = call.argument<String>("appSecret")
                val services = call.argument<List<String>>("services")
                start(appSecret, services)
                result.success(null)
            }
            "trackEvent" -> {
                val eventName = call.argument<String>("eventName")
                val properties = call.argument<Map<String, String>>("properties")
                trackEvent(eventName, properties)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }


    private fun start(appSecret: String, services: List<String>) {
        if (isConfigured) {
            return
        }

        this.appSecret = appSecret
        isConfigured = true

        val servicesClasses = arrayListOf<Class<out AppCenterService>>()
        if (services.contains("analytics")) {
            servicesClasses.add(Analytics::class.java)
        }
        if (services.contains("crashes")) {
            servicesClasses.add(Crashes::class.java)
        }
        if (services.contains("distribute")) {
            servicesClasses.add(Distribute::class.java)
            val customDistributeListener = CustomDistributeListener()
            registrar.addActivityResultListener(customDistributeListener)
            Distribute.setListener(customDistributeListener)
        }

        var servicesClassesArray = arrayOfNulls<Class<out AppCenterService>>(servicesClasses.count())
        servicesClassesArray = servicesClasses.toArray(servicesClassesArray)

        AppCenter.start(registrar.activity().application, appSecret, *servicesClassesArray)
        Log.i("Flutter-AppCenter", "AppCenter started")
    }

    //--------------------------------------
    // Analytics

    private fun trackEvent(eventName: String, properties: Map<String, String>) {
        Analytics.trackEvent(eventName, properties)
    }
}
