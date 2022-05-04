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
//      var imageFinal: UIImage?
      var phAssetArray: [PHAsset] = []
      var array: [URL] = []
      
      func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler: @escaping ((_ responseURL : URL?) ->
                                                                               Void)){
          let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
          options.canHandleAdjustmentData = {(adjustmeta : PHAdjustmentData) -> Bool in return true}
          mPhasset.requestContentEditingInput(with: options, completionHandler: {(PHContentEditingInput, info) in
              completionHandler(PHContentEditingInput!.fullSizeImageURL)
      }
      )}
      
      func getUrlsFromPHAssets(assets: [PHAsset], completion: @escaping ((_ urls:[URL]) -> ())){
          let group = DispatchGroup()
          for asset in assets {
              group.enter()
              getURL(ofPhotoWith: asset) { (url) in
                  if let url = url {
                      array.append(url)
                      print(url)
                  }
                  group.leave()
              }
              group.notify(queue: .main){
                  completion(array)
              }
          }}
      
      func phassetToUrl(phasset: PHAsset, cookie: String, id: Int, csrf: String, tag: String){
     phasset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
             var fileURL = input!.fullSizeImageURL
             print(fileURL)
         
         let headers: HTTPHeaders = [
          "content-type": "multipart/form-data",
          "cookie": cookie
        ]
        let parameters: [String: String] = [
          "id": String(id),
          "csrf": csrf,
          "tags": tag,
          "lastModified": String(Int(phasset.creationDate!.timeIntervalSince1970*1000))
        ]

         AF.upload(multipartFormData: {MultipartFormData in
            for (key, value) in parameters {
                MultipartFormData.append(Data(value.utf8), withName: key)
            }
//                        --- URL INSTANCE UPLOAD ---
             MultipartFormData.append(fileURL!, withName: "piv", fileName: "piv", mimeType: "image/png")



        }, to: sURL, method: .post, headers: headers)
            .response {response in
                print(response.debugDescription)
                 multipartDataFormResponse = response.debugDescription
                print(multipartDataFormResponse)
            }
         
                       
              
         }
          
      }
      
      
      func idToPhAsset(idList: [String], lastModifiedList: [String], cookie: String, id: Int, csrf: String, tag: String) {
          for id in idList{
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: photosOptions)
              var pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              phAssetArray.append(pivPHAsset)
          }
          print("phAssetArray.count is \(phAssetArray.count)" )
          for phasset in phAssetArray {
              phassetToUrl(phasset: phasset, cookie: cookie, id: id, csrf: csrf, tag: tag)
          }


//          getUrlsFromPHAssets(assets: Array(phAssetArray[0...3]), completion: { array in print("array.count is \(array.count)")
//              })
       }
      

      
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "iosUpload"{
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              let lastModifiedList: [String] = arguments[1] as! [String]
              let cookie: String = arguments[2] as! String
              let id: Int = arguments[3] as! Int
              let csrf: String = arguments[4] as! String
              let tag: String = arguments[5] as! String
            idToPhAsset(idList: idList, lastModifiedList: lastModifiedList, cookie: cookie, id: id, csrf: csrf, tag: tag)
              
//              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: photosOptions)
//              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
//
//              print(pivPHAsset as PHAsset)
//              print(PHAssetResource.assetResources(for: pivPHAsset).first?.uniformTypeIdentifier)
              
              
//               pivPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
//                   let fileURL = input!.fullSizeImageURL
//                   print(fileURL)
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
