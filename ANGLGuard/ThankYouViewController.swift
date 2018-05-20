import UIKit
import Alamofire
import SVProgressHUD

class ThankYouViewController: UITableViewController {
    
    @IBOutlet var lb_description: UILabel!
    @IBOutlet var bt_start: UIButton!
    
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
        lb_description.text = "thank_you".localized()
    }
    
    @IBAction func startAction(_ sender: Any) {
        if Authen.sharedInstance.type == "normal" {
            let username: String! = Personal.sharedInstance.email
            let password: String! = Personal.sharedInstance.password
            let parameters: Parameters = ["username": username, "password": password.encrypt(), "type": "normal"]
            login(parameters: parameters)
        } else {
            let email: String! = Personal.sharedInstance.email
            let key: String! = Authen.sharedInstance.key
            let type: String! = Authen.sharedInstance.type
            let parameters: Parameters = ["email": email, "key": key.encrypt(), "type": type]
            login(parameters: parameters)
        }
    }
    
    func login(parameters: Parameters) {
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        Alamofire.request(LOGIN_URL, method: .get, parameters: parameters).responseJSON { response in
            SVProgressHUD.dismiss()
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                let code: String = result["code"] as! String
                let message: String = result["message"] as! String
                NSLog("result = \(result)")
                if code == "200" {
                    if let data: Dictionary<String, Any> = result["data"]  as? Dictionary<String, Any> {
                        self.defaults.set("Y", forKey: "login")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setProfile(data: data)
                        appDelegate.mapProfile()
                        appDelegate.registerForPushNotifications()
                        self.performSegue(withIdentifier: "showAgree", sender: nil)
                    }
                } else {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
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
