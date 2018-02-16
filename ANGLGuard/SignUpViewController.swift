import UIKit
import Alamofire

class SignUpViewController: UITableViewController {

    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!
    @IBOutlet var tf_confirm: UITextField!
    @IBOutlet var bt_continue: UIButton!
    
    var email: String = ""
    var password: String = ""
    var confirm: String = ""
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func continueAction(_ sender: Any) {
        email = tf_email.text!
        password = tf_password.text!
        confirm = tf_confirm.text!
        
        if email.isValidEmail() == false {
            let alert = UIAlertController(title: "Invalid Email", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else if password.isValidPassword() == false {
            let alert = UIAlertController(title: "Invalid Password", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else if password != confirm {
            let alert = UIAlertController(title: "Password not match", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let parameters: Parameters = ["email": email]
            Alamofire.request(EMAIL_EXISTS, method: .get, parameters: parameters).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    let token: String = result["token"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        self.defaults.set(token, forKey: "token")
                        self.performSegue(withIdentifier: "showVerifyCode", sender: nil)
                    } else {
                        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerifyCode" {
            let verifyCodeView: VerifyCodeViewController = segue.destination as! VerifyCodeViewController
            verifyCodeView.email = email
        }
    }

}

extension String {
    
    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let regex = "^(?=.*\\d)(?=.*[a-z])[0-9a-z]{8,12}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
}
