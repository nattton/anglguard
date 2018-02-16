import UIKit

class Step4ViewController: UITableViewController {

    @IBOutlet var tf_blood_type: UITextField!
    @IBOutlet var tf_drug: UITextField!
    @IBOutlet var tf_food: UITextField!
    @IBOutlet var tf_chemical: UITextField!
    @IBOutlet var tf_underlying: UITextField!
    @IBOutlet var tf_medication: UITextField!
    @IBOutlet var tf_special_care: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
//        let passport: String = tf_passport.text!
//        let country: String = tf_country.text!
//        let expire_date: String = tf_expire_date.text!
//        
//        if passport.count > 0 && country.count > 0 && expire_date.count > 0 && isImage == true {
//            self.performSegue(withIdentifier: "showStep6", sender: nil)
//        }
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
