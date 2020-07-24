//
//  LoginVC.swift
//  Run Safe Login
//
//  Created by Raphaël Payet on 02/04/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import TinyConstraints



class LoginVC: UIViewController {
    //MARK: - Subviews
    let backgroundImage     = UIImageView(image: UIImage(named : AssetsImages.frontRunner))
    let emailTextField      = RSTextField(placeholder: "Email", returnKeyType: .next, keyboardType: .emailAddress)
    let passwordTextField   = RSTextField(placeholder: "Mot de Passe", returnKeyType: .go, keyboardType: .default)
    let showButton          = UIButton()
    var errorBackgroundView = UIView()
    var errorLabel          = UILabel()
    
    let followerButton      : UIButton = {
        let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.layer.cornerRadius   = 10
        bt.layer.borderWidth    = 2
        bt.layer.borderColor    = UIColor.black.cgColor
        bt.setTitle("Follower", for: .normal)
        bt.titleLabel?.font     = .preferredFont(forTextStyle: .headline)
        bt.backgroundColor      = .clear
        return bt
    }()
    
    let runnerButton        : UIButton = {
       let bt = UIButton()
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.layer.cornerRadius   = 10
        bt.layer.borderWidth    = 2
        bt.layer.borderColor    = UIColor.black.cgColor
        bt.setTitle("Runner", for: .normal)
        bt.titleLabel?.font     = .preferredFont(forTextStyle: .headline)
        bt.backgroundColor      = .clear
        return bt
    }()
    
    lazy var textFields     = [emailTextField, passwordTextField]
    lazy var authButtons    = [followerButton, runnerButton]
    
    let signInButton        = RSButton(backgroundColor: .systemBlue, title: "Connexion")
    
    //MARK: - Properties
    let externalPadding = CGFloat(50)
    let padding = CGFloat(20)
    
    let followerCollection  = Firestore.firestore().collection("Follower")
    let runnerCollection    = Firestore.firestore().collection("Runner")

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        title = "Connexion"
    }
}

//MARK: - User Interface

extension LoginVC {
    func setupUI() {
        configureSuperView()
        configureBackImage()
        configureTextFields()
        configureErrorMessage()
        configureUserTypeButton()
        configureLogInButton()
    }
    
    fileprivate func configureSuperView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func configureBackImage()  {
        view.addSubview(backgroundImage)
        backgroundImage.edgesToSuperview()
    }
    fileprivate func configureTextFields() {
        for textField in textFields {
            
            view.addSubview(textField)
            textField.height(50)
            textField.leftToSuperview(view.leftAnchor, offset: padding)
            textField.rightToSuperview(view.rightAnchor, offset: -padding)
            
            textField.delegate                  = self
            textField.autocorrectionType        = .no
            textField.autocapitalizationType    = .none
            textField.backgroundColor           = UIColor(white: 1, alpha: 0.9)
        }
        
        emailTextField.topToSuperview(view.safeAreaLayoutGuide.topAnchor, offset: 30)
        passwordTextField.topToBottom(of: emailTextField, offset: padding)
        
        emailTextField.tag      = 0
        passwordTextField.tag   = 1
        
        emailTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
    }
    fileprivate func configureUserTypeButton() {
        for button in authButtons {
            view.addSubview(button)
            button.topToBottom(of: passwordTextField, offset: padding)
            button.height(50)
            button.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
            button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.5)
        }
        
        let buttonWidth = (self.view.frame.width) / 2 - 40
        
        followerButton.leftToSuperview(view.leftAnchor, offset: padding)
        followerButton.width(buttonWidth)
        followerButton.tag = 0
        
        runnerButton.rightToSuperview(view.rightAnchor, offset: -padding)
        runnerButton.width(buttonWidth)
        runnerButton.tag = 1
    }
    fileprivate func configureLogInButton() {
        view.addSubview(signInButton)
        
        signInButton.topToBottom(of: followerButton, offset: padding)
        signInButton.leftToSuperview(view.leftAnchor, offset: padding)
        signInButton.rightToSuperview(view.rightAnchor, offset: -padding)
        signInButton.height(50)
        
        signInButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    fileprivate func configureErrorMessage() {
        view.addSubview(errorBackgroundView)
        errorBackgroundView.addSubview(errorLabel)
        
        errorBackgroundView.topToBottom(of: passwordTextField, offset: padding)
        errorBackgroundView.leftToSuperview(view.leftAnchor, offset: padding)
        errorBackgroundView.rightToSuperview(view.rightAnchor, offset: -padding)
        errorBackgroundView.height(50)
        
        errorBackgroundView.layer.cornerRadius = 10
        
        errorLabel.centerInSuperview()
        
        errorBackgroundView.alpha = 0
        errorBackgroundView.backgroundColor = .systemRed
        errorLabel.alpha = 0
        errorLabel.textAlignment = .center
    }
}

//MARK: - Actions

