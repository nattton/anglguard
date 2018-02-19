import UIKit
import SidebarOverlay

class InitalViewController: SOContainerViewController {

    override var isSideViewControllerPresented: Bool {
        didSet {
            let action = isSideViewControllerPresented ? "opened" : "closed"
            let side = self.menuSide == .left ? "left" : "right"
            NSLog("You've \(action) the \(side) view controller.")
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
        self.widthForPanGestureRecognizer = 1
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
