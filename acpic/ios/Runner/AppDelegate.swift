import UIKit
import Flutter
import Photos
import Alamofire


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
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              print(idList[0])
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: nil)
              print("piv is \(phAssetPivFetchedAsset)")
              phAssetPivFetchedAsset.enumerateObjects {(object,_,_) in
                  print("object is \(object)")

              }
              result("\(phAssetPivFetchedAsset)")
              
            
 
//              for item in idList{
//                  print("id \(item)")
//              }
//              let cookie: String = arguments[1] as! String
//              print("cookie is \(cookie)")
//              let id: Int = arguments[2] as! Int
//              print("id is \(id)")
//              let csrf: String = arguments[3] as! String
//              print("csrf is \(csrf)")
//              let tag: String = arguments[4] as! String
//              print("tag is \(tag)")

              
              
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
