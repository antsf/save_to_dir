package com.antsf.save_to_dir

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import android.app.DownloadManager
import java.lang.Exception

class SaveToDirPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private var pendingResult: Result? = null

    private lateinit var saveFile: SaveFile
    private lateinit var downloadFile: DownloadFromUrl

    companion object {
        private const val REQUEST_CODE_STORAGE_PERMISSION = 1
        private const val CHANNEL_NAME = "save_to_dir"
        private const val METHOD_GET_PLATFORM_VERSION = "getPlatformVersion"
        private const val METHOD_REQUEST_STORAGE_PERMISSION = "requestStoragePermission"
        private const val METHOD_OPEN_STORAGE_SETTINGS = "openStorageSettings"
        private const val METHOD_OPEN_FILE_MANAGER = "openFileManager"
        private const val METHOD_SAVE_FILE = "saveFile"
        private const val METHOD_DOWNLOAD_FILE = "downloadFile"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        saveFile = SaveFile(context)
        downloadFile = DownloadFromUrl(context)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // No-op
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        // No-op
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_GET_PLATFORM_VERSION -> handleGetPlatformVersion(result)
            METHOD_REQUEST_STORAGE_PERMISSION -> handleRequestStoragePermission(result)
            METHOD_OPEN_STORAGE_SETTINGS -> handleOpenStorageSettings(result)
            METHOD_OPEN_FILE_MANAGER -> handleOpenFileManager(result)
            METHOD_SAVE_FILE -> handleSaveFile(call, result)
            METHOD_DOWNLOAD_FILE -> handleDownloadFile(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleGetPlatformVersion(result: Result) {
        result.success("Android ${Build.VERSION.RELEASE}")
    }

    private fun handleRequestStoragePermission(result: Result) {
        val hasPermission = checkAndRequestPermissions()
        result.success(hasPermission)
    }

    private fun handleOpenStorageSettings(result: Result) {
        openStorageSettings()
        result.success(null)
    }

    private fun handleOpenFileManager(result: Result) {
        try {
            if (checkAndRequestPermissions()) {
                val downloadIntent = Intent(DownloadManager.ACTION_VIEW_DOWNLOADS)
                downloadIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(downloadIntent)
                result.success(true)
            } else {
                result.error("PERMISSION_DENIED", "Storage permission not granted", null)
            }

            
        } catch (e: Exception) {
            result.error("ERROR", "Unable to open the file manager, $e", null)
        }
    }

    private fun handleSaveFile(call: MethodCall, result: Result) {
        val fileName = call.argument<String>("fileName")
        val imageBytes = call.argument<ByteArray>("imageBytes")
        val mimeType = call.argument<String>("mimeType")

        if (fileName == null || imageBytes == null || mimeType == null) {
            result.error("INVALID_ARGUMENTS", "File name or content is null", null)
            return
        }

        if (hasStoragePermission()) {
            saveFile.saveFile(imageBytes, mimeType, fileName) { success, message ->
                if (success) {
                    result.success(message)
                } else {
                    result.error("SAVE_FILE_ERROR", message, null)
                }
            }
        } else {
            channel.invokeMethod("onErrorCallback", mapOf("error" to "STORAGE_PERMISSION_DENIED"))
            result.error("PERMISSION_DENIED", "Storage permission not granted", null)
        }
    }

    private fun handleDownloadFile(call: MethodCall, result: Result) {
        val url = call.argument<String>("url")
        val fileName = call.argument<String>("fileName")

        if (url == null) {
            result.error("INVALID_ARGUMENTS", "URL is null", null)
            return
        }

        if (hasStoragePermission()) {
            val downloadId = downloadFile.downloadFile(url, fileName)
            result.success(downloadId)

            downloadFile.trackDownloadProgress(
                downloadId,
                onProgress = { downloadedBytes, totalBytes ->
                    channel.invokeMethod("onProgressCallback", mapOf(
                        "bytes" to downloadedBytes,
                        "total" to totalBytes
                    ))
                },
                onComplete = { uri ->
                    channel.invokeMethod("onCompleteCallback", mapOf(
                        "downloadPath" to uri
                    ))
                },
                onError = { reason ->
                    channel.invokeMethod("onErrorCallback", mapOf(
                        "error" to reason
                    ))
                }
            )
        } else {
            channel.invokeMethod("onErrorCallback", mapOf("error" to "STORAGE_PERMISSION_DENIED"))
            result.error("PERMISSION_DENIED", "Storage permission not granted", null)
        }
    }

    private fun hasStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ requires READ_MEDIA_IMAGES for accessing media files
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_MEDIA_IMAGES
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            // For older versions, use READ_EXTERNAL_STORAGE
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun checkAndRequestPermissions(): Boolean {
        return if (hasStoragePermission()) {
            true
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // Request READ_MEDIA_IMAGES for Android 13+
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_MEDIA_IMAGES),
                    REQUEST_CODE_STORAGE_PERMISSION
                )
            } else {
                // Request READ_EXTERNAL_STORAGE for older versions
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    REQUEST_CODE_STORAGE_PERMISSION
                )
            }
            false
        }
    }

    private fun openStorageSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", context.packageName, null)
        }
        activity.startActivity(intent)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == REQUEST_CODE_STORAGE_PERMISSION && grantResults.isNotEmpty()) {
            val hasPermission = grantResults[0] == PackageManager.PERMISSION_GRANTED
            channel.invokeMethod("onRequestPermissionResult", hasPermission)
            return true
        }
        return false
    }
}