//
//  InspectionModel.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import Foundation

// MARK: - InspectionRes

struct InspectionRes: Codable {
    let inspection: Inspection
}

// MARK: - Inspection

struct Inspection: Identifiable, Codable {
    let id: Int
    let inspectionType: InspectionType
    let area: Area
    var survey: Survey
    var status: InspectionStatus?
}

enum InspectionStatus: String, Codable {
    case draft
    case submitted
    case completed
}

// MARK: - InspectionType

struct InspectionType: Codable {
    let id: Int
    let name: String
    let access: String
}

// MARK: - Area

struct Area: Codable {
    let id: Int
    let name: String
}

// MARK: - Survey

struct Survey: Codable {
    let id: Int
    var categories: [Category]
}

// MARK: - Category

struct Category: Identifiable, Codable {
    let id: Int
    let name: String
    var questions: [Question]
}

// MARK: - Question

struct Question: Identifiable, Codable {
    let id: Int
    let name: String
    let answerChoices: [AnswerChoice]
    var selectedAnswerChoiceId: Int?
}

// MARK: - AnswerChoice

struct AnswerChoice: Identifiable, Codable {
    let id: Int
    let name: String
    let score: Double
}
