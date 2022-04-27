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
//      var sURL: String!
//      sURL = "https://altocode.nl/dev/pic/app/piv"
//      var multipartDataFormResponse: String! = "A string"
      var imageFinal: UIImage?
      var phAssetArray: [PHAsset] = []
      var lastModifiedArray: [String] = []
      var array: [URL] = []
      
      func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler: @escaping ((_ responseURL : URL?) ->
                                                                               Void)){
          let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
          options.canHandleAdjustmentData = {(adjustmeta : PHAdjustmentData) -> Bool in return true}
//      mPhasset.requestContentEditingInput(with: options, completionHandler: {(PHContentEditingInput, info) in
//          completionHandler(PHContentEditingInput!.fullSizeImageURL)
          completionHandler(URL(string: "sarasa"))
          print("getting sarasa")
      }
//      )
      
      func getUrlsFromPHAssets(assets: [PHAsset], completion: @escaping ((_ array:[URL]) -> ())){
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
      
      
      func idToPhAssetAndLastModified(idList: [String]){
          for id in idList{
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: photosOptions)
              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              phAssetArray.append(pivPHAsset)
              let lastModified: String = String(Int(pivPHAsset.creationDate!.timeIntervalSince1970*1000))
              lastModifiedArray.append(lastModified)
          }
          print("phAssetArray.count is \(phAssetArray.count)" )
        
          getUrlsFromPHAssets(assets: phAssetArray, completion: { array in print("array.count is \(array.count)")
              })
       }
      

      
      
      methodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
          if call.method == "iosUpload"{
              let arguments: [Any] = call.arguments as! [Any]
              let idList: [String] = arguments[0] as! [String]
              let cookie: String = arguments[1] as! String
              let id: Int = arguments[2] as! Int
              let csrf: String = arguments[3] as! String
              let tag: String = arguments[4] as! String
              idToPhAssetAndLastModified(idList: idList)
              
//              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [idList[0]], options: photosOptions)
//              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
//
//              if #available(iOS 13, *) {
//                                let manager = PHImageManager.default()
//                                let requestOptions = PHImageRequestOptions()
//                                requestOptions.isSynchronous = true
//                                requestOptions.isNetworkAccessAllowed = false
//                                requestOptions.resizeMode = .none
//
//                                manager.requestImageDataAndOrientation(for: pivPHAsset, options: requestOptions){(data,_,_,_) in
//                                     guard let data = data else{return}
//                                     if let image = UIImage(data: data){
//                                         imageFinal = image
//                                        print(imageFinal)
//                                     }
//                                }}
              
              
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
