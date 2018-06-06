import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

protocol GroupAlertDelegate {
    func onGroupAlertDismiss()
}

class GroupAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: GroupAlertDelegate?
    
    var photo1: UIImage?
    var photo2: UIImage?
    var photo3: UIImage?
    var photo4: UIImage?
    var message: String?
    var friends: [Any] = []
    var lat: Double = 0
    var long: Double = 0
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var v_profile: UIView!
    @IBOutlet var v_group: UIView!
    @IBOutlet var tb_friend: UITableView!
    @IBOutlet var bt_confirm: UIButton!
    @IBOutlet var im_profile_avatar: UIImageView!
    @IBOutlet var lb_profile_name: UILabel!
    @IBOutlet var lb_emergency_alert: UILabel!
    @IBOutlet var lb_emergency_member: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        v_profile.layer.masksToBounds = false
        v_profile.layer.cornerRadius = 8
        v_profile.clipsToBounds = true
        
        v_group.layer.masksToBounds = false
        v_group.layer.cornerRadius = 8
        v_group.clipsToBounds = true
        
        im_profile_avatar.layer.masksToBounds = false
        im_profile_avatar.layer.cornerRadius = im_profile_avatar.frame.size.height / 2
        im_profile_avatar.clipsToBounds = true
        
        bt_confirm.layer.masksToBounds = false
        bt_confirm.layer.cornerRadius = bt_confirm.frame.size.height / 2
        bt_confirm.clipsToBounds = true
        
        if let image = defaults.string(forKey: "personal_img_bin") {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("avatar.jpg")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(image, to: destination).response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    self.im_profile_avatar.image = image
                }
            }
        }
        
        lb_profile_name.text = Personal.sharedInstance.firstname + " " + Personal.sharedInstance.lastname + "\n" + Personal.sharedInstance.email
        
        getFriends()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        self.navigationItem.title = "emergency_send_emergency".localized()
        lb_emergency_alert.text = "emergency_send_emergency".localized()
        lb_emergency_member.text = "emergency_member_colon".localized()
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
        let email: String! = friend["email"] as! String
        
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
        gCell.email.text = email
        
        return gCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                            let userId = self.defaults.string(forKey: "id")!
                            self.friends = member.filter({ (obj) -> Bool in
                                if let object = obj as? [String: Any] {
                                    if let id = object["id"] as? String {
                                        return id != userId
                                    }
                                }
                                return false
                            })
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
                        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func sendAlert() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "message": message!,
                "latitude": String(lat),
                "longitude": String(long)
            ]
            
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]
            
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in parameters {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                
                let time = Date().millisecondsSince1970
                
                if let data1 = self.photo1?.resizeImage(200, opaque: false).toData() {
                    multipartFormData.append(data1, withName: "image1", fileName: "1\(time).png", mimeType: "image/png")
                }
                
                if let data2 = self.photo2?.resizeImage(200, opaque: false).toData() {
                    multipartFormData.append(data2, withName: "image2", fileName: "2\(time).png", mimeType: "image/png")
                }
                
                if let data3 = self.photo3?.resizeImage(200, opaque: false).toData() {
                    multipartFormData.append(data3, withName: "image3", fileName: "3\(time).png", mimeType: "image/png")
                }
                
                if let data4 = self.photo4?.resizeImage(200, opaque: false).toData() {
                    multipartFormData.append(data4, withName: "image4", fileName: "4\(time).png", mimeType: "image/png")
                }
                
            }, usingThreshold: UInt64.init(), to: SEND_ALERT_URL, method: .post, headers: headers) { (result) in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let json = response.result.value {
                            let result = json as! Dictionary<String, Any>
                            let code: String = result["code"] as! String
                            let message: String = result["message"] as! String
                            NSLog("result = \(result)")
                            if code == "200" {
//                                let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: { (action) in
//                                    self.dismiss(animated: false) {
//                                        if self.delegate != nil {
//                                            self.delegate?.onGroupAlertDismiss()
//                                        }
//                                    }
//                                }))
//                                self.present(alert, animated: true, completion: nil)
                                
                                self.dismiss(animated: false) {
                                    if self.delegate != nil {
                                        self.delegate?.onGroupAlertDismiss()
                                    }
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
                                let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                                alert.addAction(defaultAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        sendAlert()
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
