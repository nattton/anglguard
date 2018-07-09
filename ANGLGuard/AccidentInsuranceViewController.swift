import UIKit

class AccidentInsuranceViewController: UITableViewController {
    
    @IBOutlet var lb_description: UILabel!
    @IBOutlet var bt_yes: UIButton!
    @IBOutlet var bt_no: UIButton!
    
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
        lb_description.text = "signup_have_insurance".localized()
        bt_yes.setTitle("bnt_yes".localized(), for: .normal)
        bt_no.setTitle("bnt_no".localized(), for: .normal)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesAction(_ sender: Any) {
        if let flag = defaults.string(forKey: "flag"), flag == "1" {
            self.performSegue(withIdentifier: "showInsurancePlan", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showInsurancePolicy", sender: nil)
        }
    }
    
    @IBAction func noAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showInsurancePlan", sender: nil)
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
