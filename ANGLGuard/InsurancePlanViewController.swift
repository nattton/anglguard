import UIKit
import Alamofire
import SVProgressHUD

class InsurancePlanViewController: UITableViewController {
    
    @IBOutlet var bt_back: UIButton!
    
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
        bt_back.setTitle("bnt_back".localized(), for: .normal)
    }
    
    @IBAction func planAction(_ sender: Any) {
        let button = sender as! UIButton
        let tag = button.tag
        var plan: String = ""
        let duration: Int = Int(Trip.sharedInstance.duration)!
        
        if duration > 7 {
            if tag == 1 {
                plan = "04"
            } else if tag == 2 {
                plan = "05"
            } else if tag == 3 {
                plan = "06"
            }
        } else {
            if tag == 1 {
                plan = "01"
            } else if tag == 2 {
                plan = "02"
            } else if tag == 3 {
                plan = "03"
            }
        }
        
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "plan": plan,
                "token": token
            ]
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(BOOK_INSURANCE_VIRIYAH, method: .post, parameters: parameters).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        self.performSegue(withIdentifier: "showViriyah", sender: nil)
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