extension LoginVC {
    @objc func loginTapped(_ sender : UIButton) {
        sender.pulsate()
        if let buttonTitle = getButtonTitle() {
            getUserProfile(for: buttonTitle) { (matchingUser, userType) in
                if matchingUser {
                    if buttonTitle == "Runner" {
                        self.signInRunner()
                    } else if buttonTitle == "Follower" {
                        self.signInUser()
                    }
                } else {
                    self.showErrorMessage(error: CustomError.status)
                }
            }
        } else {
            self.signInServer()
        }
        
        
    }
    @objc func authButtonTapped(_ button : UIButton) {
        button.isSelected = true
        button.backgroundColor = .systemPurple
        for item in authButtons {
            if item.tag != button.tag {
                item.isSelected = false
                item.backgroundColor = .clear
            }
        }
    }
    @objc func hideKeyboard(_ gesture : UITapGestureRecognizer) {
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    @objc func showPassword() {
        passwordTextField.isSecureTextEntry.toggle()
        if passwordTextField.isSecureTextEntry {
            showButton.setImage(UIImage(systemName: SFSymbols.eye), for: .normal)
        } else {
            showButton.setImage(UIImage(systemName: SFSymbols.eyeSlash), for: .normal)
        }
    }
}

//MARK: - TextField Delegate
extension LoginVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.addTarget(self, action: #selector(loginTapped), for: .editingDidEnd)
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}


//MARK: - Firebase
extension LoginVC {
    fileprivate func signInUser() {
        guard let email = emailTextField.text,
            !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty else {
                self.showErrorMessage(error: CustomError.emptyFields)
                return
        }
        
        
        
        Auth.auth().signIn(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                self.showErrorMessage(error: CustomError.mailAndPassword)
                return
            }

            guard _result != nil else {
                print("result nil")
                return
            }
            
            self.showFollowerTabBar()
            self.reset(textFields: self.textFields)
        }
    }
    fileprivate func signInRunner() {

        
        guard let email = emailTextField.text,
            !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty else {
                self.showErrorMessage(error: CustomError.emptyFields)
                return
        }
        
        self.signInButton.pulsate()
        
        Auth.auth().signIn(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                self.showErrorMessage(error: CustomError.mailAndPassword)
                return
            }
            guard _result != nil else { return }
            
            self.showRunnerScreen()
            self.reset(textFields: self.textFields)
        }
    }
    fileprivate func signInServer() {
        guard self.emailTextField.text != "",
            self.passwordTextField.text != "" else {
                showErrorMessage(error: CustomError.emptyFields)
                return
        }
        
        guard let email = self.emailTextField.text,
            email == "server@test.com",
            let password = self.passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                self.showErrorMessage(error: CustomError.mailAndPassword)
                return
            }
            
            guard _result != nil else {
                print("result nil")
                return
            }
            
            self.showServerTabBar()
            self.reset(textFields: self.textFields)
        }
    }
    fileprivate func getUserProfile( for type : String, completion : @escaping (_ matchingUser : Bool, _ userType : UserType) -> ()) {
        guard emailTextField.text != "" else { return }
        guard let email = emailTextField.text else { return }
        
        let typeDB = Firestore.firestore().collection(type)
        typeDB.getDocuments(source: .default) { (_snapshot, _error) in
            guard _error == nil else {
                print("error : \(_error!.localizedDescription)")
                return
            }
            
            guard let snapshot = _snapshot else {
                print("no snapshot")
                return
            }
            
            for document in snapshot.documents {
                let users = document.data()
                if let userEmail = users["email"] as? String,
                    email == userEmail {
                    if type == "Runner" {
                        completion(true, .Runner)
                    } else if type == "Follower" {
                        completion(true, .Follower)
                    }
                    return
                }
            }
            
            completion(false, .Follower)
            
        }
        
    }
}


//MARK: - Animations

extension LoginVC {
    fileprivate func showErrorMessage(error : String) {
        UIView.animateKeyframes(withDuration: 3, delay: 0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.05, relativeDuration: 0.1) {
                for button in self.authButtons {
                    button.transform = CGAffineTransform(translationX: 0, y: 70)
                }
                
                self.signInButton.transform = CGAffineTransform(translationX: 0, y: 70)
                
                self.errorBackgroundView.alpha = 1
                self.errorLabel.alpha = 1
                
                self.errorLabel.text = error
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.95, relativeDuration: 0.1) {
                for button in self.authButtons {
                    button.transform = .identity
                }
                
                self.errorBackgroundView.alpha = 0
                self.errorLabel.alpha = 0
                
                self.signInButton.transform = .identity
            }
        })
    }
}


//MARK: - Helper Methods

extension LoginVC {
    fileprivate func getButtonTitle() -> String? {
        for button in authButtons {
            if button.isSelected,
                let title = button.titleLabel?.text {
                return title
            }
        }
        
        return nil
    }
    
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
    
    func showServerTabBar() {
        let tabBar = UITabBarController()
        let createRaceVC    = CreateRaceVC()
        let createNavC      = UINavigationController(rootViewController: createRaceVC)
        createNavC.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(named: "checkered-flag"), tag : 0)
        
        let addRunnerVC = AddRunnerVC()
        let addRunnerNavC = UINavigationController(rootViewController: addRunnerVC)
        addRunnerNavC.tabBarItem = UITabBarItem(title: "Coureur", image: UIImage(systemName: "person"), tag: 1)
        
        let registerRunner = RegisterRunnerVC()
        let registerNavC    = UINavigationController(rootViewController: registerRunner)
        registerNavC.tabBarItem = UITabBarItem(title: "Inscription", image: UIImage(systemName: "rectangle.and.paperclip"), tag: 2)
        
        tabBar.viewControllers = [createNavC, addRunnerNavC, registerNavC]
        tabBar.modalPresentationStyle = .overFullScreen
        self.present(tabBar, animated: true)
    }
    
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
    
}



