import UIKit

final class TDAlertController: UIView {

    enum ButtonStyle {
        case normal
        case dangerous
    }
    
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let titleLabel = TDLabel(style: .boldTitle, size: 20)
    private let messageLabel = TDLabel(style: .subtitle, size: 14)
    
    private var buttons: [TDButton] = []

    init(title: String,
         message: String,
         isError: Bool = false,
         pinToEdge: Bool = true,
         buttons: TDButton...
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.buttons = buttons
        setupUI(title: title, message: message)
        if isError {
            titleLabel.textColor = .systemRed
            messageLabel.textColor = .systemPink.withAlphaComponent(0.8)
            containerView.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI(title: String, message: String) {
        backgroundView.frame = self.bounds
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        addSubview(backgroundView)

        containerView.backgroundColor = .systemBackground.withAlphaComponent(0.9)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 0.8

        addSubview(containerView)
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel] + buttons)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stack)

        stack.pinToEdges(of: containerView, padding: 30)
        
        containerView.pinToCenter(of: self)
        containerView.configSize(width: UIScreen.main.bounds.width * 0.8)
        
       alpha = 0
       transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    @discardableResult
    func createButton(title: String, style: ButtonStyle = .normal, action: (() -> Void)? = nil) -> TDButton {
        let button = TDButton(title: title) {
            action?()
            self.removeFromSuperview()
        }
        
        switch style {

        case .normal: break
            
        case .dangerous:
            button.backgroundColor = .systemRed
        }
        
        buttons.append(button)

        
        if let stack = containerView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            stack.addArrangedSubview(button)
        }
        return button
    }
    
    func showTemporarily(duration: TimeInterval = 2.0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            UIView.animate(withDuration: 0.25, animations: {
                self?.alpha = 0
                self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                self?.removeFromSuperview()
            }
        }
    }
}
