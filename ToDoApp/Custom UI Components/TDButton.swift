import UIKit

final class TDButton: UIButton {
    

    var title: String?
    var cornerRadius: CGFloat
    var bgColor: UIColor
    var useAutoLayout: Bool
    var action : (() -> Void)?
    
    init(title: String,
         cornerRadius: CGFloat = 8,
         bgColor: UIColor = .systemBlue,
         useAutoLayout: Bool = false,
         action: (() -> Void)? = nil
    ) {
        self.title = title
        self.cornerRadius = cornerRadius
        self.bgColor = bgColor
        self.useAutoLayout = useAutoLayout
        self.action = action
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        var config = UIButton.Configuration.plain()
        setTitle(title, for: .normal)
        config.titleAlignment = .center
        layer.cornerRadius = cornerRadius
        configuration = config
        layer.masksToBounds = true
        layer.borderWidth = 0.8
        layer.borderColor = UIColor.secondaryLabel.cgColor
        backgroundColor = bgColor
        tintColor = .systemGray6
        
        translatesAutoresizingMaskIntoConstraints = !useAutoLayout
        
        addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }
    
    @objc
    func handleAction() {
        action?()
    }
}
