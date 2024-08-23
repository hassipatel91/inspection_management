//
//  SurveyEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension SurveyEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyEntity> {
        return NSFetchRequest<SurveyEntity>(entityName: "SurveyEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var categories: NSSet?

}

// MARK: Generated accessors for categories
extension SurveyEntity {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: CategoryEntity)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: CategoryEntity)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

extension SurveyEntity : Identifiable {

}
