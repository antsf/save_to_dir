package com.antsf.save_to_dir

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.ByteArrayInputStream
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream
import java.net.URLConnection

class SaveFile(private val context: Context) {

    fun saveFile(imageBytes: ByteArray, mimeType: String, fileName: String, result: (Boolean, String?) -> Unit) {
        try {

            println("MIME TYPE: $mimeType")

            val outputStream: OutputStream?
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                }

                val uri = context.contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                outputStream = context.contentResolver.openOutputStream(uri!!)
            } else {
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val file = File(downloadsDir, fileName)
                outputStream = FileOutputStream(file)
            }

            if (outputStream != null) {
                outputStream.write(imageBytes)
                outputStream.close()
                result(true, "File saved successfully")
            } else {
                result(false, "Failed to get output stream")
            }
        } catch (e: Exception) {
            result(false, "Failed to save file: ${e.message}")
        }
    }
}