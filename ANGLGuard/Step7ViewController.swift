import UIKit
import Alamofire
import ADCountryPicker

class Step7ViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var tf_firstname: UITextField!
    @IBOutlet var tf_lastname: UITextField!
    @IBOutlet var tf_country_code: UITextField!
    @IBOutlet var tf_phone: UITextField!
    @IBOutlet var tf_relationship: UITextField!
    @IBOutlet var tf_email: UITextField!
    
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
    
    func showCountryPicker() {
        let picker = ADCountryPicker()
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            picker.dismiss(animated: true, completion: {
                self.tf_country_code.text = name
            })
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let firstname: String = tf_firstname.text!
        let lastname: String = tf_lastname.text!
        let country_code: String = tf_country_code.text!
        let phone: String = tf_phone.text!
        let relationship: String = tf_relationship.text!
        let email: String = tf_email.text!
        
        if firstname.count > 0 && lastname.count > 0 && country_code.count > 0 && phone.count > 0 && relationship.count > 0 {
            
            //data
            Contact.sharedInstance.firstname = firstname
            Contact.sharedInstance.lastname = lastname
            Contact.sharedInstance.contact_number = phone
            Contact.sharedInstance.relation = relationship
            Contact.sharedInstance.email = email
            
            let parameters: Parameters = [
                "personal": [
                    "email" : Personal.sharedInstance.email,
                    "password" : Personal.sharedInstance.password,
                    "firstname" : Personal.sharedInstance.firstname,
                    "middlename" : Personal.sharedInstance.middlename,
                    "lastname" : Personal.sharedInstance.lastname,
                    "gender" : Personal.sharedInstance.gender,
                    "birthdate" : Personal.sharedInstance.birthdate,
                    "height" : Personal.sharedInstance.height,
                    "weight" : Personal.sharedInstance.weight,
                    "country_code" : Personal.sharedInstance.country_code,
                    "passport_num" : Personal.sharedInstance.passport_num,
                    "passport_expire_date" : Personal.sharedInstance.passport_expire_date,
                    "mobile_num" : Personal.sharedInstance.mobile_num,
                    "mobile_cc" : Personal.sharedInstance.mobile_cc,
                    "thai_mobile_num" : Personal.sharedInstance.thai_mobile_num,
                    "thai_mobile_cc" : Personal.sharedInstance.thai_mobile_cc,
                    "personal_img_bin" : "01",
                    "passport_img" : "01"
                ],
                "contact_person" : [
                    "firstname" : Contact.sharedInstance.firstname,
                    "middlename" : Contact.sharedInstance.middlename,
                    "lastname" : Contact.sharedInstance.lastname,
                    "contact_number" : Contact.sharedInstance.contact_number,
                    "contact_number_cc" : Contact.sharedInstance.contact_number_cc,
                    "relation" : Contact.sharedInstance.relation,
                    "email" : Contact.sharedInstance.email
                ],
                "trip_plan" : [
                    "purpose" : Trip.sharedInstance.purpose,
                    "start_date" : Trip.sharedInstance.start_date,
                    "duration" : Trip.sharedInstance.duration,
                    "average_expen" : Trip.sharedInstance.average_expen,
                    "trip_arrang" : Trip.sharedInstance.trip_arrang,
                    "domestic_tran_arrang" : Trip.sharedInstance.domestic_tran_arrang,
                    "destination" : Trip.sharedInstance.destination
                ],
                "medical_profile" : [
                    "blood_type" : Medical.sharedInstance.blood_type,
                    "allergy_drug" : [
                        "seizures" : Medical.sharedInstance.seizures,
                        "insuline" : Medical.sharedInstance.insuline,
                        "iodine" : Medical.sharedInstance.iodine,
                        "penicillin" : Medical.sharedInstance.penicillin,
                        "sulfa" : Medical.sharedInstance.sulfa,
                        "others" : Medical.sharedInstance.allergy_drug_others
                        
                    ],
                    "allergy_food" : [
                        "milk" : Medical.sharedInstance.milk,
                        "eggs" : Medical.sharedInstance.eggs,
                        "fish" : Medical.sharedInstance.fish,
                        "crustacean_shellfish" : Medical.sharedInstance.crustacean_shellfish,
                        "tree_nuts" : Medical.sharedInstance.tree_nuts,
                        "peanuts" : Medical.sharedInstance.peanuts,
                        "wheat" : Medical.sharedInstance.wheat,
                        "soybeans" : Medical.sharedInstance.soybeans,
                        "others" : Medical.sharedInstance.allergy_food_others
                    ],
                    "allergy_chemical" : [
                        "shampoos" : Medical.sharedInstance.shampoos,
                        "shampoos_brand" : Medical.sharedInstance.shampoos_brand,
                        "fragrances" : Medical.sharedInstance.fragrances,
                        "fragrances_brand" : Medical.sharedInstance.fragrances_brand,
                        "cleaners" : Medical.sharedInstance.cleaners,
                        "cleaners_brand" : Medical.sharedInstance.cleaners_brand,
                        "detergents" : Medical.sharedInstance.detergents,
                        "detergents_brand" : Medical.sharedInstance.detergents_brand,
                        "cosmetics" : Medical.sharedInstance.cosmetics,
                        "cosmetics_brand" : Medical.sharedInstance.cosmetics_brand,
                        "others" : Medical.sharedInstance.allergy_chemical_others
                    ],
                    "underlying" : [
                        "diabetes_mellitus" : Medical.sharedInstance.diabetes_mellitus,
                        "hypertension" : Medical.sharedInstance.hypertension,
                        "chronic_kidney_disease" : Medical.sharedInstance.chronic_kidney_disease,
                        "heart_disease" : Medical.sharedInstance.heart_disease,
                        "old_stroke" : Medical.sharedInstance.old_stroke,
                        "others" : Medical.sharedInstance.underlying_others
                    ],
                    "current_medication" : [
                        "description" : Medical.sharedInstance.current_medication_description
                    ],
                    "special_care" : [
                        "no_need" : Medical.sharedInstance.no_need,
                        "need" : [
                            "device" : [
                                "assistive_environmental_devices" : Medical.sharedInstance.assistive_environmental_devices,
                                "gait_aid" : Medical.sharedInstance.gait_aid,
                                "wheelchair" : Medical.sharedInstance.wheelchair
                            ],
                            "care_giver" : [
                                "one" : Medical.sharedInstance.care_giver_one,
                                "two" : Medical.sharedInstance.care_giver_two
                            ]
                        ]
                    ]
                ]
            ]
            
            Alamofire.request(SIGN_UP_REGISTER, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    let message: String = result["message"] as! String
                    NSLog("result = \(result)")
                    if code == "200" {
                        self.performSegue(withIdentifier: "showAccidentInsurance", sender: nil)
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
