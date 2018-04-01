import UIKit
import Alamofire
import UserNotifications
import Firebase
import SVProgressHUD

import FBSDKLoginKit
import GoogleSignIn

//Production
//let HOST = "https://anglguard-service.angl.life/public"
//let HOST_TOURIST = "http://203.107.236.229/api-tourist-live"
//
//let VIRIYAH_URL = "https://affiliate.viriyah.co.th/ANGL/index.php?token=@"
//let VIRIYAH_SUCCESS_URL = "https://affiliate.viriyah.co.th/ANGL/successpage.php"
//
//let ASIA_PAY_URL = "https://www.paydollar.com/b2c2/eng/payment/payForm.jsp"
//let ASIA_PAY_CANCEL_URL = "https://anglguard-service.angl.life/public/siampay-cancel"
//let ASIA_PAY_SUCCESS_URL = "https://anglguard-service.angl.life/public/siampay-success"
//let ASIA_PAY_FAIL_URL = "https://anglguard-service.angl.life/public/siampay-fail"
//
//let MERCHANT_CODE = "76101221"
//Production

// dev
let HOST = "https://anglguard-service-test.angl.life/public"
let HOST_TOURIST = "http://203.107.236.229/api-tourist"

let VIRIYAH_URL = "https://affiliatedev.viriyah.co.th/ANGL/index.php?token=@"
let VIRIYAH_SUCCESS_URL = "https://affiliatedev.viriyah.co.th/ANGL/successpage.php"

let ASIA_PAY_URL = "https://test.siampay.com/b2cDemo/eng/payment/payForm.jsp"
let ASIA_PAY_CANCEL_URL = "https://anglguard-service-test.angl.life/public/siampay-cancel"
let ASIA_PAY_SUCCESS_URL = "https://anglguard-service-test.angl.life/public/siampay-success"
let ASIA_PAY_FAIL_URL = "https://anglguard-service.angl-test.life/public/siampay-fail"

let MERCHANT_CODE = "76065111"
// dev

let CHECK_VERSION_URL = HOST + "/check-version"

let MD5_KEY = "76065111"
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
let PRIVILEGE_LIST_URL = HOST + "/list-privilege"
let FAQ_URL = HOST + "/get-faq"

let EMAIL_EXISTS = HOST + "/chk-email-exists"
let EMAIL_VERIFY = HOST + "/verify-email-code"
let SMS_SEND_CODE = HOST + "/send-sms-code"
let SMS_VERIFY_CODE = HOST + "/verify-sms-code"
let SIGN_UP_REGISTER = HOST + "/registration"
let GET_INSURANCE_POLICY = HOST + "/get-profile-insurance"
let SAVE_INSURANCE_POLICY = HOST + "/save-insurance-policy-other"
let BOOK_INSURANCE_VIRIYAH = HOST + "/book-insurance-viriyah"
let SAVE_NEW_PASSWORD = HOST + "/save-new-password"
let SAVE_TRIP_PLAN = HOST + "/save-profile-trip-plan"
let SAVE_PROFILE_CONTACT = HOST + "/save-profile-contact"
let SAVE_PROFILE_MEDICAL = HOST + "/save-profile-medical"
let SAVE_PROFILE_PERSONAL = HOST + "/save-profile-personal"

let TOURIST_AUTHENTICATION = HOST_TOURIST + "/vendor/authentication/secret_key"
let TOURIST_EVENT_TRACKING = HOST_TOURIST + "/vendor/event/event_tracking/@"

let DELEY_TIME = 5.0
let LOADING_TEXT = "  Loading...  "

