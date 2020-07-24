//
//  FinishedRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 16/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints

class FinishedRaceVC: UIViewController {
    //MARK: - Objects
    var titleLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Savoye LET", size: 80)
        label.textAlignment = .center
        return label
    }()
    var descriptionLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "American Typewriter", size: 20)
        return label
    }()
    
    var timeLabel                       = UILabel()
    var hoursLabel                      = RSRacingLabel(text: "00")
    var dotsLabel                       = RSRacingLabel(text: ":")
    var minutesLabel                    = RSRacingLabel(text: "00")
    var secondDotsLabel                 = RSRacingLabel(text: ":")
    var secondsLabel                    = RSRacingLabel(text: "00")
    var firstSeparator                  = UIView()
    
    var distanceLabel                   = UILabel()
    var distanceNumberLabel             = RSRacingLabel(text : "0.0")
    var kilometerLabel                  = UILabel()
    
    let finishButton = RSButton(backgroundColor: .systemBlue, title: "Terminer")
    
    let reviewService = ReviewService.shared
    
    //MARK: - Properties
    let padding     = CGFloat(20)
    var time        : Int!
    var distance    : Double!
    
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
extension FinishedRaceVC {
    func setupUI() {
        view.backgroundColor = .systemBackground
        configureLabels()
        configureStack()
        configureButton()
        updateTimerUI()
        updateDistanceUI()
    }
    fileprivate func configureLabels() {
        let labels = [titleLabel, descriptionLabel]
        for label in labels {
            view.addSubview(label)
            label.leftToSuperview(view.leftAnchor, offset: padding)
            label.rightToSuperview(view.rightAnchor, offset: -padding)
        }
        
        titleLabel.topToSuperview(view.topAnchor, offset: padding)
        titleLabel.height(150)
        titleLabel.text = "Bravo !"
        
        descriptionLabel.topToBottom(of: titleLabel, offset: padding)
        descriptionLabel.height(100)
        descriptionLabel.text = "Vous venez de terminer votre course ! Et quelle performance !"
    }
    
    fileprivate func configureStack() {
        let quarterViewHeight = (view.bounds.height - 100) / 4
        
        let chrono = UIStackView(arrangedSubviews: [hoursLabel, dotsLabel, minutesLabel, secondDotsLabel, secondsLabel])
        chrono.axis = .horizontal
        chrono.distribution = .equalCentering
        
        let firstStackView  = UIStackView(arrangedSubviews: [timeLabel, chrono, firstSeparator])
        firstStackView.axis = .vertical
        firstStackView.distribution = .equalSpacing
        
        view.addSubview(firstStackView)
        
        view.addSubview(firstSeparator)
        
        
        let secondStackView = UIStackView(arrangedSubviews: [distanceLabel, distanceNumberLabel, kilometerLabel])
        secondStackView.axis = .vertical
        secondStackView.distribution = .equalCentering
        
        view.addSubview(secondStackView)
        
        //Constraints
        firstStackView.height(quarterViewHeight)
        firstStackView.topToBottom(of: descriptionLabel)
        firstStackView.leftToSuperview(view.leftAnchor)
        firstStackView.rightToSuperview(view.rightAnchor)
        
        firstSeparator.topToBottom(of: firstStackView)
        firstSeparator.height(1)
        firstSeparator.leftToSuperview(view.leftAnchor, offset: padding)
        firstSeparator.rightToSuperview(view.rightAnchor, offset: -padding)
        
        secondStackView.height(quarterViewHeight)
        secondStackView.topToBottom(of: firstStackView)
        secondStackView.leftToSuperview(view.leftAnchor)
        secondStackView.rightToSuperview(view.rightAnchor)
        
        timeLabel.text      = "Temps :"
        distanceLabel.text  = "Distance :"
        kilometerLabel.text = "KM"
        
        let titles = [timeLabel, distanceLabel]
        
        for label in titles {
            label.font          = .systemFont(ofSize: 20, weight : .medium)
            label.textAlignment = .center
        }
        
        kilometerLabel.font = .systemFont(ofSize: 15, weight : .light)
        kilometerLabel.textColor = .secondaryLabel
        kilometerLabel.textAlignment = .center
    }
    fileprivate func configureButton() {
        view.addSubview(finishButton)
        
        finishButton.bottomToSuperview(view.safeAreaLayoutGuide.bottomAnchor, offset: -40)
        finishButton.leftToSuperview(view.leftAnchor, offset: padding)
        finishButton.rightToSuperview(view.rightAnchor, offset: -padding)
        finishButton.height(44)
        
        finishButton.addTarget(self, action: #selector(finishRace), for: .touchUpInside)
    }
}

//MARK: - Actions
extension FinishedRaceVC {
    @objc func finishRace() {
        reviewService.requestReview()
        showRunnerScreen()
    }
}

//MARK: - Helper Methods
extension FinishedRaceVC {
    func showRunnerScreen() {
        let raceVC = RunnerRaceVC()
        raceVC.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: SFSymbols.home), tag : 0)
        let profileVC = RunnerProfileVC()
        let navC = UINavigationController(rootViewController: profileVC)
        navC.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: SFSymbols.person), tag : 1)
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [raceVC, navC]
        tabBar.modalPresentationStyle = .overFullScreen
        self.present(tabBar, animated : true)
    }
    
    
    fileprivate func updateTimerUI() {
        var hours   = Int(0)
        var minutes = Int(0)
        var seconds = Int(0)
        
        hours   = time / (60*60)
        minutes = (time / 60)%60
        seconds = time % 60
        
        if hours < 10 {
            hoursLabel.text     = "0\(String(hours))"
        } else {
            hoursLabel.text     = String(hours)
        }
        if minutes < 10 {
            minutesLabel.text   = "0\(String(minutes))"
        } else {
            minutesLabel.text   = String(minutes)
        }
        if seconds < 10 {
            secondsLabel.text   = "0\(String(seconds))"
        } else {
            secondsLabel.text   = String(seconds)
        }
    }
    
    fileprivate func updateDistanceUI() {
        DispatchQueue.main.async {
            let meters                      = self.distance.rounded()
            let metersMeasurement           = Measurement(value: meters, unit: UnitLength.meters)
            let kilometers                  = metersMeasurement.converted(to: UnitLength.kilometers)
            let kilometersValue             = (kilometers.value * 100).rounded() / 100
            
            self.distanceNumberLabel.text   = String(kilometersValue)
        }
    }
}
