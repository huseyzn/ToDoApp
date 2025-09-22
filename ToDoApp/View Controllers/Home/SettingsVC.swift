//
//  SettingsVC.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 02.09.25.
//

import UIKit
import FirebaseAuth
class SettingsVC: UIViewController {
    
    private let containerHeight: CGFloat = 60
    private let horizontalPadding: CGFloat = 16
    private let separatorHeight: CGFloat = 0.5
    
    let settings2DList = [["Show Alert on Toggle", "showAlertOnToggle"], ["Dark Mode", "isDark"], ["Will Be More", ""]]
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var logoutButton = TDButton(title: "Logout", cornerRadius: 20, bgColor: .systemBlue, useAutoLayout: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc
    func logout() {
        
        let alert = TDAlertController(title: "Logout", message: "Are you sure you want to logout?")

        alert.createButton(title: "Logout", style: .dangerous) { [weak self] in
            guard let self = self else { return }
            do {
                try Auth.auth().signOut()
                let loginVC = LoginVC()
                navigationController?.setViewControllers([loginVC], animated: true)
                print("Logged out")
            } catch {
                print("Logout error:", error.localizedDescription)
            }
        }
        
        alert.createButton(title: "Cancel", style: .normal)
        
        view.addSubview(alert)
        
        alert.pinToEdges(of: view)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(logoutButton)
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        scrollView.pinToSafeArea(of: view)
        
        stackView.pinWithFlexibleHeight(to: scrollView, padding: 10)
        stackView.configWidthSize(from: scrollView, constant: -20)
        
        logoutButton.anchor(top: stackView.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            paddingTop: 20,
                            paddingLeft: 20,
                            paddingRight: 20)
        
        logoutButton.configSize(height: 50)
        
        
        for (index, setting) in settings2DList.enumerated() {
            let labelText = setting[0]
            let key = setting[1]
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.tag = index
            label.text = labelText
            label.font = label.tag == 2 ? .boldSystemFont(ofSize: 18) : .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let toggle = UISwitch()
            toggle.tag = index
            toggle.translatesAutoresizingMaskIntoConstraints = false
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            if toggle.tag == 0 && UserDefaults.standard.object(forKey: key) == nil {
                UserDefaults.standard.set(true, forKey: key)
            }
            toggle.isOn = UserDefaults.standard.bool(forKey: key)
            toggle.isHidden = toggle.tag == 2
            
            
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor.separator
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            
            
            [label, toggle, separatorLine].forEach { view in
                containerView.addSubview(view)
            }
            
            containerView.configSize(height: containerHeight)
            
            label.anchor(leading: containerView.leadingAnchor,
                         paddingLeft: horizontalPadding)
            
            label.centerY(of: containerView)
            
            toggle.anchor(trailing: containerView.trailingAnchor,
                          paddingRight: horizontalPadding)
            
            toggle.centerY(of: containerView)
            

            separatorLine.anchor(leading: containerView.leadingAnchor,
                                 bottom: containerView.bottomAnchor,
                                 trailing: containerView.trailingAnchor,
                                 paddingLeft: horizontalPadding,
                                 paddingRight: horizontalPadding)
            
            separatorLine.configSize(height: separatorHeight)
            
            stackView.addArrangedSubview(containerView)
        }
    }
    
    @objc
    func switchChanged(_ sender: UISwitch) {
        let key = settings2DList[sender.tag][1]
        UserDefaults.standard.set(sender.isOn, forKey: key)
        
        if key == "isDark" {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
            }
        }
        
    }
}

#Preview {
    UINavigationController(rootViewController: SettingsVC())
}
