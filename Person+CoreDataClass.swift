//
//  Person+CoreDataClass.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/11/20.
//
//

import Foundation
import CoreData

@objc(Person)
public class Person: NSManagedObject {
    var monthName: String {
        return DateFormatter().monthSymbols[Int(mob) - 1]
    }
    var age: Int {
        return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
    }
}
