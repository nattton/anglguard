import UIKit
import Alamofire
import AlamofireImage

class GroupAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if let image = defaults.string(forKey: "image") {
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
        
        if let firstname = defaults.string(forKey: "firstname"), let lastname = defaults.string(forKey: "lastname") {
            lb_profile_name.text = firstname + " " + lastname
        } else {
            lb_profile_name.text = "-"
        }
        
        getFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            let member: Array = data["member"] as! [Any]
                            self.friends = member
                            self.tb_friend.reloadData()
                        }
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
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
                "image1": photo1 as Any,
                "image2": photo2 as Any,
                "image3": photo3 as Any,
                "image4": photo4 as Any,
                "latitude": String(lat),
                "longitude": String(long)
            ]
            
            Alamofire.request(SEND_ALERT_URL, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    }
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
