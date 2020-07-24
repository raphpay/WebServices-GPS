//
//  ViewController.swift
//  ConnexionScreen
//
//  Created by Raphaël Payet on 02/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import WebKit
import FirebaseFirestore
import FirebaseAuth
import TinyConstraints

class FirstVC: UIViewController {
    
    //MARK: Constants
    enum WebSites {
        static let google       = "https://www.google.fr"
        static let apple        = "https://www.apple.fr"
        static let webServices  = "https://inscriptions.webservices.re/"
        static let WSEvents     = "https://inscriptions.webservices.re/index.php/events"
    }

    //MARK: - Objects
    var appName                 = UILabel()
    var createRunnerButton      : RSButton!
    var createFollowerButton    : RSButton!
    var signInButton            : RSButton!
    var conditionsButton        : UIButton!
    var backgroundImage         = UIImageView()

    //MARK: - Properties
    let padding             : CGFloat = 10
    let buttonHeight        : CGFloat = 44
    
    let runnerCollection = Firestore.firestore().collection("Runner")
    let followerCollection = Firestore.firestore().collection("Follower")
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        listenForLoggedInUser()
    }
}

//MARK: - User Interface
extension FirstVC {
    
    fileprivate func setupUI() {
        setupBackgroundImage()
        configureButtons()
        configureAppName()
    }
    fileprivate func configureAppName() {
        view.addSubview(appName)
        appName.topToSuperview(view.safeAreaLayoutGuide.topAnchor, offset: 50)
        appName.leftToSuperview()
        appName.rightToSuperview()
        appName.height(50)
        
        appName.font            = .preferredFont(forTextStyle: .largeTitle)
        appName.textAlignment   = .center
        appName.text            = "Web Services GPS"
        appName.textColor       = .white
    }
    fileprivate func configureButtons() {
        createRunnerButton      = RSButton(backgroundColor: .systemOrange, title: "Inscription pour Coureur")
        createFollowerButton    = RSButton(backgroundColor: .systemPink, title: "Créer un compte pour Follower")
        signInButton            = RSButton(backgroundColor: .systemBlue, title: "Connexion")
        conditionsButton        = UIButton(type: .system)
        
        view.addSubview(createRunnerButton)
        view.addSubview(createFollowerButton)
        view.addSubview(signInButton)
        view.addSubview(conditionsButton)
        
        conditionsButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            conditionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            conditionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            conditionsButton.widthAnchor.constraint(equalToConstant: 200),
            conditionsButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            signInButton.bottomAnchor.constraint(equalTo: conditionsButton.topAnchor, constant: -padding),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            signInButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            createFollowerButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -padding),
            createFollowerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            createFollowerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            createFollowerButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            createRunnerButton.bottomAnchor.constraint(equalTo: createFollowerButton.topAnchor, constant: -padding),
            createRunnerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            createRunnerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            createRunnerButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        
        
        conditionsButton.setTitle("Conditions", for: .normal)
        conditionsButton.setTitleColor(.systemBlue, for: .normal)
        
        createRunnerButton.addTarget(self, action: #selector(goToServer(_:)), for: .touchUpInside)
        createFollowerButton.addTarget(self, action: #selector(followerTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(connectionTapped(_:)), for: .touchUpInside)
        conditionsButton.addTarget(self, action: #selector(conditionsTapped(_:)), for: .touchUpInside)
        //Pour le moment
        conditionsButton.isHidden = true
    }
    fileprivate func setupBackgroundImage() {
        view.addSubview(backgroundImage)
        backgroundImage.edgesToSuperview()
        backgroundImage.image = UIImage(named: AssetsImages.backRunner)
        
    }

}


//MARK: - Actions
extension FirstVC {
    @objc func goToServer(_ sender : RSButton) {
        openWebPage(website: WebSites.WSEvents)
    }
    
    @objc func followerTapped() {
        let registrationVC = InscriptionVC()
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    @objc func connectionTapped(_ sender : RSButton) {
        let logInVC = LoginVC()
        navigationController?.pushViewController(logInVC, animated: true)
    }
    @objc func conditionsTapped(_ sender : UIButton) {
        //Site a changer en fonction de l'url des conditions
        openWebPage(website: WebSites.apple)
    }
}


//MARK: - Web Controller
extension FirstVC {
    fileprivate func openWebPage(website : String) {
        let webVC = WebVC()
        webVC.website = website
        navigationController?.pushViewController(webVC, animated: true)
    }
}


//MARK: - Firebase

extension FirstVC {
    fileprivate func listenForLoggedInUser() {
        Auth.auth().addStateDidChangeListener { (auth, _user) in
            guard _user != nil else { return }
            if let userEmail = _user!.email {
                self.checkFollowerAccount(email: userEmail)
                self.checkRunnerAccount(email: userEmail)
                self.checkServerAccount(email: userEmail)
            }
        }
    }
    
    fileprivate func checkFollowerAccount(email : String) {
        followerCollection.getDocuments(source: .default) { (_snapshot, _error) in
            guard _error == nil else {
                print(_error!.localizedDescription)
                return }
            
            guard let snapshot = _snapshot else {
                print("no snapshot")
                return }
            
            for document in snapshot.documents {
                let data = document.data()
                if let currentEmail = data["email"] as? String,
                    currentEmail == email{
                    self.showFollowerTabBar()
                }
            }
        }
    }
    
    fileprivate func checkRunnerAccount(email : String) {
        runnerCollection.getDocuments(source: .default) { (_snapshot, _error) in
            guard _error == nil else {
                print(_error!.localizedDescription)
                return }
            
            guard let snapshot = _snapshot else {
                print("no snapshot")
                return }
            
            for document in snapshot.documents {
                let data = document.data()
                if let userEmail = data["email"] as? String,
                userEmail == email{
                    self.showRunnerScreen()
                }
            }
        }
    }
    
    fileprivate func checkServerAccount(email : String) {
        if email == "server@test.com" {
            self.showServerTabBar()
        }
    }
}


//MARK: - Navigation

extension FirstVC {
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
        let navC1 = UINavigationController(rootViewController : raceVC)
        navC1.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: SFSymbols.home), tag : 1)
        
        let profileVC = RunnerProfileVC()
        let navC2 = UINavigationController(rootViewController : profileVC)
        navC2.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: SFSymbols.person), tag : 0)
    
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [navC1, navC2]
        tabBar.modalPresentationStyle = .overFullScreen
        self.present(tabBar, animated : true)
    }
}
