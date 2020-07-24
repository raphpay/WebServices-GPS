//
//  WSTextField.swift
//  WebServicesLogin
//
//  Created by Raphaël Payet on 10/07/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class WSTextField : UITextField {
    
    var insets          : UIEdgeInsets
    var isSecured       : Bool
    var keyboardEntry   : UIKeyboardType
    var title           : String
    
    var titleLabel = UILabel()
    
    init(title : String, insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12), isSecured : Bool = false, keyboardEntry : UIKeyboardType = .default) {
        self.title          = title
        self.insets         = insets
        self.isSecured      = isSecured
        self.keyboardEntry  = keyboardEntry
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}


extension WSTextField {
    private func configure() {
        layer.cornerRadius = 10
        layer.borderWidth  = 2
        layer.borderColor  = UIColor.lightGray.cgColor
        
        backgroundColor = .white
        textColor = .black
        
        isSecureTextEntry = isSecured
        keyboardType = keyboardEntry
        
        addSubview(titleLabel)
        
        titleLabel.centerYToSuperview()
        titleLabel.leftToSuperview(leftAnchor, offset: 8)
        
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.text = title + " : "
        titleLabel.textColor = .black
    }
}
