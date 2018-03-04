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
        
        tf_policy_number.text = Insurance.sharedInstance.policy_number
        tf_expire_date.text = Insurance.sharedInstance.expiration_date
        tf_insurance_company.text = Insurance.sharedInstance.insurance_company
        tf_contact_name.text = Insurance.sharedInstance.contact_name
        tf_country_code.text = Insurance.sharedInstance.contact_number_cc
        tf_phone.text = Insurance.sharedInstance.contact_number
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
