import UIKit
import Alamofire
import AlamofireImage
import SVProgressHUD

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var wv: UIWebView!
    
    var link: String = ""
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        wv.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                let request: URLRequest = URLRequest(url: url)
                DispatchQueue.main.async {
                    SVProgressHUD.show(withStatus: LOADING_TEXT)
                    self.wv.loadRequest(request)
                }
            } else {
                let message = "Can't open URL"
                let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
