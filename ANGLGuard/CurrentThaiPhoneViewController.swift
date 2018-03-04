import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class CurrentThaiPhoneViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var tf_code: UITextField!
    
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
        
        tf_country_code.text = Personal.sharedInstance.thai_mobile_cc
        tf_phone.text = Personal.sharedInstance.thai_mobile_num
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tf_country_code {
            showCountryPicker()
            return false
        } else {
            return true
        }
    }
    
    func showCountryPicker() {
        let picker = ADCountryPicker()
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.dismiss(animated: true, completion: {
                self.tf_country_code.text = dialCode
            })
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            
            if country_code.count == 0 {
                showAlert(message: CC_ALERT)
            } else if phone.count == 0 {
                showAlert(message: MOBILE_NUMBER_ALERT)
            } else {
                let parameters: Parameters = [
                    "tel_code": country_code,
                    "tel_num": phone,
                    "token": token
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SMS_SEND_CODE, method: .get, parameters: parameters).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        NSLog("result = \(result)")
                        if code == "200" {
                            //data
                            Personal.sharedInstance.thai_mobile_cc = country_code
                            Personal.sharedInstance.thai_mobile_num = phone
                            
                            self.performSegue(withIdentifier: "showStep1", sender: nil)
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
    }
    
    @IBAction func updateAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            let code: String = tf_code.text!
            
            if country_code.count == 0 {
                showAlert(message: CC_ALERT)
            } else if phone.count == 0 {
                showAlert(message: MOBILE_NUMBER_ALERT)
            } else if code.count == 0 {
                showAlert(message: CODE_NOT_VALID)
            } else {
                let parameters: Parameters = [
                    "tel_code": country_code,
                    "tel_num": phone,
                    "code": code,
                    "token": token
                ]
                
                //data
                Personal.sharedInstance.thai_mobile_cc = country_code
                Personal.sharedInstance.thai_mobile_num = phone
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
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
