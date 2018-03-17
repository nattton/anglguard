import UIKit

class ForgetPasswordViewController: UITableViewController {
    
    @IBOutlet var lb_forget_password: UILabel!
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var bt_send: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_forget_password.text = "login_forgot_password".localized()
        tf_email.placeholder = "login_email".localized()
        bt_send.setTitle("bnt_send".localized(), for: .normal)
        self.title = "login_forgot_password".localized()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
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
