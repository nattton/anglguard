import UIKit

protocol UnderlyingDelegate {
    func onUnderlyingResult(result: String)
}

class UnderlyingViewController: UITableViewController {
    
    var result: String = ""
    var delegate: UnderlyingDelegate?
    let underlyings = ["Diabetes mellitus", "Hypertension", "Chronic kidney disease", "Heart disease", "Old stroke"]
    var selecteds: NSMutableArray = NSMutableArray()
    
    @IBOutlet var lb_underlying: UILabel!
    @IBOutlet var bt_diabetes: UIButton!
    @IBOutlet var bt_hypertension: UIButton!
    @IBOutlet var bt_chronic: UIButton!
    @IBOutlet var bt_heart: UIButton!
    @IBOutlet var bt_old_stroke: UIButton!
    
    @IBOutlet var tv_other: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_diabetes.isSelected = Medical.sharedInstance.diabetes_mellitus == "1" ? true : false
        bt_hypertension.isSelected = Medical.sharedInstance.hypertension == "1" ? true : false
        bt_chronic.isSelected = Medical.sharedInstance.chronic_kidney_disease == "1" ? true : false
        bt_heart.isSelected = Medical.sharedInstance.heart_disease == "1" ? true : false
        bt_old_stroke.isSelected = Medical.sharedInstance.old_stroke == "1" ? true : false
        
        tv_other.text = Medical.sharedInstance.underlying_others
        
        lb_underlying.text = "signup_Underlying_diseases".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func underlyingAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        button.isSelected = !button.isSelected
        let index = button.tag - 1
        
        if button.tag == 1 {
            Medical.sharedInstance.diabetes_mellitus = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 2 {
            Medical.sharedInstance.hypertension = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 3 {
            Medical.sharedInstance.chronic_kidney_disease = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 4 {
            Medical.sharedInstance.heart_disease = button.isSelected ? "1" : "0"
        }
        
        if button.tag == 5 {
            Medical.sharedInstance.old_stroke = button.isSelected ? "1" : "0"
        }
        
        if button.isSelected {
            selecteds.add(underlyings[index])
        } else {
            selecteds.remove(underlyings[index])
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        let other: String = tv_other.text!
        Medical.sharedInstance.underlying_others = other
        let result: String = selecteds.getStringResultSelect()
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onUnderlyingResult(result: result)
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
