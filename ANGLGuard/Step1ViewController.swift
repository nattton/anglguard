import UIKit

class Step1ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var bt_avatar: UIButton!
    @IBOutlet var tf_firstname: UITextField!
    @IBOutlet var tf_middlename: UITextField!
    @IBOutlet var tf_lastname: UITextField!
    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        bt_avatar.setImage(image, for: .normal)
        isImage = true
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func avatarAction(_ sender: Any) {
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let photoAction = UIAlertAction(title: "Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                
                DispatchQueue.main.async {
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let firstname: String = tf_firstname.text!
        let lastname: String = tf_lastname.text!
        
        if firstname.count > 0 && lastname.count > 0 && isImage == true {
            self.performSegue(withIdentifier: "showStep2", sender: nil)
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
