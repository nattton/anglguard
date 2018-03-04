import UIKit

class Medical: NSObject {
    var blood_type: String = ""

    var seizures: String = "0"
    var insuline: String = "0"
    var iodine: String = "0"
    var penicillin: String = "0"
    var sulfa: String = "0"
    var allergy_drug_others: String = ""
    
    var milk: String = "0"
    var eggs: String = "0"
    var fish: String = "0"
    var crustacean_shellfish: String = "0"
    var tree_nuts: String = "0"
    var peanuts: String = "0"
    var wheat: String = "0"
    var soybeans: String = "0"
    var allergy_food_others: String = ""
    
    var shampoos: String = "0"
    var shampoos_brand: String = ""
    var fragrances: String = "0"
    var fragrances_brand: String = ""
    var cleaners: String = "0"
    var cleaners_brand: String = ""
    var detergents: String = "0"
    var detergents_brand: String = ""
    var cosmetics: String = "0"
    var cosmetics_brand: String = ""
    var allergy_chemical_others: String = ""
    
    var diabetes_mellitus: String = "0"
    var hypertension: String = "0"
    var chronic_kidney_disease: String = "0"
    var heart_disease: String = "0"
    var old_stroke: String = "0"
    var underlying_others: String = ""
    
    var current_medication_description: String = ""
    
    var no_need: String = "0"
    var assistive_environmental_devices: String = "0"
    var gait_aid: String = "0"
    var wheelchair: String = "0"
    var care_giver_one: String = "0"
    var care_giver_two: String = "0"
    
    static let sharedInstance : Medical = {
        let instance = Medical()
        return instance
    }()
    
    override init() {
        super.init()
    }
}
