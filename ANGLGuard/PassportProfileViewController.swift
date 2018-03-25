import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class PassportProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var bt_avatar: UIButton!
    @IBOutlet var tf_passport: UITextField!
    @IBOutlet var tf_country: UITextField!
    @IBOutlet var tf_expire_date: UITextField!
    @IBOutlet var bt_update: UIButton!
    
    var datePicker: UIDatePicker?
    var isImage: Bool = false
    
    let defaults = UserDefaults.standard
    
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
        
        if let image = defaults.string(forKey: "passport_img") {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("passport_avatar.jpg")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(image, to: destination).response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        self.bt_avatar.setImage(image, for: .normal)
                    } else {
                        self.bt_avatar.setImage(UIImage(named: "emergency_img_defult"), for: .normal)
                    }
                }
            }
        }
        
        tf_passport.text = Personal.sharedInstance.passport_num
        tf_country.text = Personal.sharedInstance.country_code
        tf_expire_date.text = Personal.sharedInstance.passport_expire_date
        
        tf_expire_date.inputView = createDatePicker()
        tf_expire_date.inputAccessoryView = createDateToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        tf_passport.placeholder = "signup_passport_number".localized()
        tf_country.placeholder = "signup_country".localized()
        tf_expire_date.placeholder = "signup_expire_date".localized()
        bt_update.setTitle("bnt_update".localized(), for: .normal)
        self.title = "sub_passport".localized()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tf_country {
            showCountryPicker()
            return false
        } else {
            return true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage!
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = originalImage
        }
        bt_avatar.setImage(image, for: .normal)
        isImage = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createDatePicker() -> UIDatePicker {
        if datePicker == nil {
            datePicker = UIDatePicker()
            datePicker!.datePickerMode = .date
            datePicker!.calendar = Calendar(identifier: .gregorian)
            datePicker!.locale = Locale(identifier: "en")
            datePicker!.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        }
        
        return datePicker!
    }
    
    func createDateToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let closeButton = UIBarButtonItem(title: "bnt_close".localized(), style: .done, target: self, action: #selector(closeDate))
        closeButton.accessibilityLabel = "bnt_close".localized()
        let doneButton = UIBarButtonItem(title: "bnt_done".localized(), style: .done, target: self, action: #selector(doneDate))
        doneButton.accessibilityLabel = "bnt_done".localized()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeDate() {
        tf_expire_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
    }
    
    @objc func doneDate() {
        tf_expire_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
        updateDate()
    }
    
    @objc func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        formatter.dateFormat = "dd/MM/yyyy"
        let date_result = formatter.string(from: (datePicker?.date)!)
        tf_expire_date.text = date_result
    }
    
    func showCountryPicker() {
        let picker = ADCountryPicker()
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.dismiss(animated: true, completion: {
                self.tf_country.text = code
            })
        }
    }
    
    @IBAction func avatarAction(_ sender: Any) {
        let cameraAction = UIAlertAction(title: "picture_take_pic".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let photoAction = UIAlertAction(title: "picture_pick_pic".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let deleteAction = UIAlertAction(title: "bnt_delete".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.isImage = false
            self.bt_avatar.setImage(UIImage(named: "emergency_img_defult"), for: .normal)
        })
        
        let cancelAction = UIAlertAction(title: "bnt_cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        let passport: String = tf_passport.text!
        let country: String = tf_country.text!
        let expire_date: String = tf_expire_date.text!
        let image = bt_avatar.image(for: .normal)
        
        if passport.count == 0 {
            showAlert(message: "signup_insert_passport_number".localized())
        } else if country.count == 0 {
            showAlert(message: "signup_select_your_country".localized())
        } else if expire_date.count == 0 {
            showAlert(message: "signup_insert_passport_expire".localized())
        } else if isImage == false {
            showAlert(message: "signup_pick_image_passport".localized())
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "personal": [
                        "firstname": Personal.sharedInstance.firstname,
                        "middlename": Personal.sharedInstance.middlename,
                        "lastname": Personal.sharedInstance.lastname,
                        "gender": Personal.sharedInstance.gender,
                        "birthdate": Personal.sharedInstance.birthdate,
                        "height": Personal.sharedInstance.height,
                        "weight": Personal.sharedInstance.weight,
                        "country_code": country,
                        "passport_num": passport,
                        "passport_expire_date": expire_date,
                        "mobile_num": Personal.sharedInstance.mobile_num,
                        "mobile_cc": Personal.sharedInstance.mobile_cc,
                        "thai_mobile_num": Personal.sharedInstance.thai_mobile_num,
                        "thai_mobile_cc": Personal.sharedInstance.thai_mobile_cc,
                        "passport_img": image?.resizeImage(200, opaque: false).toBase64()
                    ]
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_PROFILE_PERSONAL, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        NSLog("result = \(result)")
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        if code == "200" {
                            if let data: [String: Any] = result["data"] as? [String: Any] {
                                if let personal: [String: Any] = data["personal"] as? [String: Any] {
                                    if let personal_img_bin: String = personal["passport_img"] as? String {
                                        self.defaults.set(personal_img_bin, forKey: "passport_img")
                                    }
                                }
                            }
                            //data
                            Personal.sharedInstance.passport_num = passport
                            Personal.sharedInstance.country_code = country
                            Personal.sharedInstance.passport_expire_date = expire_date
                            Personal.sharedInstance.passport_img = image
                            
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        } else if code == "104" {
                            self.defaults.set("N", forKey: "login")
                            self.defaults.set("N", forKey: "timer")
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.clearProfile()
                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                            let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                            UIApplication.shared.keyWindow?.rootViewController = loginViewController
                        } else {
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
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
