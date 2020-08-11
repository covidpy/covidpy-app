import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
     if #available(iOS 10.0, *) {
       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     }
//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self
//      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//      UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
//    } else {
//      let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//      application.registerUserNotificationSettings(settings)
//    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

//  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//      let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//      print("getToken")
//      print(token)
//  }
    
    
}
