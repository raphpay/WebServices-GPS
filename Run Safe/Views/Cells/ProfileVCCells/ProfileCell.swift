//
//  ProfileCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 16/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    static let reuseID  = "ProfileCell"
    
    var profileImage    = UIImageView()
    var lastNameLabel   = UILabel()
    var firstNameLabel  = UILabel()
    
    let padding = CGFloat(10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileCell {
    fileprivate func setupCell() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(profileImage)
        contentView.addSubview(lastNameLabel)
        contentView.addSubview(firstNameLabel)
        
        NSLayoutConstraint.activate([
        
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            profileImage.heightAnchor.constraint(equalToConstant: 75),
            profileImage.widthAnchor.constraint(equalToConstant: 75),
            
            lastNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant : padding),
            lastNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant : padding),
            lastNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant : -padding),
            lastNameLabel.heightAnchor.constraint(equalToConstant: 30),
            
            firstNameLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: padding),
            firstNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: padding),
            firstNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            firstNameLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        profileImage.image          = UIImage(systemName: SFSymbols.person)
        profileImage.tintColor      = .black
        
        lastNameLabel.font          = .systemFont(ofSize: 25, weight : .bold)
        lastNameLabel.textAlignment = .left
        lastNameLabel.text = "Payet"
        
        firstNameLabel.font          = .systemFont(ofSize: 20, weight : .medium)
        firstNameLabel.textAlignment = .left
        firstNameLabel.text =  "Raphael"
    }
    
    func configure(name : Name) {
        self.firstNameLabel.text = name.firstName
        self.lastNameLabel.text  = name.lastName
    }
}
