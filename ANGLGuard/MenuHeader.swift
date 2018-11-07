import UIKit
import QuartzCore

protocol MenuHeaderDelegate {
    func toggleSection(_ header: MenuHeader, section: Int)
}

class MenuHeader: UITableViewHeaderFooterView {

    var delegate: MenuHeaderDelegate?
    var section: Int = 0
    
    let iconImage = UIImageView()
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    let badgeLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        self.backgroundColor = UIColor.lightGray
        contentView.backgroundColor = UIColor(hex: 0xFFFFFF)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // Icon Image
        iconImage.contentMode = .scaleAspectFit
        contentView.addSubview(iconImage)
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        iconImage.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        iconImage.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: 8.0).isActive = true
        iconImage.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // Title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 8.0).isActive = true
        
        // Arrow label
        contentView.addSubview(arrowLabel)
        arrowLabel.textColor = UIColor.black
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        arrowLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        arrowLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // Badge Number
        contentView.addSubview(badgeLabel)
        badgeLabel.textColor = UIColor.white
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        badgeLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        badgeLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        badgeLabel.layer.backgroundColor  = UIColor.red.cgColor
        badgeLabel.layer.cornerRadius = 12
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MenuHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MenuHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        arrowLabel.rotate(collapsed ? 0.0 : .pi / 2)
    }

}

extension UIColor {
    
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
    
}

extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}
