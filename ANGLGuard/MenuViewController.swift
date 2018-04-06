import UIKit
import Alamofire

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MenuHeaderDelegate {

    @IBOutlet var tb_menu: UITableView!
    @IBOutlet var im_avatar: UIImageView!
    @IBOutlet var lb_name: UILabel!
    @IBOutlet var lb_email: UILabel!
    
    let defaults = UserDefaults.standard
    var sections = menuData
    var indexSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setInit() {
        im_avatar.layer.masksToBounds = false
        im_avatar.layer.cornerRadius = im_avatar.frame.size.height / 2
        im_avatar.clipsToBounds = true
        
        if let image = defaults.string(forKey: "personal_img_bin") {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("avatar.jpg")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(image, to: destination).response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    self.im_avatar.image = image
                }
            }
        }
        
        lb_name.text = Personal.sharedInstance.firstname
        lb_email.text = Personal.sharedInstance.email
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        let item: Item = sections[indexPath.section].items[indexPath.row]
        
        cell.title.text = getTitle(key: item.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: Item = sections[indexPath.section].items[indexPath.row]
        changeTopViewController(identifier: item.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? MenuHeader ?? MenuHeader(reuseIdentifier: "header")
        
        header.iconImage.image = UIImage(named: sections[section].icon)
        header.titleLabel.text = getTitle(key: sections[section].name)
        header.arrowLabel.text = sections[section].items.count > 0 ? ">" : ""
        header.setCollapsed(sections[section].collapsed)
        header.section = section
        header.delegate = self

        return header
    }
    
    func toggleSection(_ header: MenuHeader, section: Int) {
        if sections[section].items.count > 0 {
            let collapsed = !sections[section].collapsed
            
            sections[section].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            tb_menu.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
        } else {
            changeTopViewController(identifier: sections[section].identifier)
        }
    }
    
    func changeTopViewController(identifier: String) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        DispatchQueue.main.async {
            self.so_containerViewController?.isSideViewControllerPresented = false
            if identifier == "login" {
                self.so_containerViewController?.topViewController = nil
                let defaults = UserDefaults.standard
                defaults.set("N", forKey: "login")
                defaults.set("N", forKey: "timer")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            } else {
                self.so_containerViewController?.topViewController = viewController
            }
        }
    }
    
    func getTitle(key: String) -> String {
        return key.localized()
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
