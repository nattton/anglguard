import UIKit

class FirstAidCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var detail: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
