//
//  QuestionEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension QuestionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestionEntity> {
        return NSFetchRequest<QuestionEntity>(entityName: "QuestionEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var selectedAnswerChoiceId: Int64
    @NSManaged public var answerChoices: NSSet?

}

// MARK: Generated accessors for answerChoices
extension QuestionEntity {

    @objc(addAnswerChoicesObject:)
    @NSManaged public func addToAnswerChoices(_ value: AnswerChoiceEntity)

    @objc(removeAnswerChoicesObject:)
    @NSManaged public func removeFromAnswerChoices(_ value: AnswerChoiceEntity)

    @objc(addAnswerChoices:)
    @NSManaged public func addToAnswerChoices(_ values: NSSet)

    @objc(removeAnswerChoices:)
    @NSManaged public func removeFromAnswerChoices(_ values: NSSet)

}

extension QuestionEntity : Identifiable {

}
