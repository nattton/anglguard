import UIKit
import MapKit
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
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
                imageView.af_setImage(withURL: url)
                image = imageView.image?.resizeImage(42, opaque: false)
            }
        }
    }
    
}
