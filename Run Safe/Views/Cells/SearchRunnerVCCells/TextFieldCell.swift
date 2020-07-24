//
//  TextFieldCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 16/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class TextFieldCell: UICollectionViewCell {
    static let reuseID = "TextFieldCell"
    
    var textField = RSTextField()
    
    let padding = CGFloat(10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TextFieldCell {
    fileprivate func setupCell() {
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
