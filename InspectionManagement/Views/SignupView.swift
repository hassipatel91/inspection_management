//
//  SignupView.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import SwiftUI

struct SignupView: View {
    // ViewModel to handle registration logic
    @StateObject private var viewModel = AuthenticationViewModel()
    
    // State variables for alerts
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            // App Logo
            Image(systemName: "person.crop.circle.fill.badge.plus")
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

            // Register Button
            Button(action: {
                // Attempt to register and handle result
                viewModel.registerUser { result in
                    switch result {
                    case .success:
                        // Clear fields and show success message
                        viewModel.email = ""
                        viewModel.password = ""
                        alertMessage = "Registration successful! Please log in."
                    case .failure(let error):
                        // Show error message
                        alertMessage = error.localizedDescription
                    }
                    showAlert = true
                }
            }) {
                Text("Register")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            // Show an alert with the result of the registration
            Alert(
                title: Text("Registration"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
