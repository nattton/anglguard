import UIKit

class Step1ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var bt_avatar: UIButton!
    @IBOutlet var lb_description: UILabel!
    @IBOutlet var tf_firstname: UITextField!
    @IBOutlet var tf_middlename: UITextField!
    @IBOutlet var tf_lastname: UITextField!
    @IBOutlet var bt_back: UIButton!
    @IBOutlet var bt_next: UIButton!
    
    var isImage: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "bg_login.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        tf_firstname.text = Personal.sharedInstance.firstname
        tf_middlename.text = Personal.sharedInstance.middlename
        tf_lastname.text = Personal.sharedInstance.lastname
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setText() {
        lb_description.text = "signup_nice_to_meet_you".localized()
        tf_firstname.placeholder = "signup_first_name".localized()
        tf_middlename.placeholder = "signup_mid_name".localized()
        tf_lastname.placeholder = "signup_last_name".localized()
        bt_back.setTitle("bnt_back".localized(), for: .normal)
        bt_next.setTitle("bnt_next".localized(), for: .normal)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage!
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = originalImage
        }
        bt_avatar.setImage(image, for: .normal)
        isImage = true
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func avatarAction(_ sender: Any) {
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
            self.isImage = false
            self.bt_avatar.setImage(UIImage(named: "emergency_img_defult"), for: .normal)
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
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let firstname: String = tf_firstname.text!
        let lastname: String = tf_lastname.text!
        let middlename: String = tf_middlename.text!
        
        if firstname.count == 0 {
            showAlert(message: "signup_insert_first_name".localized())
        } else if lastname.count == 0 {
            showAlert(message: "signup_insert_last_name".localized())
        } else if isImage == false {
            showAlert(message: "signup_pick_your_profile_image".localized())
        } else {
            //data
            Personal.sharedInstance.firstname = firstname
            Personal.sharedInstance.lastname = lastname
            Personal.sharedInstance.middlename = middlename
            Personal.sharedInstance.personal_img_bin = bt_avatar.image(for: .normal)
            
            self.performSegue(withIdentifier: "showStep2", sender: nil)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "bnt_ok".localized(), style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
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
