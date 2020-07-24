//
//  RSTextField.swift
//  Run Safe
//
//  Created by Raphaël Payet on 05/02/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class RSTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame : frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(placeholder : String, returnKeyType : UIReturnKeyType, keyboardType : UIKeyboardType) {
        super.init(frame: .zero)
        self.placeholder        = placeholder
        self.returnKeyType      = returnKeyType
        self.keyboardType       = keyboardType
        configure()
    }
    
    private func configure() {
        textAlignment               = .center
        textColor                   = .black
        tintColor                   = .label
        
        adjustsFontSizeToFitWidth   = true
        minimumFontSize             = 12
        font                        = UIFont.preferredFont(forTextStyle: .headline)
        
        layer.cornerRadius          = 10
        layer.borderWidth           = 2
        
        autocorrectionType          = .no
        
        translatesAutoresizingMaskIntoConstraints = false
        
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)])
    }
    
}
