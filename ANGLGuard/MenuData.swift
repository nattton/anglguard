import Foundation

public struct Item {
    var name: String
    var identifier: String
    
    public init(name: String, identifier: String) {
        self.name = name
        self.identifier = identifier
    }
}

public struct Section {
    var name: String
    var icon: String
    var identifier: String
    var items: [Item]
    var collapsed: Bool
    
    public init(name: String, icon: String, identifier: String, items: [Item], collapsed: Bool = false) {
        self.name = name
        self.icon = icon
        self.identifier = identifier
        self.items = items
        self.collapsed = collapsed
    }
}

public var menuData: [Section] = [
    Section(name: "nav_home", icon: "ic_home", identifier: "angllife", items: [], collapsed: true),
    Section(name: "nav_profile", icon: "ic_profile", identifier: "", items: [
        Item(name: "sub_personal", identifier: "personalProfile"),
         Item(name: "sub_mobile", identifier: "telephoneNumber"),
         Item(name: "sub_passport", identifier: "passportProfile"),
         Item(name: "sub_medical", identifier: "medicalProfile"),
         Item(name: "sub_contact", identifier: "contactProfile"),
         Item(name: "sub_trip_plan", identifier: "tripPlan"),
         Item(name: "sub_insurance", identifier: "insurance"),
         Item(name: "sub_change_password", identifier: "changePassword"),
         Item(name: "login_forgot_password", identifier: "forgotPassword")
        ], collapsed: true
    ),
    Section(name: "nav_device_setting", icon: "ic_device", identifier: "group", items: [], collapsed: true),
    Section(name: "nav_notification", icon: "ic_notification", identifier: "notification", items: [], collapsed: true),
    Section(name: "nav_faq", icon: "ic_faq", identifier: "faq", items: [], collapsed: true),
    Section(name: "nav_privilege", icon: "ic_privilege", identifier: "privilege", items: [], collapsed: true),
    Section(name: "nav_language", icon: "ic_language", identifier: "language", items: [], collapsed: true),
    Section(name: "nav_term", icon: "ic_condition", identifier: "term", items: [], collapsed: true),
    Section(name: "nav_sign_out", icon: "ic_signout", identifier: "login", items: [], collapsed: true)
]
