import UIKit

class Insurance: NSObject {
    var policy_number: String = "0"
    var start_date: String = "0"
    var expiration_date: String = "0"
    var insurance_company: String = "0"
    var contact_name: String = "0"
    var contact_number_cc: String = "0"
    var contact_number: String = "0"
    
    static let sharedInstance : Insurance = {
        let instance = Insurance()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
