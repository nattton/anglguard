import UIKit

class NAlertCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var photo1: UIButton!
    @IBOutlet var photo2: UIButton!
    @IBOutlet var photo3: UIButton!
    @IBOutlet var photo4: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
