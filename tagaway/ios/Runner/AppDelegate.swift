import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let storageChannel = FlutterMethodChannel(name: "nl.tagaway/storage",
                                              binaryMessenger: controller.binaryMessenger)

    storageChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "getAvailableStorage" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.getAvailableStorage(result: result)
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getAvailableStorage(result: @escaping FlutterResult) {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    do {
      let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
      if let capacity = values.volumeAvailableCapacityForImportantUsage {
        result(Int(capacity))
      } else {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Could not fetch available storage space",
                            details: nil))
      }
    } catch {
      result(FlutterError(code: "ERROR",
                          message: "An error occurred while fetching storage space",
                          details: nil))
    }
  }
}
