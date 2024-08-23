//
//  LoginView.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import SwiftUI

struct LoginView: View {
    // ViewModel to handle authentication logic
    @StateObject private var viewModel = AuthenticationViewModel()
    
    // State variables for navigation and alerts
    @State private var showInspectionView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRegisterView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App Logo
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 40)

                // Email TextField
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)

                // Password SecureField
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .padding(.horizontal, 30)

                // Login Button
                Button(action: {
                    // Attempt to log in and handle result
                    viewModel.loginUser { result in
                        switch result {
                        case .success:
                            // Navigate to InspectionListView on success
                            showInspectionView = true
                        case .failure(let error):
                            // Show alert on failure
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                }) {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                // Register Button
                Button(action: {
                    // Show registration view
                    showRegisterView = true
                }) {
                    Text("Register")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                // Show an alert if login fails
                Alert(
                    title: Text("Login Failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $showInspectionView) {
                // Navigate to InspectionListView
                InspectionListView()
            }
            .navigationDestination(isPresented: $showRegisterView) {
                // Navigate to SignupView
                SignupView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

