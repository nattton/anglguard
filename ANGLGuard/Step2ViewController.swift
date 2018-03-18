import UIKit
import ADCountryPicker

class Step2ViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var lb_description: UILabel!
    @IBOutlet var tf_gender: UITextField!
    @IBOutlet var tf_date_of_birth: UITextField!
    @IBOutlet var tf_height: UITextField!
    @IBOutlet var tf_weight: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var genders = ["Male", "Female"]
    var genderPicker: UIPickerView?
    var datePicker: UIDatePicker?
    var country_code: String = ""
    
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
        
    }
    
    func setText() {
        lb_description.text = "signup_so_iam".localized()
        tf_gender.placeholder = "signup_gender".localized()
        tf_date_of_birth.placeholder = "signup_date_of_birth".localized()
        tf_height.placeholder = "signup_height".localized()
        tf_weight.placeholder = "signup_weight".localized()
        tf_phone.placeholder = "signup_current_phone_number".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
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
        let closeButton = UIBarButtonItem(title: "bnt_close".localized(), style: .done, target: self, action: #selector(closeGender))
        closeButton.accessibilityLabel = "bnt_close".localized()
        let doneButton = UIBarButtonItem(title: "bnt_done".localized(), style: .done, target: self, action: #selector(doneGender))
        doneButton.accessibilityLabel = "bnt_done".localized()
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let gender: String = tf_gender.text!
        let date_of_birth: String = tf_date_of_birth.text!
        let height: String = tf_height.text!
        let weight: String = tf_weight.text!
        let cc: String = tf_country_code.text!
        let phone: String = tf_phone.text!
        
        if gender.count == 0 {
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
            //data
            Personal.sharedInstance.gender = gender
            Personal.sharedInstance.birthdate = date_of_birth
            Personal.sharedInstance.height = height
            Personal.sharedInstance.weight = weight
            Personal.sharedInstance.mobile_cc = cc
            Personal.sharedInstance.mobile_num = phone
            
            self.performSegue(withIdentifier: "showVerifyPhone", sender: nil)
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
