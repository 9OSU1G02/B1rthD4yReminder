//
//  Extension.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/10/20.
//

import UIKit


// MARK: - UIViewController
extension UIViewController {
    
    // MARK: - Notification
     func listenForKeyboardNotification() {
        addObservsers(selector: #selector(keyboardWillChange(notification:)),
                      names: UIResponder.keyboardWillShowNotification,
                      UIResponder.keyboardWillHideNotification,
                      UIResponder.keyboardWillChangeFrameNotification,
                      objcect: nil)
    }
    
     func stopListenForKeyboardNotification() {
        removeObservers(names: UIResponder.keyboardWillShowNotification,
                        UIResponder.keyboardWillHideNotification,
                        UIResponder.keyboardWillChangeFrameNotification,
                        objcect: nil)
    }
    
    @objc private func keyboardWillChange(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardSize.height
        }
        else {
            view.frame.origin.y = 0
        }
    }
    
    func addObservsers(selector: Selector,names: NSNotification.Name..., objcect: Any?) {
        for name in names {
            NotificationCenter.default.addObserver(self, selector: selector, name: name, object: objcect)
        }
    }
    
    func removeObservers(names: NSNotification.Name..., objcect: Any?) {
        for name in names {
            NotificationCenter.default.removeObserver(self, name: name, object: objcect)
        }
    }
    
}


// MARK: - UIImage
extension UIImage {
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    //Create Circle Image
    var circleMasked: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


// MARK: - TextField

extension UITextField {
    func addDoneButton() {
      let toolbar = UIToolbar()
      toolbar.sizeToFit()
        let flexSpace                           = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton                          = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.resignFirstResponder))
      toolbar.items                             = [flexSpace, doneButton]
      self.inputAccessoryView = toolbar
    }
}


// MARK: - Date

extension Date {
    func convertToDayMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale                    = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone                  = TimeZone(identifier: "Asia/Jakarta")
        dateFormatter.dateFormat                = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
    func currentDayIntValue() -> Int{
        return Calendar.current.dateComponents([.day], from: Date()).day!
    }
    
    func currentMonthIntValue() -> Int {
        return Calendar.current.dateComponents([.month], from: Date()).month!
    }
}

extension String {
    
    func convertToDate() -> Date? {
        let dateFormatter                       = DateFormatter()
        dateFormatter.dateFormat                = "MMM d, yyyy"
        dateFormatter.locale                    = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone                  = .current
        return dateFormatter.date(from: self)
    }
}
