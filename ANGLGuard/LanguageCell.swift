import UIKit

class LanguageCell: UITableViewCell {
    
    @IBOutlet var language: UILabel!
    @IBOutlet var current: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
