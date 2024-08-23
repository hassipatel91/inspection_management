//
//  InspectionViewModel.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import Combine
import CoreData
import Foundation

class InspectionViewModel: ObservableObject {
    // Published properties to bind to the view
    @Published var inspections: [Inspection] = []
    @Published var inspection: Inspection?
    @Published var alertMessage: String = ""
    
    // Core Data context for performing database operations
    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    // Initialization method
    init() {
        loadInspectionsFromCoreData() // Load inspections from Core Data on initialization
    }
    
    // Starts a new inspection by fetching it from the API
    func startNewInspection(completion: @escaping (Result<InspectionRes, Error>) -> Void) {
        NetworkManager.shared.getRequest(url: "/api/inspections/start") { (result: Result<InspectionRes, Error>) in
            switch result {
            case .success(let newInspection):
                self.saveInspectionToCoreData(inspection: newInspection.inspection) // Save new inspection to Core Data
                DispatchQueue.main.async {
                    self.inspection = newInspection.inspection
                    completion(.success(newInspection)) // Return success
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error)) // Return error
                }
            }
        }
    }
    
    // Loads inspections from Core Data
    func loadInspectionsFromCoreData() {
        let request: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        do {
            let inspectionEntities = try context.fetch(request)
            inspections = inspectionEntities.map { Inspection(entity: $0) } // Convert Core Data entities to model objects
        } catch {
            print("Failed to load inspections: \(error.localizedDescription)")
        }
    }
    
    // Saves an inspection object to Core Data
    func saveInspectionToCoreData(inspection: Inspection) {
        let inspectionEntity = InspectionEntity(context: context)
        inspectionEntity.id = Int64(inspection.id)
        inspectionEntity.status = inspection.status?.rawValue
        
        // Save inspection type
        let inspectionTypeEntity = InspectionTypeEntity(context: context)
        inspectionTypeEntity.id = Int64(inspection.inspectionType.id)
        inspectionTypeEntity.name = inspection.inspectionType.name
        inspectionTypeEntity.access = inspection.inspectionType.access
        inspectionEntity.inspectionType = inspectionTypeEntity
        
        // Save area
        let areaEntity = AreaModelEntity(context: context)
        areaEntity.id = Int64(inspection.area.id)
        areaEntity.name = inspection.area.name
        inspectionEntity.area = areaEntity
        
        // Save survey and its related entities
        let surveyEntity = SurveyEntity(context: context)
        for category in inspection.survey.categories {
            let categoryEntity = CategoryEntity(context: context)
            categoryEntity.id = Int64(category.id)
            categoryEntity.name = category.name
            
            // Save questions and answer choices
            for question in category.questions {
                let questionEntity = QuestionEntity(context: context)
                questionEntity.id = Int64(question.id)
                questionEntity.name = question.name
                questionEntity.selectedAnswerChoiceId = Int64(question.selectedAnswerChoiceId ?? 0)
                
                for answerChoice in question.answerChoices {
                    let answerChoiceEntity = AnswerChoiceEntity(context: context)
                    answerChoiceEntity.id = Int64(answerChoice.id)
                    answerChoiceEntity.name = answerChoice.name
                    answerChoiceEntity.score = answerChoice.score
                    questionEntity.addToAnswerChoices(answerChoiceEntity)
                }
                categoryEntity.addToQuestions(questionEntity)
            }
            surveyEntity.addToCategories(categoryEntity)
        }
        surveyEntity.id = Int64(inspection.survey.id)
        inspectionEntity.survey = surveyEntity
        
        do {
            try context.save() // Save all changes to Core Data
        } catch {
            print("Failed to save inspection: \(error.localizedDescription)")
        }
    }
    
    // Submits the current inspection by sending it to the API
    func submitInspection(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let inspection = inspection else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No inspection to submit"])))
            return
        }
        
        if validateInspection() {
            let inspectionReq = InspectionRes(inspection: inspection)
            NetworkManager.shared.postRequest(url: "/api/inspections/submit", body: inspectionReq) { result in
                switch result {
                case .success:
                    self.updateInspectionStatusToSubmitted() // Update inspection status to submitted
                    DispatchQueue.main.async {
                        completion(.success(())) // Return success
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error)) // Return error
                    }
                }
            }
        } else {
            alertMessage = "Please answer all questions before submitting." // Set alert message if validation fails
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: alertMessage])))
        }
    }
    
    // Updates the inspection status to 'submitted' in Core Data
    private func updateInspectionStatusToSubmitted() {
        guard let inspection = inspection else { return }
        
        let request: NSFetchRequest<InspectionEntity> = InspectionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int32(inspection.id))
        
        do {
            let inspectionEntities = try context.fetch(request)
            if let inspectionEntity = inspectionEntities.first {
                inspectionEntity.status = InspectionStatus.submitted.rawValue
                
                // Update selected answers in Core Data
                for category in inspection.survey.categories {
                    for question in category.questions {
                        if let answerChoiceId = question.selectedAnswerChoiceId {
                            let questionRequest: NSFetchRequest<QuestionEntity> = QuestionEntity.fetchRequest()
                            questionRequest.predicate = NSPredicate(format: "id == %d", Int32(question.id))
                            
                            if let questionEntity = try context.fetch(questionRequest).first {
                                questionEntity.selectedAnswerChoiceId = Int64(answerChoiceId)
                            }
                        }
                    }
                }
                
                try context.save() // Save changes to Core Data
                loadInspectionsFromCoreData() // Refresh the list of inspections
            }
        } catch {
            print("Failed to update inspection status: \(error.localizedDescription)")
        }
    }
    
    // Calculates the final score for the current inspection
    func calculateFinalScore() -> Double {
        guard let survey = inspection?.survey else { return 0.0 }
        var totalScore = 0.0
        
        for category in survey.categories {
            for question in category.questions {
                if let selectedId = question.selectedAnswerChoiceId,
                   let selectedChoice = question.answerChoices.first(where: { $0.id == selectedId }) {
                    totalScore += selectedChoice.score
                }
            }
        }
        return totalScore
    }
    
    // Validates that all questions in the inspection have been answered
    func validateInspection() -> Bool {
        guard let categories = inspection?.survey.categories else {
            return false
        }
        
        for category in categories {
            for question in category.questions {
                if question.selectedAnswerChoiceId == nil {
                    return false
                }
            }
        }
        
        return true
    }
}

