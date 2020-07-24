//
//  BigFollowerRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 11/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints
import Lottie

class BigFollowerRaceVC: UIViewController {
    //MARK: - Objects
    
    var animationView : AnimationView! = nil
    let containerLabelView = UIView()
    let backButton :  UIButton = {
        let button = UIButton(type : .system)
        button.setImage(UIImage(named : ButtonIcons.back), for: .normal)
        return button
    }()
    let name : UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .left
        return label
    }()
    let location : UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .left
        return label
    }()
    let distance : UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .left
        return label
    }()
    let descriptionLabel : UILabel = {
       let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .natural
        return label
    }()
    let seeButton = RSButton(backgroundColor: .systemPink, title: "Voir")

    
    //MARK: - Properties
    let padding = CGFloat(20)
    var race    : Race!
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}


//MARK: - User Interface
extension BigFollowerRaceVC {
    func setupUI() {
        configureSuperView()
        configureImage()
        configureContainer()
        configureButtons()
        configureLabels()
        writeThings()
    }
    
    fileprivate func configureSuperView() {
        view.backgroundColor = .systemBackground
    }
    fileprivate func configureImage() {
        var animationName = ""
        //TODO: Get race type with the previous VC"
        if let raceType = race.type {
            switch raceType {
            case "Trail"    : animationName = LottieNames.run
            case "XC"       : animationName = LottieNames.rideGreen
            default         : animationName = LottieNames.bike1
            }
        }
        
        let animation = Animation.named(animationName)
        
        
        animationView = AnimationView(animation: animation)
        
        view.addSubview(animationView)
        
        animationView.edgesToSuperview(excluding: .bottom)
        animationView.height(300)
        
        animationView.play()
        animationView.loopMode = .loop
        
        if let raceType = race.type {
            switch raceType {
            case "Trail"    : animationView.contentMode = .scaleAspectFit
            case "XC"       : animationView.contentMode = .scaleAspectFill
            default         : animationName = LottieNames.bike1
            }
        }
    }
    
    fileprivate func configureContainer() {
        view.addSubview(containerLabelView)
        
        containerLabelView.backgroundColor = .systemBackground
        
        containerLabelView.topToBottom(of: animationView, offset: -padding * 2)
        containerLabelView.edgesToSuperview(excluding: .top)
        
        containerLabelView.layer.cornerRadius = 30
    }
    
    fileprivate func configureLabels() {
        
        let labels = [name, location, distance, descriptionLabel]
        
        for label in labels {
            containerLabelView.addSubview(label)
            
            label.leftToSuperview(view.leftAnchor, offset: padding)
            label.rightToSuperview(view.rightAnchor, offset: -padding)
        }
        
        
        
        name.topToBottom(of: animationView, offset: padding)
        name.height(38)
        
        location.topToBottom(of: name, offset: padding)
        location.height(25)
        
        distance.topToBottom(of: location, offset: padding)
        distance.height(25)
        
        descriptionLabel.topToBottom(of: distance, offset: padding)
        descriptionLabel.bottomToTop(of: seeButton, offset: -padding)
    }
    fileprivate func writeThings() {
        name.text = race.name
        location.text = race.place
        if let distanceNumber = race.distance { distance.text = "Longueur : \(distanceNumber) KM" } else { distance.text = ""}
        descriptionLabel.text = race.description ?? ""
    }
    
    fileprivate func configureButtons() {
        view.addSubview(backButton)
        backButton.topToSuperview(view.topAnchor, offset: padding * 2)
        backButton.leftToSuperview(view.leftAnchor, offset: padding)
        backButton.height(50)
        backButton.width(50)
        
        backButton.addTarget(self, action: #selector(backToHomeScreen), for: .touchUpInside)
        
        containerLabelView.addSubview(seeButton)
    
        seeButton.leftToSuperview(containerLabelView.leftAnchor, offset: padding)
        seeButton.rightToSuperview(containerLabelView.rightAnchor, offset: -padding)
        seeButton.bottomToSuperview(containerLabelView.bottomAnchor, offset: -40)
        seeButton.height(44)
        
        seeButton.addTarget(self, action: #selector(seeButtonTapped), for: .touchUpInside)
    }
}


//MARK: - Actions
extension BigFollowerRaceVC {
    @objc func backToHomeScreen() {
        self.dismiss(animated: true)
    }
    
    @objc func seeButtonTapped() {
        let specificRace = SpecificRaceVC()
        specificRace.raceName = race.name
        specificRace.racePlace = race.place
        navigationController?.pushViewController(specificRace, animated: true)
    }
}
