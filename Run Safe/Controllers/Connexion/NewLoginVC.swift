//
//  NewLoginVC.swift
//  WebServicesLogin
//
//  Created by Raphaël Payet on 10/07/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

let screen = UIScreen.main.bounds

class NewLoginVC: UIViewController {
    
    //MARK: - Views
    let logo                = UIImageView()
    let flagImageView       = UIImageView()
    let welcomeLabel        = UILabel()
    let welcomeLabel2       = UILabel()
    let loginButton         = WSButton(color: .runBlue, title: "Connexion")
    let inscriptionButton   = WSButton(color: .runRed, title: "Inscription")
    let indicationLabel     = UILabel()
    let emailTextField      = WSTextField(title: "Email",
                                          insets: UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 12),
                                          keyboardEntry: .emailAddress)
    let passwordTextField   = WSTextField(title: "Mot de passe",
                                          insets: UIEdgeInsets(top: 0, left: 150, bottom: 0, right: 12),
                                          isSecured: true)
    
    let followerButton      = WSButton(strokeColor : .WSOrange, title : "Follower")
    let orLabel             = UILabel()
    let runnerButton        = WSButton(strokeColor: .WSOrange, title: "Runner")
    
    let connexionHUD        = JGProgressHUD(style: .dark)
    
    
    //MARK: - Stacks
    lazy var titleStack     = UIStackView(arrangedSubviews: [welcomeLabel, welcomeLabel2])
    lazy var textFieldStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
    lazy var buttonStack    = UIStackView(arrangedSubviews: [loginButton, inscriptionButton, indicationLabel])
    lazy var authStack      = UIStackView(arrangedSubviews: [followerButton, orLabel, runnerButton])
    
    //MARK: - Arrays
    lazy var textFields     = [emailTextField, passwordTextField]
    lazy var buttons        = [loginButton, inscriptionButton]
    lazy var authButtons    = [followerButton, runnerButton]
    
    //MARK: - Properties
    let padding                     = CGFloat(20)
    var emailShow                   = false
    var passwordShow                = false
    var login                       = false
    var register                    = false
    var indication                  = ""
    
    let authColor                   = UIColor.WSOrange
    let signInColor                 = UIColor.runBlue
    let registerColor               = UIColor.runRed
    
    let fifthScreen                 = screen.height / 5
    
    let followerCollection  = Firestore.firestore().collection("Follower")
    let runnerCollection    = Firestore.firestore().collection("Runner")
    
    let fbManager           = FirebaseManager()
    
    //MARK: - Constraints
    var loginYConstraint            : NSLayoutConstraint!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateLabels()
        animateButtons()
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}


//MARK: - User Interface
extension NewLoginVC {
    
    func setupUI() {
        configureSuperView()
        configureBackground()
        configureLogo()
        configureWelcomeLabels()
        configureTextFields()
        configureButtons()
        configureAuthButtons()
    }
    
    func configureSuperView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func configureLogo() {
        view.addSubview(logo)
        logo.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        logo.height(fifthScreen)
        logo.image = UIImage(named: AssetsImages.logo)
    }
    
    func configureBackground() {
        view.addSubview(flagImageView)
        flagImageView.image = UIImage(named :AssetsImages.runFlag)
        flagImageView.contentMode = .scaleAspectFill
        flagImageView.alpha = 0.8
        flagImageView.edgesToSuperview()
    }
    
    func configureWelcomeLabels() {
        titleStack.axis         = .vertical
        titleStack.alignment    = .center
        titleStack.distribution = .fillEqually
        
        view.addSubview(titleStack)
        titleStack.topToBottom(of: logo)
        titleStack.leftToSuperview(view.leftAnchor, offset: 8)
        titleStack.rightToSuperview(view.rightAnchor, offset: -8)
        titleStack.height(fifthScreen)
        
        welcomeLabel.text   = "Bienvenue sur WebServices GPS"
        welcomeLabel.font   = .systemFont(ofSize: 25, weight: .bold)
        
        welcomeLabel2.text  = "Connectez-vous ou inscrivez-vous"
        welcomeLabel2.font  = .systemFont(ofSize: 20, weight: .medium)
        
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel2.adjustsFontSizeToFitWidth = true
    }
    
