import UIKit

class AllergyOfDrugViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    let drugs = ["Anti-Seizures", "Insulin", "lodine", "Penicillin", "Sulfa"]
    
    @IBOutlet var tb_drug: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drugs.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == drugs.count {
            return 166
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == drugs.count {
            let oCell: OtherCell = tableView.dequeueReusableCell(withIdentifier: "OtherCell") as! OtherCell
            oCell.other.delegate = self
            oCell.ok.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            
            return oCell
        } else {
            let aCell: AllergyOfDrugCell = tableView.dequeueReusableCell(withIdentifier: "AllergyOfDrugCell") as! AllergyOfDrugCell
            aCell.name.text = drugs[indexPath.row]
            
            return aCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tb_drug.scrollToRow(at: IndexPath.init(row: drugs.count - 1, section: 0), at: .top, animated: true)
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
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