// Extension to initialize Inspection from Core Data entity
extension Inspection {
    init(entity: InspectionEntity) {
        self.id = Int(entity.id)
        self.inspectionType = InspectionType(
            id: Int(entity.inspectionType?.id ?? 0),
            name: entity.inspectionType?.name ?? "",
            access: entity.inspectionType?.access ?? ""
        )
        self.area = Area(
            id: Int(entity.area?.id ?? 0),
            name: entity.area?.name ?? ""
        )
        self.status = InspectionStatus(rawValue: entity.status ?? "") ?? .draft
        
        // Convert Survey entity to Survey model
        if let surveyEntity = entity.survey {
            // Convert categories
            let categories: [Category] = surveyEntity.categories?.compactMap { categoryEntity in
                guard let categoryEntity = categoryEntity as? CategoryEntity else { return nil }
                
                // Convert questions
                let questions: [Question] = categoryEntity.questions?.compactMap { questionEntity in
                    guard let questionEntity = questionEntity as? QuestionEntity else { return nil }
                    
                    // Convert answerChoices
                    let answerChoices: [AnswerChoice] = questionEntity.answerChoices?.compactMap { answerChoiceEntity in
                        guard let answerChoiceEntity = answerChoiceEntity as? AnswerChoiceEntity else { return nil }
                        return AnswerChoice(
                            id: Int(answerChoiceEntity.id),
                            name: answerChoiceEntity.name ?? "",
                            score: answerChoiceEntity.score
                        )
                    } ?? []
                    
                    return Question(
                        id: Int(questionEntity.id),
                        name: questionEntity.name ?? "",
                        answerChoices: answerChoices, selectedAnswerChoiceId: Int(questionEntity.selectedAnswerChoiceId)
                    )
                } ?? []
                
                return Category(
                    id: Int(categoryEntity.id),
                    name: categoryEntity.name ?? "",
                    questions: questions
                )
            } ?? []
            
            // Initialize Survey
            self.survey = Survey(
                id: Int(surveyEntity.id),
                categories: categories
            )
        } else {
            self.survey = Survey(id: 0, categories: [])
        }
    }
}


