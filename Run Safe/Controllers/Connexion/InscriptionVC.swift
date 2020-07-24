//
//  InscriptionVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 05/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import TinyConstraints

class InscriptionVC: UIViewController {
    
    //MARK: - Objects
    let emailTextField      = RSTextField(placeholder: "Email", returnKeyType: .next, keyboardType: .emailAddress)
    let firstNameTextField  = RSTextField(placeholder: "Prénom", returnKeyType: .next, keyboardType: .default)
    let lastNameTextField   = RSTextField(placeholder: "Nom", returnKeyType: .next, keyboardType: .default)
    let passwordTextField   = RSTextField(placeholder: "Mot de Passe", returnKeyType: .done, keyboardType: .default)
    let errorMessageLabel   = RSButton()
    
    let showButton          = UIButton()
    let continueButton      = RSButton(backgroundColor: .systemBlue, title: "Créer un compte")
    let backgroundImage     = UIImageView()
    
    lazy var textFields     = [emailTextField, passwordTextField]
    
    //MARK: - Properties
    let padding = CGFloat(20)
    let followerCollection = Firestore.firestore().collection("Follower")

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Inscription"
    }
}


//MARK: - User Interface
extension InscriptionVC {
    fileprivate func setupUI() {
        configureImage()
        configureSuperView()
        confgureSubviews()
        configureButton()
    }
    fileprivate func configureSuperView() {
        let tapOutsideTextFields = UITapGestureRecognizer(target: self, action: #selector(hidesKeyboard(_:)))
        view.addGestureRecognizer(tapOutsideTextFields)
    }
    fileprivate func configureImage() {
        view.addSubview(backgroundImage)
        backgroundImage.edgesToSuperview()
        backgroundImage.image = UIImage(named: AssetsImages.cormoranFalls)
    }
    fileprivate func confgureSubviews() {
        let subviews = [emailTextField, firstNameTextField, lastNameTextField ,passwordTextField, continueButton, errorMessageLabel]
        
        for subview in subviews {
            view.addSubview(subview)
            
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                subview.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            firstNameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: padding),
            
            passwordTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: padding),
            
            continueButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            
            errorMessageLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant : padding)
        ])
        
        emailTextField.autocapitalizationType       = .none
        emailTextField.backgroundColor              = .white
        emailTextField.tintColor                    = .black
        emailTextField.tag                          = 0
        emailTextField.delegate                     = self
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)])
        
        firstNameTextField.backgroundColor          = .white
        firstNameTextField.tag                      = 1
        firstNameTextField.delegate                 = self
        
        lastNameTextField.backgroundColor           = .white
        lastNameTextField.tag                       = 2
        lastNameTextField.delegate                  = self
        
        passwordTextField.isSecureTextEntry         = true
        passwordTextField.autocapitalizationType    = .none
        passwordTextField.backgroundColor           = .white
        passwordTextField.tag                       = 3
        passwordTextField.delegate                  = self
        setupPasswordTextField()
        
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.alpha = 0
        errorMessageLabel.backgroundColor = .systemRed
    }
    fileprivate func setupPasswordTextField() {
        passwordTextField.addSubview(showButton)
        showButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            showButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -5),
            showButton.heightAnchor.constraint(equalToConstant: 40),
            showButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        showButton.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        showButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
    }
    
    fileprivate func configureButton() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
}


//MARK: - Actions
extension InscriptionVC {
    @objc func continueTapped(_ sender : UIButton) {
        sender.pulsate()
        createUser()
    }
    
    @objc func showPassword() {
        passwordTextField.isSecureTextEntry.toggle()
        if passwordTextField.isSecureTextEntry {
            showButton.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        } else {
            showButton.setImage(UIImage(systemName: SFSymbols.eyeSlash), for: .normal)
        }
    }
    @objc func hidesKeyboard(_ gesture : UITapGestureRecognizer) {
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    
}


//MARK: - Firebase

extension InscriptionVC {
    fileprivate func createUser() {
        guard emailTextField.text != "",
            firstNameTextField.text != "",
            lastNameTextField.text != "",
            passwordTextField.text != "" else {
                self.showErrorMessage(text: "Champs manquants")
            return
        }
        
        let error = self.validateFields(emailTextField: emailTextField, passwordTextField: passwordTextField)
        
        guard error == nil else {
            print("error validating fields : \(error!)")
            self.showErrorMessage(text: "Mot de Passe non valide")
            return
        }
        
        guard let email = emailTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let password = passwordTextField.text else {
                self.showErrorMessage(text: "Champs manquants")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                print("error creating user : \(_error!.localizedDescription)")
                self.showErrorMessage(text: _error!.localizedDescription)
                return
            }
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
            
            self.followerCollection.document(result.user.uid).setData(userData) { (_error) in
                guard _error == nil else {
                    print("error setting data")
                    self.showErrorMessage(text: _error!.localizedDescription)
                    return
                }
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { (_result, _error) in
                guard _error == nil else {
                    self.presentSimpleAlert(title: "Erreur", message: _error!.localizedDescription)
                    return
                }
                
                self.showFollowerTabBar()
            }
        }
    
    }
}


//MARK: - Helper Methods

extension InscriptionVC {
    func showFollowerTabBar() {
        let tabBar      = UITabBarController()
        let racesVC     = FollowerRaceVC()
        let racesNavC   = UINavigationController(rootViewController: racesVC)
        racesNavC.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: SFSymbols.list), tag: 1)
        
        let searchVC    = SearchRunnerVC()
        let searchNavC  = UINavigationController(rootViewController: searchVC)
        searchNavC.tabBarItem = UITabBarItem(title: "Rechercher", image: UIImage(systemName: SFSymbols.search), tag: 0)
        
        let profileVC   = ProfileVC()
        let profileNavC = UINavigationController(rootViewController: profileVC)
        profileNavC.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: SFSymbols.person), tag: 2)
        
        tabBar.viewControllers = [racesNavC, searchNavC, profileNavC]
        tabBar.modalPresentationStyle = .fullScreen
        self.present(tabBar, animated: true)
    }
    
    fileprivate func showErrorMessage(text : String) {
        if errorMessageLabel.alpha == 0 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                    self.errorMessageLabel.alpha = 1
                    self.errorMessageLabel.setTitle(text, for: .normal)
                })
            }
        } else {
            errorMessageLabel.setTitle(text, for: .normal)
        }
    }
}


//MARK: - TextField Delegate
extension InscriptionVC : UITextFieldDelegate {
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
