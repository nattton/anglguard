import UIKit
import Alamofire
import SVProgressHUD

class ChangePasswordViewController: UITableViewController {
    
    @IBOutlet var tf_current_password: UITextField!
    @IBOutlet var tf_new_password: UITextField!
    @IBOutlet var tf_re_new_password: UITextField!
    @IBOutlet var bt_update: UIButton!
    
    var current_password: String = ""
    var new_password: String = ""
    var re_new_password: String = ""
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        tf_current_password.placeholder = "pass_current".localized()
        tf_new_password.placeholder = "pass_new".localized()
        tf_re_new_password.placeholder = "pass_re".localized()
        bt_update.setTitle("bnt_update".localized(), for: .normal)
        self.title = "sub_change_password".localized()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        current_password = tf_current_password.text!
        new_password = tf_new_password.text!
        re_new_password = tf_re_new_password.text!
        
        if current_password.isEmpty {
            showAlert(message: "Please fill current password")
        } else if new_password.isValidPassword() == false {
            showAlert(message: "Invalid Password")
        } else if new_password != re_new_password {
            showAlert(message: "Password not match")
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "current_password": current_password.encrypt(),
                    "new_password": new_password.encrypt()
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_NEW_PASSWORD, method: .post, parameters: parameters).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        NSLog("result = \(result)")
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        if code == "200" {
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
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
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func showQRCode(_ sender: Any) {
        let profileQRCodeView = storyboard?.instantiateViewController(withIdentifier: "QRCode")
        profileQRCodeView?.modalTransitionStyle = .crossDissolve
        profileQRCodeView?.modalPresentationStyle = .overCurrentContext
        self.present(profileQRCodeView!, animated: true, completion: nil)
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
