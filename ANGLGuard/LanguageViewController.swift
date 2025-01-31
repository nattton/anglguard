import UIKit

class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tb_language: UITableView!
    
    let languages = ["ภาษาไทย", "English", "中国"]
    let keys = ["th", "en", "zh-Hans"]
    var selecteds: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tb_language.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LanguageCell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! LanguageCell
        let language = languages[indexPath.row]
        cell.language.text = language
        
        let key = keys[indexPath.row]
        if key == Language.getCurrentLanguage() {
            cell.current.isSelected = true
        } else {
            cell.current.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Language.setCurrentLanguage(keys[indexPath.row])
        tableView.reloadData()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
