package nl.altocode.tagaway;

import io.flutter.app.FlutterApplication;
import com.rmawatson.flutterisolate.FlutterIsolatePlugin;

public class MainApplication extends FlutterApplication {
  @Override
  public void onCreate() {
    super.onCreate();
    FlutterIsolatePlugin.setCustomIsolateRegistrant(CustomPluginRegistrant.class);
  }
}
