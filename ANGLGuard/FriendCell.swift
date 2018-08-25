import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var more: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
