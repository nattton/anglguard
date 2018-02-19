import UIKit
protocol SpacialCareDelegate {
    func onSpacialCareResult(result: String)
}

class SpacialCareViewController: UITableViewController {
    
    var delegate: SpacialCareDelegate?
    
    @IBOutlet var bt_no_need: UIButton!
    @IBOutlet var bt_need: UIButton!
    @IBOutlet var bt_device: UIButton!
    @IBOutlet var bt_universal_design: UIButton!
    @IBOutlet var bt_gait_aid: UIButton!
    @IBOutlet var bt_wheel_chair: UIButton!
    @IBOutlet var bt_care_giver: UIButton!
    @IBOutlet var bt_one: UIButton!
    @IBOutlet var bt_two: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_universal_design.isSelected = Medical.sharedInstance.assistive_environmental_devices == "1" ? true : false
        bt_universal_design.isEnabled = Medical.sharedInstance.assistive_environmental_devices == "1" ? true : false
        
        bt_gait_aid.isSelected = Medical.sharedInstance.gait_aid == "1" ? true : false
        bt_gait_aid.isEnabled = Medical.sharedInstance.gait_aid == "1" ? true : false
        
        bt_wheel_chair.isSelected = Medical.sharedInstance.wheelchair == "1" ? true : false
        bt_wheel_chair.isEnabled = Medical.sharedInstance.wheelchair == "1" ? true : false
        
        bt_one.isSelected = Medical.sharedInstance.care_giver_one == "1" ? true : false
        bt_one.isEnabled = Medical.sharedInstance.care_giver_one == "1" ? true : false
        
        bt_two.isSelected = Medical.sharedInstance.care_giver_two == "1" ? true : false
        bt_two.isEnabled = Medical.sharedInstance.care_giver_two == "1" ? true : false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @IBAction func noNeedAction(_ sender: Any) {
        Medical.sharedInstance.no_need = "1"
        Medical.sharedInstance.assistive_environmental_devices = "0"
        Medical.sharedInstance.gait_aid = "0"
        Medical.sharedInstance.wheelchair = "0"
        Medical.sharedInstance.care_giver_one = "0"
        Medical.sharedInstance.care_giver_two = "0"
        
        bt_need.isSelected = false
        bt_need.isEnabled = true
        
        bt_device.isSelected = false
        bt_device.isEnabled = false
        
        bt_universal_design.isSelected = false
        bt_universal_design.isEnabled = false
        
        bt_gait_aid.isSelected = false
        bt_gait_aid.isEnabled = false
        
        bt_wheel_chair.isSelected = false
        bt_wheel_chair.isEnabled = false
        
        bt_care_giver.isSelected = false
        bt_care_giver.isEnabled = false
        
        bt_one.isSelected = false
        bt_one.isEnabled = false
        
        bt_two.isSelected = false
        bt_two.isEnabled = false
    }
    
    @IBAction func needAction(_ sender: Any) {
        Medical.sharedInstance.no_need = "0"
        
        bt_no_need.isSelected = false
        bt_need.isSelected = true
        bt_device.isEnabled = true
        bt_care_giver.isEnabled = true
    }
    
    @IBAction func deviceAction(_ sender: Any) {
        
        bt_universal_design.isEnabled = true
        bt_gait_aid.isEnabled = true
        bt_wheel_chair.isEnabled = true
    }
    
    @IBAction func universalAction(_ sender: Any) {
        bt_universal_design.isEnabled = !bt_universal_design.isEnabled
        
        Medical.sharedInstance.assistive_environmental_devices = bt_universal_design.isEnabled == true ? "1" : "0"
    }
    
    @IBAction func gaitAidAction(_ sender: Any) {
        bt_gait_aid.isEnabled = !bt_gait_aid.isEnabled
        
        Medical.sharedInstance.gait_aid = bt_gait_aid.isEnabled == true ? "1" : "0"
    }
    
    @IBAction func wheelChairAction(_ sender: Any) {
        bt_wheel_chair.isEnabled = !bt_wheel_chair.isEnabled
        
        Medical.sharedInstance.wheelchair = bt_wheel_chair.isEnabled == true ? "1" : "0"
    }
    
    @IBAction func careGiverAction(_ sender: Any) {
        bt_care_giver.isEnabled = !bt_care_giver.isEnabled
        
        bt_one.isEnabled = true
        bt_two.isEnabled = true
    }
    
    @IBAction func oneAction(_ sender: Any) {
        bt_one.isEnabled = !bt_one.isEnabled
        
        Medical.sharedInstance.care_giver_one = bt_one.isEnabled == true ? "1" : "0"
    }
    
    @IBAction func twoAction(_ sender: Any) {
        bt_two.isEnabled = !bt_two.isEnabled
        
        Medical.sharedInstance.care_giver_two = bt_two.isEnabled == true ? "1" : "0"
    }
    
    @IBAction func okAction(_ sender: Any) {
        var result: String = ""
        
        if Medical.sharedInstance.no_need == "1" {
            result = "No Need"
        } else {
            result = "Need"
        }
        
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onSpacialCareResult(result: result)
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
