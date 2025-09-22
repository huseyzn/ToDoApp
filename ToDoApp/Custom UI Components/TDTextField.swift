import UIKit

final class TDTextField: UITextField {
    
    var ph: String = ""
    var isSecure: Bool = false
    var kbType: UIKeyboardType = .default
    var leftPadding: CGFloat = 0
    var rightPadding: CGFloat = 0
    var useAutoLayout: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init(ph: String,
         isSecure: Bool = false,
         kbType: UIKeyboardType = .default,
         leftPadding: CGFloat = 0,
         rightPadding: CGFloat = 0,
         useAutoLayout: Bool = false
    ) {
        self.ph = ph
        self.isSecure = isSecure
        self.kbType = kbType
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        self.useAutoLayout = useAutoLayout
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        borderStyle = .none
        placeholder = ph
        isSecureTextEntry = isSecure
        keyboardType = kbType
        backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.05)
            : UIColor.lightGray.withAlphaComponent(0.1)
        }
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondaryLabel.cgColor
        textColor = .label
        font = .systemFont(ofSize: 16)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = !useAutoLayout
        autocorrectionType = .no
        setLeftPadding(leftPadding)
        setRightPadding(rightPadding)
    }
    
    override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    private func updatePlaceholder() {
        guard let text = placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemBlue.withAlphaComponent(0.4)
                : UIColor.systemBlue.withAlphaComponent(0.4)
            ]
        )
    }
}
