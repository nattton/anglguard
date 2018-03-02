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
        let username: String! = Personal.sharedInstance.email
        let password: String! = Personal.sharedInstance.password
        let parameters: Parameters = ["username": username, "password": password]
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
                        let personal = data["personal"]  as! Dictionary<String, Any>
                        self.setProfile(data: personal)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    
    func setProfile(data: Dictionary<String, Any>) {
        let defaults = UserDefaults.standard
        let id: String? = data["id"] as? String
        let image: String? = data["personal_img_bin"] as? String
        let link: String? = data["personal_link"] as? String
        let title: String? = data["title"] as? String
        let firstname: String? = data["first_name"] as? String
        let lastname: String? = data["last_name"] as? String
        let email: String? = data["email"] as? String
        let gender: String? = data["gender"] as? String
        let birthday: String? = data["date_of_birth"] as? String
        let height: String? = data["height"] as? String
        let weight: String? = data["weight"] as? String
        let token: String? = data["token"] as? String
        
        defaults.set(id, forKey: "id")
        defaults.set(image, forKey: "image")
        defaults.set(link, forKey: "link")
        defaults.set(title, forKey: "title")
        defaults.set(firstname, forKey: "firstname")
        defaults.set(lastname, forKey: "lastname")
        defaults.set(email, forKey: "email")
        defaults.set(gender, forKey: "gender")
        defaults.set(birthday, forKey: "birthday")
        defaults.set(height, forKey: "height")
        defaults.set(weight, forKey: "weight")
        defaults.set(token, forKey: "token")
        defaults.set("Y", forKey: "login")
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
