//
//  RaceCell.swift
//  Map Screen
//
//  Created by Raphaël Payet on 29/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import TinyConstraints

class RaceCell: UICollectionViewCell {
    static let reuseID = "RaceCell"
    
    let neumorphicView  = EMTNeumorphicView()
    let backgroundImage = UIImageView()
    let title           = UILabel()
    let date            = UILabel()
    let place           = UILabel()
    let seeButton       = UIButton(type: .system)
    let separator       = UIView()
    
    var showsSeparator = true {
        didSet {
            updateSeparator()
        }
    }
    
    func updateSeparator() {
        separator.isHidden = !showsSeparator
    }
    
    func configure(with race : Race) {
        self.title.text = race.name
//        self.date.text  = race.date
        self.place.text = race.place
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RaceCell {
    fileprivate func setupCell() {
        let padding = CGFloat(10)
        let midCell = contentView.frame.size.width / 2 - (padding * 2)

        contentView.addSubview(neumorphicView)
        contentView.addSubview(backgroundImage)
        contentView.addSubview(title)
        contentView.addSubview(place)
        contentView.addSubview(date)
        contentView.addSubview(seeButton)
        contentView.addSubview(separator)
        
        
        //Constraints
        neumorphicView.edgesToSuperview()
        
        backgroundImage.edgesToSuperview()
        
        title.topToSuperview(contentView.topAnchor, offset: padding)
        title.leadingToSuperview(contentView.leadingAnchor, offset: padding)
        title.height(60)
        title.width(midCell)
        
        separator.topToSuperview()
        separator.leadingToSuperview()
        separator.trailingToSuperview()
        separator.height(1)
        
        place.bottomToSuperview(contentView.bottomAnchor, offset: -padding)
        place.leadingToSuperview(contentView.leadingAnchor, offset: padding)
        place.width(midCell)
        place.height(30)
        
        date.topToSuperview(contentView.topAnchor, offset: padding)
        date.trailingToSuperview(contentView.trailingAnchor, offset: padding)
        date.height(20)
        date.width(midCell)
        
        separator.backgroundColor = .placeholderText
        
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        neumorphicView.neumorphicLayer?.elementBackgroundColor = UIColor.systemBackground.cgColor
        neumorphicView.neumorphicLayer?.depthType = .convex
        neumorphicView.neumorphicLayer?.elementDepth = 5
        
        backgroundImage.contentMode = .scaleAspectFill
        
        title.font  = .preferredFont(forTextStyle: .title2)
        title.textColor = .label
        title.numberOfLines = 0
        
        place.font  = .preferredFont(forTextStyle: .subheadline)
        place.textColor = .label
        
        date.font   = .preferredFont(forTextStyle: .body)
        date.textAlignment = .right
        date.textColor = .label
        
        seeButton.setImage(UIImage(systemName: SFSymbols.plus), for: .normal)
        seeButton.tintColor = .label
        
        separator.alpha = 0
    }
}
