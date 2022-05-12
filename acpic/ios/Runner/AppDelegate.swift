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
      var creationDateTimeArray: [Date] = []
      
      
      func multipartFormDataUpload(cookie: String, id: Int, csrf: String, tag: String){
          var operationsGoingOn = 0
          let limit = 20
          var done = 0
          func areWeDone () {
              if (done == pathArray.count) {
                  print("done is \(done)")
                 print("Done uploading")
             }
          }
          func upload(date: Date, path: URL) {
              print("operationsGoingOn in multipart is \(operationsGoingOn)")
              if (operationsGoingOn >= limit) {
                  DispatchQueue.main.asyncAfter(deadline: .now () + 1) {
                      upload(date: date, path: path)
                  }
              }
              else{
                  operationsGoingOn+=1;
                  let headers: HTTPHeaders = [
                   "content-type": "multipart/form-data",
                   "cookie": cookie
                 ]
                 let parameters: [String: String] = [
                   "id": String(id),
                   "csrf": csrf,
                   "tags": tag,
                   "lastModified": String(Int(date.timeIntervalSince1970*1000))
                 ]
                  AF.upload(multipartFormData: {MultipartFormData in
                     for (key, value) in parameters {
                         MultipartFormData.append(Data(value.utf8), withName: key)
                     }
                     MultipartFormData.append(path, withName: "piv", fileName: "piv", mimeType: "image/png")
                  }, to: sURL, method: .post, headers: headers)
                     .response {response in
//                         print(response.debugDescription)
                         operationsGoingOn-=1;
                          done += 1
                          areWeDone()
                     }
              }
          }
          for (date, path) in zip(creationDateTimeArray, pathArray){
              upload(date: date, path: path)
          }
      }
      
      
      func idsToPaths(idList: [String], cookie: String, id: Int, csrf: String, tag: String) {
          for id in idList{
              let phAssetPivFetchedAsset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: photosOptions)
              let pivPHAsset = phAssetPivFetchedAsset.firstObject! as PHAsset
              phAssetArray.append(pivPHAsset)
          }
          print("phAssetArray.count is \(phAssetArray.count)" )
          var operationsGoingOn = 0
          let limit = 200
          var done = 0
          func areWeDone () {
              if (done == phAssetArray.count) {
                 print("pathArray.count is \(pathArray.count)")
                  multipartFormDataUpload(cookie: cookie, id: id, csrf: csrf, tag: tag)
             }
          }
          func PathLookup (asset: PHAsset) {
              print("operationsGoingOn in PathLookup is \(operationsGoingOn)")
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
                        let creationDateTime = input?.creationDate
                        creationDateTimeArray.append(creationDateTime!)
                    } else if(asset.mediaType == .video){
                        let path: AVURLAsset = input!.audiovisualAsset! as! AVURLAsset
                        pathArray.append(path.url)
                        let creationDateTime = input?.creationDate
                        creationDateTimeArray.append(creationDateTime!)
                    } else if (asset.mediaType != .image || asset.mediaType != .video){
                        print("WE HAVE A STRANGE ASSET \(asset)")
                    }
                   operationsGoingOn-=1;
                    done += 1
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
              idsToPaths(idList: idList, cookie: cookie, id: id, csrf: csrf, tag: tag)
             
              
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
