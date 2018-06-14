import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class LearnFirstAidDetailViewController: UIViewController, UIWebViewDelegate {
    
    var first_aid_id: Int = 0
    let defaults = UserDefaults.standard
    var content: String = ""
    var video: String = ""
    var isContent: Bool = true
    
    @IBOutlet var tab_content: UISegmentedControl!
    @IBOutlet var wv: UIWebView!
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        wv.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        getFirstAid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        tab_content.setTitle("aid_content".localized(), forSegmentAt: 0)
        tab_content.setTitle("aid_vdo".localized(), forSegmentAt: 1)
        self.title = "aid_header".localized()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    func getFirstAid() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "lang": Language.getCurrentLanguage().language(),
                "id": first_aid_id
            ]
            
            Alamofire.request(FIRSTAID_CONTENT_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            if let cData: String = data["content"] as? String {
                                self.content = cData
                            }
                            if let vData: String = data["video_content"] as? String {
                                self.video = vData
                            }
                            
                            self.showDetail(html: self.content)
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
    
    func showDetail(html: String) {
        wv.loadHTMLString(html, baseURL: nil)
    }
    
    @IBAction func typeChange(_ sender: Any) {
        isContent = !isContent
        
        if isContent == true {
            showDetail(html: content)
        } else {
            showDetail(html: video)
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
