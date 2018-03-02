import UIKit
import Alamofire
import ADCountryPicker

class Step3ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
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
                self.tf_country.text = name
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let passport: String = tf_passport.text!
        let country: String = tf_country.text!
        let expire_date: String = tf_expire_date.text!
        
        if passport.count > 0 && country.count > 0 && expire_date.count > 0 && isImage == true {
            //data
            Personal.sharedInstance.passport_num = passport
            Personal.sharedInstance.passport_expire_date = expire_date
            Personal.sharedInstance.passport_img = bt_avatar.image(for: .normal)
            
            self.performSegue(withIdentifier: "showStep4", sender: nil)
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
