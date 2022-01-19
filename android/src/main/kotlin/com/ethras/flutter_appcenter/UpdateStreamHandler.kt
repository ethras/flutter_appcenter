package com.ethras.flutter_appcenter

import android.app.Activity
import com.microsoft.appcenter.distribute.Distribute
import com.microsoft.appcenter.distribute.DistributeListener
import com.microsoft.appcenter.distribute.ReleaseDetails
import io.flutter.plugin.common.EventChannel
import java.util.HashSet


class UpdateStreamHandler : EventChannel.StreamHandler, DistributeListener {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        // TODO tmp fix until 4.4.3
        val packageName = arguments as String?
        if (packageName != null) {
            Distribute.addStores(mutableSetOf(packageName))
        }
        Distribute.setListener(this)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        Distribute.setListener(null)
    }

    override fun onReleaseAvailable(activity: Activity?, releaseDetails: ReleaseDetails): Boolean {
        val versionName = releaseDetails.shortVersion
        val versionCode = releaseDetails.version
        val releaseNotes = releaseDetails.releaseNotes ?: ""
        val releaseNotesUrl = releaseDetails.releaseNotesUrl

        val map = HashMap<String, Any>()
        map["versionName"] = versionName
        map["versionCode"] = versionCode
        map["releaseNotes"] = releaseNotes
        eventSink?.success(map)

        return true
    }

    override fun onNoReleaseAvailable(activity: Activity?) {
        eventSink?.success(null)
    }

}