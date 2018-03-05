import UIKit
import Alamofire
import SVProgressHUD

class MedicalProfileViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var tf_blood_type: UITextField!
    @IBOutlet var tf_drug: UITextField!
    @IBOutlet var tf_food: UITextField!
    @IBOutlet var tf_chemical: UITextField!
    @IBOutlet var tf_underlying: UITextField!
    @IBOutlet var tf_medication: UITextField!
    @IBOutlet var tf_special_care: UITextField!
    
    var bloods = ["O", "A", "B", "AB"]
    var bloodPicker: UIPickerView?
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
        
        tf_blood_type.text = Medical.sharedInstance.blood_type
        
        tf_blood_type.inputView = createBloodPicker()
        tf_blood_type.inputAccessoryView = createBloodToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeBlood))
        closeButton.accessibilityLabel = "Close"
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBlood))
        doneButton.accessibilityLabel = "Done"
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
    
    @IBAction func updateAction(_ sender: Any) {
        let blood_type: String = tf_blood_type.text!
        
        if blood_type.count == 0 {
            let alert = UIAlertController(title: BLOOD_TYPE_ALERT, message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "medical_profile": [
                        "blood_type": blood_type,
                        "allergy_drug": [
                            "seizures": Medical.sharedInstance.seizures,
                            "insuline": Medical.sharedInstance.insuline,
                            "iodine": Medical.sharedInstance.iodine,
                            "penicillin": Medical.sharedInstance.penicillin,
                            "sulfa": Medical.sharedInstance.sulfa,
                            "others": Medical.sharedInstance.allergy_drug_others
                        ],
                        "allergy_food": [
                            "milk": Medical.sharedInstance.milk,
                            "eggs": Medical.sharedInstance.eggs,
                            "fish": Medical.sharedInstance.fish,
                            "crustacean_shellfish": Medical.sharedInstance.crustacean_shellfish,
                            "tree_nuts": Medical.sharedInstance.tree_nuts,
                            "peanuts": Medical.sharedInstance.peanuts,
                            "wheat": Medical.sharedInstance.wheat,
                            "soybeans": Medical.sharedInstance.soybeans,
                            "others": Medical.sharedInstance.allergy_food_others
                        ],
                        "allergy_chemical": [
                            "shampoos": Medical.sharedInstance.shampoos,
                            "shampoos_brand": Medical.sharedInstance.shampoos_brand,
                            "fragrances": Medical.sharedInstance.fragrances,
                            "fragrances_brand": Medical.sharedInstance.fragrances_brand,
                            "cleaners": Medical.sharedInstance.cleaners,
                            "cleaners_brand": Medical.sharedInstance.cleaners_brand,
                            "detergents": Medical.sharedInstance.detergents,
                            "detergents_brand": Medical.sharedInstance.detergents_brand,
                            "cosmetics": Medical.sharedInstance.cosmetics,
                            "cosmetics_brand": Medical.sharedInstance.cosmetics_brand,
                            "others": Medical.sharedInstance.allergy_chemical_others
                        ],
                        "underlying": [
                            "diabetes_mellitus": Medical.sharedInstance.diabetes_mellitus,
                            "hypertension": Medical.sharedInstance.hypertension,
                            "chronic_kidney_disease": Medical.sharedInstance.chronic_kidney_disease,
                            "heart_disease": Medical.sharedInstance.heart_disease,
                            "old_stroke": Medical.sharedInstance.old_stroke,
                            "others": Medical.sharedInstance.underlying_others
                        ],
                        "current_medication": [
                            "description": Medical.sharedInstance.current_medication_description
                        ],
                        "special_care": [
                            "no_need": Medical.sharedInstance.no_need,
                            "need": [
                                "device": [
                                    "assistive_environmental_devices": Medical.sharedInstance.assistive_environmental_devices,
                                    "gait_aid": Medical.sharedInstance.gait_aid,
                                    "wheelchair": Medical.sharedInstance.wheelchair
                            ],
                                "care_giver": [
                                    "one": Medical.sharedInstance.care_giver_one,
                                    "two": Medical.sharedInstance.care_giver_two
                                ]
                            ]
                        ]
                    ]
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_PROFILE_MEDICAL, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        NSLog("result = \(result)")
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        if code == "200" {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
