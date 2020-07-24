//
//  SearchButtonCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 16/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit


class SearchButtonCell: UICollectionViewCell {
    
    static let reuseID = "SearchButtonCell"
    
    var button = RSButton()
    
    
    let padding = CGFloat(10)
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension SearchButtonCell {
    fileprivate func setupCell() {
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: padding),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        
    }
    
    func configure(_ button : RSButton) {
        if let title = button.title(for: .normal) {
            self.button.setTitle(title, for: .normal)
        }
        self.button.backgroundColor = button.backgroundColor
    }
}
