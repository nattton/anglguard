import UIKit

class PrivilegeCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var banner: UIImageView!
    @IBOutlet var detail: UILabel!
    @IBOutlet var content: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        
        banner.layer.cornerRadius = 8
        banner.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
