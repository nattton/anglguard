import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var friends: [Any] = []
    let defaults = UserDefaults.standard
    
    @IBOutlet var tb_friend: UITableView!
    @IBOutlet var bt_add_friend: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bt_add_friend.layer.masksToBounds = false
        bt_add_friend.layer.cornerRadius = bt_add_friend.frame.size.height / 2
        bt_add_friend.clipsToBounds = true
        
        list()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        self.title = "group_title".localized()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fCell: FriendCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendCell
        let friend = friends[indexPath.row] as! [String: Any]
        let img: String! = friend["personal_image_path"] as! String
        let firstname: String! = friend["firstname"] as! String
        let lastname: String! = friend["lastname"] as! String
        let email: String! = friend["email"] as! String
        
        let eImg: String! = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: eImg){
            fCell.avatar.af_setImage(withURL: url)
        } else {
            fCell.avatar.image = UIImage(named: "ic_avatar")
        }
        
        fCell.avatar.rounded()
        
        fCell.name.text = firstname + " " + lastname
        fCell.email.text = email
        fCell.more.tag = indexPath.row
        fCell.more.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
        
        if indexPath.row % 2 == 0 {
            fCell.backgroundColor = UIColor.white
        } else {
            fCell.backgroundColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        }
        
        return fCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            confirm(index: indexPath.row)
        }
    }
    
    func list() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token
            ]
            
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(FAMILY_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
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
    
    func confirm(index: Int) {
        let alert = UIAlertController(title: "group_del_desc".localized(), message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "bnt_confirm".localized(), style: .default, handler: { (action) in
            let friend = self.friends[index] as! [String: Any]
            let id: String! = friend["id"] as! String
            self.delete(friend_id: id, index: index)
        }))
        
        alert.addAction(UIAlertAction(title: "bnt_cancel".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func delete(friend_id: String, index: Int) {
        if let token = defaults.string(forKey: "token"), let id = defaults.string(forKey: "id") {
            let parameters: Parameters = [
                "token": token,
                "id": id,
                "friend_id": friend_id
            ]
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(FAMILY_DELETE_URL, method: .post, parameters: parameters).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        self.friends.remove(at: index)
                        self.tb_friend.reloadData()
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
    
    @IBAction func showMore(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "bnt_delete".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.confirm(index: index)
        })
        let cancelAction = UIAlertAction(title: "bnt_cancel".localized(), style: .cancel, handler: nil)
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func showQRCode(_ sender: Any) {
        let profileQRCodeView = storyboard?.instantiateViewController(withIdentifier: "QRCode")
        profileQRCodeView?.modalTransitionStyle = .crossDissolve
        profileQRCodeView?.modalPresentationStyle = .overCurrentContext
        self.present(profileQRCodeView!, animated: true, completion: nil)
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

extension UIImageView {
    
    func rounded() {
        let radius = self.frame.size.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
