import UIKit
import Alamofire
import SVProgressHUD

class VerifyCodeViewController: UITableViewController {
    
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var bt_send: UIButton!
    @IBOutlet var tf_verify_code: UITextField!
    @IBOutlet var lb_verify_code: UILabel!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var email: String = ""
    var code: String = ""
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
        
        setText()
        
        if Authen.sharedInstance.type == "wechat" {
            tf_email.borderStyle = .roundedRect
            tf_email.isUserInteractionEnabled = true
            tf_email.textColor = .black
        } else {
            tf_email.text = email
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        tf_email.placeholder = "login_email".localized()
        bt_send.setTitle("signup_send_code".localized(), for: .normal)
        lb_verify_code.text = "signup_please_enter".localized()
        tf_verify_code.placeholder = "signup_code".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        email = tf_email.text!
        if email.isValidEmail() == false {
            showAlert(message: "login_email_not_format".localized())
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
                        
                        let alert = UIAlertController(title: "signup_send_code_complete".localized(), message: "", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
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
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        verfyCode()
    }
    
    func verfyCode() {
        code = tf_verify_code.text!
        if code.count != 6 {
            let alert = UIAlertController(title: CODE_NOT_VALID, message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "email": email,
                    "code": code,
                    "token": token
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(EMAIL_VERIFY, method: .get, parameters: parameters).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        NSLog("result = \(result)")
                        if code == "200" {
                            if let data: Dictionary<String, Any> = result["data"]  as? Dictionary<String, Any> {
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.setProfile(data: data)
                                appDelegate.mapProfile()
                            }
                            
                            Authen.sharedInstance.token = token
                            
                            self.defaults.set(token, forKey: "token")
                            self.performSegue(withIdentifier: "showStep1", sender: nil)
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
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
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
