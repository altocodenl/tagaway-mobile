import UIKit
import Flutter
import Photos
import Alamofire
import SystemConfiguration


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//Custom code here ---
      let photosOptions = PHFetchOptions()
      var sURL: String!
      var imageFinal: UIImage?
      sURL = "https://altocode.nl/dev/pic/app/piv"
      var multipartDataFormResponse: String! = "A string"
      
      func getArrayOfBytesFromImage(imageFinal:NSData) -> Array<UInt8>
      {
        // the number of elements:
        let count = imageFinal.length / MemoryLayout<Int8>.size

        // create array of appropriate length:
        var bytes = [UInt8](repeating: 0, count: count)

        // copy bytes into array
          imageFinal.getBytes(&bytes, length:count * MemoryLayout<Int8>.size)

        var byteArray:Array = Array<UInt8>()

        for i in 0 ..< count {
          byteArray.append(bytes[i])
        }

        return byteArray

      }
      
      

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
              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              print(pivPHAsset as PHAsset)
              let manager = PHImageManager.default()
              let requestOptions = PHImageRequestOptions()
              requestOptions.isSynchronous = true
              requestOptions.isNetworkAccessAllowed = false
              requestOptions.resizeMode = .none
              if #available(iOS 13, *) {
                  manager.requestImageDataAndOrientation(for: pivPHAsset, options: requestOptions){(data,_,_,_) in
                       guard let data = data else{return}
                       if let image = UIImage(data: data){
                           imageFinal = image
                       }
                  }
              } else {
                  // Fallback on earlier versions
//                  manager.requestImage(for: <#T##PHAsset#>, targetSize: <#T##CGSize#>, contentMode: <#T##PHImageContentMode#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(UIImage?, [AnyHashable : Any]?) -> Void#>)
              }
              let headers: HTTPHeaders = [
                "content-type": "multipart/form-data",
                "cookie": cookie
              ]
              let parameters: [String: String] = [
                "id": String(id),
                "csrf": csrf,
                "tags": tag,
                "lastModified": String(Int(pivPHAsset.creationDate!.timeIntervalSince1970*1000))
              ]
              
               AF.upload(multipartFormData: {MultipartFormData in
                  for (key, value) in parameters {
                      MultipartFormData.append(Data(value.utf8), withName: key)
                  }
                   MultipartFormData.append((imageFinal?.pngData())!, withName: "piv", fileName: "piv", mimeType: "image/png")
              }, to: sURL, method: .post, headers: headers)
                  .response {response in
                      print(response.debugDescription)
                       multipartDataFormResponse = response.debugDescription
                  }
//              result(call.arguments)

            result("a string")
              
          }else{
              result(FlutterMethodNotImplemented)
          }
      })
      
      
      
      
//Custom code finishes here ---
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
