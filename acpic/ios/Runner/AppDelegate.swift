import UIKit
import Flutter
//import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
//    handleEventsForBackgroundURLSession identifier: "com.altocode.acpicapp.events",
//                     completionHandler: @escaping () -> Void) {
//            backgroundCompletionHandler = completionHandler
//    }
//    private lazy var urlSession: URLSession = {
//        let config = URLSessionConfiguration.background(withIdentifier: "com.altocode.acpicapp")
//        config.sharedContainerIdentifier = "group.altocode.acpicapp"
//        config.isDiscretionary = false
//        config.sessionSendsLaunchEvents = true
//        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
//    }
//    let backgroundTask = urlSession.uploadTask(with: "https://altocode.nl/picdev/piv", fromFile: <#T##URL#>)
//    backgroundTask.earliestBeginDate = Date().addingTimeInterval(6 * 1)
//    backgroundTask.resume()
}
