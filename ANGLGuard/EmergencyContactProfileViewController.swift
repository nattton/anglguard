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
            showAlert(message: FIRSTNAME_ALERT)
        } else if lastname.count == 0 {
            showAlert(message: LASTNAME_ALERT)
        } else if country_code.count == 0 {
            showAlert(message: CC_ALERT)
        } else if phone.count == 0 {
            showAlert(message: MOBILE_NUMBER_ALERT)
        } else if relationship.count == 0 {
            showAlert(message: RELATION_SHIP_ALERT)
        } else {
            //data
            Contact.sharedInstance.firstname = firstname
            Contact.sharedInstance.lastname = lastname
            Contact.sharedInstance.contact_number_cc = country_code
            Contact.sharedInstance.contact_number = phone
            Contact.sharedInstance.relation = relationship
            Contact.sharedInstance.email = email
        }
        
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
