import UIKit

enum LabelStyle {
    case title
    case boldTitle
    case semiBoldTitle
    case largeTitle
    case subtitle
    case boldSubtitle
    case semiBoldSubtitle
    case errorTitle
}

final class TDLabel: UILabel {
    
    var labelText: String
    private var style: LabelStyle
    var size: CGFloat
    var alignment : NSTextAlignment
    init(labelText: String = "",
         style: LabelStyle = .title,
         size: CGFloat = 17,
         autoLayout: Bool = false,
         alignment: NSTextAlignment = .center
    ) {
        self.labelText = labelText
        self.style = style
        self.size = size
        self.alignment = alignment
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = !autoLayout
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        text = labelText
        
        switch style {
        case .title:
            textColor = .label
            font = .systemFont(ofSize: size)
        case .boldTitle:
            textColor = .label
            font = UIFont.boldSystemFont(ofSize: size)
        case .semiBoldTitle:
            textColor = .label
            font = UIFont.systemFont(ofSize: size, weight: .semibold)
        case .largeTitle:
            textColor = .label
            font = .preferredFont(forTextStyle: .largeTitle)
        case .subtitle:
            textColor = .secondaryLabel
            font = .systemFont(ofSize: size)
        case .boldSubtitle:
            textColor = .secondaryLabel
            font = UIFont.boldSystemFont(ofSize: size)
        case .semiBoldSubtitle:
            textColor = .secondaryLabel
            font = .systemFont(ofSize: size, weight: .semibold)

        case .errorTitle:
            textColor = .systemRed
            font = .systemFont(ofSize: size)
        }
    }
}
