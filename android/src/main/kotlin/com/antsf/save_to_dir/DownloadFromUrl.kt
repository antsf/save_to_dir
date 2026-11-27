package com.antsf.save_to_dir

import android.app.DownloadManager
import android.content.Context
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Environment
import android.os.Handler
import android.os.Looper

class DownloadFromUrl(private val context: Context) {

    private lateinit var downloadManager: DownloadManager
    private lateinit var progressObserver: ContentObserver

    fun downloadFile(url: String, fileName: String?): Long {
        downloadManager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

        val resolvedFileName = fileName ?: url.substringAfterLast("/")

        val request =
                DownloadManager.Request(Uri.parse(url))
                        .setTitle(resolvedFileName)
                        .setDescription("Downloading")
                        .setNotificationVisibility(
                                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
                        )
                        .setDestinationInExternalPublicDir(
                                Environment.DIRECTORY_DOWNLOADS,
                                resolvedFileName
                        )
                        .setAllowedOverMetered(true)
                        .setAllowedOverRoaming(true)

        return downloadManager.enqueue(request)
    }

    fun trackDownloadProgress(
            downloadId: Long,
            onProgress: (Long, Long) -> Unit,
            onComplete: (String) -> Unit,
            onError: (Int) -> Unit,
    ) {
        progressObserver =
                object : ContentObserver(Handler(Looper.getMainLooper())) {
                    override fun onChange(selfChange: Boolean) {
                        val query = DownloadManager.Query().setFilterById(downloadId)
                        val cursor: Cursor = downloadManager.query(query)
                        if (cursor.moveToFirst()) {
                            val status =
                                    cursor.getInt(
                                            cursor.getColumnIndexOrThrow(
                                                    DownloadManager.COLUMN_STATUS
                                            )
                                    )
                            when (status) {
                                DownloadManager.STATUS_RUNNING -> {
                                    val downloadedBytes =
                                            cursor.getLong(
                                                    cursor.getColumnIndexOrThrow(
                                                            DownloadManager
                                                                    .COLUMN_BYTES_DOWNLOADED_SO_FAR
                                                    )
                                            )
                                    val totalBytes =
                                            cursor.getLong(
                                                    cursor.getColumnIndexOrThrow(
                                                            DownloadManager.COLUMN_TOTAL_SIZE_BYTES
                                                    )
                                            )
                                    onProgress(downloadedBytes, totalBytes)
                                }
                                DownloadManager.STATUS_SUCCESSFUL -> {
                                    val uri =
                                            cursor.getString(
                                                    cursor.getColumnIndexOrThrow(
                                                            DownloadManager.COLUMN_LOCAL_URI
                                                    )
                                            )
                                    onComplete(uri ?: "Download completed")
                                    context.contentResolver.unregisterContentObserver(this)
                                }
                                DownloadManager.STATUS_FAILED -> {
                                    val reason =
                                            cursor.getInt(
                                                    cursor.getColumnIndexOrThrow(
                                                            DownloadManager.COLUMN_REASON
                                                    )
                                            )
                                    onError(reason)
                                    context.contentResolver.unregisterContentObserver(this)
                                }
                            }
                        }
                        cursor.close()
                    }
                }

        context.contentResolver.registerContentObserver(
                Uri.parse("content://downloads/my_downloads"),
                true,
                progressObserver
        )
    }
}
