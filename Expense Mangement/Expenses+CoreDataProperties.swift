//
//  Expenses+CoreDataProperties.swift
//  
//
//  Created by Wunna on 1/31/23.
//
//

import Foundation
import CoreData


extension Expenses {
    
    static let shared = fetchData()

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses> {
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }

    @NSManaged public var amount: Int64
    @NSManaged public var category: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var date: String?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var type: Bool
    @NSManaged public var updatedAt: String?

}
