import UIKit
import ADCountryPicker

class Step2ViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tf_gender.inputView = createGenderPicker()
        tf_gender.inputAccessoryView = createGenderToolBar()
        
        tf_date_of_birth.inputView = createDatePicker()
        tf_date_of_birth.inputAccessoryView = createDateToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        let phone: String = tf_phone.text!
        
        if gender.count > 0 && date_of_birth.count > 0 && height.count > 0 && weight.count > 0 && country_code.count > 0 && phone.count > 0 {
            //data
            Personal.sharedInstance.gender = gender
            Personal.sharedInstance.birthdate = date_of_birth
            Personal.sharedInstance.height = height
            Personal.sharedInstance.weight = weight
            Personal.sharedInstance.country_code = country_code
            Personal.sharedInstance.mobile_num = phone
            
            self.performSegue(withIdentifier: "showVerifyPhone", sender: nil)
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
