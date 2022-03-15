import UIKit
import Flutter


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//Custom code here ---
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannel = FlutterMethodChannel(name: "nl.altocode.acpic/iosupload", binaryMessenger: controller.binaryMessenger)
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "hello"{
              let ids: [String] = call.arguments as! [String]
              for item in ids{
                  print("id \(item)")
              }
//              let cookie: String = call.arguments as! String
//              print("cookie is \(cookie)")
//              let id: String = call.arguments as! String
//              print("id is \(id)")
//              let csrf: String = call.arguments as! String
//              print("csrf is \(csrf)")
//              let tags: [String] = call.arguments as! [String]
//              for item in tags{
//                  print("tag \(item)")
//              }
              
              
//              result(call.arguments)
          }else{
              result(FlutterMethodNotImplemented)
          }
      })
      
      
      
      
//Custom code finishes here ---
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
