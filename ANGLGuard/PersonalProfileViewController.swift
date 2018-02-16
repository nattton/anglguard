import UIKit
import Alamofire

class PersonalProfileViewController: UIViewController {
    
    var qrcodeImage: CIImage!
    
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var qrcode: UIImageView!
    @IBOutlet var v_profile: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        v_profile.layer.masksToBounds = false
        v_profile.layer.cornerRadius = 8
        v_profile.clipsToBounds = true
        
        let defaults = UserDefaults.standard
        
        if let image = defaults.string(forKey: "image") {
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
        
        if let firstname = defaults.string(forKey: "firstname"), let lastname = defaults.string(forKey: "lastname") {
            name.text = firstname + " " + lastname
        } else {
            name.text = "-"
        }
        
        if qrcodeImage == nil {
            if let link = defaults.string(forKey: "link") {
                let data = link.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
                let filter = CIFilter(name: "CIQRCodeGenerator")
                filter?.setValue(data, forKey: "inputMessage")
                filter?.setValue("Q", forKey: "inputCorrectionLevel")
                qrcodeImage = filter?.outputImage
                displayQRCodeImage()
            }
        } else {
            qrcode.image = nil
            qrcodeImage = nil
        }
    }
    
    func displayQRCodeImage() {
        let scaleX = qrcode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrcode.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrcode.image = UIImage(ciImage: transformedImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.dismiss(animated: true, completion: nil)
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
