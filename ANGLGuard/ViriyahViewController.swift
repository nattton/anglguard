import UIKit

class ViriyahViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = defaults.string(forKey: "token") {
            let url = URL(string: VIRIYAH_URL.replacingOccurrences(of: "@", with: token))
            let request = URLRequest(url: url!)
            webView.loadRequest(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.request?.url?.absoluteString.range(of: VIRIYAH_SUCCESS_URL) != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + DELEY_TIME, execute: {
                self.performSegue(withIdentifier: "showThankYou", sender: nil)
            })
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
