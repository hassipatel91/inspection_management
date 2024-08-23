//
//  InspectionEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension InspectionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InspectionEntity> {
        return NSFetchRequest<InspectionEntity>(entityName: "InspectionEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var status: String?
    @NSManaged public var inspectionType: InspectionTypeEntity?
    @NSManaged public var area: AreaModelEntity?
    @NSManaged public var survey: SurveyEntity?

}

extension InspectionEntity : Identifiable {

}
