//
//  InspectionListView.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import SwiftUI


struct InspectionListView: View {
    // ViewModel to manage inspections
    @StateObject private var viewModel = InspectionViewModel()
    
    // State variables for navigation and alerts
    @State private var showInspectionDetail = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // List displaying all inspections
                List(viewModel.inspections) { inspection in
                    Button(action: {
                        // Set selected inspection and show detail view
                        viewModel.inspection = inspection
                        showInspectionDetail = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                // Inspection ID
                                Text("Inspection \(inspection.id)")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                // Area name
                                Text("\(inspection.area.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                // Status of the inspection
                                Text("Status: \(inspection.status!.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(inspection.status == .completed ? .orange : (inspection.status == .submitted ? .green : .red))
                            }
                            Spacer()
                            // Chevron icon indicating navigation
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                    .padding(.vertical, 5)
                }
                .onAppear {
                    // Load inspections from Core Data when view appears
                    viewModel.loadInspectionsFromCoreData()
                }
            }
            .navigationTitle("Inspections")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Start a new inspection and handle result
                        viewModel.startNewInspection { result in
                            switch result {
                            case .success(let inspection):
                                viewModel.inspection = inspection.inspection
                                showInspectionDetail = true
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }) {
                        // Icon for starting a new inspection
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $showInspectionDetail) {
                // Navigate to inspection detail view
                InspectionDetailView(viewModel: viewModel)
            }
            .alert(isPresented: $showAlert) {
                // Show error alert
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
    }
}

