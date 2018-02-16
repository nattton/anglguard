import UIKit

class NMessageCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
