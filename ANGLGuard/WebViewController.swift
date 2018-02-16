import UIKit
import Alamofire
import AlamofireImage

class WebViewController: UIViewController {
    
    @IBOutlet var wv: UIWebView!
    
    var link: String = ""
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        wv.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: link){
            let request: URLRequest = URLRequest(url: url)
            DispatchQueue.main.async {
                self.wv.loadRequest(request)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
