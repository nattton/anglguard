import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class EmergencyContactProfileViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var tf_firstname: UITextField!
    @IBOutlet var tf_lastname: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var tf_relationship: UITextField!
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var bt_update: UIButton!
    
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
        
        tf_firstname.text = Contact.sharedInstance.firstname
        tf_lastname.text = Contact.sharedInstance.lastname
        tf_country_code.text = Contact.sharedInstance.contact_number_cc
        tf_phone.text = Contact.sharedInstance.contact_number
        tf_relationship.text = Contact.sharedInstance.relation
        tf_email.text = Contact.sharedInstance.email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        tf_firstname.placeholder = "signup_first_name".localized()
        tf_lastname.placeholder = "signup_last_name".localized()
        tf_country_code.placeholder = "signup_country".localized()
        tf_phone.placeholder = "signup_contact_number".localized()
        tf_relationship.placeholder = "signup_relationship".localized()
        tf_email.placeholder = "signup_email".localized()
        bt_update.setTitle("bnt_update".localized(), for: .normal)
        self.title = "sub_contact".localized()
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
    
    @IBAction func updateAction(_ sender: Any) {
        let firstname: String = tf_firstname.text!
        let lastname: String = tf_lastname.text!
        let country_code: String = tf_country_code.text!
        let phone: String = tf_phone.text!
        let relationship: String = tf_relationship.text!
        let email: String = tf_email.text!
        
        if firstname.count == 0 {
            showAlert(message: "signup_insert_first_name".localized())
        } else if lastname.count == 0 {
            showAlert(message: "signup_insert_last_name".localized())
        } else if country_code.count == 0 {
            showAlert(message: CC_ALERT)
        } else if phone.count == 0 {
            showAlert(message: "signup_fill_mobile_number".localized())
        } else if relationship.count == 0 {
            showAlert(message: RELATION_SHIP_ALERT)
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "contact_person": [
                        "firstname": firstname,
                        "middlename": "",
                        "lastname": lastname,
                        "contact_number": phone,
                        "contact_number_cc": country_code,
                        "relation": relationship,
                        "email": email
                    ]
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_PROFILE_CONTACT, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        NSLog("result = \(result)")
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        if code == "200" {
                            //data
                            Contact.sharedInstance.firstname = firstname
                            Contact.sharedInstance.lastname = lastname
                            Contact.sharedInstance.contact_number_cc = country_code
                            Contact.sharedInstance.contact_number = phone
                            Contact.sharedInstance.relation = relationship
                            Contact.sharedInstance.email = email
                            
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
