//
//  RSAlertVC.swift
//  AlertVC
//
//  Created by Raphaël Payet on 09/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import TinyConstraints

class RSAlertVC: UIViewController {
    
    
    
    //MARK: - Objects
    let containerView       = UIView()
    let profileImage        = UIImageView()
    let firstNameLabel      = UILabel()
    let lastNameLabel       = UILabel()
    let numberLabel         = UILabel()
    let placeLabel          = UILabel()
    let followButton        = RSButton(backgroundColor: .systemOrange, title: "Suivre")
    let seeButton           = RSButton(backgroundColor: .systemBlue, title: "Voir")
    var errorButton         : RSButton! = nil
    var successButton       : RSButton! = nil
        
    let followersRef        = Database.database().reference().child("followers")
    let runnerCollection    = Firestore.firestore().collection("Runner")
    let runningCollection   = Firestore.firestore().collection("Running")
    
    
    //MARK: Properties
    var runner          : Runner?
    var place           : Int?
    var alreadyFollow   : Bool!
    
    let padding = CGFloat(20)
    
    init(runner : Runner, place : Int) {
        super.init(nibName : nil, bundle : nil)
        self.runner     = runner
        self.place      = place
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}


//MARK: - User Interface
extension RSAlertVC {
    fileprivate func setupUI() {
        configureView()
        configureContainerView()
        configureProfileImage()
        configureNumberLabel()
        configureNameLabels()
        configureButtons()
        configurePlaceLabel()
    }
    
    fileprivate func configureView() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        let tapOutsideBox = UITapGestureRecognizer(target: self, action: #selector(dismissVC(_:)))
        view.addGestureRecognizer(tapOutsideBox)
    }
    
