import UIKit

class NAlertCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var photo1: UIImageView!
    @IBOutlet var photo2: UIImageView!
    @IBOutlet var photo3: UIImageView!
    @IBOutlet var photo4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
