//
//  NeumorphicCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 22/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import TinyConstraints

class NeumorphicCell: UICollectionViewCell {
    
    var neumorphicView = EMTNeumorphicView()
    let name = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configure() {
        contentView.addSubview(neumorphicView)
        
        neumorphicView.edgesToSuperview()
        
        neumorphicView.neumorphicLayer?.elementBackgroundColor = UIColor.systemBackground.cgColor
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        
        // set convex or concave.
        neumorphicView.neumorphicLayer?.depthType = .convex
        // set elementDepth (corresponds to shadowRadius). Default is 5
        neumorphicView.neumorphicLayer?.elementDepth = 5
        
        neumorphicView.addSubview(name)
        
        name.text = "Test"
        
        name.edgesToSuperview()
    }
}