    fileprivate func configureContainerView() {
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            containerView.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        containerView.backgroundColor       = .systemBackground
        containerView.layer.cornerRadius    = 16
        containerView.layer.borderWidth     = 2
        containerView.layer.borderColor     = UIColor.white.cgColor
    }
    fileprivate func configureProfileImage() {
        containerView.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            profileImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            profileImage.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        profileImage.image      = UIImage(systemName: SFSymbols.person)
        profileImage.tintColor  = .black
    }
    fileprivate func configureNumberLabel() {
        containerView.addSubview(numberLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            numberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            numberLabel.heightAnchor.constraint(equalToConstant: 50),
            numberLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        numberLabel.font = .systemFont(ofSize: 30, weight : .bold)
        numberLabel.textAlignment = .right
        if let number = runner?.number,
            number != 0 {
            numberLabel.text = String(number)
        } else {
            numberLabel.text = ""
        }
    }
    fileprivate func configureNameLabels() {
        let nameStackView = UIStackView(arrangedSubviews: [lastNameLabel, firstNameLabel])
        
        containerView.addSubview(nameStackView)
        
        nameStackView.translatesAutoresizingMaskIntoConstraints = false
        nameStackView.distribution = .fillProportionally
        nameStackView.axis = .vertical
        
        NSLayoutConstraint.activate([
            nameStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            nameStackView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: padding),
            nameStackView.trailingAnchor.constraint(equalTo: numberLabel.leadingAnchor, constant: -padding),
            nameStackView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
        ])
        
        lastNameLabel.font  = .systemFont(ofSize: 25, weight: .bold)
        lastNameLabel.text  = runner?.lastName ?? "Nom"
        lastNameLabel.textAlignment     = .center
        
        firstNameLabel.font = .systemFont(ofSize: 20)
        firstNameLabel.text = runner?.firstName ?? "Prénom"
        firstNameLabel.textAlignment    = .center
    }
    fileprivate func configureButtons() {
        containerView.addSubview(followButton)
        containerView.addSubview(seeButton)
        
        let midCell = CGFloat(300 / 2) - 25
        
        followButton.leftToSuperview(containerView.leftAnchor, offset: padding)
        followButton.width(midCell)
        followButton.height(44)
        followButton.bottomToSuperview(containerView.bottomAnchor, offset: -padding)
        
        seeButton.rightToSuperview(containerView.rightAnchor, offset: -padding)
        seeButton.width(midCell)
        seeButton.height(44)
        seeButton.bottomToSuperview(containerView.bottomAnchor, offset: -padding)
        
        followButton.addTarget(self, action: #selector(followRunner), for: .touchUpInside)
        seeButton.addTarget(self, action: #selector(seeRunnerPosition), for: .touchUpInside)
        
        
    }
    fileprivate func configurePlaceLabel() {
        containerView.addSubview(placeLabel)
        
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            placeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            placeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            placeLabel.bottomAnchor.constraint(equalTo: followButton.topAnchor, constant: 8)
        ])
        
        placeLabel.font = .preferredFont(forTextStyle: .body)
        placeLabel.textAlignment = .center
        if let place = self.place,
            place != 0 {
            placeLabel.text = "Classement : \(place)/250"
        } else {
            placeLabel.text = "Classement inconnu"
        }
    }
}

//MARK: - Actions

extension RSAlertVC {
    @objc func followRunner() {
        if let user = Auth.auth().currentUser {
            //We will get the name of the favorited runner and search it then into firestore and get his ids
            
            checkIfRunnerIsFollowed { (isFollowed) in
                if !isFollowed {
                    self.dismissErrorMessage()
                    self.runnerCollection.getDocuments(source: .default) { (_snapshot, _error) in
                            guard _error == nil else {
                                self.presentSimpleAlert(title: "Impossible de le suivre", message: "Cette personne va sûrement trop vite pour nous, réessayer plus tard.")
                                return
                            }

                            guard let snapshot = _snapshot else { return }

                            for document in snapshot.documents {
                                let data = document.data()
                                if let runnerFirstName = data["firstName"] as? String,
                                    let runnerLastName = data["lastName"] as? String,
                                    let runnerUID = data["uid"] as? String,
                                    runnerFirstName == self.runner?.firstName,
                                    runnerLastName == self.runner?.lastName {


                                    let currentFollowerRef = self.followersRef.child(user.uid)


                                    let favoriteValue = [
                                        "runnerUID" : runnerUID
                                    ] as [String : Any]

                                    currentFollowerRef.childByAutoId().setValue(favoriteValue) { (_error, _) in
                                        guard _error == nil else {
                                            self.presentSimpleAlert(title: "Oups", message: "Impossible de suivre ce coureur, il va sûrement trop vite !")
                                            return
                                        }
                                        
                                        self.showSuccessMessage()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.dismissSuccessMessage()
                                        }
                                    }
                                }
                            }
                        }
                } else {
                    self.showErrorMessage()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismissErrorMessage()
                    }
                }
            }
            
        }
    }
    @objc func seeRunnerPosition() {
        var currentUID : String? = ""
        
        if let runner = runner {
            currentUID = runner.uid
            print("runner.uid : \(runner.uid)")
        }
        runningCollection.getDocuments { (_snapshot, _error) in
            guard _error == nil else {
                self.presentSimpleAlert(title: "Impossible de le suivre", message: "Cette personne va sûrement trop vite pour nous, réessayer plus tard.")
                return
            }

            guard let snapshot = _snapshot else { return }

            for document in snapshot.documents {
                let data = document.data()
                if let uid = data["uid"] as? String,
                    uid == currentUID,
                    let lastRunnerLatitude = data["lastLatitude"] as? Double,
                    let lastRunnerLongitude = data["lastLongitude"] as? Double {
                    let runnerMap = SpecifiRunnerVC()
                    let runnerPosition = CLLocationCoordinate2D(latitude: lastRunnerLatitude, longitude: lastRunnerLongitude)
                    runnerMap.position = runnerPosition
                    let navC = UINavigationController(rootViewController: runnerMap)
                    self.present(navC, animated: true)
                } else {
                    self.presentSimpleAlert(title: "Oups !", message: "Le coureur n'a pas encore commencé la course, revenez plus tard ou suivez-le !")
                }
                
                
            }

        }
    }
    
    @objc func dismissVC(_ gesture : UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}

