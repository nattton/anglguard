import UIKit
import Alamofire
import SVProgressHUD

import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UITableViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var tf_username: UITextField!
    @IBOutlet var tf_password: UITextField!
    
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
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if UIScreen.main.sizeType == .iPhone4 {
                return 174
            } else {
                return 262
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
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let parameters: Parameters = [
                "email": user.profile.email,
                "key": user.authentication.idToken.encrypt(),
                "type": "google"
            ]
            login(parameters: parameters)
        }
    }
    
    @IBAction func signinAction(_ sender: Any) {
        let username: String! = tf_username.text
        let password: String! = tf_password.text
        let parameters: Parameters = [
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
            case .success( _, _, let accessToken):
                let parameters = ["fields": "id, name, email"]
                FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        if let data = result as? [String : AnyObject] {
                            if let email = data["email"] as? String {
                                let parameters: Parameters = [
                                    "email": email,
                                    "key": accessToken.authenticationToken.encrypt(),
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
            outlookService.getUserEmail() { result in
                if let email = result {
                    let token = self.outlookService.token()
                    let parameters: Parameters = [
                        "email": email,
                        "key": token!.encrypt(),
                        "type": "outlook"
                    ]
                    self.login(parameters: parameters)
                }
                self.outlookService.logout()
            }
        } else {
            outlookService.login(from: self) { (result) in
                if let token = result {
                    self.outlookService.getUserEmail() { result in
                        if let email = result {
                            let parameters: Parameters = [
                                "email": email,
                                "key": token.encrypt(),
                                "type": "outlook"
                            ]
                            self.login(parameters: parameters)
                        }
                        self.outlookService.logout()
                    }
                } else {
                    NSLog("Error logging")
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
                        appDelegate.registerForPushNotifications()
                        self.performSegue(withIdentifier: "showMain", sender: nil)
                    }
                } else {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
