//
//  HorizontalNewRaceCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 15/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints
import EMTNeumorphicView
import Lottie

class HorizontalNewRaceCell: UICollectionViewCell {
    
    static let reuseID = "HorizontalNewRaceCell"
    
    var animationView   : AnimationView! = nil
    var neumorphicView  = EMTNeumorphicView()
    var raceLabel       = UILabel()
    var placeLabel      = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with race : Race) {
        self.raceLabel.text     = race.name
        self.placeLabel.text    = race.place
        
        if animationView == nil {
            if let raceType = race.type {
                var animationName = ""
                switch raceType {
                case "Trail"    : animationName = LottieNames.run
                case "XC"       : animationName = LottieNames.bike1
                case "DH"       : animationName = LottieNames.bike2
                case "Route"    : animationName = LottieNames.bike1
                default         : animationName = LottieNames.run
                }
                
                configureAnimation(with: animationName)
            }
        } else {
            animationView.play()
        }
    }
    
    
    fileprivate func setupUI() {
        configureContainerView()
        configureLabels()
    }
    
    
    
    fileprivate func configureContainerView() {
        contentView.addSubview(neumorphicView)
        
        neumorphicView.edgesToSuperview()
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        neumorphicView.neumorphicLayer?.elementBackgroundColor = UIColor.systemBackground.cgColor
        neumorphicView.neumorphicLayer?.depthType = .convex
        neumorphicView.neumorphicLayer?.elementDepth = 5
    }
    
    func configureAnimation(with name : String) {
        let animation = Animation.named(name)
        animationView = AnimationView(animation: animation)
        
        contentView.addSubview(animationView)
        
        animationView.edgesToSuperview(excluding: .trailing)
        animationView.width(contentView.frame.height)
        
        animationView.play()
        animationView.loopMode = .loop
        animationView.contentMode = .scaleToFill
    }
    
    
    
    fileprivate func configureLabels() {
        let labels = UIStackView(arrangedSubviews: [raceLabel, placeLabel])
        
        labels.axis = .vertical
        labels.distribution = .equalCentering
        labels.alignment = .center
        
        contentView.addSubview(labels)
        
        let insets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 6)
        labels.edgesToSuperview(excluding: .leading, insets: insets)
        labels.width(contentView.frame.width - contentView.frame.height)
        
        raceLabel.font = .systemFont(ofSize: 20, weight: .bold)
        raceLabel.textAlignment = .left
        
        placeLabel.textAlignment = .left
        placeLabel.textColor = .secondaryLabel
        placeLabel.font = .systemFont(ofSize: 18, weight : .medium)
    }
    
    
    
}
