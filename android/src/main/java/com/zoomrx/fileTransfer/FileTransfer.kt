package com.zoomrx.fileTransfer
import com.getcapacitor.*
import com.zoomrx.filetransfer.DownloadContext
import com.zoomrx.filetransfer.FileTransferHandler
import com.zoomrx.filetransfer.UploadContext

@NativePlugin
class FileTransfer : Plugin() {

    private val transferIdMap = mutableMapOf<String, Int>()

    @PluginMethod
    fun download(call: PluginCall) {
        val source = call.getString("src")
        val destination = call.getString("destination")
        val jsTransferId = call.getString("objectId")
        val options = call.getObject("options")

        val headers = options.optJSONObject("headers")
        val backgroundMode = options.optBoolean("background")

        val downloadContext = DownloadContext(source, destination, headers,
                {bytesRead: Long, totalBytes: Long ->
                    val ret = JSObject()
                    ret.put("id", jsTransferId)
                    ret.put("bytesRead", bytesRead)
                    ret.put("totalBytes", totalBytes)
                    notifyListeners("download", ret)
                },
                {response ->
                    call.resolve(JSObject.fromJSONObject(response))
                },
                {error ->
                    call.reject(error.getString("message"), error.getInt("code").toString())
                },
                backgroundMode
        )

        FileTransferHandler.startDownload(downloadContext).let { nativeTransferId ->
            if (nativeTransferId != -1)
                transferIdMap[jsTransferId] = nativeTransferId
        }
    }

    @PluginMethod
    fun upload(call: PluginCall) {
        val source = call.getString("src")
        val destination = call.getString("destination")
        val jsTransferId = call.getString("objectId")
        val options = call.getObject("options")

        val headers = options.optJSONObject("headers")
        val backgroundMode = options.optBoolean("background")
        val fileKey = options.optString("fileKey", "file")
        val fileName = options.optString("fileName", "image.png")
        val mimeType = options.optString("mimeType", "image/png")

        val uploadContext = UploadContext(source, destination, headers,
                {bytesRead: Long, totalBytes: Long ->
                    val ret = JSObject()
                    ret.put("id", jsTransferId)
                    ret.put("bytesRead", bytesRead)
                    ret.put("totalBytes", totalBytes)
                    notifyListeners("download", ret)
                },
                {response ->
                    call.resolve(JSObject.fromJSONObject(response))
                },
                {error ->
                    call.reject(error.getString("message"), error.getInt("code").toString())
                },
                backgroundMode,
                fileKey,
                fileName,
                mimeType
        )

        FileTransferHandler.startUpload(uploadContext).let { nativeTransferId ->
            if (nativeTransferId != -1)
                transferIdMap[jsTransferId] = nativeTransferId
        }
    }

    @PluginMethod
    fun abort(call: PluginCall) {
        val jsTransferId = call.getString("objectId")
        val errorCallback = {
            call.reject("No transfer found with given ID", "123")
        }
        transferIdMap[jsTransferId]?.let {
            if (FileTransferHandler.abortTransfer(it)) {
                call.resolve()
            } else errorCallback()
        } ?: {
            errorCallback()
        }()
    }
}