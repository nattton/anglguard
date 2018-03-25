import UIKit
import Alamofire
import AlamofireImage

class HelpViewController: UITableViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GroupAlertDelegate, EmergencyDelegate {
    
    var bt_help_center: CGFloat?
    var type: String = ""
    var photo: Int = 0
    var lat: Double = 0
    var long: Double = 0
    
    @IBOutlet var lb_photo: UILabel!
    @IBOutlet var bt_photo1: UIButton!
    @IBOutlet var bt_photo2: UIButton!
    @IBOutlet var bt_photo3: UIButton!
    @IBOutlet var bt_photo4: UIButton!
    @IBOutlet var tv_message: UITextView!
    @IBOutlet var bt_help: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_photo.text = "emergency_photo".localized()
        tv_message.text = "emergency_message".localized()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Message"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage!
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = originalImage
        }
        
        if photo == 1 {
            bt_photo1.setBackgroundImage(image, for: .normal)
        } else if photo == 2 {
            bt_photo2.setBackgroundImage(image, for: .normal)
        } else if photo == 3 {
            bt_photo3.setBackgroundImage(image, for: .normal)
        } else if photo == 4 {
            bt_photo4.setBackgroundImage(image, for: .normal)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func onGroupAlertDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onEmergencyDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageAction(_ sender: Any) {
        let button =  sender as! UIButton
        photo = button.tag
        
        let cameraAction = UIAlertAction(title: "picture_take_pic".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let photoAction = UIAlertAction(title: "picture_pick_pic".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let deleteAction = UIAlertAction(title: "bnt_delete".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.photo == 1 {
                self.bt_photo1.setBackgroundImage(UIImage(named: "emergency_img_defult"), for: .normal)
            } else if self.photo == 2 {
                self.bt_photo2.setBackgroundImage(UIImage(named: "emergency_img_defult"), for: .normal)
            } else if self.photo == 3 {
                self.bt_photo3.setBackgroundImage(UIImage(named: "emergency_img_defult"), for: .normal)
            } else if self.photo == 4 {
                self.bt_photo4.setBackgroundImage(UIImage(named: "emergency_img_defult"), for: .normal)
            }
        })
        
        let cancelAction = UIAlertAction(title: "bnt_cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == .began {
            bt_help_center = view.center.x
        }
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y)
            
            if type == "" {
                if translation.x > 20 {
                    type = "emergency"
                } else if translation.x < -20  {
                    type = "alert"
                }
            }
            
            if recognizer.state == .ended {
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = CGPoint(x: self.bt_help_center!, y: view.center.y)
                }, completion: { (succes) in
                    if self.type == "alert" {
                        self.performSegue(withIdentifier: "showGroupAlert", sender: nil)
                    } else if self.type == "emergency" {
                        self.performSegue(withIdentifier: "showEmergency", sender: nil)
                    }
                    
                    self.type = ""
                })
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupAlert" {
            let navigationController = segue.destination as! UINavigationController
            let groupAlert: GroupAlertViewController = navigationController.topViewController as! GroupAlertViewController
            groupAlert.lat = lat
            groupAlert.long = long
            groupAlert.photo1 = bt_photo1.backgroundImage(for: .normal)
            groupAlert.photo2 = bt_photo2.backgroundImage(for: .normal)
            groupAlert.photo3 = bt_photo3.backgroundImage(for: .normal)
            groupAlert.photo4 = bt_photo4.backgroundImage(for: .normal)
            groupAlert.message = tv_message.text
            groupAlert.delegate = self
        }
        
        if segue.identifier == "showEmergency" {
            let navigationController = segue.destination as! UINavigationController
            let emergency: EmergencyViewController = navigationController.topViewController as! EmergencyViewController
            emergency.lat = lat
            emergency.long = long
            emergency.photo1 = bt_photo1.backgroundImage(for: .normal)
            emergency.photo2 = bt_photo2.backgroundImage(for: .normal)
            emergency.photo3 = bt_photo3.backgroundImage(for: .normal)
            emergency.photo4 = bt_photo4.backgroundImage(for: .normal)
            emergency.message = tv_message.text
            emergency.delegate = self
        }
    }

}
