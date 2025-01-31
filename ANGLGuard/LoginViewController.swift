import UIKit
import Alamofire
import SVProgressHUD

import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UITableViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var lb_sigm_in: UILabel!
    @IBOutlet var tf_username: UITextField!
    @IBOutlet var tf_password: UITextField!
    @IBOutlet var bt_forget_password: UIButton!
    @IBOutlet var bt_login: UIButton!
    @IBOutlet var lb_or: UILabel!
    
    let defaults = UserDefaults.standard
    
    let outlookService = OutlookService.shared()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(weChatResponse(notification:)), name: WECHAT_RESPONSE_NOTIFICATION_NAME, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_sigm_in.text = "login_sigin".localized()
        tf_username.placeholder = "login_username".localized()
        tf_password.placeholder = "login_password".localized()
        bt_forget_password.setTitle("login_forgot_password".localized(), for: .normal)
        bt_login.setTitle("login_login".localized(), for: .normal)
        lb_or.text = "login_or".localized()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if UIScreen.main.sizeType == .iPhone4 {
                return 174
            } else {
                return 322
            }
        } else if indexPath.row == 1 || indexPath.row == 2  {
            return 48
        } else {
            return 190
        }
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            let alert = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let parameters: Parameters = [
                "device":"ios",
                "email": user.profile.email!,
                "key": user.userID.encrypt(),
                "type": "google"
            ]
            self.login(parameters: parameters)
        }
    }
    
    @IBAction func signinAction(_ sender: Any) {
        let username = tf_username.text!
        let password = tf_password.text!
        let parameters: Parameters = [
            "device":"ios",
            "username": username,
            "password": password.encrypt(),
            "type": "normal"
        ]
        login(parameters: parameters)
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, _):
                let parameters = ["fields": "id, name, email"]
                FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        if let data = result as? [String : AnyObject] {
                            if let email = data["email"] as? String, let id = data["id"] as? String {
                                let parameters: Parameters = [
                                    "device":"ios",
                                    "email": email,
                                    "key": id.encrypt(),
                                    "type": "facebook"
                                ]
                                self.login(parameters: parameters)
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func googleAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func outlookAction(_ sender: Any) {
        if self.outlookService.isLoggedIn {
            outlookService.getUserProfile() { email, id  in
                if let userEmail = email, let userId = id {
                    let parameters: Parameters = [
                        "device":"ios",
                        "email": userEmail,
                        "key": userId.encrypt(),
                        "type": "outlook"
                    ]
                    self.login(parameters: parameters)
                }
                self.outlookService.logout()
            }
        } else {
            outlookService.login(from: self) { (result) in
                if result != nil {
                    self.outlookService.getUserProfile() { email, id in
                        if let userEmail = email, let userId = id {
                            let parameters: Parameters = [
                                "device":"ios",
                                "email": userEmail,
                                "key": userId.encrypt(),
                                "type": "outlook"
                            ]
                            self.login(parameters: parameters)
                        }
                        self.outlookService.logout()
                    }
                }
            }
        }
    }
    
    @IBAction func wechatAction(_ sender: Any) {
        if WXApi.isWXAppInstalled() == true {
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "com.angllife.anglguard"
            WXApi.send(req)
        } else {
            let message = "text_wechat_not_install".localized()
            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func weChatResponse(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let code = userInfo["response"] as? String {
                weChatAccessToken(code: code)
            }
        }
    }
    
    func weChatAccessToken(code: String) {
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        let parameters: Parameters = [
            "device":"ios",
            "appid": WECHAT_APP_ID,
            "secret": WECHAT_APP_SECRET,
            "code": code,
            "grant_type": "authorization_code"
        ]
        Alamofire.request(WECHAT_GET_ACCESSTOKEN_URL, method: .get, parameters: parameters).responseJSON { response in
            SVProgressHUD.dismiss()
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                NSLog("result = \(result)")
                if let errmsg = result["errmsg"] as? String {
                    let alert = UIAlertController(title: errmsg, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let openid: String = result["openid"] as! String
                    let parameters: Parameters = [
                        "device":"ios",
                        "username": openid,
                        "key": openid.encrypt(),
                        "type": "wechat"
                    ]
                    self.login(parameters: parameters)
                }
            }
        }
    }
    
    func login(parameters: Parameters) {
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        Alamofire.request(LOGIN_URL, method: .get, parameters: parameters).responseJSON { response in
            SVProgressHUD.dismiss()
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                let code: String = result["code"] as! String
                let message: String = result["message"] as! String
                NSLog("result = \(result)")
                if code == "200" {
                    if let data: Dictionary<String, Any> = result["data"]  as? Dictionary<String, Any> {
                        self.defaults.set("Y", forKey: "login")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setProfile(data: data)
                        appDelegate.mapProfile()
                        appDelegate.registerForPushNotifications()
                        if let personal = data["personal"] as? [String: Any] {
                            if let term = personal["show_term_flag"] as? String {
                                if term == "Y" {
                                    self.performSegue(withIdentifier: "showAgree", sender: nil)
                                } else {
                                    self.performSegue(withIdentifier: "showMain", sender: nil)
                                }
                            } else {
                                self.performSegue(withIdentifier: "showMain", sender: nil)
                            }
                        } else {
                            self.performSegue(withIdentifier: "showMain", sender: nil)
                        }
                        NotificationCenter.default.removeObserver(self, name: WECHAT_RESPONSE_NOTIFICATION_NAME, object: nil)
                    }
                } else {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UIScreen {
    
    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 1920.0
    }
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
