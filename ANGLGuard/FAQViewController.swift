import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class FAQViewController: UIViewController, UIWebViewDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "lang": Language.getCurrentLanguage().language()
            ]
            
            SVProgressHUD.show(withStatus: LOADING_TEXT)
            Alamofire.request(FAQ_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            if let faq: String = data["faq"] as? String {
                                SVProgressHUD.show(withStatus: LOADING_TEXT)
                                self.webView.loadHTMLString(faq, baseURL: nil)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
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
