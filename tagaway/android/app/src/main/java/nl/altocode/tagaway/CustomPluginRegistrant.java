package nl.altocode.tagaway;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import com.fluttercandies.photo_manager.PhotoManagerPlugin;

public final class CustomPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new PhotoManagerPlugin());
  }
}
