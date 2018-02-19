import UIKit

class Step4ViewController: UITableViewController, AllergyOfDrugDelegate, AllergyOfFoodDelegate, AllergyOfChemicalDelegate, UnderlyingDelegate, CurrentMedicationDelegate, SpacialCareDelegate {

    @IBOutlet var tf_blood_type: UITextField!
    @IBOutlet var tf_drug: UITextField!
    @IBOutlet var tf_food: UITextField!
    @IBOutlet var tf_chemical: UITextField!
    @IBOutlet var tf_underlying: UITextField!
    @IBOutlet var tf_medication: UITextField!
    @IBOutlet var tf_special_care: UITextField!
    
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
    
    func onAllergyOfDrugResult(result: String) {
        tf_drug.text = result
    }
    
    func onAllergyOfFoodResult(result: String) {
        tf_food.text = result
    }
    
    func onAllergyOfChemicalResult(result: String) {
        tf_chemical.text = result
    }
    
    func onUnderlyingResult(result: String) {
        tf_underlying.text = result
    }
    
    func onCurrentMedicationResult(result: String) {
        tf_medication.text = result
    }
    
    func onSpacialCareResult(result: String) {
        tf_special_care.text = result
    }

    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let blood_type: String = tf_blood_type.text!
        
        if blood_type.count > 0 {
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
