import UIKit

protocol AllergyOfFoodDelegate {
    func onAllergyOfFoodResult(result: String)
}

class AllergyOfFoodViewController: UITableViewController {
    
    var result: String = ""
    var delegate: AllergyOfFoodDelegate?
    let foods = ["Milk", "Eggs", "Fish", "Crustacean Shellfish", "Tree Nuts", "Peanuts", "Wheat", "Soybeans"]
    var selecteds: NSMutableArray = NSMutableArray()
    
    @IBOutlet var lb_allergy_of_foods: UILabel!
    @IBOutlet var bt_milk: UIButton!
    @IBOutlet var bt_eggs: UIButton!
    @IBOutlet var bt_fish: UIButton!
    @IBOutlet var bt_crustacean: UIButton!
    @IBOutlet var bt_tree_nut: UIButton!
    @IBOutlet var bt_peanuts: UIButton!
    @IBOutlet var bt_wheat: UIButton!
    @IBOutlet var bt_soybeans: UIButton!
    
    @IBOutlet var tv_other: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_milk.isSelected = Medical.sharedInstance.milk == "1" ? true : false
        bt_eggs.isSelected = Medical.sharedInstance.eggs == "1" ? true : false
        bt_fish.isSelected = Medical.sharedInstance.fish == "1" ? true : false
        bt_crustacean.isSelected = Medical.sharedInstance.crustacean_shellfish == "1" ? true : false
        bt_tree_nut.isSelected = Medical.sharedInstance.tree_nuts == "1" ? true : false
        bt_peanuts.isSelected = Medical.sharedInstance.peanuts == "1" ? true : false
        bt_wheat.isSelected = Medical.sharedInstance.wheat == "1" ? true : false
        bt_soybeans.isSelected = Medical.sharedInstance.soybeans == "1" ? true : false
        
        tv_other.text = Medical.sharedInstance.allergy_food_others
        
        lb_allergy_of_foods.text = "signup_allergy_food".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func foodAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
        let index = button.tag - 1
        
        if button.tag == 1 {
            Medical.sharedInstance.milk = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 2 {
            Medical.sharedInstance.eggs = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 3 {
            Medical.sharedInstance.fish = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 4 {
            Medical.sharedInstance.crustacean_shellfish = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 5 {
            Medical.sharedInstance.tree_nuts = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 6 {
            Medical.sharedInstance.peanuts = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 7 {
            Medical.sharedInstance.wheat = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 8 {
            Medical.sharedInstance.soybeans = button.isSelected ? "1" : "0"
        }
        
        if button.isSelected {
            selecteds.add(foods[index])
        } else {
            selecteds.remove(foods[index])
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        let other: String = tv_other.text!
        Medical.sharedInstance.allergy_food_others = other
        let result: String = selecteds.getStringResultSelect()
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onAllergyOfFoodResult(result: result)
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
