import UIKit
protocol CurrentMedicationDelegate {
    func onCurrentMedicationResult(result: String)
}

class CurrentMedicationViewController: UITableViewController {
    
    var delegate: CurrentMedicationDelegate?
    
    @IBOutlet var tv_other: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv_other.text = Medical.sharedInstance.current_medication_description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func okAction(_ sender: Any) {
        let other: String = tv_other.text!
        Medical.sharedInstance.current_medication_description = other
        self.dismiss(animated: true) {
            if (self.delegate != nil) {
                self.delegate?.onCurrentMedicationResult(result: other)
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
