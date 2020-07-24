//
//  RSInscriptionAlert.swift
//  Run Safe
//
//  Created by Raphaël Payet on 22/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import TinyConstraints

class RSInscriptionAlert: UIViewController {
    
    
    
    //MARK: - Objects
    let containerView       = UIView()
    let profileImage        = UIImageView()
    let firstNameLabel      = UILabel()
    let lastNameLabel       = UILabel()
    let numberLabel         = UILabel()
    let placeLabel          = UILabel()
    let inscriptionButton   = RSButton(backgroundColor: .systemOrange, title: "Inscrire")
    var errorButton         : RSButton! = nil
    var successButton       : RSButton! = nil
        
    let runnerReference     = Database.database().reference().child("runners")
    let runnerCollection    = Firestore.firestore().collection("Runner")
    let runningCollection   = Firestore.firestore().collection("Running")
    
    
    //MARK: Properties
    var race            : Race?
    var runner          : Runner?
    var place           : Int?
    var alreadyFollow   : Bool!
    
    let padding = CGFloat(20)
    
    init(runner : Runner, race : Race) {
        super.init(nibName : nil, bundle : nil)
        self.runner     = runner
        self.race       = race
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
extension RSInscriptionAlert {
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
        
        containerView.centerInSuperview()
        containerView.width(300)
        containerView.height(200)
        
        containerView.backgroundColor       = .systemBackground
        containerView.layer.cornerRadius    = 16
        containerView.layer.borderWidth     = 2
        containerView.layer.borderColor     = UIColor.white.cgColor
    }
    fileprivate func configureProfileImage() {
        containerView.addSubview(profileImage)
        
        
        profileImage.topToSuperview(containerView.topAnchor, offset: padding)
        profileImage.leftToSuperview(containerView.leftAnchor, offset: padding)
        profileImage.width(50)
        profileImage.height(50)
        
        profileImage.image      = UIImage(systemName: SFSymbols.person)
        profileImage.tintColor  = .black
    }
    fileprivate func configureNumberLabel() {
        containerView.addSubview(numberLabel)
        
        numberLabel.topToSuperview(containerView.topAnchor, offset: padding)
        numberLabel.rightToSuperview(containerView.rightAnchor, offset: -padding)
        numberLabel.height(50)
        numberLabel.width(50)
        
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
        containerView.addSubview(inscriptionButton)
        
        
        inscriptionButton.leftToSuperview(containerView.leftAnchor, offset: padding)
        inscriptionButton.rightToSuperview(containerView.rightAnchor, offset: -padding)
        inscriptionButton.height(44)
        inscriptionButton.bottomToSuperview(containerView.bottomAnchor, offset: -padding)
        
        
        inscriptionButton.addTarget(self, action: #selector(registerRunner), for: .touchUpInside)
        
        
        
    }
    fileprivate func configurePlaceLabel() {
        containerView.addSubview(placeLabel)
        
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            placeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            placeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            placeLabel.bottomAnchor.constraint(equalTo: inscriptionButton.topAnchor, constant: 8)
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

extension RSInscriptionAlert {
    @objc func registerRunner() {
        let runnerReference = getCurrentRunnerReference()
        if let reference = runnerReference,
            let selectedRace = race {
            checkIfRunnerIsRegister(reference: reference, to: selectedRace) { (isRegistered) in
                if isRegistered {
                    //TODO: Show error
                    self.inscriptionButton.cubeTransition(button: self.inscriptionButton, title: "Déjà inscrit", direction: .positive, newColor: .systemRed)
                    delay(seconds: 2) {
                        self.inscriptionButton.cubeTransition(button: self.inscriptionButton, title: "Inscription", direction: .negative, newColor: .systemOrange)
                    }
                } else {
                    let raceData = ["race" : selectedRace.name] as [String : Any]
                    reference.childByAutoId().setValue(raceData) { (_error, ref) in
                        guard _error == nil else {
                            print("error : \(_error!.localizedDescription)")
                            return }
                        
                        self.inscriptionButton.cubeTransition(button: self.inscriptionButton, title: "Coureur inscrit 🎉", direction: .negative, newColor: .systemGreen)
                        delay(seconds: 2) {
                            self.inscriptionButton.cubeTransition(button: self.inscriptionButton, title: "Inscription", direction: .positive, newColor: .systemOrange)
                        }
                    }
                }
            }
        }
    }
    
    @objc func dismissVC(_ gesture : UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}

//MARK: - Firebase
extension RSInscriptionAlert {
    
    fileprivate func getCurrentRunnerReference() -> DatabaseReference? {
        var reference = DatabaseReference()
        guard let runnerUID = runner?.uid else { return nil }
        reference = runnerReference.child(runnerUID)
        return reference
    }
    fileprivate func checkIfRunnerIsRegister(reference : DatabaseReference, to race : Race, completion : @escaping (_ isRegistered : Bool) -> ()) {
        var isRegistered : Bool = false
        reference.observeSingleEvent(of: .value) { (snaphot) in
            for child in snaphot.children {
                if let childSnap = child as? DataSnapshot,
                    let infos = childSnap.value as? [String : Any],
                    let dataRace = infos["race"] as? String {
                    
                    if dataRace == race.name  {
                        //Le coureur est déjà inscrit à la course
                        isRegistered = true
                    } else {
                        //Sinon, on l'inscrit
                        isRegistered = false
                    }
                }
            }
            completion(isRegistered)
        }
    }
    
    
}


//MARK: - Animations

extension RSInscriptionAlert {
    fileprivate func showErrorMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.inscriptionButton.alpha = 0
            
            self.inscriptionButton.transform = CGAffineTransform(translationX: -400, y: 0)
            
            self.inscriptionButton.isUserInteractionEnabled  = false
            
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
            
            if self.inscriptionButton.alpha == 0 {
                self.inscriptionButton.alpha = 1
                
                self.inscriptionButton.isUserInteractionEnabled  = true
                
                self.inscriptionButton.transform = .identity
            }
        })
    }
    
    fileprivate func showSuccessMessage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            self.inscriptionButton.alpha = 0
            
            self.inscriptionButton.transform = CGAffineTransform(translationX: -400, y: 0)
            
            self.inscriptionButton.isUserInteractionEnabled  = false
            
            
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
            
            if self.inscriptionButton.alpha == 0 {
                
                self.inscriptionButton.alpha = 1
                
                self.inscriptionButton.isUserInteractionEnabled  = true
                
                self.inscriptionButton.transform = .identity
            }
        })
    }
    
}
