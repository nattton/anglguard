import UIKit
import MapKit
import Alamofire
import AlamofireImage

class AttractionAnnotationView: MKAnnotationView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let attractionAnnotation = self.annotation as? AttractionAnnotation else { return }
        
        if (attractionAnnotation.icon!.isEmpty) {
            image = attractionAnnotation.type.image()
        } else {
            let eImg: String! = attractionAnnotation.icon!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url = URL(string: eImg){
                Alamofire.request(url, method: .get).responseImage { response in
                    guard let topImage = response.result.value else { return }
                    let imageName = attractionAnnotation.status == "A" ? "im_pin_active.png" : "im_pin_inactive.png"
                    let bottomImage = UIImage(named: imageName)
                    self.image = UIImage().merge(bottom: bottomImage!, top: topImage)
                }
            }
        }
    }
    
}

extension UIImage {
    
    var circle: UIImage {
        let sizeWidth = CGSize(width: size.width, height: size.width)
        let sizeHeight = CGSize(width: size.height, height: size.height)
        let square = size.width < size.height ? sizeWidth : sizeHeight
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func merge(bottom: UIImage, top: UIImage) -> UIImage {
        let size = CGSize(width: bottom.size.width, height: bottom.size.height)
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottom.draw(in: rect)
        
        let avatarWidth = size.width * 0.8
        let x = rect.size.width / 2 - avatarWidth / 2
        let y = rect.size.height * 0.065
        let avatarSize = CGRect(x: x, y: y, width: avatarWidth, height: avatarWidth)
        top.circle.draw(in: avatarSize, blendMode: .normal, alpha: 1)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
