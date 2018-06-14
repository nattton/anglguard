import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class PrivilegeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var privileges: [Any] = []
    var pName: String = ""
    var pLink: String = ""
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var tb_privilege: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tb_privilege.tableFooterView = nil
        
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "lang": Language.getCurrentLanguage().language()
            ]
            
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(PRIVILEGE_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            let privilege: Array = data["privilege"] as! [Any]
                            self.privileges = privilege
                            self.tb_privilege.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privileges.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pCell: PrivilegeCell = tableView.dequeueReusableCell(withIdentifier: "PrivilegeCell") as! PrivilegeCell
        
        let privilege = privileges[indexPath.row] as! [String: Any]
        let title: String! = privilege["title"] as! String
        let description: String! = privilege["description"] as! String

        if let banner: String = privilege["banner"] as? String {
            let eBanner: String! = banner.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url = URL(string: eBanner){
                pCell.banner.af_setImage(withURL: url)
            } else {
                pCell.banner.image = UIImage(named: "emergency_img_defult")
            }
        }
        
        pCell.title.text = title
        pCell.detail.text = description
        
        return pCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let privilege = privileges[indexPath.row] as! [String: Any]
        
        if let title = privilege["title"] as? String {
            pName = title
        }

        if let link: String =  privilege["link"] as? String {
            if let eLink = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                pLink = eLink
            }
        }
        
        self.performSegue(withIdentifier: "showPrivilegeDetail", sender: nil)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPrivilegeDetail" {
            let privilegeDetail: WebViewController = segue.destination as! WebViewController
            privilegeDetail.link = pLink
            privilegeDetail.navigationItem.title = pName
        }
    }

}
