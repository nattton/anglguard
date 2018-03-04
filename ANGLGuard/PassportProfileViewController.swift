import UIKit
import Alamofire
import ADCountryPicker

class PassportProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var bt_avatar: UIButton!
    @IBOutlet var tf_passport: UITextField!
    @IBOutlet var tf_country: UITextField!
    @IBOutlet var tf_expire_date: UITextField!
    
    var datePicker: UIDatePicker?
    var isImage: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tf_passport.text = Personal.sharedInstance.passport_num
        tf_country.text = Personal.sharedInstance.country_code
        tf_expire_date.text = Personal.sharedInstance.passport_expire_date
        
        tf_expire_date.inputView = createDatePicker()
        tf_expire_date.inputAccessoryView = createDateToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
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
        let passport: String = tf_passport.text!
        let country: String = tf_country.text!
        let expire_date: String = tf_expire_date.text!
        
        if passport.count == 0 {
            showAlert(message: PASSPORT_NUMBER_ALERT)
        } else if country.count == 0 {
            showAlert(message: CC_ALERT)
        } else if expire_date.count == 0 {
            showAlert(message: PASSPORT_EXPIRE_ALERT)
        } else if isImage == false {
            showAlert(message: PASSPORT_IMAGE_ALERT)
        } else {
            //data
            Personal.sharedInstance.passport_num = passport
            Personal.sharedInstance.country_code = country
            Personal.sharedInstance.passport_expire_date = expire_date
            Personal.sharedInstance.passport_img = bt_avatar.image(for: .normal)
        }
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
