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
      let photosOptions = PHFetchOptions()
      var sURL: String!
      sURL = "https://altocode.nl/dev/pic/app/piv"

      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannel = FlutterMethodChannel(name: "nl.altocode.acpic/iosupload", binaryMessenger: controller.binaryMessenger)
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "iosUpload"{
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              let cookie: String = arguments[1] as! String
              let id: Int = arguments[2] as! Int
              let csrf: String = arguments[3] as! String
              let tag: String = arguments[4] as! String
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: photosOptions)
              let piv = phAssetPivFetchedAsset.firstObject! as PHAsset
              print(piv as PHAsset)
              
//              print((piv?.creationDate?.timeIntervalSince1970))
//              print(Int(piv?.creationDate?.timeIntervalSince1970 ?? 0))
//              print(String(Int(piv?.creationDate?.timeIntervalSince1970 ?? 0)))
              
//              let headers: HTTPHeaders = [
//                "content-type": "multipart/form-data",
//                "cookie": cookie
//              ]
//              let parameters: [String: [String]] = [
//                "id":[String(id)],
//                "csrf": [csrf],
//                "tags": [tag],
//                "lastModified": [String(Int(piv.creationDate?.timeIntervalSince1970 ?? 0))]
//              ]
//              AF.upload(multipartFormData: {MultipartFormData in
//
//
//              }, to: sURL, method: .post, headers: headers)
              
              
          
//              phAssetPivFetchedAsset.enumerateObjects {(object,_,_)
//                  in
//                                print("object is \(object)")
//                            }
//              result("\(phAssetPivFetchedAsset)")


              
              
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
