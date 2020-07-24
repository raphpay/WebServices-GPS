//
//  WSButton.swift
//  WebServicesLogin
//
//  Created by Raphaël Payet on 12/07/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class WSButton : UIButton {
    
    var strokeColor : UIColor = .white
    var color : UIColor = .white
    var title : String  = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(color : UIColor, title : String) {
        super.init(frame: .zero)
        self.color = color
        self.title = title
        configure()
        configureBackground()
    }
    
    init(strokeColor : UIColor, title : String) {
        super.init(frame: .zero)
        self.strokeColor = strokeColor
        self.title = title
        configure()
        configureStroke()
    }
    
    func configure() {
        layer.cornerRadius = 10
        setTitleColor(color == .white ? .black : .white, for: .normal)
        setTitle(title, for: .normal)
    }
    
    func configureBackground() {
        backgroundColor = color
    }
    
    func configureStroke() {
        layer.borderWidth = 2
        layer.borderColor = strokeColor.cgColor
    }
}
