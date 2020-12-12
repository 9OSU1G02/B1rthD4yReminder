//
//  Person+CoreDataProperties.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/12/20.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var avatar: Data?
    @NSManaged public var birthday: Date!
    @NSManaged public var email: String?
    @NSManaged public var mob: Int32
    @NSManaged public var name: String!
    @NSManaged public var notification: Bool
    @NSManaged public var phone: String?
    @NSManaged public var dob: Int32

}

extension Person : Identifiable {

}
