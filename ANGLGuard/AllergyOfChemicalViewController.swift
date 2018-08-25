import UIKit

protocol AllergyOfChemicalDelegate {
    func onAllergyOfChemicalResult(result: String)
}

class AllergyOfChemicalViewController: UITableViewController {
    
    var result: String = ""
    var delegate: AllergyOfChemicalDelegate?
    let chemicals = ["Shampoos", "Fragrances", "Cleaners", "Detergents", "Cosmetic"]
    var selecteds: NSMutableArray = NSMutableArray()
    
    @IBOutlet var lb_allergy_of_chemical: UILabel!
    @IBOutlet var bt_shampoos: UIButton!
    @IBOutlet var bt_fragrances: UIButton!
    @IBOutlet var bt_cleaners: UIButton!
    @IBOutlet var bt_detergents: UIButton!
    @IBOutlet var bt_cosmetic: UIButton!
    
    @IBOutlet var tf_shampoos: UITextField!
    @IBOutlet var tf_fragrances: UITextField!
    @IBOutlet var tf_cleaners: UITextField!
    @IBOutlet var tf_detergents: UITextField!
    @IBOutlet var tf_cosmetic: UITextField!
    
    @IBOutlet var tv_other: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_shampoos.isSelected = Medical.sharedInstance.shampoos == "1" ? true : false
        bt_fragrances.isSelected = Medical.sharedInstance.fragrances == "1" ? true : false
        bt_cleaners.isSelected = Medical.sharedInstance.cleaners == "1" ? true : false
        bt_detergents.isSelected = Medical.sharedInstance.detergents == "1" ? true : false
        bt_cosmetic.isSelected = Medical.sharedInstance.cosmetics == "1" ? true : false
        
        tf_shampoos.text = Medical.sharedInstance.shampoos_brand
        tf_fragrances.text = Medical.sharedInstance.fragrances_brand
        tf_cleaners.text = Medical.sharedInstance.cleaners_brand
        tf_detergents.text = Medical.sharedInstance.detergents_brand
        tf_cosmetic.text = Medical.sharedInstance.cosmetics_brand
        
        tv_other.text = Medical.sharedInstance.allergy_chemical_others
        
        lb_allergy_of_chemical.text = "signup_allergy_chemical".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func chemicalAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
        let index = button.tag - 1
        
        if button.tag == 1 {
            Medical.sharedInstance.shampoos = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 2 {
            Medical.sharedInstance.fragrances = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 3 {
            Medical.sharedInstance.cleaners = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 4 {
            Medical.sharedInstance.detergents = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 5 {
            Medical.sharedInstance.cosmetics = button.isSelected ? "1" : "0"
        }
        
        if button.isSelected {
            selecteds.add(chemicals[index])
        } else {
            selecteds.remove(chemicals[index])
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        let shampoos: String = tf_shampoos.text!
        let fragrances: String = tf_fragrances.text!
        let cleaners: String = tf_cleaners.text!
        let detergents: String = tf_detergents.text!
        let cosmetic: String = tf_cosmetic.text!
        let other: String = tv_other.text!
        
        if bt_shampoos.isSelected == true {
            Medical.sharedInstance.shampoos_brand = shampoos
        }
        
        if bt_fragrances.isSelected == true {
            Medical.sharedInstance.fragrances_brand = fragrances
        }
        
        if bt_cleaners.isSelected == true {
            Medical.sharedInstance.cleaners_brand = cleaners
        }
        
        if bt_detergents.isSelected == true {
            Medical.sharedInstance.detergents_brand = detergents
        }
        
        if bt_cosmetic.isSelected == true {
            Medical.sharedInstance.cosmetics_brand = cosmetic
        }
        
        Medical.sharedInstance.allergy_chemical_others = other
        
        let result: String = selecteds.getStringResultSelect()
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onAllergyOfChemicalResult(result: result)
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
