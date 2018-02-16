import UIKit
import MapKit

enum AttractionType: Int {
    case current = 0
    case hospital
    case ambulance
    
    func image() -> UIImage {
        switch self {
        case .current:
            return #imageLiteral(resourceName: "im_avatar")
        case .hospital:
            return #imageLiteral(resourceName: "ic_hospital")
        case .ambulance:
            return #imageLiteral(resourceName: "ic_ambulance")
        }
    }
}

class AttractionAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var type: AttractionType
    var icon: String?
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, type: AttractionType, icon: String) {
        self.coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        self.title = title
        self.type = type
        self.icon = icon
    }
    
}
