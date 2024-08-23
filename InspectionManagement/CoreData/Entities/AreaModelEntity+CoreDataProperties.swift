//
//  AreaModelEntity+CoreDataProperties.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//
//

import Foundation
import CoreData


extension AreaModelEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AreaModelEntity> {
        return NSFetchRequest<AreaModelEntity>(entityName: "AreaModelEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}

extension AreaModelEntity : Identifiable {

}
