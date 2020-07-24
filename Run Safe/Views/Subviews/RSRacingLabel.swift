//
//  RSRacingLabel.swift
//  Run Safe
//
//  Created by Raphaël Payet on 17/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class RSRacingLabel: UILabel {
    var number : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text : String) {
        super.init(frame: .zero)
        self.text = text
        configure()
    }
}

extension RSRacingLabel {
    fileprivate func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        font = .systemFont(ofSize: 70, weight : .bold)
    }
}
