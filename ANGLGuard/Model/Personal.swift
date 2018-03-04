import UIKit

class Personal: NSObject {
    var email: String = ""
    var password: String = ""
    var firstname: String = ""
    var middlename: String = ""
    var lastname: String = ""
    var gender: String = ""
    var birthdate: String = ""
    var height: String = ""
    var weight: String = ""
    var country_code: String = ""
    var passport_num: String = ""
    var passport_expire_date: String = ""
    var mobile_num: String = ""
    var mobile_cc: String = ""
    var thai_mobile_num: String = ""
    var thai_mobile_cc: String = ""
    var personal_img_bin: UIImage?
    var passport_img: UIImage?
    
    static let sharedInstance : Personal = {
        let instance = Personal()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
