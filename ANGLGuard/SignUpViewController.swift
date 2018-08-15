import UIKit
import Alamofire
import SVProgressHUD

import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class SignUpViewController: UITableViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var lb_sign_up: UILabel!
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!
    @IBOutlet var tf_confirm: UITextField!
    @IBOutlet var bt_continue: UIButton!
    @IBOutlet var lb_or: UILabel!
    
    var email: String = ""
    var password: String = ""
    var confirm: String = ""
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.clearProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(weChatResponse(notification:)), name: WECHAT_RESPONSE_NOTIFICATION_NAME, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_sign_up.text = "login_signup".localized()
        tf_email.placeholder = "login_email".localized()
        tf_password.placeholder = "login_password".localized()
        tf_confirm.placeholder = "login_confirm_password".localized()
        bt_continue.setTitle("login_continue".localized(), for: .normal)
        lb_or.text = "login_or".localized()
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
            Authen.sharedInstance.key = user.userID
            Authen.sharedInstance.type = "google"
            verify(email: user.profile.email)
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        email = tf_email.text!
        password = tf_password.text!
        confirm = tf_confirm.text!
        
        if email.isValidEmail() == false {
            showAlert(message: "login_email_not_format".localized())
        } else if password.isValidPassword() == false {
            showAlert(message: "login_password_contain".localized())
        } else if password != confirm {
            showAlert(message: "login_password_not_match".localized())
        } else {
            Authen.sharedInstance.key = ""
            Authen.sharedInstance.type = "normal"
            Personal.sharedInstance.password = password
            verify(email: email)
        }
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
                                Authen.sharedInstance.key = id
                                Authen.sharedInstance.type = "facebook"
                                self.verify(email: email)
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
            outlookService.getUserProfile { (email, id) in
                if let userEmail = email, let userId = id {
                    Authen.sharedInstance.key = userId
                    Authen.sharedInstance.type = "outlook"
                    self.verify(email: userEmail)
                }
                self.outlookService.logout()
            }
        } else {
            outlookService.login(from: self) { (result) in
                if result != nil {
                    self.outlookService.getUserProfile(callback: { (email, id) in
                        if let userEmail = email, let userId = id {
                            Authen.sharedInstance.key = userId
                            Authen.sharedInstance.type = "outlook"
                            self.verify(email: userEmail)
                        }
                        self.outlookService.logout()
                    })
                }
            }
        }
    }
    
    @IBAction func wechatAction(_ sender: Any) {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "com.angllife.anglguard"
        WXApi.send(req)
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
                    Personal.sharedInstance.username = openid
                    Authen.sharedInstance.type = "wechat"
                    self.performSegue(withIdentifier: "showVerifyCode", sender: nil)
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func verify(email: String) {
        let parameters: Parameters = ["email": email]
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        Alamofire.request(EMAIL_EXISTS, method: .get, parameters: parameters).responseJSON { response in
            SVProgressHUD.dismiss()
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                NSLog("result = \(result)")
                let code: String = result["code"] as! String
                let message: String = result["message"] as! String
                if code == "200" {
                    let token: String = result["token"] as! String
                    self.defaults.set(token, forKey: "token")
                    
                    //data
                    Personal.sharedInstance.email = email
                    
                    self.performSegue(withIdentifier: "showVerifyCode", sender: nil)
                } else if code == "104" {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: { (action) in
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerifyCode" {
            let verifyCodeView: VerifyCodeViewController = segue.destination as! VerifyCodeViewController
            verifyCodeView.email = Personal.sharedInstance.email
        }
    }

}

extension String {
    
    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let regex = "^(?=.*\\d)(?=.*[a-zA-Z])[0-9a-zA-Z!@#$%^&*()-_=+{}|?>.<,:;~`’]{8,12}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
}
