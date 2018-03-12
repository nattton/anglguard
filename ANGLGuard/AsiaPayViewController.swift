import UIKit
import SVProgressHUD

class AsiaPayViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let url = NSURL (string: ASIA_PAY_URL)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let post: String =  "merchantId=\(MERCHANT_CODE)" +
                            "&amount=250" +
                            "&orderRef=\(getOrderRef())" +
                            "&currCode=764" +
                            "&mpsMode=NIL" +
                            "&successUrl=\(ASIA_PAY_SUCCESS_URL)" +
                            "&failUrl=\(ASIA_PAY_FAIL_URL)" +
                            "&cancelUrl=\(ASIA_PAY_CANCEL_URL)" +
                            "&payType=N" +
                            "&lang=E" +
                            "&payMethod=" +
                            "&screenMode=inLine" +
                            "&deviceMode=auto" +
                            "&oriCountry=764" +
                            "&destCountry=764" +
                            "&remark=" +
                            "&failRetry=" +
                            "&print=" +
                            "&appId=" +
                            "&appRef=" +
                            "&redirect=30" +
                            "&o_charge=0"
        
        let postData: NSData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)! as NSData
        request.httpBody = postData as Data
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        webView.loadRequest(request as URLRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        if webView.request?.url?.absoluteString.range(of: ASIA_PAY_SUCCESS_URL) != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + DELEY_TIME, execute: {
                self.performSegue(withIdentifier: "showThankYou", sender: nil)
            })
        }
    }
    
    func getOrderRef() -> String {
        var orderRef: String = ""
        if let token = defaults.string(forKey: "token") {
            orderRef = token.replacingOccurrences(of: "-", with: "") + randomString(length: 3)
        }
        return orderRef
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
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
