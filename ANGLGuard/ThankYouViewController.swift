import UIKit
import Alamofire
import SVProgressHUD

class ThankYouViewController: UITableViewController {

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
    
    @IBAction func startAction(_ sender: Any) {
        if Authen.sharedInstance.type == "normal" {
            let username: String! = Personal.sharedInstance.email
            let password: String! = Personal.sharedInstance.password
            let parameters: Parameters = ["username": username, "password": password]
            login(parameters: parameters)
        } else {
            let email: String! = Personal.sharedInstance.email
            let key: String! = Authen.sharedInstance.key
            let type: String! = Authen.sharedInstance.type
            let parameters: Parameters = ["email": email, "key": key, "type": type]
            login(parameters: parameters)
        }
    }
    
    func login(parameters: Parameters) {
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        Alamofire.request(EMAIL_EXISTS, method: .get, parameters: parameters).responseJSON { response in
            SVProgressHUD.dismiss()
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                NSLog("result = \(result)")
                let code: String = result["code"] as! String
                let message: String = result["message"] as! String
                if code == "200" {
                    if let data: Dictionary<String, Any> = result["data"]  as? Dictionary<String, Any> {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setProfile(data: data)
                        appDelegate.registerForPushNotifications()
                        self.performSegue(withIdentifier: "showMain", sender: nil)
                    }
                } else {
                    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
