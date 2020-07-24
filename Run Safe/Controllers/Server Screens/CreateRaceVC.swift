//
//  CreateRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 01/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import TinyConstraints
import JGProgressHUD

class CreateRaceVC: UIViewController {
    
    //MARK: - Subviews
    var nameTextField   = RSTextField(placeholder: "Nom de la course", returnKeyType: .next,
                                      keyboardType: .default)
    var placeTextField  = RSTextField(placeholder: "Ville", returnKeyType: .next, keyboardType: .default)
    var typeTextField   = RSTextField(placeholder: "Type de Course", returnKeyType: .done,
                                      keyboardType: .default)
    
    var errorMessage    = UILabel()
    
    var sendButton      = RSButton(backgroundColor: .systemBlue, title: "Envoyer au serveur")
    
    var logOutButton    = RSButton(backgroundColor: .systemRed, title: "Déconnexion")
    
    var memoLabel       = UILabel()
    var memoLabel2      = UILabel()
    
    let hud = JGProgressHUD(style : .dark)
    
    //MARK: - Properties
    let padding     = CGFloat(20)
    let eventsRef   = Database.database().reference().child("events")
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        //TODO: Find the navBar problem ( nothing can be shown in there )
    }
}

//MARK: - User Interface
extension CreateRaceVC {
    fileprivate func setupUI() {
        view.backgroundColor = .systemBackground
        
        let subviews = [nameTextField, placeTextField, typeTextField, errorMessage, sendButton, logOutButton , memoLabel, memoLabel2]
        let textFields = [nameTextField, placeTextField, typeTextField]
        
        for subview in subviews {
            view.addSubview(subview)
            
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                subview.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        for textField in textFields {
            textField.delegate = self
        }
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            placeTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant : padding),
            
            typeTextField.topAnchor.constraint(equalTo: placeTextField.bottomAnchor, constant: padding),
            
            errorMessage.topAnchor.constraint(equalTo: typeTextField.bottomAnchor, constant: padding),
            
            sendButton.topAnchor.constraint(equalTo: errorMessage.bottomAnchor, constant : padding),
            
            logOutButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: padding),
            
            memoLabel.topAnchor.constraint(equalTo: logOutButton.bottomAnchor, constant: padding),
            memoLabel.heightAnchor.constraint(equalToConstant: 100),
            
            memoLabel2.topAnchor.constraint(equalTo: memoLabel.bottomAnchor, constant: 5),
            memoLabel2.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        nameTextField.tag   = 0
        placeTextField.tag  = 1
        typeTextField.tag   = 2
        
        errorMessage.textColor      = .red
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        errorMessage.alpha          = 0
        errorMessage.textAlignment  = .center
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        logOutButton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        
        memoLabel.translatesAutoresizingMaskIntoConstraints = false
        memoLabel.numberOfLines = 0
        memoLabel.text = "Pour rappel, les types de courses sont : Trail, DH, XC, Route."
        memoLabel.textAlignment = .center
        memoLabel.alpha = 0
        
        memoLabel2.translatesAutoresizingMaskIntoConstraints = false
        memoLabel2.numberOfLines = 0
        memoLabel2.text = "Veillez à bien les orthographier"
        memoLabel2.textAlignment = .center
        memoLabel2.alpha = 0
        memoLabel2.textColor = .red
    }
}

//MARK: - Actions
extension CreateRaceVC {
    @objc func sendButtonTapped() {
        if isTextFieldCorrect() {
            sendToFirebase()
        } else {
            showMemo()
        }
    }
    
    @objc func logOutTapped() {
        do {
            try Auth.auth().signOut()
            let navC = UINavigationController(rootViewController: FirstVC())
            navC.modalPresentationStyle = .fullScreen
            self.present(navC, animated: true)
        } catch let logOutError as NSError {
            self.presentSimpleAlert(title: "Erreur", message: "Il y a eu une erreur lors de la déconnexion")
            print("error signing in : \(logOutError.localizedDescription)")
            return
        }
    }
}



//MARK: - Firebase
extension CreateRaceVC {
    fileprivate func sendToFirebase() {
        hud.textLabel.text = "Chargement"
        hud.show(in: self.view)
        
        guard nameTextField.text != "",
        placeTextField.text != "",
            typeTextField.text != "" else {
                errorMessage.text   = "Veuillez remplir tous les champs"
                errorMessage.alpha  = 1
                hud.dismiss()
                return
        }
        
        guard let name = nameTextField.text,
            let place = placeTextField.text,
            let type = typeTextField.text else {
                print("error with textfields")
                hud.dismiss()
                return
        }
        
        resetTextFields()
        
        let eventData = [
            "name" : name,
            "place" : place,
            "type" : type
        ] as [String : Any]
        
        eventsRef.childByAutoId().setValue(eventData) { (_error, reference) in
            guard _error == nil else {
                self.presentSimpleAlert(title: "Erreur", message: _error!.localizedDescription)
                return
            }
            self.showSuccessHUD()
            
        }
        
    }
}

//MARK: - Helper Methods
extension CreateRaceVC {
    fileprivate func resetTextFields() {
        nameTextField.text = ""
        placeTextField.text = ""
        typeTextField.text = ""
    }
    
    fileprivate func isTextFieldCorrect() -> Bool{
        if typeTextField.text == "Trail" ||
            typeTextField.text == "DH" ||
            typeTextField.text == "XC" ||
            typeTextField.text == "Route" {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func showMemo() {
        memoLabel.alpha = 1
        memoLabel2.alpha = 1
    }
    
    fileprivate func showSuccessHUD() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            UIView.animate(withDuration: 0.1) {
                self.hud.textLabel.text     = "Succès"
                self.hud.indicatorView      = JGProgressHUDSuccessIndicatorView()
            }
            
            self.hud.dismiss(afterDelay: 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hud.indicatorView = JGProgressHUDIndicatorView()
            self.presentSimpleAlert(title: "Pense bête", message: "N'oubliez pas de transmettre les données GPS au serveur !")
        }
    }
}

//MARK: - Textfield Delegate
extension CreateRaceVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}
