//
//  SignUpViewModel.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 11.09.25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

protocol SignUpDelegate: AnyObject {
    func didSignUp()
}

final class SignUpViewModel {
    
    @Published var username: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""
    
    @Published private(set) var isFormValid: Bool = false
    @Published private(set) var errorMessage: String = ""
    
    weak var delegate: SignUpDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        Publishers.CombineLatest(
            Publishers.CombineLatest4($name, $email, $password, $passwordAgain),
            $username)
        .map { [weak self] firstFour, username in
            let (name, email, pass, passAgain) = firstFour
            
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
                  !email.trimmingCharacters(in: .whitespaces).isEmpty,
                  !pass.trimmingCharacters(in: .whitespaces).isEmpty,
                  !passAgain.trimmingCharacters(in: .whitespaces).isEmpty
            else {
                self?.errorMessage = "Please fill all fields"
                return false
            }
            guard self?.isValidEmail(email) == true else {
                self?.errorMessage = "Enter a valid email"
                return false
            }
            
            guard name.count >= 3 else {
                self?.errorMessage = "Name must be at least 3 characters long"
                return false
            }
            guard pass.count >= 7 else {
                self?.errorMessage = "Password must be at least 7 characters long"
                return false
            }
            guard pass == passAgain else {
                self?.errorMessage = "Passwords do not match"
                return false
            }
            
            guard NetworkMonitor.shared.isConnected else {
                self?.errorMessage = "Please check your internet connection"
                return false
            }
            
            self?.errorMessage = ""
            return true
        }
        .assign(to: \.isFormValid, on: self)
        .store(in: &cancellables)
    }
    
    func register(completion: @escaping (Bool) -> Void) {
        
        guard isFormValid else {
            errorMessage = "Please fill all fields correctly"
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let userID = result?.user.uid else {
                self.errorMessage = "User ID not found"
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.createUser(id: userID) { [weak self] success in
                guard let self = self else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                if !success {
                    self.errorMessage = "Failed to save user data"
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                do {
                    
                    try Auth.auth().signOut()
                    
                    DispatchQueue.main.async {
                        self.delegate?.didSignUp()
                        completion(true)
                    }
                    
                } catch {
                    
                    self.errorMessage = "Couldn't sign out after registration"
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    private func createUser(id: String, completion: @escaping (Bool) -> Void) {
        
        let newUser: [String: Any] = [
            "id": id,
            "name": name,
            "email": email,
            "username": username,
            "joined": Date().timeIntervalSince1970
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(id)
            .setData(newUser) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            .evaluate(with: email)
        
    }
    
    private func checkUsernameAvailability(completion: @escaping (Bool) -> Void) {
        
        Firestore.firestore()
            .collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                completion(snapshot?.documents.isEmpty ?? false)
            }
        
    }
    
}

extension Encodable {
    
    func asDict() -> [String : Any] {
        
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            return json ?? [:]
            
        } catch {
            return [:]
        }
    }
    
}
