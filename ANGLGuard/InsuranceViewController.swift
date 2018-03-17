import UIKit
import Alamofire
import SVProgressHUD

class InsuranceViewController: UITableViewController {
    
    @IBOutlet var tf_policy_number: UITextField!
    @IBOutlet var tf_expire_date: UITextField!
    @IBOutlet var tf_insurance_company: UITextField!
    @IBOutlet var tf_contact_name: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    
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
        
        tf_policy_number.text = Insurance.sharedInstance.policy_number
        tf_expire_date.text = Insurance.sharedInstance.expiration_date
        tf_insurance_company.text = Insurance.sharedInstance.insurance_company
        tf_contact_name.text = Insurance.sharedInstance.contact_name
        tf_country_code.text = Insurance.sharedInstance.contact_number_cc
        tf_phone.text = Insurance.sharedInstance.contact_number
    }
    
    func setText() {
        tf_policy_number.placeholder = "signup_policy_number".localized()
        tf_expire_date.placeholder = "signup_expiration_date".localized()
        tf_insurance_company.placeholder = "signup_insurance_company".localized()
        tf_contact_name.placeholder = "signup_conntact_name".localized()
        tf_country_code.placeholder = "signup_country".localized()
        tf_phone.placeholder = "signup_contact_number".localized()
        self.title = "sub_insurance".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
