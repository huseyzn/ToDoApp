import UIKit

final class TDImageView: UIImageView {

    override var image: UIImage? {
        get {
            return super.image
        } set {
            super.image = newValue
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        } set {
            super.backgroundColor = newValue
        }
    }
    
    
    var mode: UIView.ContentMode = .scaleAspectFit
    
    var autoLayout: Bool = false
    
    var cornerRadius: CGFloat = 8
    
    init(image: UIImage? = nil, backgroundColor: UIColor? = .clear, mode: UIView.ContentMode = .scaleAspectFill, autoLayout: Bool = false, cornerRadius: CGFloat = 8) {
        super.init(frame: .zero)
        self.image = image
        self.backgroundColor = backgroundColor
        self.mode = mode
        self.autoLayout = !autoLayout
        self.cornerRadius = cornerRadius
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.image = image
        self.backgroundColor = backgroundColor
        self.contentMode = mode
        self.translatesAutoresizingMaskIntoConstraints = autoLayout
        self.layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
}
