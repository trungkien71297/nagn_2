package nagn.peemoti.epubeditor

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val OPEN_FILE_CHANNEL = "nagn.peemoti.epubeditor"
    private lateinit var methodChannel: MethodChannel
    private var tmpSave = ""
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OPEN_FILE_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "OPEN_FILE" -> openFile(call, result)
                "GET_DOWNLOAD" -> getDownloadDir(call, result)
                "SAVE_FILE" -> saveFile(call, result)
            }
        }
    }

    private fun openFile(call: MethodCall, result: MethodChannel.Result) {
        val mime: String = call.argument<String>("mime") ?: ""
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        intent.type = mime
        startActivityForResult(intent, 1)
        result.success(null)
    }
    private fun getDownloadDir(call: MethodCall, result: MethodChannel.Result) {
        val docDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
        result.success(docDir.path)
    }

    private fun saveFile(call: MethodCall, result: MethodChannel.Result) {
        val path: String = call.argument<String>("file") ?: ""
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
        intent.type = "application/epub+zip"
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        intent.putExtra(Intent.EXTRA_TITLE, getName(path))
        tmpSave = path
        startActivityForResult(intent, 2)
    }

    private fun getName(path: String): String {
        return path.split("/").last()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == Activity.RESULT_OK) {
            val selectedDocumentUri = data?.data
            Log.d("Method ------", selectedDocumentUri?.path ?: "Not found")
            methodChannel.invokeMethod("OPEN_FILE_RESULT", {"path" to (selectedDocumentUri?.path ?: "")})
        }
        else if (requestCode == 2 && resultCode == Activity.RESULT_OK) {
            if (data?.data != null) {
                try {
                    val inputStream = contentResolver.openInputStream(Uri.fromFile(File(tmpSave)));
                    val outputStream = contentResolver.openOutputStream(data.data!!);
                    val buffer = ByteArray(1024)
                    var bytesRead: Int
                    while (inputStream!!.read(buffer).also { bytesRead = it } != -1) {
                        outputStream!!.write(buffer, 0, bytesRead)
                    }
                    inputStream.close();
                    outputStream?.close();
                    methodChannel.invokeMethod("SAVE_FILE_RESULT", mapOf("result" to true))
                } catch (e: IOException) {
                    Log.d("Method ------", e.toString())
                    methodChannel.invokeMethod("SAVE_FILE_RESULT", mapOf("result" to false))
                }
            }
        }
    }
}
