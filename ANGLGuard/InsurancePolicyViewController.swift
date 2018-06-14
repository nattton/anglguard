import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class InsurancePolicyViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var lb_description: UILabel!
    @IBOutlet var tf_policy_number: UITextField!
    @IBOutlet var tf_expire_date: UITextField!
    @IBOutlet var tf_insurance_company: UITextField!
    @IBOutlet var tf_contact_name: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var datePicker: UIDatePicker?
    
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
        
        tf_policy_number.layer.borderColor = UIColor.red.cgColor
        tf_policy_number.layer.borderWidth = 2
        tf_policy_number.layer.cornerRadius = 4
        
        tf_expire_date.layer.borderColor = UIColor.red.cgColor
        tf_expire_date.layer.borderWidth = 2
        tf_expire_date.layer.cornerRadius = 4
        
        tf_insurance_company.layer.borderColor = UIColor.red.cgColor
        tf_insurance_company.layer.borderWidth = 2
        tf_insurance_company.layer.cornerRadius = 4
        
        tf_contact_name.layer.borderColor = UIColor.red.cgColor
        tf_contact_name.layer.borderWidth = 2
        tf_contact_name.layer.cornerRadius = 4
        
        tf_country_code.layer.borderColor = UIColor.red.cgColor
        tf_country_code.layer.borderWidth = 2
        tf_country_code.layer.cornerRadius = 4
        
        tf_phone.layer.borderColor = UIColor.red.cgColor
        tf_phone.layer.borderWidth = 2
        tf_phone.layer.cornerRadius = 4
        
        tf_expire_date.inputView = createDatePicker()
        tf_expire_date.inputAccessoryView = createDateToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_description.text = "signup_please_fulfill".localized()
        tf_policy_number.placeholder = "signup_policy_number".localized()
        tf_expire_date.placeholder = "signup_expiration_date".localized()
        tf_insurance_company.placeholder = "signup_insurance_company".localized()
        tf_contact_name.placeholder = "signup_conntact_name".localized()
        tf_phone.placeholder = "signup_contact_number".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tf_country_code {
            showCountryPicker()
            return false
        } else {
            return true
        }
    }
    
    func createDatePicker() -> UIDatePicker {
        if datePicker == nil {
            datePicker = UIDatePicker()
            datePicker!.datePickerMode = .date
            datePicker!.calendar = Calendar(identifier: .gregorian)
            datePicker!.locale = Locale(identifier: "en")
            datePicker!.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        }
        
        return datePicker!
    }
    
    func createDateToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let closeButton = UIBarButtonItem(title: "bnt_close".localized(), style: .done, target: self, action: #selector(closeDate))
        closeButton.accessibilityLabel = "bnt_close".localized()
        let doneButton = UIBarButtonItem(title: "bnt_done".localized(), style: .done, target: self, action: #selector(doneDate))
        doneButton.accessibilityLabel = "bnt_done".localized()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeDate() {
        tf_expire_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
    }
    
    @objc func doneDate() {
        tf_expire_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
        updateDate()
    }
    
    @objc func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        formatter.dateFormat = "dd/MM/yyyy"
        let date_result = formatter.string(from: (datePicker?.date)!)
        tf_expire_date.text = date_result
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let policy_number: String = tf_policy_number.text!
            let expiration_date: String = tf_expire_date.text!
            let insurance_company: String = tf_insurance_company.text!
            let contact_name: String = tf_contact_name.text!
            let contact_number_cc: String = tf_country_code.text!
            let contact_number: String = tf_phone.text!
            
            if policy_number.count == 0  {
                showAlert(message: "signup_fill_policy_number".localized())
            } else if expiration_date.count == 0  {
                showAlert(message: "signup_fill_policy_expire_date".localized())
            } else if insurance_company.count == 0  {
                showAlert(message: "signup_fill_policy_company".localized())
            } else if contact_name.count == 0  {
                showAlert(message: "signup_fill_policy_contact".localized())
            } else if contact_number_cc.count == 0  {
                showAlert(message: CC_ALERT)
            } else if contact_number.count == 0  {
                showAlert(message: "signup_fill_policy_mobile_number".localized())
            } else {
                let parameters: Parameters = [
                    "policy_number": policy_number,
                    "expiration_date": expiration_date,
                    "insurance_company": insurance_company,
                    "contact_name": contact_name,
                    "contact_number_cc": contact_number_cc,
                    "contact_number": contact_number,
                    "token": token
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_INSURANCE_POLICY, method: .post, parameters: parameters).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        NSLog("result = \(result)")
                        if code == "200" {
                            self.performSegue(withIdentifier: "showAsiaPay", sender: nil)
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