//MARK: - Firebase
extension RSAlertVC {
    fileprivate func checkIfRunnerIsFollowed(completion : @escaping (_ isFollowed : Bool) -> ()) {
        guard let user = Auth.auth().currentUser else { return }
        guard let runnerUID = runner?.uid else { return }
        let currentUserRef = followersRef.child(user.uid)
        currentUserRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                    let infos = childSnap.value as? [String : Any],
                    let uid = infos["runnerUID"] as? String,
                    runnerUID == uid {
                    self.alreadyFollow = true
                }
            }
            completion(self.alreadyFollow ?? false)
        }
    }
}


//MARK: - Animations

extension RSAlertVC {
    fileprivate func showErrorMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.seeButton.alpha    = 0
            self.followButton.alpha = 0
            
            self.seeButton.transform = CGAffineTransform(translationX: 400, y: 0)
            self.followButton.transform = CGAffineTransform(translationX: -400, y: 0)
            
            self.seeButton.isUserInteractionEnabled     = false
            self.followButton.isUserInteractionEnabled  = false
            
            if self.errorButton != nil {
                self.errorButton.removeFromSuperview()
                self.errorButton = nil
            }
            
            
            
            self.errorButton = RSButton(backgroundColor: .systemRed, title: "Vous suivez déjà ce coureur")
            self.containerView.addSubview(self.errorButton)
            
            let insets = UIEdgeInsets(top: 0, left: self.padding, bottom: self.padding, right: self.padding)
            self.errorButton.edgesToSuperview(excluding: .top, insets: insets)
            self.errorButton.height(44)
        })
    }
    
    fileprivate func dismissErrorMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            if self.errorButton != nil {
                self.errorButton.removeFromSuperview()
                self.errorButton = nil
            }
            
            if self.seeButton.alpha == 0 && self.followButton.alpha == 0 {
                self.seeButton.alpha    = 1
                self.followButton.alpha = 1
                
                self.seeButton.isUserInteractionEnabled     = true
                self.followButton.isUserInteractionEnabled  = true
                
                self.seeButton.transform = CGAffineTransform(translationX: 0, y: 0)
                self.followButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        })
    }
    
    fileprivate func showSuccessMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            self.seeButton.alpha    = 0
            self.followButton.alpha = 0
            
            self.seeButton.transform = CGAffineTransform(translationX: 400, y: 0)
            self.followButton.transform = CGAffineTransform(translationX: -400, y: 0)
            
            self.seeButton.isUserInteractionEnabled     = false
            self.followButton.isUserInteractionEnabled  = false
            
            
            if self.successButton != nil {
                self.successButton.removeFromSuperview()
                self.successButton = nil
            }
            
            self.successButton = RSButton(backgroundColor: .systemGreen, title: "Coureur suivi ! 🎉")
            self.containerView.addSubview(self.successButton)
            
            let insets = UIEdgeInsets(top: 0, left: self.padding, bottom: self.padding, right: self.padding)
            self.successButton.edgesToSuperview(excluding: .top, insets: insets)
            self.successButton.height(44)
        })
    }
    
    fileprivate func dismissSuccessMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            if self.successButton != nil {
                self.successButton.removeFromSuperview()
                self.successButton = nil
            }
            
            if self.seeButton.alpha == 0 && self.followButton.alpha == 0 {
                self.seeButton.alpha    = 1
                self.followButton.alpha = 1
                
                self.seeButton.isUserInteractionEnabled     = true
                self.followButton.isUserInteractionEnabled  = true
                
                self.seeButton.transform = CGAffineTransform(translationX: 0, y: 0)
                self.followButton.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        })
    }
    
}
