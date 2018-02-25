import UIKit
import Alamofire
import AlamofireImage

class AddFriendsViewController: UIViewController {

    let defaults = UserDefaults.standard
    var friend_id: Int = 0
    
    @IBOutlet var tf_search: UITextField!
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var bt_add: UIButton!
    @IBOutlet var v_result: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func searchAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token"), let id = defaults.string(forKey: "id") {
            let search: String = tf_search.text!
            let parameters: Parameters = [
                "token": token,
                "id": id,
                "name": search
            ]
            
            Alamofire.request(FAMILY_SEARCH_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            if let members: Array = data["member"] as? [Any] {
                                let member = members[0] as! [String: Any]
                                let id: Int = member["id"] as! Int
                                let firstname: String = member["firstname"] as! String
                                let lastname: String = member["lastname"] as! String
                                let img: String = member["image"] as! String
                                
                                let eImg: String! = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                if let url = URL(string: HOST + eImg){
                                    self.avatar.af_setImage(withURL: url)
                                } else {
                                    self.avatar.image = UIImage(named: "ic_avatar")
                                }
                                
                                self.friend_id = id
                                
                                self.name.text = firstname + " " + lastname
                                self.avatar.isHidden = false
                                self.name.isHidden = false
                                self.bt_add.isHidden = false
                                self.v_result.isHidden = false
                            }
                        }
                    } else if code == "102" {
                        self.name.text = message
                        self.avatar.isHidden = true
                        self.name.isHidden = false
                        self.bt_add.isHidden = true
                        self.v_result.isHidden = false
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
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
    
    @IBAction func addAction(_ sender: Any) {
        if let token = defaults.string(forKey: "token"), let id = defaults.string(forKey: "id") {
            let parameters: Parameters = [
                "token": token,
                "id": id,
                "friend_id": friend_id
            ]
            
            Alamofire.request(FAMILY_ADD_URL, method: .post, parameters: parameters).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        self.navigationController?.popViewController(animated: true)
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
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
