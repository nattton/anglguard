import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class LearnFirstAidViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var first_aids: [Any] = []
    var first_aid_id: Int = 0
    let defaults = UserDefaults.standard
    
    @IBOutlet var tb_first_aid: UITableView!
    @IBOutlet var tf_search: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        getFirstAids()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        tf_search.placeholder = "aid_search".localized()
        self.title = "aid_header".localized()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return first_aids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fCell: FirstAidCell = tableView.dequeueReusableCell(withIdentifier: "FirstAidCell") as! FirstAidCell
        let first_aid = first_aids[indexPath.row] as! [String: Any]
        
        if let icon: String = first_aid["icon"] as? String {
            let eIcon: String! = icon.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url = URL(string: eIcon){
                fCell.icon?.af_setImage(withURL: url)
            } else {
                fCell.icon?.image = UIImage(named: "im_avatar")
            }
        }
        
        if let title: String = first_aid["title"] as? String {
            fCell.title?.text = title
        }
        
        if let description: String = first_aid["description"] as? String {
            fCell.detail?.text = description
        }
        
        return fCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let first_aid = first_aids[indexPath.row] as! [String: Any]
        let id: Int! = first_aid["id"] as! Int
        first_aid_id = id
        
        self.performSegue(withIdentifier: "showLearnFirstAidDetail", sender: nil)
    }
    
    func getFirstAids() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "lang": Language.getCurrentLanguage().language()
            ]
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(FIRSTAID_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            if let first_aid: Array = data["first_aid"] as? [Any] {
                                self.first_aids = first_aid
                                self.tb_first_aid.reloadData()
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
        if segue.identifier == "showLearnFirstAidDetail" {
            let learnFirstAidDetail: LearnFirstAidDetailViewController = segue.destination as! LearnFirstAidDetailViewController
            learnFirstAidDetail.first_aid_id = first_aid_id
        }
    }

}
