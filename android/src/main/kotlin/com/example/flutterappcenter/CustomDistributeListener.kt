package com.example.flutterappcenter

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.microsoft.appcenter.distribute.Distribute
import com.microsoft.appcenter.distribute.DistributeListener
import com.microsoft.appcenter.distribute.ReleaseDetails
import com.microsoft.appcenter.distribute.UpdateAction
import io.flutter.plugin.common.PluginRegistry
import androidx.appcompat.app.AppCompatActivity;

class UpdateDialogActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Look at releaseDetails public methods to get version information, release notes text or release notes URL
        val versionName = intent.getStringExtra("versionName")
        val versionCode = intent.getStringExtra("versionCode")
        val releaseNotes = intent.getStringExtra("releaseNotes")
        val releaseNotesUrl = intent.getStringExtra("releaseNotesUrl")
        val isMandatoryUpdate = intent.getBooleanExtra("isMandatoryUpdate", false)

        // Build our own dialog title and message
        val dialogBuilder = AlertDialog.Builder(this)
        dialogBuilder.setTitle("Version $versionName available!") // you should use a string resource instead of course, this is just to simplify example
        dialogBuilder.setMessage(releaseNotes)

        // Mimic default SDK buttons
        dialogBuilder.setPositiveButton(com.microsoft.appcenter.distribute.R.string.appcenter_distribute_update_dialog_download) { dialog, which ->
            // This method is used to tell the SDK what button was clicked
            Distribute.notifyUpdateAction(UpdateAction.UPDATE)
            endActivity()
        }

        // We can postpone the release only if the update is not mandatory
        if (!isMandatoryUpdate) {
            dialogBuilder.setNegativeButton(com.microsoft.appcenter.distribute.R.string.appcenter_distribute_update_dialog_postpone) { dialog, which ->
                // This method is used to tell the SDK what button was clicked
                Distribute.notifyUpdateAction(UpdateAction.POSTPONE)
                endActivity()
            }
        }
        dialogBuilder.setCancelable(false) // if it's cancelable you should map cancel to postpone, but only for optional updates
        dialogBuilder.create().show()
    }

    private fun endActivity() {
        setResult(Activity.RESULT_OK)
        finish()
    }
}

const val updateActivityCode = 30000

class CustomDistributeListener : DistributeListener, PluginRegistry.ActivityResultListener {
    private var shouldStartActivity = true

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == updateActivityCode) {
            return true
        }
        return false
    }

    override fun onReleaseAvailable(activity: Activity, releaseDetails: ReleaseDetails): Boolean {
        if (shouldStartActivity) {
            shouldStartActivity = false
            Log.i("AppCenter", "New updated available ${releaseDetails.version}")
            val intent = Intent(activity, UpdateDialogActivity::class.java)
            intent.putExtra("versionName", releaseDetails.shortVersion)
            intent.putExtra("versionCode", releaseDetails.version)
            intent.putExtra("releaseNotes", releaseDetails.releaseNotes)
            intent.putExtra("releaseNotesUrl", releaseDetails.releaseNotesUrl)
            intent.putExtra("isMandatoryUpdate", releaseDetails.isMandatoryUpdate)
            activity.startActivityForResult(intent, updateActivityCode)
        }
        else {
            Log.i("AppCenter", "Not displaying update")
        }
        // Return true if you are using your own dialog, false otherwise
        return true
    }
}

