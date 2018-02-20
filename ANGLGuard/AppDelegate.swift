import UIKit
import Alamofire
import UserNotifications
import Firebase

let HOST = "https://anglguard-service.angl.life/public"
let HOST_TOURIST = "http://203.107.236.229/api-tourist"
let SECRET_KEY = "aWuxjr5RQhDRItGII616"

let LOGIN_URL = HOST + "/authen"
let SAVE_NOTI_URL = HOST + "/save-noti-key"
let HOSPITAL_LIST_URL = HOST + "/list-hospital"
let UPDATE_LOCATION_URL = HOST + "/update-current-location"
let SEND_ALERT_URL = HOST + "/send-alert"
let BES_ALERT_URL = HOST + "/call-bes-alert"
let FIRSTAID_LIST_URL = HOST + "/list-firstaid"
let FIRSTAID_CONTENT_URL = HOST + "/get-firstaid-content"
let FAMILY_LIST_URL = HOST + "/list-member-family"
let FAMILY_SEARCH_URL = HOST + "/search-member-family"
let FAMILY_ADD_URL = HOST + "/add-member-family"
let FAMILY_DELETE_URL = HOST + "/delete-member-family"
let NOTIFICATION_LIST_URL = HOST + "/list-notification-history"

let EMAIL_EXISTS = HOST + "/chk-email-exists"
let EMAIL_VERIFY = HOST + "/verify-email-code"
let SMS_SEND_CODE = HOST + "/send-sms-code"
let SMS_VERIFY_CODE = HOST + "/verify-sms-code"
let SIGN_UP_REGISTER = HOST + "/registration"
let SAVE_INSURANCE_POLICY = HOST + "/save-insurance-policy-other"

let TOURIST_AUTHENTICATION = HOST_TOURIST + "/vendor/authentication/secret_key"
let TOURIST_EVENT_TRACKING = HOST_TOURIST + "/vendor/event/event_tracking/@"

let VIRIYAH_URL = "https://affiliatedev.viriyah.co.th/ANGL/index.php?token=@"
let VIRIYAH_SUCCESS_URL = "https://affiliatedev.viriyah.co.th/ANGL/successpage.php"
let ASIA_PAY_URL = "https://test.siampay.com/b2cDemo/eng/payment/payForm.jsp"
let ASIA_PAY_SUCCESS_URL = "https://anglguard-service.angl.life/public/siampay-success"

let DELEY_TIME = 3.0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var appIsStarting: Bool = false
    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let login = defaults.string(forKey: "login") {
            if login == "Y" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "inital")
                self.window?.rootViewController = viewController
            }
        }
        
        if let token = defaults.string(forKey: "token") {
            print("token = \(token)")
        }
        
        //register push notification
        registerForPushNotifications()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
//        Messaging.messaging().delegate = self
        
        //check push notification
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as! [AnyHashable : Any]? {
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if let latitude: String = remoteNotification["latitude"] as? String, let longitude: String = remoteNotification["longitude"] as? String {
                    let alert = UIAlertController(title: latitude + " " + longitude, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    topController.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        appIsStarting = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        appIsStarting = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appIsStarting = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appIsStarting = false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Messaging.messaging().apnsToken = deviceToken
        
        let fcmToken = Messaging.messaging().fcmToken
        print("fcmToken: \(fcmToken!)")

        registerToMobilePush(deviceToken: fcmToken!)
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        if var topController = window?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//
//            if let latitude: String = userInfo["latitude"] as? String, let longitude: String = userInfo["longitude"] as? String {
//                let alert = UIAlertController(title: latitude + " " + longitude, message: "", preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(defaultAction)
//                topController.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .background || application.applicationState == .inactive && !appIsStarting {
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                if let latitude: String = userInfo["latitude"] as? String, let longitude: String = userInfo["longitude"] as? String {
                    let alert = UIAlertController(title: latitude + " " + longitude, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    topController.present(alert, animated: true, completion: nil)
                }
            }
        } else if application.applicationState == .inactive && appIsStarting {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcmToken: \(fcmToken)")
        registerToMobilePush(deviceToken: fcmToken)
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ (granted, error) in
                guard granted else { return }
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func registerToMobilePush(deviceToken: String)  {
        if let token = defaults.string(forKey: "token") {
            if let login = defaults.string(forKey: "login") {
                if login == "Y" {
                    let parameters: Parameters = [
                        "token": token,
                        "notikey": deviceToken
                    ]
                    
                    Alamofire.request(SAVE_NOTI_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                        let result = String(data: response.data!, encoding: String.Encoding.utf8)!
                        NSLog("save = \(result)")
                        if let json = response.result.value {
                            let result = json as! Dictionary<String, Any>
                            let code: String = result["code"] as! String
                            if code == "104" {
                                self.defaults.set("N", forKey: "login")
                                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                                UIApplication.shared.keyWindow?.rootViewController = loginViewController
                            }
                        }
                    }
                }
            }
        }
    }

}

