import UIKit

class Step6ViewController: UITableViewController {
    
    @IBOutlet var tf_purpose: UITextField!
    @IBOutlet var tf_start_date: UITextField!
    @IBOutlet var tf_lenght_of_day: UITextField!
    @IBOutlet var tf_average: UITextField!
    @IBOutlet var tf_trip: UITextField!
    @IBOutlet var tf_domestic: UITextField!
    @IBOutlet var tf_destination: UITextField!
    
    var datePicker: UIDatePicker?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tf_start_date.inputView = createDatePicker()
        tf_start_date.inputAccessoryView = createDateToolBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createDatePicker() -> UIDatePicker {
        if datePicker == nil {
            datePicker = UIDatePicker()
            datePicker!.datePickerMode = .date
            datePicker!.calendar = Calendar(identifier: .gregorian)
            datePicker!.locale = Locale(identifier: "en")
            datePicker!.addTarget(self, action: #selector(updateDate), for: .valueChanged)
        }
        
        return datePicker!
    }
    
    func createDateToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeDate))
        closeButton.accessibilityLabel = "Close"
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDate))
        doneButton.accessibilityLabel = "Done"
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.isTranslucent = false
        toolbar.sizeToFit()
        toolbar.setItems([closeButton,spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }
    
    @objc func closeDate() {
        tf_start_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
    }
    
    @objc func doneDate() {
        tf_start_date.resignFirstResponder()
        datePicker?.removeFromSuperview()
        updateDate()
    }
    
    @objc func updateDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.setLocalizedDateFormatFromTemplate("dd/MM/yyyy")
        let date_result = formatter.string(from: (datePicker?.date)!)
        tf_start_date.text = date_result
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let purpose: String = tf_purpose.text!
        let start_date: String = tf_start_date.text!
        let lenght_of_day: String = tf_lenght_of_day.text!
        let average_expen: String = tf_average.text!
        let trip_arrang: String = tf_trip.text!
        let domestic_tran_arrang: String = tf_domestic.text!
        let destination: String = tf_destination.text!
        
        if purpose.count > 0 && start_date.count > 0 && lenght_of_day.count > 0 {
            //data
            Trip.sharedInstance.purpose = purpose
            Trip.sharedInstance.start_date = start_date
            Trip.sharedInstance.duration = lenght_of_day
            Trip.sharedInstance.average_expen = average_expen
            Trip.sharedInstance.trip_arrang = trip_arrang
            Trip.sharedInstance.domestic_tran_arrang = domestic_tran_arrang
            Trip.sharedInstance.destination = destination
            
            self.performSegue(withIdentifier: "showStep7", sender: nil)
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
