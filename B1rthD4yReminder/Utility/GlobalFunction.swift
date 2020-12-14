//
//  GlobalFunction.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/14/20.
//

import UIKit

func isTodayBirthDay(dob: Int32, mob: Int32) -> Bool {
    let currentMonth = Calendar.current.dateComponents([.month], from: Date()).month!
    let currentDay = Calendar.current.dateComponents([.day], from: Date()).day!
    return  dob == currentDay && mob == currentMonth
}

func warningAlert(message: String) -> UIAlertController{
    let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
    return alert
}
