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
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let methodChannel = FlutterMethodChannel(name: "nl.altocode.acpic/iosupload", binaryMessenger: controller.binaryMessenger)
      
      let photosOptions = PHFetchOptions()
      var sURL: String!
      sURL = "https://altocode.nl/dev/pic/app/piv"
      var multipartDataFormResponse: String! = "A string"
      var imageFinal: UIImage?
      
//      func idToPhAsset(idList: [String], cookie: String, id: Int, csrf: String, tag: String){
//
//      var copyOfidList: [String] = idList
//          func populatePhAssetArray()-> Void{
//              if(copyOfidList.isEmpty){
//                  print("Done uploading")
//                  return
//              }
//              else{
//                  let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [copyOfidList[0]], options: photosOptions)
//                  let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
//                  let lastModified = String(Int(pivPHAsset.creationDate!.timeIntervalSince1970*1000))
//              copyOfidList.remove(at: 0)}
//              print(copyOfidList.count)
//              populatePhAssetArray()
//          }
//          populatePhAssetArray()
//      }

      
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "iosUpload"{
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              let cookie: String = arguments[1] as! String
              let id: Int = arguments[2] as! Int
              let csrf: String = arguments[3] as! String
              let tag: String = arguments[4] as! String
//              idToPhAsset(idList: idList, cookie: cookie, id: id, csrf: csrf, tag: tag)
              
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: photosOptions)
              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              
//              print(pivPHAsset as PHAsset)
//              print(PHAssetResource.assetResources(for: pivPHAsset).first?.uniformTypeIdentifier)
              
               pivPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                   let fileURL = input!.fullSizeImageURL
//                   let dataImage: NSData = NSData(contentsOfFile: fileURL!.path)!
                   print(fileURL)

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
//                        --- URL INSTANCE UPLOAD ---
                        MultipartFormData.append(fileURL!, withName: "piv", fileName: "piv", mimeType: "image/png")
//                        --- DATA INSTANCE UPLOAD ---
//                        MultipartFormData.append(dataImage as Data, withName: "piv", fileName: "piv", mimeType: "image/png")


                   }, to: sURL, method: .post, headers: headers)
                       .response {response in
                           print(response.debugDescription)
                            multipartDataFormResponse = response.debugDescription
                           print(multipartDataFormResponse)
                       }

              }
              
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
