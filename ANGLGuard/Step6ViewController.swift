import UIKit
import ADCountryPicker

class Step6ViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var lb_description: UILabel!
    @IBOutlet var tf_departure_country: UITextField!
    @IBOutlet var tf_purpose: UITextField!
    @IBOutlet var tf_start_date: UITextField!
    @IBOutlet var tf_lenght_of_day: UITextField!
    @IBOutlet var tf_average: UITextField!
    @IBOutlet var tf_trip: UITextField!
    @IBOutlet var tf_domestic: UITextField!
    @IBOutlet var tf_destination: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var datePicker: UIDatePicker?
    var departure_country_code: String = ""
    
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
        
        tf_departure_country.layer.borderColor = UIColor.red.cgColor
        tf_departure_country.layer.borderWidth = 2
        tf_departure_country.layer.cornerRadius = 4
        
        tf_purpose.layer.borderColor = UIColor.red.cgColor
        tf_purpose.layer.borderWidth = 2
        tf_purpose.layer.cornerRadius = 4
        
        tf_start_date.layer.borderColor = UIColor.red.cgColor
        tf_start_date.layer.borderWidth = 2
        tf_start_date.layer.cornerRadius = 4
        
        tf_lenght_of_day.layer.borderColor = UIColor.red.cgColor
        tf_lenght_of_day.layer.borderWidth = 2
        tf_lenght_of_day.layer.cornerRadius = 4
        
        departure_country_code = Trip.sharedInstance.departure_country
        tf_departure_country.text = countryName(code: Trip.sharedInstance.departure_country)
        tf_purpose.text = Trip.sharedInstance.purpose
        tf_start_date.text = Trip.sharedInstance.start_date
        tf_lenght_of_day.text = Trip.sharedInstance.duration
        tf_average.text = Trip.sharedInstance.average_expen
        tf_trip.text = Trip.sharedInstance.trip_arrang
        tf_domestic.text = Trip.sharedInstance.domestic_tran_arrang
        tf_destination.text = Trip.sharedInstance.destination
        
        tf_start_date.inputView = createDatePicker()
        tf_start_date.inputAccessoryView = createDateToolBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_description.text = "signup_how_do".localized()
        tf_departure_country.placeholder = "signup_departure_country".localized()
        tf_purpose.placeholder = "signup_purpost_trip".localized()
        tf_start_date.placeholder = "signup_start_date".localized()
        tf_lenght_of_day.placeholder = "signup_lenglh_of_stay".localized()
        tf_average.placeholder = "signup_average_expense".localized()
        tf_trip.placeholder = "signup_trip_arrangement".localized()
        tf_domestic.placeholder = "signup_domestic".localized()
        tf_destination.placeholder = "signup_destinations".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tf_departure_country {
            showCountryPicker()
            return false
        } else {
            return true
        }
    }
    
    func showCountryPicker() {
        let picker = ADCountryPicker()
        picker.customCountriesCode = ["BN","KH","ID","LA","MY","MM","PH","SG","VN","CN","HK","JP","KP",
                                      "TW","AT", "BE","DK","FI","FR","DE","IT","NL","NO","RU","ES","SE","CH",
                                      "GB","AR","BR","CA", "US","BD","IN","NP","PK","LK","AU","NZ","EG","IL",
                                      "KW","SA","AE","ZA","IE","GR", "PT","SI","TR","BY","BG","CZ","EE","HU",
                                      "KZ","LV","LT","PL","RO","SK","UA","UZ","BH","JO","LB","OM","QA"]
        picker.showCurrentCountry = false
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.dismiss(animated: true, completion: {
                self.departure_country_code = dialCode.replacingOccurrences(of: "+", with: "")
                self.tf_departure_country.text = name
            })
        }
    }
    
    func countryName(code: String) -> String {
        let CallingCodes = { () -> [[String: String]] in
            let resourceBundle = Bundle(for: ADCountryPicker.classForCoder())
            guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
            return NSArray(contentsOfFile: path) as! [[String: String]]
        }
        
        let countryData = CallingCodes().filter { $0["dial_code"] == "+" + code }
        
        if countryData.count > 0 {
            let countryCode: String = countryData[0]["name"] ?? ""
            return countryCode
        } else {
            return code
        }
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
        tf_start_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
    }
    
    @objc func doneDate() {
        tf_start_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
        updateDate()
    }
    
    @objc func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        formatter.dateFormat = "dd/MM/yyyy"
        let date_result = formatter.string(from: (datePicker?.date)!)
        tf_start_date.text = date_result
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let purpose: String = tf_purpose.text!
        let start_date: String = tf_start_date.text!
        let lenght_of_day: String = tf_lenght_of_day.text!
        let average_expen: String = tf_average.text!
        let trip_arrang: String = tf_trip.text!
        let domestic_tran_arrang: String = tf_domestic.text!
        let destination: String = tf_destination.text!
        
        if departure_country_code.count == 0 {
            showAlert(message: "signup_departure_country".localized())
        } else if purpose.count == 0 {
            showAlert(message: "signup_choice_your_purpose".localized())
        } else if start_date.count == 0 {
            showAlert(message: "signup_insert_start_date".localized())
        } else if lenght_of_day.count == 0 {
            showAlert(message: "signup_insert_length_of_stay".localized())
        } else {
            //data
            Trip.sharedInstance.departure_country = departure_country_code
            Trip.sharedInstance.purpose = purpose
            Trip.sharedInstance.start_date = start_date
            Trip.sharedInstance.duration = lenght_of_day
            Trip.sharedInstance.average_expen = average_expen
            Trip.sharedInstance.trip_arrang = trip_arrang
            Trip.sharedInstance.domestic_tran_arrang = domestic_tran_arrang
            Trip.sharedInstance.destination = destination
            
            self.performSegue(withIdentifier: "showStep7", sender: nil)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
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
