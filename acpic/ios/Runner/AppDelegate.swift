import UIKit
import Flutter
import Photos
import Alamofire
import SystemConfiguration
import Foundation



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//Custom code here ---
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannel = FlutterMethodChannel(name: "nl.altocode.acpic/iosupload", binaryMessenger: controller.binaryMessenger)
      
      let photosOptions = PHFetchOptions()
      var sURL: String!
      sURL = "https://altocode.nl/dev/pic/app/piv"
//      var multipartDataFormResponse: String! = "A string"
      var phAssetArray: [PHAsset] = []
      var pathArray: [URL] = []
      
      
      func idsToPaths(idList: [String]) {
          for id in idList{
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: photosOptions)
              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              phAssetArray.append(pivPHAsset)
          }
          print("phAssetArray.count is \(phAssetArray.count)" )
          var operationsGoingOn = 0
          let limit = 200
          func areWeDone () {
              if (pathArray.count == phAssetArray.count) {
                 print("pathArray.count is \(pathArray.count)")
                  print(pathArray.first)
                  print(pathArray.last)
//                  CALL TO BACKGROUND MULTIPARTFORM/DATA
             }
          }
          func PathLookup (asset: PHAsset) {
             if (operationsGoingOn >= limit) {
                 DispatchQueue.main.asyncAfter(deadline: .now () + 0.5) {
                     PathLookup(asset: asset)
                 }
             }
             else {
                operationsGoingOn+=1;
                asset.requestContentEditingInput (with: PHContentEditingInputRequestOptions()) {(input, _) in
                    if(asset.mediaType == .image){
                        let path = input?.fullSizeImageURL
                        pathArray.append(path!)
                    } else if(asset.mediaType == .video){
                        let path: AVURLAsset = input!.audiovisualAsset! as! AVURLAsset
                        pathArray.append(path.url)
                    } else if (asset.mediaType != .image || asset.mediaType != .video){
                        let path = URL(string: "sarasa")
                        print("WE A STRANGE ASSET \(asset)")
                        pathArray.append(path!)
                    }
                   operationsGoingOn-=1;
                    print(operationsGoingOn)
                    areWeDone()
                }
             }
          }
          for asset in phAssetArray{
              PathLookup(asset: asset)
          }
      }
      
      
      
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "iosUpload"{
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              let cookie: String = arguments[1] as! String
              let id: Int = arguments[2] as! Int
              let csrf: String = arguments[3] as! String
              let tag: String = arguments[4] as! String
            idsToPaths(idList: idList)
             
              
//
//              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: photosOptions)
//              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
//               pivPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
////                   let fileURL = input!.fullSizeImageURL
//                   let fileURL: AVURLAsset = input!.audiovisualAsset! as! AVURLAsset
//                   print(fileURL.url)
               
//
//                   let headers: HTTPHeaders = [
//                     "content-type": "multipart/form-data",
//                     "cookie": cookie
//                   ]
//                   let parameters: [String: String] = [
//                     "id": String(id),
//                     "csrf": csrf,
//                     "tags": tag,
//                     "lastModified": String(Int(pivPHAsset.creationDate!.timeIntervalSince1970*1000))
//                   ]
//
//                    AF.upload(multipartFormData: {MultipartFormData in
//                       for (key, value) in parameters {
//                           MultipartFormData.append(Data(value.utf8), withName: key)
//                       }
////                        --- URL INSTANCE UPLOAD ---
//                        MultipartFormData.append(fileURL!, withName: "piv", fileName: "piv", mimeType: "image/png")
////                        --- DATA INSTANCE UPLOAD ---
////                        MultipartFormData.append(dataImage as Data, withName: "piv", fileName: "piv", mimeType: "image/png")
//
//
//                   }, to: sURL, method: .post, headers: headers)
//                       .response {response in
//                           print(response.debugDescription)
//                            multipartDataFormResponse = response.debugDescription
//                           print(multipartDataFormResponse)
//                       }
//
//              }
//
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
