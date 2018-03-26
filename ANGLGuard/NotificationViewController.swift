import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notifications: [Any] = []
    let defaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    var selectedImage: UIImage?
    
    @IBOutlet var tb_notification: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token
            ]
            
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(NOTIFICATION_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            let notificaton: Array = data["notificaton"] as! [Any]
                            self.notifications = notificaton
                            self.tb_notification.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        self.title = "nav_notification".localized()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notification = notifications[indexPath.row] as! [String: String]
        let type: String! = notification["type"]
        
        if type == "alert" {
            return 145
        } else {
            return 84
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let notification = notifications[indexPath.row] as! [String: String]
        let type: String! = notification["type"]
        let defaultImage = UIImage(named: "emergency_img_defult")
        
        if type == "alert" {
            let nACell: NAlertCell = tableView.dequeueReusableCell(withIdentifier: "NAlertCell") as! NAlertCell
            
            let date: String! = notification["create_date"]
            nACell.date.text = date
            
            let message: String! = notification["message"]
            nACell.message.text = message
            
            let image1: String! = notification["image1"]
            let eImg1: String! = image1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url1 = URL(string: eImg1){
                nACell.photo1.af_setImage(for: .normal, url: url1)
            } else {
                nACell.photo1.setImage(defaultImage, for: .normal)
            }
            
            let image2: String! = notification["image2"]
            let eImg2: String! = image2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url2 = URL(string: eImg2){
                nACell.photo2.af_setImage(for: .normal, url: url2)
            } else {
                nACell.photo2.setImage(defaultImage, for: .normal)
            }
            
            let image3: String! = notification["image3"]
            let eImg3: String! = image3.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url3 = URL(string: eImg3){
                nACell.photo3.af_setImage(for: .normal, url: url3)
            } else {
                nACell.photo3.setImage(defaultImage, for: .normal)
            }
            
            let image4: String! = notification["image4"]
            let eImg4: String! = image4.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url4 = URL(string: eImg4){
                nACell.photo4.af_setImage(for: .normal, url: url4)
            } else {
                nACell.photo4.setImage(defaultImage, for: .normal)
            }
            
            nACell.photo1.addTarget(self, action: #selector(showPreview(_:)), for: .touchUpInside)
            nACell.photo2.addTarget(self, action: #selector(showPreview(_:)), for: .touchUpInside)
            nACell.photo3.addTarget(self, action: #selector(showPreview(_:)), for: .touchUpInside)
            nACell.photo4.addTarget(self, action: #selector(showPreview(_:)), for: .touchUpInside)
            
            cell = nACell
        } else {
            let nMCell: NMessageCell = tableView.dequeueReusableCell(withIdentifier: "NMessageCell") as! NMessageCell
            
            let date: String! = notification["create_date"]
            nMCell.date.text = date
            
            let message: String! = notification["message"]
            nMCell.message.text = message
            
            cell = nMCell
        }
        
//        let firstname: String! = friend["firstname"]
//        let lastname: String! = friend["lastname"]
//
//        let eImg: String! = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        if let url = URL(string: eImg){
//            fCell.avatar.af_setImage(withURL: url)
//        } else {
//            fCell.avatar.image = UIImage(named: "ic_avatar")
//        }
//
//        fCell.name.text = firstname + " " + lastname
//
//        if indexPath.row % 2 == 0 {
//            fCell.backgroundColor = UIColor.white
//        } else {
//            fCell.backgroundColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
//        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func convertDate(date: String) -> String {
        var dateString = ""
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        dateString = dateFormatter.string(from: dateObj!)
        return dateString
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func showPreview(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        let image = button.image(for: .normal)
        let defaultImage = UIImage(named: "emergency_img_defult")
        
        if image != defaultImage {
            selectedImage = image
            self.performSegue(withIdentifier: "showPreview", sender: nil)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPreview" {
            let previewImageView: PreviewImageViewController = segue.destination as! PreviewImageViewController
            previewImageView.preview = selectedImage
        }
    }

}