let CODE_NOT_VALID = "Code is not valid."
let PROFILE_IMAGE_ALERT = "Please pick your profile image."
let FIRSTNAME_ALERT = "Please insert first name."
let LASTNAME_ALERT = "Please insert last name."
let GENDER_ALERT = "Please fill gender."
let DATE_OF_BITH_ALERT = "Please fill date of bith."
let HEIGHT_ALERT = "Please fill height."
let WEIGHT_ALERT = "Please fill weight."
let CC_ALERT = "Please fill country code."
let MOBILE_NUMBER_ALERT = "Please fill mobile number."
let PASSPORT_IMAGE_ALERT = "Please pick image passport."
let PASSPORT_NUMBER_ALERT = "Please insert passport number."
let COUNTRY_ALERT = "Please select your country."
let PASSPORT_EXPIRE_ALERT = "Please insert passport expire."
let BLOOD_TYPE_ALERT = "Please select blood type."
let PURPOSE_ALERT = "Please choice your purpose of the trip."
let START_DATE_ALERT = "Please insert start date."
let LENGTH_OF_STAY_ALERT = "Please insert lenght of stay."
let RELATION_SHIP_ALERT = "Please insert relation ship."
let POLICY_NUMBER_ALERT = "Please insert policy number."
let EXPIRE_DATE_ALERT = "Please insert expire date."
let INSURANCE_COMPANY_ALERT = "Please insert insurance company."
let CONTACT_NAME_ALERT = "Please insert contact name."

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, WXApiDelegate {
    
    var window: UIWindow?
    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        checkVersion()
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        if let login = defaults.string(forKey: "login") {
            if login == "Y" {
                mapProfile()
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
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    topController.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "405428121980-34ck2gf8b1cp4b3dlkttnnbdd1ck99rn.apps.googleusercontent.com"
        
        // WeChat: use your AppID
        WXApi.registerApp("wx235325325")
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == "anglguard" {
            let service = OutlookService.shared()
            service.handleOAuthCallback(url: url)
            return true
        } else if url.scheme == "wxc5aac2e8f9f73a9837" {
            WXApi.handleOpen(url, delegate: self)
        } else {
            if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            } else if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
        }
        
        return false
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        if var topController = window?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//
//            if let latitude: String = userInfo["latitude"] as? String, let longitude: String = userInfo["longitude"] as? String {
//                let alert = UIAlertController(title: latitude + " " + longitude, message: "", preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
//                alert.addAction(defaultAction)
//                topController.present(alert, animated: true, completion: nil)
//            }
//        }
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
                                self.defaults.set("N", forKey: "timer")
                                self.clearProfile()
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
    
    func checkVersion()  {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let parameters: Parameters = [
                "platform": "ios",
                "version": version
            ]
            
            Alamofire.request(CHECK_VERSION_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                let result = String(data: response.data!, encoding: String.Encoding.utf8)!
                NSLog("version = \(result)")
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let force_update: Bool = result["force_update"] as! Bool
                    if force_update == true {
                        if let link: String = result["link"] as? String {
                            if let url = URL(string : link) {
                                let alert = UIAlertController(title: "force update", message: "", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: { (action) in
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        UIApplication.shared.openURL(url)
                                    }
                                })
                                
                                alert.addAction(defaultAction)
                                
                                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                                    while let presentedViewController = topController.presentedViewController {
                                        topController = presentedViewController
                                    }
                                    DispatchQueue.main.async {
                                        topController.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setProfile(data: Dictionary<String, Any>) {
        let personal = data["personal"]  as! Dictionary<String, Any>
        defaults.set(personal["id"] as? String, forKey: "id")
        defaults.set(personal["token"] as? String, forKey: "token")
        defaults.set(personal["first_name"] as? String, forKey: "first_name")
        defaults.set(personal["middle_name"] as? String, forKey: "middle_name")
        defaults.set(personal["last_name"] as? String, forKey: "last_name")
        defaults.set(personal["gender"] as? String, forKey: "gender")
        defaults.set(personal["date_of_birth"] as? String, forKey: "birthdate")
        defaults.set(personal["height"] as? String, forKey: "height")
        defaults.set(personal["weight"] as? String, forKey: "weight")
        defaults.set(personal["country_code"] as? String, forKey: "country_code")
        defaults.set(personal["passport_num"] as? String, forKey: "passport_num")
        defaults.set(personal["passport_expire_date"] as? String, forKey: "passport_expire_date")
        defaults.set(personal["passport_img"] as? String, forKey: "passport_img")
        defaults.set(personal["personal_img_bin"] as? String, forKey: "personal_img_bin")
        defaults.set(personal["email"] as? String, forKey: "email")
        defaults.set(personal["mobile_num"] as? String, forKey: "mobile_num")
        defaults.set(personal["mobile_cc"] as? String, forKey: "mobile_cc")
        defaults.set(personal["thai_mobile_num"] as? String, forKey: "thai_mobile_num")
        defaults.set(personal["thai_mobile_cc"] as? String, forKey: "thai_mobile_cc")
        defaults.set(personal["personal_link"] as? String, forKey: "personal_link")
        
        let contact = data["contact_person"]  as! Dictionary<String, Any>
        defaults.set(contact["first_name"] as? String, forKey: "contact_first_name")
        defaults.set(contact["middle_name"] as? String, forKey: "contact_middle_name")
        defaults.set(contact["last_name"] as? String, forKey: "contact_last_name")
        defaults.set(contact["contact_number"] as? String, forKey: "contact_number")
        defaults.set(contact["contact_number_cc"] as? String, forKey: "contact_number_cc")
        defaults.set(contact["relation"] as? String, forKey: "contact_relation")
        defaults.set(contact["email"] as? String, forKey: "contact_email")
        
        let trip = data["trip_plan"]  as! Dictionary<String, Any>
        defaults.set(trip["purpose"] as? String, forKey: "trip_purpose")
        defaults.set(trip["destination"] as? String, forKey: "trip_destination")
        defaults.set(trip["duration"] as? String, forKey: "trip_duration")
        defaults.set(trip["average_expen"] as? String, forKey: "trip_average_expen")
        defaults.set(trip["trip_arrange"] as? String, forKey: "trip_arrange")
        defaults.set(trip["domestic_trans_arrange"] as? String, forKey: "trip_domestic_trans_arrange")
        defaults.set(trip["start_date"] as? String, forKey: "trip_start_date")
        
        let medical = data["medical_profile"]  as! Dictionary<String, Any>
        defaults.set(medical["blood_type"] as? String, forKey: "medical_blood_type")
        
        let drug = medical["allergy_drug"]  as! Dictionary<String, Any>
        defaults.set(drug["seizures"] as? String, forKey: "drug_seizures")
        defaults.set(drug["insuline"] as? String, forKey: "drug_insuline")
        defaults.set(drug["iodine"] as? String, forKey: "drug_iodine")
        defaults.set(drug["penicillin"] as? String, forKey: "drug_penicillin")
        defaults.set(drug["sulfa"] as? String, forKey: "drug_sulfa")
        defaults.set(drug["others"] as? String, forKey: "drug_others")
        
        let food = medical["allergy_food"]  as! Dictionary<String, Any>
        defaults.set(food["milk"] as? String, forKey: "food_milk")
        defaults.set(food["eggs"] as? String, forKey: "food_eggs")
        defaults.set(food["fish"] as? String, forKey: "food_fish")
        defaults.set(food["crustacean_shellfish"] as? String, forKey: "food_crustacean_shellfish")
        defaults.set(food["tree_nuts"] as? String, forKey: "food_tree_nuts")
        defaults.set(food["peanuts"] as? String, forKey: "food_peanuts")
        defaults.set(food["wheat"] as? String, forKey: "food_wheat")
        defaults.set(food["soybeans"] as? String, forKey: "food_soybeans")
        defaults.set(food["others"] as? String, forKey: "food_others")
        
        let chemical = medical["allergy_chemical"]  as! Dictionary<String, Any>
        defaults.set(chemical["shampoos"] as? String, forKey: "chemical_shampoos")
        defaults.set(chemical["shampoos_brand"] as? String, forKey: "chemical_shampoos_brand")
        defaults.set(chemical["fragrances"] as? String, forKey: "chemical_fragrances")
        defaults.set(chemical["fragrances_brand"] as? String, forKey: "chemical_fragrances_brand")
        defaults.set(chemical["cleaners"] as? String, forKey: "chemical_cleaners")
        defaults.set(chemical["cleaners_brand"] as? String, forKey: "chemical_cleaners_brand")
        defaults.set(chemical["detergents"] as? String, forKey: "chemical_detergents")
        defaults.set(chemical["detergents_brand"] as? String, forKey: "chemical_detergents_brand")
        defaults.set(chemical["cosmetics"] as? String, forKey: "chemical_cosmetics")
        defaults.set(chemical["cosmetics_brand"] as? String, forKey: "chemical_cosmetics_brand")
        defaults.set(chemical["others"] as? String, forKey: "chemical_others")
        
        let underlying = medical["underlying"]  as! Dictionary<String, Any>
        defaults.set(underlying["diabetes_mellitus"] as? String, forKey: "underlying_diabetes_mellitus")
        defaults.set(underlying["hypertension"] as? String, forKey: "underlying_hypertension")
        defaults.set(underlying["chronic_kidney_disease"] as? String, forKey: "underlying_chronic_kidney_disease")
        defaults.set(underlying["heart_disease"] as? String, forKey: "underlying_heart_disease")
        defaults.set(underlying["old_stroke"] as? String, forKey: "underlying_old_stroke")
        defaults.set(underlying["others"] as? String, forKey: "underlying_others")
        
        let current_medication = medical["current_medication"]  as! Dictionary<String, Any>
        defaults.set(current_medication["description"] as? String, forKey: "current_medication_description")
        
        let special_care = medical["special_care"]  as! Dictionary<String, Any>
        defaults.set(special_care["no_need"] as? String, forKey: "special_care_no_need")
        
        let need = special_care["need"]  as! Dictionary<String, Any>
        let device = need["device"]  as! Dictionary<String, Any>
        defaults.set(device["assistive_environmental_devices"] as? String, forKey: "device_assistive_environmental_devices")
        defaults.set(device["gait_aid"] as? String, forKey: "device_gait_aid")
        defaults.set(device["wheelchair"] as? String, forKey: "device_wheelchair")
        
        let care_giver = need["care_giver"]  as! Dictionary<String, Any>
        defaults.set(care_giver["one"] as? String, forKey: "care_giver_one")
        defaults.set(care_giver["two"] as? String, forKey: "care_giver_two")
        
        if let insurance: Dictionary<String, Any> = data["insurance"] as? Dictionary<String, Any> {
            defaults.set(insurance["policy_number"] as? String, forKey: "insurance_policy_number")
            defaults.set(insurance["start_date"] as? String, forKey: "insurance_start_date")
            defaults.set(insurance["expiration_date"] as? String, forKey: "insurance_expiration_date")
            defaults.set(insurance["insurance_company"] as? String, forKey: "insurance_insurance_company")
            defaults.set(insurance["contact_name"] as? String, forKey: "insurance_contact_name")
            defaults.set(insurance["contact_number_cc"] as? String, forKey: "insurance_contact_number_cc")
            defaults.set(insurance["contact_number"] as? String, forKey: "insurance_contact_number")
        }
        
        mapProfile()
    }
    
    func mapProfile() {
        Personal.sharedInstance.email = defaults.string(forKey: "email")!
        Personal.sharedInstance.firstname = defaults.string(forKey: "first_name")!
        Personal.sharedInstance.middlename = defaults.string(forKey: "middle_name")!
        Personal.sharedInstance.lastname = defaults.string(forKey: "last_name")!
        Personal.sharedInstance.gender = defaults.string(forKey: "gender")!
        Personal.sharedInstance.birthdate = defaults.string(forKey: "birthdate")!
        Personal.sharedInstance.height = defaults.string(forKey: "height")!
        Personal.sharedInstance.weight = defaults.string(forKey: "weight")!
        Personal.sharedInstance.country_code = defaults.string(forKey: "country_code")!
        Personal.sharedInstance.passport_num = defaults.string(forKey: "passport_num")!
        Personal.sharedInstance.passport_expire_date = defaults.string(forKey: "passport_expire_date")!
        Personal.sharedInstance.mobile_num = defaults.string(forKey: "mobile_num")!
        Personal.sharedInstance.mobile_cc = defaults.string(forKey: "mobile_cc")!
        Personal.sharedInstance.thai_mobile_num = defaults.string(forKey: "thai_mobile_num")!
        Personal.sharedInstance.thai_mobile_cc = defaults.string(forKey: "thai_mobile_cc")!
        Personal.sharedInstance.personal_link = defaults.string(forKey: "personal_link")!
        
        Contact.sharedInstance.firstname = defaults.string(forKey: "contact_first_name")!
        Contact.sharedInstance.middlename = defaults.string(forKey: "contact_middle_name")!
        Contact.sharedInstance.lastname = defaults.string(forKey: "contact_last_name")!
        Contact.sharedInstance.contact_number = defaults.string(forKey: "contact_number")!
        Contact.sharedInstance.contact_number_cc = defaults.string(forKey: "contact_number_cc")!
        Contact.sharedInstance.relation = defaults.string(forKey: "contact_relation")!
        Contact.sharedInstance.email = defaults.string(forKey: "contact_email")!
        
        Trip.sharedInstance.purpose = defaults.string(forKey: "trip_purpose")!
        Trip.sharedInstance.start_date = defaults.string(forKey: "trip_start_date")!
        Trip.sharedInstance.duration = defaults.string(forKey: "trip_duration")!
        Trip.sharedInstance.average_expen = defaults.string(forKey: "trip_average_expen")!
        Trip.sharedInstance.trip_arrang = defaults.string(forKey: "trip_arrange")!
        Trip.sharedInstance.domestic_tran_arrang = defaults.string(forKey: "trip_domestic_trans_arrange")!
        Trip.sharedInstance.destination = defaults.string(forKey: "trip_destination")!
        
        Medical.sharedInstance.blood_type = defaults.string(forKey: "medical_blood_type")!
        
        Medical.sharedInstance.seizures = defaults.string(forKey: "drug_seizures")!
        Medical.sharedInstance.insuline = defaults.string(forKey: "drug_insuline")!
        Medical.sharedInstance.iodine = defaults.string(forKey: "drug_iodine")!
        Medical.sharedInstance.penicillin = defaults.string(forKey: "drug_penicillin")!
        Medical.sharedInstance.sulfa = defaults.string(forKey: "drug_sulfa")!
        Medical.sharedInstance.allergy_drug_others = defaults.string(forKey: "drug_others")!
        
        Medical.sharedInstance.milk = defaults.string(forKey: "food_milk")!
        Medical.sharedInstance.eggs = defaults.string(forKey: "food_eggs")!
        Medical.sharedInstance.fish = defaults.string(forKey: "food_fish")!
        Medical.sharedInstance.crustacean_shellfish = defaults.string(forKey: "food_crustacean_shellfish")!
        Medical.sharedInstance.tree_nuts = defaults.string(forKey: "food_tree_nuts")!
        Medical.sharedInstance.peanuts = defaults.string(forKey: "food_peanuts")!
        Medical.sharedInstance.wheat = defaults.string(forKey: "food_wheat")!
        Medical.sharedInstance.soybeans = defaults.string(forKey: "food_soybeans")!
        Medical.sharedInstance.allergy_food_others = defaults.string(forKey: "food_others")!
        
        Medical.sharedInstance.shampoos = defaults.string(forKey: "chemical_shampoos")!
        Medical.sharedInstance.shampoos_brand = defaults.string(forKey: "chemical_shampoos_brand")!
        Medical.sharedInstance.fragrances = defaults.string(forKey: "chemical_fragrances")!
        Medical.sharedInstance.fragrances_brand = defaults.string(forKey: "chemical_fragrances_brand")!
        Medical.sharedInstance.cleaners = defaults.string(forKey: "chemical_cleaners")!
        Medical.sharedInstance.cleaners_brand = defaults.string(forKey: "chemical_cleaners_brand")!
        Medical.sharedInstance.detergents = defaults.string(forKey: "chemical_detergents")!
        Medical.sharedInstance.detergents_brand = defaults.string(forKey: "chemical_detergents_brand")!
        Medical.sharedInstance.cosmetics = defaults.string(forKey: "chemical_cosmetics")!
        Medical.sharedInstance.cosmetics_brand = defaults.string(forKey: "chemical_cosmetics_brand")!
        Medical.sharedInstance.allergy_chemical_others = defaults.string(forKey: "chemical_others")!
        
        Medical.sharedInstance.diabetes_mellitus = defaults.string(forKey: "underlying_diabetes_mellitus")!
        Medical.sharedInstance.hypertension = defaults.string(forKey: "underlying_hypertension")!
        Medical.sharedInstance.chronic_kidney_disease = defaults.string(forKey: "underlying_chronic_kidney_disease")!
        Medical.sharedInstance.heart_disease = defaults.string(forKey: "underlying_heart_disease")!
        Medical.sharedInstance.old_stroke = defaults.string(forKey: "underlying_old_stroke")!
        Medical.sharedInstance.underlying_others = defaults.string(forKey: "underlying_others")!
        
        Medical.sharedInstance.current_medication_description = defaults.string(forKey: "current_medication_description")!
        
        Medical.sharedInstance.no_need = defaults.string(forKey: "special_care_no_need")!
        Medical.sharedInstance.assistive_environmental_devices = defaults.string(forKey: "device_assistive_environmental_devices")!
        Medical.sharedInstance.gait_aid = defaults.string(forKey: "device_gait_aid")!
        Medical.sharedInstance.wheelchair = defaults.string(forKey: "device_wheelchair")!
        Medical.sharedInstance.care_giver_one = defaults.string(forKey: "care_giver_one")!
        Medical.sharedInstance.care_giver_two = defaults.string(forKey: "care_giver_two")!

        if defaults.string(forKey: "insurance_policy_number") != nil {
            Insurance.sharedInstance.policy_number = defaults.string(forKey: "insurance_policy_number")!
            Insurance.sharedInstance.start_date = defaults.string(forKey: "insurance_start_date")!
            Insurance.sharedInstance.expiration_date = defaults.string(forKey: "insurance_expiration_date")!
            Insurance.sharedInstance.insurance_company = defaults.string(forKey: "insurance_insurance_company")!
            Insurance.sharedInstance.contact_name = defaults.string(forKey: "insurance_contact_name")!
            Insurance.sharedInstance.contact_number_cc = defaults.string(forKey: "insurance_contact_number_cc")!
            Insurance.sharedInstance.contact_number = defaults.string(forKey: "insurance_contact_number")!
        }
    }
    
    func clearProfile() {
        Personal.sharedInstance.email = ""
        Personal.sharedInstance.firstname = ""
        Personal.sharedInstance.middlename = ""
        Personal.sharedInstance.lastname = ""
        Personal.sharedInstance.gender = ""
        Personal.sharedInstance.birthdate = ""
        Personal.sharedInstance.height = ""
        Personal.sharedInstance.weight = ""
        Personal.sharedInstance.country_code = ""
        Personal.sharedInstance.passport_num = ""
        Personal.sharedInstance.passport_expire_date = ""
        Personal.sharedInstance.mobile_num = ""
        Personal.sharedInstance.mobile_cc = ""
        Personal.sharedInstance.thai_mobile_num = ""
        Personal.sharedInstance.thai_mobile_cc = ""
        
        Contact.sharedInstance.firstname = ""
        Contact.sharedInstance.middlename = ""
        Contact.sharedInstance.lastname = ""
        Contact.sharedInstance.contact_number = ""
        Contact.sharedInstance.contact_number_cc = ""
        Contact.sharedInstance.relation = ""
        Contact.sharedInstance.email = ""
        
        Trip.sharedInstance.purpose = ""
        Trip.sharedInstance.start_date = ""
        Trip.sharedInstance.duration = ""
        Trip.sharedInstance.average_expen = ""
        Trip.sharedInstance.trip_arrang = ""
        Trip.sharedInstance.domestic_tran_arrang = ""
        Trip.sharedInstance.destination = ""
        
        Medical.sharedInstance.blood_type = ""
        
        Medical.sharedInstance.seizures = "0"
        Medical.sharedInstance.insuline = "0"
        Medical.sharedInstance.iodine = "0"
        Medical.sharedInstance.penicillin = "0"
        Medical.sharedInstance.sulfa = "0"
        Medical.sharedInstance.allergy_drug_others = ""
        
        Medical.sharedInstance.milk = "0"
        Medical.sharedInstance.eggs = "0"
        Medical.sharedInstance.fish = "0"
        Medical.sharedInstance.crustacean_shellfish = "0"
        Medical.sharedInstance.tree_nuts = "0"
        Medical.sharedInstance.peanuts = "0"
        Medical.sharedInstance.wheat = "0"
        Medical.sharedInstance.soybeans = "0"
        Medical.sharedInstance.allergy_food_others = ""
        
        Medical.sharedInstance.shampoos = "0"
        Medical.sharedInstance.shampoos_brand = ""
        Medical.sharedInstance.fragrances = "0"
        Medical.sharedInstance.fragrances_brand = ""
        Medical.sharedInstance.cleaners = "0"
        Medical.sharedInstance.cleaners_brand = ""
        Medical.sharedInstance.detergents = "0"
        Medical.sharedInstance.detergents_brand = ""
        Medical.sharedInstance.cosmetics = "0"
        Medical.sharedInstance.cosmetics_brand = ""
        Medical.sharedInstance.allergy_chemical_others = ""
        
        Medical.sharedInstance.diabetes_mellitus = "0"
        Medical.sharedInstance.hypertension = "0"
        Medical.sharedInstance.chronic_kidney_disease = "0"
        Medical.sharedInstance.heart_disease = "0"
        Medical.sharedInstance.old_stroke = "0"
        Medical.sharedInstance.underlying_others = ""
        
        Medical.sharedInstance.current_medication_description = ""
        
        Medical.sharedInstance.no_need = "0"
        Medical.sharedInstance.assistive_environmental_devices = "0"
        Medical.sharedInstance.gait_aid = "0"
        Medical.sharedInstance.wheelchair = "0"
        Medical.sharedInstance.care_giver_one = "0"
        Medical.sharedInstance.care_giver_two = "0"
        
        Insurance.sharedInstance.policy_number = ""
        Insurance.sharedInstance.start_date = ""
        Insurance.sharedInstance.expiration_date = ""
        Insurance.sharedInstance.insurance_company = ""
        Insurance.sharedInstance.contact_name = ""
        Insurance.sharedInstance.contact_number_cc = ""
        Insurance.sharedInstance.contact_number = ""
    }

}

