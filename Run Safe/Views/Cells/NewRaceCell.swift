//
//  NewRaceCell.swift
//  New Runner Col View
//
//  Created by Raphaël Payet on 11/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import Lottie
import TinyConstraints

class NewRaceCell: UICollectionViewCell {
    
    static let reuseID = "NewRaceCell"
    
    var neumorphicView = EMTNeumorphicView()
    var animationView  : AnimationView! = nil
    var animationName  = String()
    var name : UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    var location : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(neumorphicView)
        neumorphicView.edgesToSuperview()
        
        contentView.addSubview(name)
        contentView.addSubview(location)
        
        let labelStackView = UIStackView(arrangedSubviews: [name, location])
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillProportionally
        
        contentView.addSubview(labelStackView)
        
        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        labelStackView.edgesToSuperview(excluding: .top, insets: insets)
        labelStackView.height(50)
        labelStackView.spacing = 10
        
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        neumorphicView.neumorphicLayer?.elementBackgroundColor = UIColor.systemBackground.cgColor
        neumorphicView.neumorphicLayer?.depthType = .convex
        neumorphicView.neumorphicLayer?.elementDepth = 5
    }
    
    func configure(race : Race) {
        name.text               = race.name
        location.text           = race.place
        
        if animationView == nil {
            if let raceType = race.type {
                switch raceType {
                case "Trail"    : animationName = LottieNames.run
                case "XC"       : animationName = LottieNames.rideGreen
                case "Route"    : animationName = LottieNames.bike1
                default         : animationName = LottieNames.run
                }
                
                configureAnimation(with: animationName)
            }
        } else {
            animationView.play()
        }
    }
    
    func configureAnimation(with name : String) {
        let animation = Animation.named(name)
        animationView = AnimationView(animation: animation)
        
        contentView.addSubview(animationView)
        
        animationView.edgesToSuperview(excluding: .bottom)
        animationView.height(self.contentView.frame.height / 2)
        
        animationView.play()
        animationView.loopMode = .loop
        animationView.contentMode = .scaleToFill
        animationView.layer.masksToBounds = true
    }
}
