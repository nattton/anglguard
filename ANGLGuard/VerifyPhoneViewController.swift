import UIKit
import Alamofire

class VerifyPhoneViewController: UITableViewController {
    
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var tf_code: UITextField!
    
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
    
    @IBAction func laterAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showStep3", sender: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            
            let parameters: Parameters = [
                "tel_code": country_code,
                "tel_num": phone,
                "token": token
            ]
            
            Alamofire.request(SMS_SEND_CODE, method: .get, parameters: parameters).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        self.performSegue(withIdentifier: "showStep1", sender: nil)
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token") {
            let country_code: String = tf_country_code.text!
            let phone: String = tf_phone.text!
            let code: String = tf_code.text!
            
            let parameters: Parameters = [
                "tel_code": country_code,
                "tel_num": phone,
                "code": code,
                "token": token
            ]
            
            Alamofire.request(SMS_VERIFY_CODE, method: .get, parameters: parameters).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        self.performSegue(withIdentifier: "showStep3", sender: nil)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
