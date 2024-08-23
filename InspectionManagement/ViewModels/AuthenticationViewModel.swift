//
//  AuthenticationViewModel.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import Combine
import Foundation

class AuthenticationViewModel: ObservableObject {
    // Published properties to bind to the view
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isEmailValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var alertMessage: String = ""
    
    // Set to hold any Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Initialization method
    init() {
        setupValidation() // Set up validation for email and password
    }
    
    // Set up validation for email and password
    func setupValidation() {
        // Validate email format
        $email
            .map { email in
                // Regular expression for validating email format
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}")
                return emailPredicate.evaluate(with: email)
            }
            .assign(to: &$isEmailValid) // Bind the result to isEmailValid property
        
        // Validate if password is not empty
        $password
            .map { password in
                !password.isEmpty
            }
            .assign(to: &$isPasswordValid) // Bind the result to isPasswordValid property
    }
    
    // Function to handle user registration
    func registerUser(completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if email and password are valid
        if isEmailValid && isPasswordValid {
            let authData = AuthenticationReq(email: email, password: password) // Prepare authentication data
            // Send registration request
            NetworkManager.shared.postRequest(url: "/api/register", body: authData) { result in
                switch result {
                case .success:
                    completion(.success(())) // Call completion handler with success
                case .failure(let error):
                    completion(.failure(error)) // Call completion handler with failure
                }
            }
        } else {
            // Set error message if email or password is invalid
            alertMessage = "Invalid email or password"
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: alertMessage])))
        }
    }
    
    // Function to handle user login
    func loginUser(completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if email and password are valid
        if isEmailValid && isPasswordValid {
            let authData = AuthenticationReq(email: email, password: password) // Prepare authentication data
            // Send login request
            NetworkManager.shared.postRequest(url: "/api/login", body: authData) { result in
                switch result {
                case .success:
                    completion(.success(())) // Call completion handler with success
                case .failure(let error):
                    completion(.failure(error)) // Call completion handler with failure
                }
            }
        } else {
            // Set error message if email or password is invalid
            alertMessage = "Invalid email or password"
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: alertMessage])))
        }
    }
}
