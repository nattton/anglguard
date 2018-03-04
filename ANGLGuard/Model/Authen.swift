import UIKit

class Authen: NSObject {
    var token: String = ""
    var type: String = "normal"
    var key: String = ""
    
    static let sharedInstance : Authen = {
        let instance = Authen()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
