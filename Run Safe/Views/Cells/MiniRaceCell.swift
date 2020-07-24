//
//  MiniRaceCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 29/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints
import EMTNeumorphicView
import RandomColorSwift

class MiniRaceCell: UICollectionViewCell {
    static let reuseID = "MiniRaceCell"
    
    var neumorphicView  = EMTNeumorphicView()
    var backView        = UIView()
    var nameLabel       = UILabel()
    var placeLabel      = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MiniRaceCell {
    fileprivate func setupUI() {
        contentView.addSubview(neumorphicView)
        
        neumorphicView.edgesToSuperview()
        
        
        let labelStack = UIStackView(arrangedSubviews: [nameLabel, placeLabel])
        contentView.addSubview(labelStack)
        
        let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        labelStack.edgesToSuperview(insets: padding)
        labelStack.axis = .vertical
        labelStack.distribution = .fillProportionally
        
        let color = randomColor(hue: .blue, luminosity: .light)
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        neumorphicView.neumorphicLayer?.elementBackgroundColor = color.cgColor
        neumorphicView.neumorphicLayer?.depthType = .convex
        neumorphicView.neumorphicLayer?.elementDepth = 5
        
        
        nameLabel.font              = .systemFont(ofSize: 12, weight: .bold)
        nameLabel.numberOfLines     = 0
        
        placeLabel.font             = .systemFont(ofSize: 10, weight: .light)
        placeLabel.numberOfLines    = 0
    }
    
    func configure(with race : Race) {
        nameLabel.text  = race.name
        placeLabel.text = race.place
    }
}
