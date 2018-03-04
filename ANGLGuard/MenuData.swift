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
    Section(name: "Home", icon: "ic_home", identifier: "angllife", items: [], collapsed: true),
    Section(name: "Profile", icon: "ic_profile", identifier: "", items: [
        Item(name: "Personal", identifier: "personalProfile"),
         Item(name: "Mobile", identifier: "telephoneNumber"),
         Item(name: "Passport", identifier: "passportProfile"),
         Item(name: "Medical", identifier: "medicalProfile"),
         Item(name: "Contact", identifier: "contactProfile"),
         Item(name: "Trip Plan", identifier: "tripPlan"),
         Item(name: "Insurance", identifier: "insurance"),
         Item(name: "Change password", identifier: "changePassword"),
         Item(name: "Forget password", identifier: "forgotPassword")
        ], collapsed: true),
    Section(name: "Group", icon: "ic_device", identifier: "group", items: [], collapsed: true),
    Section(name: "Notification", icon: "ic_notification", identifier: "notification", items: [], collapsed: true),
    Section(name: "Language", icon: "ic_language", identifier: "language", items: [], collapsed: true),
    Section(name: "Term & Conditions", icon: "ic_condition", identifier: "term", items: [], collapsed: true),
    Section(name: "Sign Out", icon: "ic_signout", identifier: "login", items: [], collapsed: true)
]
