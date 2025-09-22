//
//  Extensions.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 09.09.25.
//

import UIKit
extension UIView {
    /// Pins to the super view with equal padding
    func pinToEdges(of superView: UIView, padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -padding),
        ])
    }
    
    /// Pins to the super view except bottom anchor with equal padding
    func pinWithFlexibleHeight(to superView: UIView, padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -padding),
        ])
    }
    
    /// Pins to the super view with safe area layout guide, equal padding, you can do padding top only too
    func pinToSafeArea(of superView: UIView, padding: CGFloat = 0, paddingTop: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: paddingTop ?? padding),
            leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
        ])
    }
    
    /// Pins to the center of the super view
    func pinToCenter(of superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }
    
    func centerY(of superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }
    
    func centerX(of superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
    }

    /// for anchor
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                centerY: NSLayoutYAxisAnchor? = nil,
                centerX: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -paddingRight).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    /// for addsubview
    func addSubviewsFromExt(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }

    ///width size with constraint
    func configWidthSize(from superView: UIView, constant: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let constant = constant {
            widthAnchor.constraint(equalTo: superView.widthAnchor, constant: constant).isActive = true
        }
    }
    ///height size with constraint
    func configHeightSize(from superView: UIView, constant: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let constant = constant {
            heightAnchor.constraint(equalTo: superView.heightAnchor, constant: constant).isActive = true
        }
    }
    
    /// for width and height
    func configSize(height: CGFloat? = nil, width: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
}

extension UITextField {
    
    func setStandardConstraints(to superview: UIView, height: CGFloat = 40, verticalPadding: CGFloat = 0, horizontalPadding: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: verticalPadding),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -verticalPadding),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIViewController {
    func showCustomAlert(title: String, message: String, withOkButton: Bool = true, isError: Bool = false) {
        let alert = TDAlertController(title: title, message: message, isError: isError)
        if withOkButton {
            alert.createButton(title: "OK", action: nil)
        }
        self.view.addSubview(alert)
        alert.pinToEdges(of: self.view)
    }
    
    func showTemporarilyAlert(title: String, message: String, isError: Bool = false, duration: TimeInterval = 1.5) {
        let alert = TDAlertController(title: title, message: message, isError: isError)

        self.view.addSubview(alert)

        alert.pinToCenter(of: view)

        alert.showTemporarily(duration: duration)
    }
}
