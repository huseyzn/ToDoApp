//
//  LoginViewModel.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 14.09.25.
//

import Foundation
import Combine
import FirebaseAuth

protocol LoginDelegate: AnyObject {
    func didLogin()
}

final class LoginViewModel {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String = ""
    @Published private(set) var isFormValid: Bool = false
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    weak var delegate: LoginDelegate?
    private var cancellables = Set<AnyCancellable>()
    var networkMonitor = NetworkMonitor.shared
    
    init() {
        Publishers.CombineLatest($email, $password)
            .map { [weak self] email, pass in
                
                guard let self = self else { return false }
                
                guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
                      !pass.trimmingCharacters(in: .whitespaces).isEmpty
                else {
                    self.errorMessage = "Please fill all fields"
                    return false
                }
                
                guard isValidEmail(email) else {
                    self.errorMessage = "Enter a valid email"
                    return false
                }
                
                guard networkMonitor.isConnected else {
                    self.errorMessage = "Please check your internet connection"
                    return false
                }

                self.errorMessage = ""
                return true
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
    
    func login(completion: @escaping (String?) -> Void) {
        
        guard isFormValid else {
            completion(errorMessage)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                completion(errorMessage)
                return
            }
            
            completion(nil)
            self.delegate?.didLogin()
            
        }
        
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            .evaluate(with: email)
    }
    
}
