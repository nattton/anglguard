import UIKit
import SidebarOverlay

class InitalViewController: SOContainerViewController {

    override var isSideViewControllerPresented: Bool {
        didSet {
//            let action = isSideViewControllerPresented ? "opened" : "closed"
//            let side = self.menuSide == .left ? "left" : "right"
//            NSLog("You've \(action) the \(side) view controller.")
            if isSideViewControllerPresented {
                let menuView = self.sideViewController as! MenuViewController
                menuView.setInit()
                menuView.tb_menu.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMenu()
        setNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setMenu() {
        self.menuSide = .left
        self.widthForPanGestureRecognizer = 0
        self.sideMenuWidth = 300
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "angllife")
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "menu")
    }
    
    func setNavigation() {
        UINavigationBar.appearance().tintColor = UIColor.black
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

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIViewContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func toBase64() -> String {
        let imageData = UIImagePNGRepresentation(self)
        let base64String = imageData?.base64EncodedString(options: .endLineWithLineFeed)
        return base64String!
    }
}

extension NSMutableArray {
    
    func getStringResultSelect() -> String {
        var results = ""
        for (index, value) in self.enumerated() {
            if index == self.count - 1 {
                results = results + (value as! String)
            } else {
                results = results + (value as! String) + ", "
            }
        }
        
        return results
    }
    
}

extension String {
    
    func MD5() -> String {
//        let length = Int(CC_MD5_DIGEST_LENGTH)
//        var digest = [UInt8](repeating: 0, count: length)
//        if let d = self.data(using: String.Encoding.utf8) {
//            d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
//                CC_MD5(body, CC_LONG(d.count), &digest)
//            }
//        }
//        return (0..<length).reduce("") {
//            $0 + String(format: "%02x", digest[$1])
//        }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = self.data(using: String.Encoding.utf8) {
//            CC_MD5(data, CC_LONG(data.count), &digest)
            _ = data.withUnsafeBytes {bytes in
                CC_MD5(bytes, CC_LONG(data.count), &digest)
            }
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    var md5: String {
        guard let data = self.data(using: String.Encoding.utf8) else { return "" }
        
        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func encrypt() -> String {
        let encrypted: String = self + MD5_KEY
        return encrypted.md5
    }
    
    func fromBase64() -> UIImage {
        let decodedData = Data(base64Encoded: self, options: .ignoreUnknownCharacters)
        let decodedimage = UIImage(data: decodedData!)
        return decodedimage!
    }
    
    func language() -> String {
        return self.replacingOccurrences(of: "zh-Hans", with: "cn").uppercased()
    }
    
}
