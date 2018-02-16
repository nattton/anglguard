import UIKit

class AngllifeCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var email: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
