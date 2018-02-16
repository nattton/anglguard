import UIKit

class HospitalCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var thumb: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
