//
//  LoginVC.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 09.09.25.
//

import UIKit

class LoginVC: UIViewController {

    let signUpVM = SignUpViewModel()
    let loginVM = LoginViewModel()

    //MARK: - Views
    private lazy var stackView = TDStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 15)
    
    private lazy var usernameTextField = TDTextField(ph: "Email", kbType: .default, leftPadding: 10, useAutoLayout: true)
    
    private lazy var passwordTextField = TDTextField(ph: "Password", isSecure: true, kbType: .default, leftPadding: 10, useAutoLayout: true)
    
    private lazy var loginButton = TDButton(title: "Login", cornerRadius: 10){ [weak self] in
        
        guard let self = self else { return }

        self.loginVM.email = self.usernameTextField.text ?? ""
        self.loginVM.password = self.passwordTextField.text ?? ""
        
        self.loginVM.login { error in
            if let error = error {
                self.showTemporarilyAlert(title: "Login error", message: error, isError: true)
            }
        }
    }
    
    private lazy var goToSignUpVCButton = TDButton(title: "Sign Up", cornerRadius: 10, bgColor: .systemOrange) { [weak self] in
        guard let self = self else { return }
        let vc = SignUpVC()
        vc.viewModel.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func createDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configSize(height: 1)
        return view
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleLogin()
        loginVM.delegate = self
    }
    
    //MARK: - Bind ViewModel
    func handleLogin(){
        usernameTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc func textChanged(){
        loginVM.email = usernameTextField.text ?? ""
        loginVM.password = passwordTextField.text ?? ""
    }
    
    //MARK: - Setup User Interface
    func setupUI() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        title = "Login"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [usernameTextField, passwordTextField].forEach { view in
            stackView.addArrangedSubview(view)
            view.configSize(height: 50)
            view.autocapitalizationType = .none
        }
        
        [loginButton, createDivider(), goToSignUpVCButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        [loginButton, goToSignUpVCButton].forEach { view in
            view.configSize(height: 50)
        }
        
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         paddingTop: 40,
                         paddingLeft: 10,
                         paddingRight: 10)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

    }
    
    //MARK: - Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

//MARK: - Delegates
extension LoginVC: SignUpDelegate, LoginDelegate {
    
    func didSignUp() {
        showTemporarilyAlert(title: "Sign Up", message: "You successfully signed up", duration: 2)
    }

    
    func didLogin() {
        let vc = HomeVC()
        navigationController?.setViewControllers([vc], animated: true)
    }
    
}


#Preview {
    UINavigationController(rootViewController: LoginVC())
}
