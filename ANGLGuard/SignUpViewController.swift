import UIKit
import Alamofire
import SVProgressHUD

class SignUpViewController: UITableViewController {

    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!
    @IBOutlet var tf_confirm: UITextField!
    @IBOutlet var bt_continue: UIButton!
    
    var email: String = ""
    var password: String = ""
    var confirm: String = ""
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func continueAction(_ sender: Any) {
        email = tf_email.text!
        password = tf_password.text!
        confirm = tf_confirm.text!
        
        if email.isValidEmail() == false {
            showAlert(message: "Invalid Email")
        } else if password.isValidPassword() == false {
            showAlert(message: "Invalid Password")
        } else if password != confirm {
            showAlert(message: "Password not match")
        } else {
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
                        Personal.sharedInstance.email = self.email
                        Personal.sharedInstance.password = self.password
                        
                        self.performSegue(withIdentifier: "showVerifyCode", sender: nil)
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    } else {
                        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerifyCode" {
            let verifyCodeView: VerifyCodeViewController = segue.destination as! VerifyCodeViewController
            verifyCodeView.email = email
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