    func configureTextFields() {
        textFieldStack.axis         = .vertical
        textFieldStack.spacing      = 30
        textFieldStack.distribution = .fillEqually
        textFieldStack.contentMode = .scaleAspectFit
        
        view.addSubview(textFieldStack)
        textFieldStack.leftToSuperview(view.leftAnchor, offset: padding)
        textFieldStack.rightToSuperview(view.rightAnchor, offset: -padding)
        textFieldStack.topToBottom(of: welcomeLabel2)
        textFieldStack.height(fifthScreen - 20)
        
        for textField in textFields {
            textField.delegate = self
            textField.alpha = 0
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        
        emailTextField.returnKeyType    = .next
        passwordTextField.returnKeyType = .go
    }
    
    func configureButtons() {
        buttonStack.axis            = .vertical
        buttonStack.spacing         = 8
        buttonStack.distribution    = .fillEqually
        
        view.addSubview(buttonStack)
        buttonStack.leftToSuperview(view.leftAnchor, offset: padding)
        buttonStack.rightToSuperview(view.rightAnchor, offset: -padding)
        buttonStack.height(fifthScreen)
        
        loginYConstraint = buttonStack.topToBottom(of: welcomeLabel2, offset: padding)
        
        loginButton.addTarget(self, action: #selector(loginTapped(button:)), for: .touchUpInside)
        inscriptionButton.addTarget(self, action: #selector(inscriptionTapped(button:)), for: .touchUpInside)
        
        indicationLabel.textColor       = .secondaryLabel
        indicationLabel.textAlignment   = .center
        indicationLabel.alpha           = 0
    }
    
    func configureAuthButtons() {
        authStack.axis          = .horizontal
        authStack.alignment     = .center
        authStack.distribution  = .fillEqually
        
        for button in authButtons {
            button.alpha = 0
            button.addTarget(self, action: #selector(authButtonTapped(button:)), for: .touchUpInside)
        }
        
        view.addSubview(authStack)
        authStack.height(fifthScreen)
        authStack.topToBottom(of: buttonStack)
        authStack.leftToSuperview(view.leftAnchor, offset: padding)
        authStack.rightToSuperview(view.rightAnchor, offset: -padding)
        
        followerButton.tag = 0
        runnerButton.tag = 1
        
        orLabel.text = "Ou"
        orLabel.textAlignment = .center
        orLabel.alpha = 0
    }
}

//MARK: - Actions
extension NewLoginVC {
    @objc func animateTextField() {
        changeTextFieldResponder()
    }
    
    @objc func loginTapped(button : UIButton) {
        showEmailTextField(from: button)
        disable(button: button)

        guard isEntryValid(textField: emailTextField) else { return }
        showPasswordTextField()

        guard isEntryValid(textField: passwordTextField) else { return }
        //TODO : Login
        showAuthButtons()
    }
    
    @objc func inscriptionTapped(button : UIButton) {
        showEmailTextField(from: button)
        disable(button: button)
        
        guard isEntryValid(textField: emailTextField) else { return }
        showPasswordTextField()
        
        guard isEntryValid(textField: passwordTextField) else { return }
        showAuthButtons()
    }
    
    @objc func hideKeyboard() {
        for textfield in textFields {
            textfield.resignFirstResponder()
        }
    }
    
    @objc func authButtonTapped(button : UIButton) {
        button.isSelected = true
        selectAuth(button: button)
        for item in authButtons {
            if item.tag != button.tag {
                item.isSelected = false
                deselectAuth(button: item)
            }
        }
        
        guard let email = emailTextField.text,
        !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty  else { return }
        if button.tag == 0 {
            showHUD()
            fbManager.matchingUser(for: "Follower", email: email) { (matchingFollower) in
                if matchingFollower {
                    self.fbManager.signIn(email: email, password: password) { (success) in
                        if success {
                            self.showSuccessHud()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.reset(textFields: self.textFields)
                                self.showFollowerTabBar()
                            }
                        } else {
                            self.showErrorHud(error: CustomError.cantSignIn)
                        }
                    }
                } else {
                    self.showErrorHud(error: CustomError.noAccount)
                }
            }
        } else {
            showHUD()
            fbManager.matchingUser(for: "Runner", email: email) { (matchingRunner) in
                if matchingRunner {
                    self.fbManager.signIn(email: email, password: password) { (success) in
                        if success {
                            self.showSuccessHud()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.reset(textFields: self.textFields)
                                self.showRunnerScreen()
                            }
                        } else {
                            self.showErrorHud(error: CustomError.cantSignIn)
                        }
                    }
                } else {
                    self.showErrorHud(error: CustomError.noAccount)
                }
            }
        }
    }
}

//MARK: - Animations
extension NewLoginVC {
    //Labels
    func animateLabels() {
        let flyRight        = CABasicAnimation(keyPath: "position.x")
        flyRight.fromValue  = -screen.width
        flyRight.toValue    = screen.width / 2
        flyRight.duration   = 0.8
        titleStack.layer.add(flyRight, forKey: nil)
    }
    
    //Buttons

    func animateButtons() {
        let fadeIn          = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue    = 0
        fadeIn.toValue      = 1
        fadeIn.duration     = 0.5
        
        fadeIn.beginTime    = CACurrentMediaTime() + 2
        fadeIn.fillMode     = .both
        
        loginButton.layer.add(fadeIn, forKey: nil)
        inscriptionButton.layer.add(fadeIn, forKey: nil)
        indicationLabel.layer.add(fadeIn, forKey: nil)
    }
    
    //TextFields
    func showEmailTextField(from button : UIButton) {
        if button == loginButton && !login && !emailShow {
            loginYConstraint.constant += fifthScreen / 2
            
            indication = "Vous êtes en train de vous connecter"
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.emailTextField.alpha = 1
                self.indicationLabel.text = self.indication
            }) { (_) in
                self.emailShow  = true
                self.login      = true
            }
        } else if button == inscriptionButton && !register && !emailShow {
            loginYConstraint.constant += fifthScreen / 2
            indication = "Vous êtes en train de vous inscrire"
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.emailTextField.alpha = 1
                self.indicationLabel.text = self.indication
            }) { (_) in
                self.emailShow  = true
                self.register   = true
            }
        }
        
        
    }
    func disable(button : UIButton) {
        deselect(button: button)
        button.isSelected = true
        
        var strokeColor : UIColor!
        
        if button == loginButton {
            strokeColor = signInColor
            indication = "Vous êtes en train de vous connecter"
        } else if button == inscriptionButton {
            strokeColor = registerColor
            indication = "Vous êtes en train de vous inscrire"
        }
        
        self.indicationLabel.text = self.indication
        
        UIView.animate(withDuration: 0.5) {
            button.layer.borderWidth = 2
            button.layer.borderColor = strokeColor.cgColor
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            
            self.indicationLabel.alpha = 1
        }
    }
    func showPasswordTextField() {
        if !passwordShow {
            loginYConstraint.constant += 70
            passwordShow.toggle()
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.passwordTextField.alpha = 1
            })
        }
    }
    func shake(textField : UITextField) {
        if isEntryValid(textField: textField) { return } else {
            let jump = CASpringAnimation(keyPath: "position.y")
            jump.initialVelocity = 100.0
            jump.mass = 10.0
            jump.stiffness = 1500.0
            jump.damping = 50.0
            jump.fromValue = textField.layer.position.y + 1.0
            jump.toValue = textField.layer.position.y
            jump.duration = jump.settlingDuration
            textField.layer.add(jump, forKey: nil)
            
            let flash = CASpringAnimation(keyPath: "borderColor")
            flash.damping = 7.0
            flash.stiffness = 200.0
            flash.fromValue = UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0).cgColor
            flash.toValue = UIColor.lightGray.cgColor
            flash.duration = flash.settlingDuration
            textField.layer.add(flash, forKey: nil)

            textField.layer.cornerRadius = 10
        }
    }
    func showAuthButtons() {
        for textField in textFields {
            textField.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.5) {
            for button in self.authButtons {
                button.alpha = 1
            }
            
            self.orLabel.alpha = 1
        }
    }
    
    func selectAuth(button : UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.backgroundColor = self.authColor
            button.setTitleColor(.white, for: .normal)
        }
    }
    
    func deselectAuth(button : UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor   = .white
            button.layer.borderColor = self.authColor.cgColor
            button.layer.borderWidth = 2
        }
    }
}

