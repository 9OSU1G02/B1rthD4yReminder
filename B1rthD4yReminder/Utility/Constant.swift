//
//  Constant.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/14/20.
//

import UIKit
import CoreData
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context     = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var fetchedRC: NSFetchedResultsController<Person>!
