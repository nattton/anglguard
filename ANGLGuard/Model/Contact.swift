import UIKit

class Contact: NSObject {
    var firstname: String = ""
    var middlename: String = ""
    var lastname: String = ""
    var contact_number: String = ""
    var contact_number_cc: String = ""
    var relation: String = ""
    var email: String = ""
    
    static let sharedInstance : Contact = {
        let instance = Contact()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
