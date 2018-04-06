import UIKit
import SVProgressHUD

class TermAndConditionViewController: UIViewController, UIWebViewDelegate {
    
     @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        
        if let url = Bundle.main.url(forResource: "condition_en", withExtension: "html") {
            webView.loadRequest(URLRequest(url: url))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        self.title = "nav_term".localized()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
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
    
    @IBAction func agreeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showMain", sender: nil)
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
