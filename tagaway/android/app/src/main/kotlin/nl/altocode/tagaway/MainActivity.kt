package nl.altocode.tagaway

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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
