import UIKit

class SplashViewController: UIViewController {

    @IBOutlet var bt_signin: UIButton!
    @IBOutlet var bt_signup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setText() {
        bt_signin.setTitle("login_sigin".localized(), for: .normal)
        bt_signup.setTitle("login_signup".localized(), for: .normal)
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
