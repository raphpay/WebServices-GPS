//
//  AddRunnerVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 19/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD

class AddRunnerVC: UIViewController {
    
    
    //MARK: - Objects
    var firstNameTextField  = RSTextField(placeholder: "Prénom", returnKeyType: .next, keyboardType: .default)
    var lastNameTextField   = RSTextField(placeholder: "Nom", returnKeyType: .next, keyboardType: .default)
    var emailTextField      = RSTextField(placeholder: "Email", returnKeyType: .next, keyboardType: .emailAddress)
    var passwordTextField   = RSTextField(placeholder: "Mot de Passe", returnKeyType: .next, keyboardType: .default)
    var raceTextField       = RSTextField(placeholder: "Course", returnKeyType: .next, keyboardType: .default)
    var sendButton          = RSButton(backgroundColor: .systemBlue, title: "Envoyer au serveur")

    
    lazy var textFields     = [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, raceTextField]
    lazy var subviews       = [firstNameTextField, lastNameTextField, emailTextField, passwordTextField,
                               raceTextField ,sendButton]
    
    let hud             = JGProgressHUD(style: .dark)
    let successHUD      = JGProgressHUDSuccessIndicatorView()
    
    //MARK: - Properties
    let padding = CGFloat(20)
    let runnerCollection = Firestore.firestore().collection("Runner")
    let runnersRef          = Database.database().reference().child("runners")
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Add a hideKeyboard TGR to this screen and the other server screen
        setupUI()
        
        Auth.auth().addStateDidChangeListener { (auth, _user) in
            guard let _ = _user else { return }
//            print(user.email)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.title = "Ajouter un coureur"
    }
}


//MARK: - User Interface
extension AddRunnerVC {
    fileprivate func setupUI() {
        view.backgroundColor = .systemBackground
        
        for subview in subviews {
            view.addSubview(subview)
            
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                subview.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: padding),
            
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: padding),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            
            raceTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            
            sendButton.topAnchor.constraint(equalTo: raceTextField.bottomAnchor, constant: padding)
        ])
        
        configureTextFields()
        configureButton()
    }
    
    fileprivate func configureTextFields() {
        firstNameTextField.tag  = 0
        lastNameTextField.tag   = 1
        emailTextField.tag      = 2
        passwordTextField.tag   = 3
        raceTextField.tag       = 4
        
        firstNameTextField.delegate  = self
        lastNameTextField.delegate   = self
        emailTextField.delegate      = self
        passwordTextField.delegate   = self
        raceTextField.delegate       = self
        
        emailTextField.autocapitalizationType = .none
        passwordTextField.autocapitalizationType = .none
    }
    
    fileprivate func configureButton() {
        sendButton.addTarget(self, action: #selector(sendToServer), for: .touchUpInside)
    }
}


//MARK: - Actions

extension AddRunnerVC {
    @objc func sendToServer() {
        createRunnerProfile()
        self.reset(textFields: textFields)
    }
}



//MARK: - Text Field Delegate
extension AddRunnerVC : UITextFieldDelegate {
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


//MARK: - Firebase

extension AddRunnerVC {
    
    fileprivate func createRunnerProfile() {
        self.hud.textLabel.text = "Chargement"
        self.hud.show(in: self.view)
        
        guard firstNameTextField.text != "",
        lastNameTextField.text != "",
        emailTextField.text != "",
            passwordTextField.text != "" ,
            raceTextField.text != "" else {
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.textLabel.text = "Champs manquants"
                self.hud.dismiss(afterDelay: 2.0)
                return }
        
        guard let firstName = firstNameTextField.text,
        let lastName = lastNameTextField.text,
        let email = emailTextField.text,
            let password = passwordTextField.text ,
            let race = raceTextField.text else { return }
        
        self.createUser(email: email, password: password, firstName : firstName, lastName : lastName, race : race)
    }
    
    fileprivate func createUser(email : String, password : String, firstName : String, lastName : String, race : String) {
        Auth.auth().createUser(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                self.presentSimpleAlert(title: "Erreur de création", message: _error!.localizedDescription)
                self.hud.dismiss()
            return }
            guard let result = _result else {
                print("no result")
                return
            }
            
            let userData = [
            "firstName" : firstName,
            "lastName" : lastName,
            "email" : email,
            "uid" : result.user.uid
            ] as [String : Any]
            
            
            //Append runner to runner collectin in firestore
            self.runnerCollection.document(result.user.uid).setData(userData) { (_error) in
                guard _error == nil else {
                    self.presentSimpleAlert(title: "Erreur", message: "Il y a eu une erreur lors de la mise en place des données : \(_error!.localizedDescription)")
                    return
                }
                
                //No error, the runner is successfully register to firestore
                //Register runner to race and add him in database
                self.registerRunnerToRace(uid: result.user.uid, race: race)
                
                //Show success message
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    UIView.animate(withDuration: 0.1) {
                        self.hud.textLabel.text = "Succès"
                        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    }
                    
                    self.hud.dismiss(afterDelay: 1.0)
                }
                
                
            }
        }
    }
    
    fileprivate func registerRunnerToRace(uid : String, race : String) {
        let value = [ "race" : race ] as [String : Any]
        
        runnersRef.child(uid).childByAutoId().setValue(value)
    }
    
}
