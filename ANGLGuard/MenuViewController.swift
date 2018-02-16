import UIKit
import Alamofire

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let menus = [
        ["ic_profile", "ic_profile", "ic_device", "ic_notification", "ic_language", "ic_condition", "ic_signout"],
        ["Home", "Profile", "Group", "Notification", "Language", "Term & Conditions", "Sign Out"]
    ]
    let identifiers = ["angllife", "angllife", "profile", "group", "notification", "language", "term", "login"]
    
    var indexSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[0].count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        } else {
            return 58
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let aCell: AngllifeCell = tableView.dequeueReusableCell(withIdentifier: "AngllifeCell") as! AngllifeCell
            
            let defaults = UserDefaults.standard
            
            if let image = defaults.string(forKey: "image") {
                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent("avatar.jpg")
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                Alamofire.download(image, to: destination).response { response in
                    if response.error == nil, let imagePath = response.destinationURL?.path {
                        let image = UIImage(contentsOfFile: imagePath)
                        aCell.avatar.image = image
                    }
                }
            }
            
            if let firstname = defaults.string(forKey: "firstname"), let lastname = defaults.string(forKey: "lastname") {
                aCell.name.text = firstname + " " + lastname
            } else {
                aCell.name.text = "-"
            }
            
            if let email = defaults.string(forKey: "email") {
                aCell.email.text = email
            } else {
                aCell.email.text = "-"
            }
            
            return aCell
        } else {
            let mCell: MenuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
            mCell.icon.image = UIImage(named: menus[0][indexPath.row - 1])
            mCell.title.text = menus[1][indexPath.row - 1]
            
            return mCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTopViewController(index: indexPath.row)
    }
    
    func changeTopViewController(index: Int) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers[index])
        DispatchQueue.main.async {
            self.so_containerViewController?.isSideViewControllerPresented = false
            if index == 7 {
                let defaults = UserDefaults.standard
                defaults.set("N", forKey: "login")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            } else if index == 0 {
                
            } else {
                self.so_containerViewController?.topViewController = viewController
            }
        }
        indexSelected = index
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
