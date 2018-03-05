import UIKit
import Alamofire
import ADCountryPicker
import SVProgressHUD

class PersonalProfileViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var bt_avatar: UIButton!
    @IBOutlet var tf_firstname: UITextField!
    @IBOutlet var tf_middlename: UITextField!
    @IBOutlet var tf_lastname: UITextField!
    @IBOutlet var tf_gender: UITextField!
    @IBOutlet var tf_date_of_birth: UITextField!
    @IBOutlet var tf_height: UITextField!
    @IBOutlet var tf_weight: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    
    var genders = ["Male", "Female"]
    var genderPicker: UIPickerView?
    var datePicker: UIDatePicker?
    var country_code: String = ""
    
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
        
        tf_firstname.text = Personal.sharedInstance.firstname
        tf_middlename.text = Personal.sharedInstance.middlename
        tf_lastname.text = Personal.sharedInstance.lastname
        tf_gender.text = Personal.sharedInstance.gender
        tf_date_of_birth.text = Personal.sharedInstance.birthdate
        tf_height.text = Personal.sharedInstance.height
        tf_weight.text = Personal.sharedInstance.weight
        tf_country_code.text = Personal.sharedInstance.mobile_cc
        tf_phone.text = Personal.sharedInstance.mobile_num
        
        tf_gender.inputView = createGenderPicker()
        tf_gender.inputAccessoryView = createGenderToolBar()
        
        tf_date_of_birth.inputView = createDatePicker()
        tf_date_of_birth.inputAccessoryView = createDateToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tf_country_code {
            showCountryPicker()
            return false
        } else {
            return true
        }
    }
    
    func createGenderPicker() -> UIPickerView {
        if genderPicker == nil {
            genderPicker = UIPickerView()
            genderPicker?.delegate = self
        }
        
        return genderPicker!
    }
    
    func createGenderToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeGender))
        closeButton.accessibilityLabel = "Close"
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneGender))
        doneButton.accessibilityLabel = "Done"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeGender() {
        tf_gender.resignFirstResponder()
        genderPicker?.removeFromSuperview()
    }
    
    @objc func doneGender() {
        updateGender()
        
        tf_gender.resignFirstResponder()
        genderPicker?.removeFromSuperview()
    }
    
    func updateGender() {
        let row: Int! = genderPicker?.selectedRow(inComponent: 0)
        tf_gender.text = "\(genders[row])"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tf_gender.text = "\(genders[row])"
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
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeDate))
        closeButton.accessibilityLabel = "Close"
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDate))
        doneButton.accessibilityLabel = "Done"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeDate() {
        tf_date_of_birth.resignFirstResponder()
        datePicker?.removeFromSuperview()
    }
    
    @objc func doneDate() {
        tf_date_of_birth.resignFirstResponder()
        datePicker?.removeFromSuperview()
        updateDate()
    }
    
    @objc func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        formatter.dateFormat = "dd/MM/yyyy"
        let date_result = formatter.string(from: (datePicker?.date)!)
        tf_date_of_birth.text = date_result
    }
    
    func showCountryPicker() {
        let picker = ADCountryPicker()
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.dismiss(animated: true, completion: {
                self.country_code = name
                self.tf_country_code.text = dialCode
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        bt_avatar.setImage(image, for: .normal)
        isImage = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func avatarAction(_ sender: Any) {
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let photoAction = UIAlertAction(title: "Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.isImage = false
            self.bt_avatar.setImage(UIImage(named: "emergency_img_defult"), for: .normal)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
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
        let firstname: String = tf_firstname.text!
        let lastname: String = tf_lastname.text!
        let middlename: String = tf_middlename.text!
        let gender: String = tf_gender.text!
        let date_of_birth: String = tf_date_of_birth.text!
        let height: String = tf_height.text!
        let weight: String = tf_weight.text!
        let cc: String = tf_country_code.text!
        let phone: String = tf_phone.text!
        let image = bt_avatar.image(for: .normal)
        
        if firstname.count == 0 {
            showAlert(message: FIRSTNAME_ALERT)
        } else if lastname.count == 0 {
            showAlert(message: LASTNAME_ALERT)
        } else if isImage == false {
            showAlert(message: PROFILE_IMAGE_ALERT)
        } else if gender.count == 0 {
            showAlert(message: GENDER_ALERT)
        } else if date_of_birth.count == 0 {
            showAlert(message: DATE_OF_BITH_ALERT)
        } else if height.count == 0 {
            showAlert(message: HEIGHT_ALERT)
        } else if weight.count == 0 {
            showAlert(message: WEIGHT_ALERT)
        } else if cc.count == 0 {
            showAlert(message: CC_ALERT)
        } else if phone.count == 0 {
            showAlert(message: MOBILE_NUMBER_ALERT)
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "personal": [
                        "firstname": firstname,
                        "middlename": middlename,
                        "lastname": lastname,
                        "gender": gender,
                        "birthdate": date_of_birth,
                        "height": height,
                        "weight": weight,
                        "country_code": Personal.sharedInstance.country_code,
                        "passport_num": Personal.sharedInstance.passport_num,
                        "passport_expire_date": Personal.sharedInstance.passport_expire_date,
                        "mobile_num": phone,
                        "mobile_cc": cc,
                        "thai_mobile_num": Personal.sharedInstance.thai_mobile_num,
                        "thai_mobile_cc": Personal.sharedInstance.thai_mobile_cc
//                        "personal_img_bin": "binary encode base 64"
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
                            //data
                            Personal.sharedInstance.firstname = firstname
                            Personal.sharedInstance.lastname = lastname
                            Personal.sharedInstance.middlename = middlename
                            Personal.sharedInstance.personal_img_bin = image
                            Personal.sharedInstance.gender = gender
                            Personal.sharedInstance.birthdate = date_of_birth
                            Personal.sharedInstance.height = height
                            Personal.sharedInstance.weight = weight
                            Personal.sharedInstance.mobile_cc = cc
                            Personal.sharedInstance.mobile_num = phone
                            
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
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
