import UIKit

class Step4ViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, AllergyOfDrugDelegate, AllergyOfFoodDelegate, AllergyOfChemicalDelegate, UnderlyingDelegate, CurrentMedicationDelegate, SpacialCareDelegate {

    @IBOutlet var lb_description: UILabel!
    @IBOutlet var tf_blood_type: UITextField!
    @IBOutlet var tf_drug: UITextField!
    @IBOutlet var tf_food: UITextField!
    @IBOutlet var tf_chemical: UITextField!
    @IBOutlet var tf_underlying: UITextField!
    @IBOutlet var tf_medication: UITextField!
    @IBOutlet var tf_special_care: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var bloods = ["O", "A", "B", "AB"]
    var bloodPicker: UIPickerView?
    
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
        
        tf_blood_type.layer.borderColor = UIColor.red.cgColor
        tf_blood_type.layer.borderWidth = 1
        tf_blood_type.layer.cornerRadius = 4
        
        tf_blood_type.text = Medical.sharedInstance.blood_type
        
        tf_blood_type.inputView = createBloodPicker()
        tf_blood_type.inputAccessoryView = createBloodToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_description.text = "signup_just_start".localized()
        tf_blood_type.placeholder = "signup_blood_type".localized()
        tf_drug.placeholder = "signup_allergy_drug".localized()
        tf_food.placeholder = "signup_allergy_food".localized()
        tf_chemical.placeholder = "signup_allergy_chemical".localized()
        tf_underlying.placeholder = "signup_Underlying_diseases".localized()
        tf_medication.placeholder = "signup_current_medication".localized()
        tf_special_care.placeholder = "signup_special_care".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
    }
    
    func createBloodPicker() -> UIPickerView {
        if bloodPicker == nil {
            bloodPicker = UIPickerView()
            bloodPicker?.delegate = self
        }
        
        return bloodPicker!
    }
    
    func createBloodToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let closeButton = UIBarButtonItem(title: "bnt_close".localized(), style: .done, target: self, action: #selector(closeBlood))
        closeButton.accessibilityLabel = "bnt_close".localized()
        let doneButton = UIBarButtonItem(title: "bnt_done".localized(), style: .done, target: self, action: #selector(doneBlood))
        doneButton.accessibilityLabel = "bnt_done".localized()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeBlood() {
        tf_blood_type.resignFirstResponder()
        bloodPicker?.removeFromSuperview()
    }
    
    @objc func doneBlood() {
        updateBlood()
        
        tf_blood_type.resignFirstResponder()
        bloodPicker?.removeFromSuperview()
    }
    
    func updateBlood() {
        let row: Int! = bloodPicker?.selectedRow(inComponent: 0)
        tf_blood_type.text = "\(bloods[row])"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return bloods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bloods[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tf_blood_type.text = "\(bloods[row])"
    }
    
    func onAllergyOfDrugResult(result: String) {
//        tf_drug.text = result
    }
    
    func onAllergyOfFoodResult(result: String) {
//        tf_food.text = result
    }
    
    func onAllergyOfChemicalResult(result: String) {
//        tf_chemical.text = result
    }
    
    func onUnderlyingResult(result: String) {
//        tf_underlying.text = result
    }
    
    func onCurrentMedicationResult(result: String) {
//        tf_medication.text = result
    }
    
    func onSpacialCareResult(result: String) {
//        tf_special_care.text = result
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let blood_type: String = tf_blood_type.text!
        
        if blood_type.count == 0 {
            let alert = UIAlertController(title: "signup_choice_blood_type".localized(), message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            //data
            Medical.sharedInstance.blood_type = blood_type
            
            self.performSegue(withIdentifier: "showStep6", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDrug" {
            let allergyOfDrugView: AllergyOfDrugViewController = segue.destination as! AllergyOfDrugViewController
            allergyOfDrugView.delegate = self
        }
        
        if segue.identifier == "showFood" {
            let allergyOfFoodView: AllergyOfFoodViewController = segue.destination as! AllergyOfFoodViewController
            allergyOfFoodView.delegate = self
        }
        
        if segue.identifier == "showChemical" {
            let allergyOfChemicalView: AllergyOfChemicalViewController = segue.destination as! AllergyOfChemicalViewController
            allergyOfChemicalView.delegate = self
        }
        
        if segue.identifier == "showUnderlying" {
            let underlyingView: UnderlyingViewController = segue.destination as! UnderlyingViewController
            underlyingView.delegate = self
        }
        
        if segue.identifier == "showCurrentMedicationandHerb" {
            let currentMedicationView: CurrentMedicationViewController = segue.destination as! CurrentMedicationViewController
            currentMedicationView.delegate = self
        }
        
        if segue.identifier == "showSpacialCare" {
            let spacialCareView: SpacialCareViewController = segue.destination as! SpacialCareViewController
            spacialCareView.delegate = self
        }
        
    }

}
