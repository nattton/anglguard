import UIKit

class Trip: NSObject {
    var purpose: String = ""
    var start_date: String = ""
    var duration: String = ""
    var average_expen: String = ""
    var trip_arrang: String = ""
    var domestic_tran_arrang: String = ""
    var destination: String = ""
    
    static let sharedInstance : Trip = {
        let instance = Trip()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
