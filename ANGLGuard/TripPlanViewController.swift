import UIKit
import Alamofire
import SVProgressHUD

class TripPlanViewController: UITableViewController {
    
    @IBOutlet var tf_purpose: UITextField!
    @IBOutlet var tf_start_date: UITextField!
    @IBOutlet var tf_lenght_of_day: UITextField!
    @IBOutlet var tf_average: UITextField!
    @IBOutlet var tf_trip: UITextField!
    @IBOutlet var tf_domestic: UITextField!
    @IBOutlet var tf_destination: UITextField!
    
    var datePicker: UIDatePicker?
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
        
        tf_purpose.text = Trip.sharedInstance.purpose
        tf_start_date.text = Trip.sharedInstance.start_date
        tf_lenght_of_day.text = Trip.sharedInstance.duration
        tf_average.text = Trip.sharedInstance.average_expen
        tf_trip.text = Trip.sharedInstance.trip_arrang
        tf_domestic.text = Trip.sharedInstance.domestic_tran_arrang
        tf_destination.text = Trip.sharedInstance.destination
        
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
    
    @IBAction func updateAction(_ sender: Any) {
        let purpose: String = tf_purpose.text!
        let average_expen: String = tf_average.text!
        let trip_arrang: String = tf_trip.text!
        let domestic_tran_arrang: String = tf_domestic.text!
        let destination: String = tf_destination.text!
        
        if purpose.count == 0 {
            showAlert(message: PURPOSE_ALERT)
        } else {
            if let token = defaults.string(forKey: "token") {
                let parameters: Parameters = [
                    "token": token,
                    "trip_plan": [
                       "purpose": purpose,
                       "average_expen": average_expen,
                       "trip_arrang": trip_arrang,
                       "domestic_tran_arrang": domestic_tran_arrang,
                       "destination": destination
                    ]
                ]
                SVProgressHUD.show(withStatus: LOADING_TEXT)
                Alamofire.request(SAVE_TRIP_PLAN, method: .post, parameters: parameters).responseJSON { response in
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        let result = json as! Dictionary<String, Any>
                        NSLog("result = \(result)")
                        let code: String = result["code"] as! String
                        let message: String = result["message"] as! String
                        if code == "200" {
                            //data
                            Trip.sharedInstance.purpose = purpose
                            Trip.sharedInstance.average_expen = average_expen
                            Trip.sharedInstance.trip_arrang = trip_arrang
                            Trip.sharedInstance.domestic_tran_arrang = domestic_tran_arrang
                            Trip.sharedInstance.destination = destination
                            
                            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        } else if code == "104" {
                            self.defaults.set("N", forKey: "login")
                            self.defaults.set("N", forKey: "timer")
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.clearProfile()
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
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
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
