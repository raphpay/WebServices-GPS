//
//  RSTitleLabel.swift
//  Triple Connexion Screens
//
//  Created by Raphaël Payet on 03/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class RSTitleLabel: UILabel {
    
    var title : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text : String) {
        super.init(frame : .zero)
        self.text = text
        configure()
    }
    fileprivate func configure() {
//        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        font = .systemFont(ofSize: 25, weight: .bold)
    }
}
