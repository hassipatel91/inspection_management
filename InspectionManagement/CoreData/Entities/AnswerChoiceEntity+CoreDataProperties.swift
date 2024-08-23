//
//  AnswerChoiceEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension AnswerChoiceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnswerChoiceEntity> {
        return NSFetchRequest<AnswerChoiceEntity>(entityName: "AnswerChoiceEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var score: Double

}

extension AnswerChoiceEntity : Identifiable {

}
