//
//  Header.swift
//  Map Screen
//
//  Created by Raphaël Payet on 30/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class Header : UICollectionReusableView {
    static let reuseID = "Header"
    
    let title       = UILabel()
    let seeButton   = UIButton(type: .system)
    let separator   = UIView()
    
    let padding = CGFloat(10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Header {
    fileprivate func setupHeader() {
            separator.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            seeButton.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(separator)
            addSubview(title)
            addSubview(seeButton)
            
            NSLayoutConstraint.activate([
                separator.topAnchor.constraint(equalTo: topAnchor),
                separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding ),
                separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                separator.heightAnchor.constraint(equalToConstant: 1),
                
                
                seeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                seeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                seeButton.widthAnchor.constraint(equalToConstant: 60),
                seeButton.heightAnchor.constraint(equalToConstant: 30),
                
                title.centerYAnchor.constraint(equalTo: centerYAnchor),
                title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                title.trailingAnchor.constraint(equalTo: seeButton.leadingAnchor, constant: padding),
                title.heightAnchor.constraint(equalToConstant: 30),
            ])
            
            separator.backgroundColor = .quaternaryLabel
            
            title.font          = .systemFont(ofSize: 28, weight : .bold)
            title.textAlignment = .left
            title.textColor     = .label
            
            seeButton.setTitle("Tout voir", for: .normal)
    }
}
