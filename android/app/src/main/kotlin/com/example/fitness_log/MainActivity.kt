package com.example.fitness_log

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.fitness_log/files"
    private val signatureChannelName = "com.example.fitness_log/signature"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveToDownloads") {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    if (bytes == null || fileName.isNullOrBlank()) {
                        result.error("BAD_ARGS", "缺少文件内容或文件名", null)
                        return@setMethodCallHandler
                    }
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            result.success(saveWithMediaStore(fileName, bytes))
                        } else {
                            if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) !=
                                PackageManager.PERMISSION_GRANTED
                            ) {
                                result.error("PERMISSION_DENIED", "需要存储权限", null)
                                return@setMethodCallHandler
                            }
                            result.success(saveLegacy(fileName, bytes))
                        }
                    } catch (error: SecurityException) {
                        result.error("PERMISSION_DENIED", error.message, null)
                    } catch (error: Exception) {
                        result.error("SAVE_FAILED", error.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, signatureChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "sha256") {
                    result.success(signatureSha256())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun signatureSha256(): String? {
        return try {
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                info.signatures
            }
            val signature = signatures?.firstOrNull() ?: return null
            MessageDigest.getInstance("SHA-256")
                .digest(signature.toByteArray())
                .joinToString("") { "%02x".format(it.toInt() and 0xff) }
        } catch (_: Exception) {
            null
        }
    }

    private fun saveWithMediaStore(fileName: String, bytes: ByteArray): String {
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(
                MediaStore.Downloads.MIME_TYPE,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val resolver = contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("无法创建下载文件")
        resolver.openOutputStream(uri)?.use { it.write(bytes) }
            ?: throw IllegalStateException("无法写入下载文件")
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return uri.toString()
    }

    @Suppress("DEPRECATION")
    private fun saveLegacy(fileName: String, bytes: ByteArray): String {
        val directory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        if (!directory.exists()) directory.mkdirs()
        val file = File(directory, fileName)
        file.writeBytes(bytes)
        return file.absolutePath
    }
}
