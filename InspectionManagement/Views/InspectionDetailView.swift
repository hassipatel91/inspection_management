//
//  InspectionDetailView.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import SwiftUI


struct InspectionDetailView: View {
    // ViewModel to manage inspection data
    @ObservedObject var viewModel: InspectionViewModel
    
    // State variables for managing alerts and final score
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var finalScore: Double = 0.0

    var body: some View {
        VStack {
            // List of inspection questions and answers
            inspectionListView
            
            // Section for submission and final score
            submissionSection
        }
        .navigationTitle("Inspection Details")
        .onAppear(perform: handleOnAppear) // Handle logic when view appears
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Alert"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // View displaying the list of inspection questions and categories
    private var inspectionListView: some View {
        List {
            if let categories = viewModel.inspection?.survey.categories {
                ForEach(categories) { category in
                    Section(header: sectionHeaderView(for: category)) {
                        ForEach(category.questions) { question in
                            QuestionRow(question: question,
                                        selectedAnswerId: bindingForAnswerChoiceId(for: question),
                                        onAnswerChange: { newAnswerId in
                                            updateSelectedAnswer(for: question.id, with: newAnswerId)
                                        })
                            .disabled(viewModel.inspection?.status == .submitted) // Disable interaction if submitted
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    // View displaying the submission button or final score
    private var submissionSection: some View {
        Group {
            if viewModel.inspection?.status == .submitted {
                // Display final score if the inspection is submitted
                Text("Final Score: \(finalScore, specifier: "%.2f")")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.green)
            } else {
                // Button to submit the inspection
                Button("Submit Inspection", action: handleSubmitInspection)
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(!viewModel.validateInspection()) // Disable if inspection is invalid
            }
        }
    }

    // Header view for each category section
    private func sectionHeaderView(for category: Category) -> some View {
        Text(category.name)
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
    }

    // Logic to execute when the view appears
    private func handleOnAppear() {
        if viewModel.inspection?.status == .submitted {
            finalScore = viewModel.calculateFinalScore() // Calculate score if inspection is already submitted
        }
    }

    // Handle inspection submission
    private func handleSubmitInspection() {
        viewModel.submitInspection { result in
            switch result {
            case .success:
                finalScore = viewModel.calculateFinalScore() // Calculate score after successful submission
                alertMessage = "Inspection submitted successfully!"
                showAlert = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    // Bind the selected answer choice ID for a question
    private func bindingForAnswerChoiceId(for question: Question) -> Binding<Int?> {
        Binding<Int?>(
            get: {
                question.selectedAnswerChoiceId
            },
            set: { newValue in
                updateSelectedAnswer(for: question.id, with: newValue)
            }
        )
    }
    
    // Update the selected answer for a specific question
    private func updateSelectedAnswer(for questionId: Int, with newAnswerId: Int?) {
        if let categoryIndex = viewModel.inspection?.survey.categories.firstIndex(where: { $0.questions.contains(where: { $0.id == questionId }) }) {
            if let questionIndex = viewModel.inspection?.survey.categories[categoryIndex].questions.firstIndex(where: { $0.id == questionId }) {
                viewModel.inspection?.survey.categories[categoryIndex].questions[questionIndex].selectedAnswerChoiceId = newAnswerId
            }
        }
    }
}

struct RadioButton: View {
    // ID and label for the radio button
    let id: Int
    let label: String
    @Binding var selectedId: Int?
    
    var body: some View {
        HStack {
            Image(systemName: selectedId == id ? "largecircle.fill.circle" : "circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    selectedId = id // Update selected ID on tap
                }
            Text(label)
                .font(.body)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 5)
    }
}

struct QuestionRow: View {
    // Question data and callbacks
    let question: Question
    @Binding var selectedAnswerId: Int?
    let onAnswerChange: (Int?) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            // Question text
            questionNameView
            
            // List of answer choices
            answerChoicesView
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 1)
        )
        .padding(.horizontal, 15)
    }
    
    // View displaying the question text
    private var questionNameView: some View {
        Text(question.name)
            .font(.body)
            .foregroundColor(.blue)
            .padding(.leading, 10)
    }

    // View displaying the answer choices as radio buttons
    private var answerChoicesView: some View {
        ForEach(question.answerChoices) { choice in
            RadioButton(id: choice.id,
                        label: choice.name,
                        selectedId: $selectedAnswerId)
                .onTapGesture {
                    selectedAnswerId = choice.id
                    onAnswerChange(choice.id)
                }
        }
    }
}


