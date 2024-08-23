//
//  InspectionTypeEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension InspectionTypeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionTypeEntity> {
        return NSFetchRequest<InspectionTypeEntity>(entityName: "InspectionTypeEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var access: String?

}

extension InspectionTypeEntity : Identifiable {

}
