package com.allwin.expensetracker

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import java.io.File
import org.json.JSONArray

class MainActivity : FlutterFragmentActivity() {
    private val SMS_EVENT_CHANNEL = "com.allwin.expensetracker/sms_stream"
    private val SMS_METHOD_CHANNEL = "com.allwin.expensetracker/sms_queue"
    private val EXPORT_METHOD_CHANNEL = "com.allwin.expensetracker/export"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Method Channel for queued SMS
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAndClearPendingSms") {
                val prefs = getSharedPreferences("ExpenseTrackerPrefs", Context.MODE_PRIVATE)
                val queueString = prefs.getString("pending_sms_queue", "[]")
                
                // Clear the queue immediately after reading
                prefs.edit().putString("pending_sms_queue", "[]").apply()
                
                result.success(queueString)
            } else {
                result.notImplemented()
            }
        }

        // Setup Method Channel for Excel export
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EXPORT_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "exportToExcel") {
                val fileName = call.argument<String>("fileName") ?: "Expense_Tracker_Export.csv"
                val content = call.argument<String>("content") ?: ""
                val title = call.argument<String>("title") ?: "Download in Excel"

                try {
                    // 1. Save to app cache exports dir
                    val exportDir = File(cacheDir, "exports")
                    if (!exportDir.exists()) exportDir.mkdirs()
                    val cacheFile = File(exportDir, fileName)
                    cacheFile.writeText(content, Charsets.UTF_8)

                    // 2. Also save to Downloads folder so it appears in device Downloads
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val resolver = contentResolver
                            val contentValues = ContentValues().apply {
                                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                                put(MediaStore.MediaColumns.MIME_TYPE, "text/csv")
                                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                            }
                            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                            if (uri != null) {
                                resolver.openOutputStream(uri)?.use { os ->
                                    os.write(content.toByteArray(Charsets.UTF_8))
                                }
                            }
                        } else {
                            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                            val downloadFile = File(downloadsDir, fileName)
                            downloadFile.writeText(content, Charsets.UTF_8)
                        }
                    } catch (e: Exception) {
                        // Non-fatal if direct downloads folder write is restricted
                    }

                    // 3. Launch Android Open/Share Chooser with FileProvider
                    val fileUri = FileProvider.getUriForFile(
                        this,
                        "$packageName.fileprovider",
                        cacheFile
                    )

                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/csv"
                        putExtra(Intent.EXTRA_STREAM, fileUri)
                        putExtra(Intent.EXTRA_SUBJECT, fileName)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    val chooser = Intent.createChooser(intent, title)
                    chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(chooser)

                    result.success(true)
                } catch (e: Exception) {
                    result.error("EXPORT_FAILED", e.localizedMessage, null)
                }
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    SmsReceiver.smsListener = { smsData ->
                        runOnUiThread {
                            eventSink?.success(smsData)
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    SmsReceiver.smsListener = null
                }
            })
    }
}
