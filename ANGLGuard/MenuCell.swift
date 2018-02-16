import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if selected == true {
//            icon.image = UIImage(named: "icon_selected")
//        } else {
//            icon.image = UIImage(named: "icon_unselect")
//        }
    }

}
