import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class VerifyPhoneViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var lb_caution: UILabel!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var bt_skip: UIButton!
    @IBOutlet var lb_verify_code: UILabel!
    @IBOutlet var bt_send_code: UIButton!
    @IBOutlet var tf_code: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_verify: UIButton!
    
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
        
        tf_country_code.text = countryCode(code: Personal.sharedInstance.thai_mobile_cc)
        tf_phone.text = Personal.sharedInstance.thai_mobile_num
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_caution.text = "signup_caution".localized()
        tf_phone.placeholder = "signup_current_phone_number".localized()
        bt_send_code.setTitle("signup_send_code".localized(), for: .normal)
        lb_verify_code.text = "signup_please_enter_your_otp".localized()
        tf_code.placeholder = "signup_code".localized()
        bt_verify.setTitle("signup_verify_code".localized(), for: .normal)
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_skip.setTitle("bnt_skip".localized(), for: .normal)
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
    
    @IBAction func skipAction(_ sender: Any) {
        let country_code: String = tf_country_code.text!
        let phone: String = tf_phone.text!
        
        //data
        Personal.sharedInstance.thai_mobile_cc = country_code
        Personal.sharedInstance.thai_mobile_num = phone
        
        self.performSegue(withIdentifier: "showStep3", sender: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            
            if country_code.count == 0 {
                showAlert(message: CC_ALERT)
            } else if phone.count == 0 {
                showAlert(message: "signup_fill_mobile_number".localized())
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
                            
                            self.performSegue(withIdentifier: "showStep3", sender: nil)
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func verifyAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            let code: String = tf_code.text!
            
            if country_code.count == 0 {
                showAlert(message: CC_ALERT)
            } else if phone.count == 0 {
                showAlert(message: "signup_fill_mobile_number".localized())
            } else if code.count == 0 {
                showAlert(message: CODE_NOT_VALID)
            } else {
                let parameters: Parameters = [
                    "tel_code": country_code,
                    "tel_num": phone,
                    "code": code,
                    "token": token
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SMS_VERIFY_CODE, method: .get, parameters: parameters).responseJSON { response in
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
                            
                            self.performSegue(withIdentifier: "showStep3", sender: nil)
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
    
    func countryCode(code: String) -> String {
        let CallingCodes = { () -> [[String: String]] in
            let resourceBundle = Bundle(for: ADCountryPicker.classForCoder())
            guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
            return NSArray(contentsOfFile: path) as! [[String: String]]
        }
        
        let countryData = CallingCodes().filter { $0["code"] == code }
        
        if countryData.count > 0 {
            let countryCode: String = countryData[0]["dial_code"] ?? ""
            return countryCode
        } else {
            return code
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
