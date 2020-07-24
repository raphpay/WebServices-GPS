//
//  RunnerCell.swift
//  Run Safe
//
//  Created by Raphaël Payet on 07/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import TinyConstraints

class RunnerCell: UICollectionViewCell {
    //MARK: - Properties
    static let reuseID = "RunnerCell"
    let padding = CGFloat(10)
    
    //MARK: - Subviews
    var neumorphicView  = EMTNeumorphicView()
    var profileImage    = UIImageView()
    var nameLabel       = UILabel()
    var raceLabel       = UILabel()
    var numberLabel     = UILabel()
    
    
    
    //MARK: - Initilaizers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - User Interface
extension RunnerCell {
    fileprivate func setup() {
        contentView.addSubview(neumorphicView)
        
        neumorphicView.edgesToSuperview()
        
        neumorphicView.neumorphicLayer?.cornerRadius = 10
        neumorphicView.neumorphicLayer?.elementBackgroundColor = UIColor.systemBackground.cgColor
        // set convex or concave.
        neumorphicView.neumorphicLayer?.depthType = .convex
        // set elementDepth (corresponds to shadowRadius). Default is 5
        neumorphicView.neumorphicLayer?.elementDepth = 5
        
        
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, raceLabel, numberLabel])
        textStackView.distribution  = .fillProportionally
        textStackView.axis          = .vertical
        
        
        contentView.addSubview(profileImage)
        contentView.addSubview(textStackView)
        
        let profileInsets   = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: 0)
        let stackViewInsets = UIEdgeInsets(top: padding, left: 0, bottom: padding, right: padding)
            
        profileImage.edgesToSuperview(excluding: .trailing, insets: profileInsets)
        
        textStackView.leftToRight(of : profileImage, offset: padding)
        textStackView.edgesToSuperview(excluding: .leading, insets: stackViewInsets)
        
        profileImage.contentMode    = .scaleAspectFill
        profileImage.tintColor      = .black
        
        nameLabel.font      = .preferredFont(forTextStyle: .body)
        raceLabel.font      = .preferredFont(forTextStyle: .callout)
        
        numberLabel.font    = .preferredFont(forTextStyle: .callout)
    }
}

//MARK: - Configuration
extension RunnerCell {
    func configure(runner : Runner) {
        let name = "\(runner.firstName) \(runner.lastName)"
        
        nameLabel.text = name
        if runner.nextRace != "" {
            raceLabel.text = runner.nextRace
        }
        if runner.number != 0 {
            numberLabel.text = "Dossard : \(runner.number)"
        }
        //A changer par la suite
        profileImage.image = UIImage(systemName: SFSymbols.person)
    }
}

//MARK: Actions


