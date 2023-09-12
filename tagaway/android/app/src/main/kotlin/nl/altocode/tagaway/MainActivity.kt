package nl.altocode.tagaway
import android.os.Bundle
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        throw RuntimeException("MainActivity loaded")
    }
    private val CHANNEL = "nl.tagaway/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAvailableStorage") {
                val stat = StatFs("/data")
                val availableBytes = stat.availableBytes
                result.success(availableBytes)
            } else {
                result.notImplemented()
            }
        }
    }
}