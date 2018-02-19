import UIKit

protocol AllergyOfDrugDelegate {
    func onAllergyOfDrugResult(result: String)
}

class AllergyOfDrugViewController: UITableViewController {
    
    var result: String = ""
    var delegate: AllergyOfDrugDelegate?
    let drugs = ["Anti-Seizures", "Insulin", "Iodine", "Penicilin", "Sulfa"]
    var selecteds: NSMutableArray = NSMutableArray()
    
    @IBOutlet var bt_seizures: UIButton!
    @IBOutlet var bt_insuline: UIButton!
    @IBOutlet var bt_iodine: UIButton!
    @IBOutlet var bt_penicillin: UIButton!
    @IBOutlet var bt_sulfa: UIButton!
    
    @IBOutlet var tv_other: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_seizures.isSelected = Medical.sharedInstance.seizures == "1" ? true : false
        bt_insuline.isSelected = Medical.sharedInstance.insuline == "1" ? true : false
        bt_iodine.isSelected = Medical.sharedInstance.iodine == "1" ? true : false
        bt_penicillin.isSelected = Medical.sharedInstance.penicillin == "1" ? true : false
        bt_sulfa.isSelected = Medical.sharedInstance.sulfa == "1" ? true : false
        
        tv_other.text = Medical.sharedInstance.allergy_drug_others
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func drugAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
        let index = button.tag - 1
        
        if button.tag == 1 {
            Medical.sharedInstance.seizures = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 2 {
            Medical.sharedInstance.insuline = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 3 {
            Medical.sharedInstance.iodine = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 4 {
            Medical.sharedInstance.penicillin = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 5 {
            Medical.sharedInstance.sulfa = button.isSelected ? "1" : "0"
        }
        
        if button.isSelected {
            selecteds.add(drugs[index])
        } else {
            selecteds.remove(drugs[index])
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        let other: String = tv_other.text!
        Medical.sharedInstance.allergy_drug_others = other
        let result: String = selecteds.getStringResultSelect()
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onAllergyOfDrugResult(result: result)
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