//MARK: - Helper Methods
extension NewLoginVC {

    //TextField
    func isEntryValid(textField : UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        return true
    }
    
    func changeTextFieldResponder() {
        if emailTextField.isFirstResponder {
            if isEntryValid(textField: emailTextField) {
                showPasswordTextField()
                passwordTextField.becomeFirstResponder()
                loginButton.setTitle("Connexion", for: .normal)
            } else {
                shake(textField: emailTextField)
            }
        } else if passwordTextField.isFirstResponder {
            if isEntryValid(textField: passwordTextField) {
                passwordTextField.resignFirstResponder()
            } else {
                shake(textField: passwordTextField)
            }
        }
    }
    
    //Buttons
    
    func deselect(button : UIButton) {
        var buttonToDeselect : UIButton!
        buttonToDeselect = button == loginButton ? inscriptionButton : loginButton
        
        var color : UIColor!
        color = buttonToDeselect == loginButton ? signInColor : registerColor
        if buttonToDeselect == loginButton {
            color = signInColor
        } else if buttonToDeselect == inscriptionButton {
            color = registerColor
        } else if buttonToDeselect == followerButton || buttonToDeselect == runnerButton {
            color = authColor
        }
        
        UIView.animate(withDuration: 0.5) {
            buttonToDeselect.backgroundColor = color
            buttonToDeselect.setTitleColor(.white, for: .normal)
        }
    }
    
    //HUD :
    
    func showHUD() {
        connexionHUD.textLabel.text = "Connexion"
        connexionHUD.show(in: self.view)
    }
    
    func showSuccessHud() {
        connexionHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
        connexionHUD.textLabel.text = "Réussi"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismissHud()
        }
    }
    
    func showErrorHud(error : String) {
        connexionHUD.indicatorView = JGProgressHUDErrorIndicatorView()
        connexionHUD.textLabel.text = "Erreur : \(error)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismissHud()
        }
    }
    
    func dismissHud() {
        connexionHUD.dismiss()
    }
    
    //Navigation
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

//MARK: - UITextFieldDelegate
extension NewLoginVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeTextFieldResponder()
        guard isEntryValid(textField: emailTextField) else { return false }
        showPasswordTextField()
        
        guard isEntryValid(textField: passwordTextField) else { return false }
        //TODO : Login
        showAuthButtons()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        shake(textField: textField)
    }
}
