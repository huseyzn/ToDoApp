//
//  SignUpVC.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 09.09.25.
//

import UIKit
import Combine

class SignUpVC: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    var viewModel = SignUpViewModel()
    
    //MARK: - Views
    var stackView = TDStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 10, autoLayout: true)
    
    var nameTF = TDTextField(ph: "Name", leftPadding: 10, useAutoLayout: true)
    var usernameTF = TDTextField(ph: "Username", leftPadding: 10, useAutoLayout: true)
    var emailTF = TDTextField(ph: "Email", leftPadding: 10, useAutoLayout: true)
    var passwordTF = TDTextField(ph: "Password", isSecure: true, leftPadding: 10, useAutoLayout: true)
    var passwordAgainTF = TDTextField(ph: "Password again", isSecure: true, leftPadding: 10, useAutoLayout: true)
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    lazy var signUpButton = TDButton(title: "Sign Up", cornerRadius: 10, bgColor: .systemOrange, useAutoLayout: true) { [weak self] in
        guard let self = self else {return}

            if !self.viewModel.errorMessage.isEmpty {
                self.showTemporarilyAlert(title: "Sign up error", message: self.viewModel.errorMessage, isError: true)
                return
            }
            
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            
            self.viewModel.register { [weak self] success in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    if success {
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        let errorMessage = self.viewModel.errorMessage.isEmpty ? "Registration failed" : self.viewModel.errorMessage
                        self.showTemporarilyAlert(title: "Sign up error", message: errorMessage, isError: true)
                    }
                }
            }
    }
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    //MARK: - Dismiss Keyboard Func
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Setup User Interface
    func setupUI(){
        view.backgroundColor = .systemBackground
        title = "Sign Up"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = LoginVC().title
        view.addSubview(stackView)
        [nameTF, usernameTF, emailTF, passwordTF, passwordAgainTF, signUpButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    }
    
    //MARK: - Bind ViewModel
    private func bindViewModel() {
        [nameTF, usernameTF, emailTF, passwordTF, passwordAgainTF].forEach {
            $0.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
            if $0 !== nameTF {
                $0.autocapitalizationType = .none
            }
        }
    }
    @objc private func textChanged(_ sender: UITextField) {
        viewModel.name          = nameTF.text ?? ""
        viewModel.username      = usernameTF.text ?? ""
        viewModel.email         = emailTF.text ?? ""
        viewModel.password      = passwordTF.text ?? ""
        viewModel.passwordAgain = passwordAgainTF.text ?? ""
    }
    
    //MARK: - Constraints
    func setupConstraints(){
        stackView.pinWithFlexibleHeight(to: view, padding: 20)
        
        let views = [nameTF, usernameTF, emailTF, passwordTF, passwordAgainTF, signUpButton]
        
        views.forEach { view in
            view.configSize(height: 50)
        }
        activityIndicator.pinToCenter(of: view)
    }
}

#Preview {
    UINavigationController(rootViewController: SignUpVC())
}
