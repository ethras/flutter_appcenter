package com.example.flutterappcenter

import android.app.Application
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.AppCenterService
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.distribute.Distribute
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterAppcenterPlugin(private val app: Application) : MethodCallHandler {
    var isConfigured = false
    var appSecret: String = ""

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "flutter_appcenter")
            channel.setMethodCallHandler(FlutterAppcenterPlugin(registrar.activity().application))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        val method = call.method
        when(method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "configure" -> {
                val appSecret = call.argument<String>("appSecret")
                configure(appSecret)
                result.success(null)
            }
            "start" -> {
                val services = call.argument<List<String>>("services")
                start(services)
                result.success(null)
            }
            "trackEvent" ->  {
                val eventName = call.argument<String>("eventName")
                val properties = call.argument<Map<String, String>>("properties")
                trackEvent(eventName, properties)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun configure(appSecret: String) {
        this.appSecret = appSecret
        isConfigured = true
    }


    private fun start(services: List<String>) {
        val servicesClasses = arrayListOf<Class<out AppCenterService>>()
        if (services.contains("analytics")) {
            servicesClasses.add(Analytics::class.java)
        }
        if (services.contains("crashes")) {
            servicesClasses.add(Crashes::class.java)
        }
        if (services.contains("distribute")) {
            servicesClasses.add(Distribute::class.java)
        }

        var servicesClassesArray = arrayOfNulls<Class<out AppCenterService>>(servicesClasses.count())
        servicesClassesArray = servicesClasses.toArray(servicesClassesArray)

        AppCenter.start(app, appSecret, *servicesClassesArray)
    }

    //--------------------------------------
    // Analytics

    private fun trackEvent(eventName: String, properties: Map<String, String>) {
        Analytics.trackEvent(eventName, properties)
    }
}
