import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

protocol EmergencyDelegate {
    func onEmergencyDismiss()
}

let phone_number = 1724

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: EmergencyDelegate?
    
    var photo1: UIImage?
    var photo2: UIImage?
    var photo3: UIImage?
    var photo4: UIImage?
    var message: String?
    var friends: [Any] = []
    var lat: Double = 0
    var long: Double = 0
    var friendId: String = ""
    var bt_call_center: CGFloat?
    var isCall: Bool = false
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var v_group: UIView!
    @IBOutlet var v_call: UIView!
    @IBOutlet var v_warning: UIView!
    @IBOutlet var v_friend: UIView!
    @IBOutlet var tb_friend: UITableView!
    @IBOutlet var bt_call: UIButton!
    @IBOutlet var bt_confirm: UIButton!
    
    @IBOutlet var lb_call: UILabel!
    @IBOutlet var lb_call_description: UILabel!
    @IBOutlet var lb_emergency_alert: UILabel!
    @IBOutlet var lb_emergency_term: UILabel!
    @IBOutlet var lb_emergency_term_description: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        v_call.layer.masksToBounds = false
        v_call.layer.cornerRadius = 8
        v_call.clipsToBounds = true
        
        v_group.layer.masksToBounds = false
        v_group.layer.cornerRadius = 8
        v_group.clipsToBounds = true
        
        bt_confirm.layer.masksToBounds = false
        bt_confirm.layer.cornerRadius = bt_confirm.frame.size.height / 2
        bt_confirm.clipsToBounds = true
        
        bt_call_center = bt_call.center.x
        
        getFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        lb_call.text = "emergency_call_1724".localized()
        lb_call_description.text = "emergency_emergency".localized()
        lb_emergency_alert.text = "emergency_send_emergency".localized()
        lb_emergency_term.text = "emergency_term".localized()
        lb_emergency_term_description.text = "emergency_please_make".localized()
        bt_confirm.setTitle("bnt_confirm".localized(), for: .normal)
    }
    
    //list friend
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gCell: GroupAlertCell = tableView.dequeueReusableCell(withIdentifier: "GroupAlertCell") as! GroupAlertCell
        let friend = friends[indexPath.row] as! [String: Any]
        let img: String! = friend["personal_image_path"] as! String
        let firstname: String! = friend["firstname"] as! String
        let lastname: String! = friend["lastname"] as! String
        
        let eImg: String! = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: eImg){
            gCell.avatar.af_setImage(withURL: url)
        } else {
            gCell.avatar.image = UIImage(named: "ic_avatar")
        }
        
        gCell.avatar.layer.masksToBounds = false
        gCell.avatar.layer.cornerRadius = gCell.avatar.frame.height / 2
        gCell.avatar.clipsToBounds = true
        
        gCell.name.text = firstname + " " + lastname
        
        return gCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row] as! [String: Any]
        if let id: String = friend["id"] as? String {
            friendId = id
            callBESAlert()
        }
    }
    
    func getFriends() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token
            ]
            Alamofire.request(FAMILY_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            let member: Array = data["member"] as! [Any]
                            self.friends = member
                            self.tb_friend.reloadData()
                        }
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
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
    
    func callBESAlert() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "request_user_id": friendId,
                "message": message!,
                "image1": photo1 as Any,
                "image2": photo2 as Any,
                "image3": photo3 as Any,
                "image4": photo4 as Any,
                "latitude": String(lat),
                "longitude": String(long)
            ]
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(BES_ALERT_URL, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: false) {
                                if self.delegate != nil {
                                    self.delegate?.onEmergencyDismiss()
                                }
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
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
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y)
            
            if isCall == false {
                if translation.x > 20 {
                    isCall = true
                }
            }
            
            if recognizer.state == .ended {
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = CGPoint(x: self.bt_call_center!, y: view.center.y)
                }, completion: { (succes) in
                    if self.isCall == true {
                        self.emergencyCall()
                        self.isCall = false
                    }
                })
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func emergencyCall() {
        if let url = URL(string: "tel://\(phone_number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        v_warning.isHidden = true
        v_friend.isHidden = false
    }
    @IBAction func callBESAlertAction(_ sender: Any) {
        callBESAlert()
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
