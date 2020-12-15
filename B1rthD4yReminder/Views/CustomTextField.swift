//
//  CustomTextField.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/15/20.
//

import UIKit

class CustomTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    private func config() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray.cgColor
        layer.cornerRadius = 10
        
        textAlignment = .center
        textColor = .label
        tintColor = .label
        font = UIFont.preferredFont(forTextStyle: .title2)
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        clearButtonMode = .whileEditing
        backgroundColor = .tertiarySystemBackground
        autocorrectionType = .no
        returnKeyType = .done
    }
}
