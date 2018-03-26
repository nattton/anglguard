import UIKit
import Alamofire

class ProfileQRCodeViewController: UIViewController {
    
    var qrcodeImage: CIImage!
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var bt_qrcode: UIButton!
    @IBOutlet var v_profile: UIView!
    @IBOutlet var lb_iHealt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.size.height / 2
        avatar.clipsToBounds = true
        
        v_profile.layer.masksToBounds = false
        v_profile.layer.cornerRadius = 8
        v_profile.clipsToBounds = true
        
        let defaults = UserDefaults.standard
        
        if let image = defaults.string(forKey: "personal_img_bin") {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("avatar.jpg")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(image, to: destination).response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    self.avatar.image = image
                }
            }
        }
        
        name.text = Personal.sharedInstance.firstname + " " + Personal.sharedInstance.lastname
        
        if qrcodeImage == nil {
            if Personal.sharedInstance.personal_link.count > 0 {
                let data = Personal.sharedInstance.personal_link.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
                let filter = CIFilter(name: "CIQRCodeGenerator")
                filter?.setValue(data, forKey: "inputMessage")
                filter?.setValue("Q", forKey: "inputCorrectionLevel")
                qrcodeImage = filter?.outputImage
                displayQRCodeImage()
            }
        } else {
            bt_qrcode.setImage(nil, for: .normal)
            qrcodeImage = nil
        }
    }

    func displayQRCodeImage() {
        let scaleX = bt_qrcode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = bt_qrcode.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        bt_qrcode.setImage(UIImage(ciImage: transformedImage), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func qrcodeAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showWebView", sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let navigationController = segue.destination as! UINavigationController
            let qrcodeDetail: WebViewController = navigationController.topViewController as! WebViewController
            qrcodeDetail.link = Personal.sharedInstance.personal_link
            qrcodeDetail.navigationItem.title = Personal.sharedInstance.firstname + " " + Personal.sharedInstance.lastname
        }
    }

}
