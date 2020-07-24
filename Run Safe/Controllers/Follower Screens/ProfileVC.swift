//
//  ProfileVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 06/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD

class ProfileVC: UIViewController {
    
    //MARK: - Enumerations
    enum AlertTitle {
        static let password = "Mot de Passe"
        static let error    = "Erreur"
        static let success  = "Tout est bon"
        static let logOut   = "Déconnexion"
    }
    enum AlertButtonTitle {
        static let confirm  = "Confirmer"
        static let cancel   = "Annuler"
    }
    enum SectionKind : Int, CaseIterable {
        case profile, settings, runners
        
        var place : Int {
            switch self {
            case .profile   : return 0
            case .settings  : return 1
            case .runners   : return 2
            }
        }
    }
    
    //MARK: - Objects
    var collectionView  : UICollectionView! = nil
    
    let hud = JGProgressHUD(style: .dark)
    
    var favoriteRunners = [Runner]()
    var favoriteUIDs    = [String]()
    
    var reviewService = ReviewService.shared
    
    //MARK: - Properties
    
    var listActions = [
        "Changer le mot de passe",
        "Se déconnecter"
    ]
    
    var runners = [Runner]()
    var name = Name()
    
    let followerCollection  = Firestore.firestore().collection("Follower")
    let runnerCollection    = Firestore.firestore().collection("Runner")
    let followerRef         = Database.database().reference().child("followers")
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hud.textLabel.text = "Chargement"
        hud.show(in: self.view)
        getUserName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profil"
        getFavoriteRunners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.reviewService.requestReview()
        }
    }
}

//MARK: - User Interface
extension ProfileVC {
    fileprivate func setupUI() {
        view.backgroundColor = .systemBackground
        configureCollectionView()
    }
    fileprivate func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex : Int, layoutEnvironment : NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { return nil }
            let place       = sectionKind.place
            
            //La taille de l'item sera toujours la même
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            //La taille du groupe, ainsi que le nombre de colonne varie en fonction de sa place
            var groupWidth      : NSCollectionLayoutDimension!
            var groupHeight     : NSCollectionLayoutDimension!
            var columnCount     = Int()
            switch place {
                case 0  :
                    groupWidth  = NSCollectionLayoutDimension.fractionalWidth(0.93)
                    groupHeight = NSCollectionLayoutDimension.estimated(100)
                    columnCount = 1
                
                case 1  :
                    groupWidth  = NSCollectionLayoutDimension.fractionalWidth(0.93)
                    groupHeight = NSCollectionLayoutDimension.estimated(40)
                    columnCount = 1
                
                case 2  :
                    groupWidth  = NSCollectionLayoutDimension.fractionalWidth(1)
                    groupHeight = NSCollectionLayoutDimension.estimated(100)
                    columnCount = 2
                default : groupHeight = NSCollectionLayoutDimension.estimated(0)
            }
            
            let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth,
                                                  heightDimension: groupHeight)
            let group   = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
            let spacing = CGFloat(10)
            group.interItemSpacing = .fixed(spacing)

            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            
            let padding = CGFloat(10)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
            
            //Les réglages de la section va dépendre de sa place
            switch place {
            case 2 :
                let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
                let layoutSectionHeader     = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [layoutSectionHeader]
                layoutSectionHeader.pinToVisibleBounds = true
                
            default : break
            }
            
            return section
        }
        
        return layout
    }
    fileprivate func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.reuseID)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        collectionView.register(RunnerCell.self, forCellWithReuseIdentifier: RunnerCell.reuseID)
        collectionView.register(Header.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Header.reuseID)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
}

//MARK: Actions

extension ProfileVC {
    @objc func seeAllRunners() {
        if !runners.isEmpty {
            let allRunnerList = AllRunnerListVC()
            allRunnerList.runners = self.runners
            let navC = UINavigationController(rootViewController: allRunnerList)
            self.present(navC, animated: true)
        } else {
            let alert = UIAlertController(title: "Oups !", message: "Vous n'avez pas suivi de coureurs, allez vite les chercher dans l'écran d'à côté !", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}


//MARK: - CollectionView Delegate & DataSource

extension ProfileVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0  : return 1
        case 1  : return listActions.count
        case 2  : return runners.count
        default : return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 2 :
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseID, for: indexPath) as? Header else { fatalError("Unable to dequeue header")}
            header.backgroundColor = .systemBackground
            header.title.text = "Personnes suivies"
            header.seeButton.addTarget(self, action: #selector(seeAllRunners), for: .touchUpInside)
            header.separator.alpha = 0
            return header
            
        default:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.reuseID, for: indexPath) as? ProfileCell else { fatalError("Unable to dequeue profile cell")}
            cell.configure(name: name)
            return cell
            
        case 1 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { fatalError("Unable to dequeue List cell")}
            cell.configure(with: listActions[indexPath.item])
            return cell
            
        case 2 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunnerCell.reuseID, for: indexPath) as? RunnerCell else { fatalError("Unable to dequeue runner cell")}
            cell.configure(runner: runners[indexPath.row])
            return cell
            
        default :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "cell", for: indexPath)
            cell.backgroundColor = .green
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 1 {
            switch indexPath.item {
            case 0: showUpdatePasswordAlert()
            case 1: showLogOutAlert()
            default:
                break
            }
        } else if indexPath.section == 2 {
            self.presentRunner(runner: runners[indexPath.item], place: 0)
        }
    }
    
}


//MARK: - Alert Controllers

extension ProfileVC {
    
    func showUpdatePasswordAlert() {
        let alert = UIAlertController(title: "Changer de mot de passe", message: "Veuillez entre votre email pour changer de mot de passe.", preferredStyle: .alert)
        
        alert.addTextField { (emailTextField) in
            
        }
        
        alert.addAction(UIAlertAction(title: "Envoyer", style: .default, handler: { (_) in
            guard let email = alert.textFields?.first?.text,
                !email.isEmpty else { return }
            self.updatePassword(email: email) { (_) in
                let alert = UIAlertController(title: "Email envoyé", message: "Veuillez suivre les instructions pour changer de mot de passe.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok !", style: .default))
                self.present(alert, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        
        self.present(alert, animated: true)
    }
    fileprivate func showLogOutAlert() {
        let alert = UIAlertController(title: AlertTitle.logOut, message: "Etes-vous sûr de vouloir vous déconnecter ?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirmer", style: .default, handler: { (_) in
            self.logOut()
        })
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    fileprivate func showEraseAccountAlert() {
        //Il nous vaut une double approbation de l'utilisateur pour éviter les erreurs.
        //On demande alors si il est bien sûr de vouloir effacer son compte avant de le faire
        
        //Première alerte
        let alert = UIAlertController(title: "Effacer le compte", message: "Etes-vous sur de vouloir effacer votre compte ?", preferredStyle: .alert)
        
        //Premières actions
        let cancelAction = UIAlertAction(title: "Non", style: .cancel)
        let confirmAction = UIAlertAction(title: "Oui", style: .default, handler: { (_) in
            //Seconde alerte
            let sureAlert = UIAlertController(title: "Effacer le compte", message: "Attention cette opération est définitive !\nNous avons besoin de votre mot de passe pour vous authentifier.", preferredStyle: .alert)
            
            //Secondes Actions
            sureAlert.addTextField { (currentPasswordField) in
                currentPasswordField.isSecureTextEntry = true
                currentPasswordField.placeholder = "Mot de passe"
            }
            let sureCancelAction = UIAlertAction(title: "Non", style: .cancel)
            let sureConfirmAction = UIAlertAction(title: "Confirmer", style: .default) { (_) in
                guard let passwordField = alert.textFields?.first,
                    passwordField.text != "",
                    let password = passwordField.text else  {
                        self.present(sureAlert, animated: true)
                        return
                }
                
                if let user = Auth.auth().currentUser {
                    self.deleteAccount(for: user, password: password)
                } else {
                    print("no user")
                }
            }
            
            
            sureAlert.addAction(sureConfirmAction)
            sureAlert.addAction(sureCancelAction)
            self.present(sureAlert, animated: true)
        })
        
        
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
        
    }
    fileprivate func showForgottenPasswordAlert() {
        showSimpleAlert(title: "Email envoyé", message: "Nous vous avons envoyé un mail. Vous allez pouvoir changer le mot de passe.")
        
        
    }
    fileprivate func showSimpleAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    fileprivate func sendToHomeScreen(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.logOut()
            let navC = UINavigationController(rootViewController: FirstVC())
            navC.modalPresentationStyle = .overFullScreen
            self.present(navC, animated: true)
        }))
        self.present(alert, animated: true)
        
    }
}


//MARK: - Firebase

extension ProfileVC {
    func updatePassword(email : String, completion : @escaping (_ error :  String?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (_error) in
            guard _error == nil else { return }
        }
    }

    fileprivate func sendNewPassword() {
        
    }
    fileprivate func logOut() {
        do {
            try Auth.auth().signOut()
            self.showFirstVC()
        } catch let logOutError as NSError {
            self.showSimpleAlert(title: "Erreur", message: "Il y a eu une erreur lors de la déconnexion")
            print("error signing in : \(logOutError.localizedDescription)")
            return
        }
    }
    fileprivate func deleteAccount(for user : User, password : String) {
        if let userEmail  = user.email{
            let credential = EmailAuthProvider.credential(withEmail: userEmail, password: password)
            
            user.reauthenticate(with: credential) { (_result, _error) in
                guard _error == nil else {
                    //User doesn't re authenticate
                    print(_error!.localizedDescription)
                    return
                }
                
                user.delete { (_error) in
                    guard _error == nil else {
                        print(_error!.localizedDescription)
                        return
                    }
                    //Account deleted, show alert, then the first VC
                    self.showSimpleAlert(title: "Votre compte a bien été supprimé", message: "Revenez vite nous voir 😉")
                    let navC = UINavigationController(rootViewController: FirstVC())
                    self.present(navC, animated: true)
                }
            }
        } else {
            print("couldn't get user email")
        }
    }
    fileprivate func showFirstVC() {
        let navC = UINavigationController(rootViewController: NewLoginVC())
        navC.modalPresentationStyle = .fullScreen
        self.present(navC, animated: true)
    }
    fileprivate func getUserName() {
        if let user = Auth.auth().currentUser {
            followerCollection.document(user.uid).getDocument { (_snapshot, _error) in
                guard _error == nil else {
                    print("error getting data : \(_error!.localizedDescription)")
                    return
                }
                
                guard let document = _snapshot else { return }
            
                if let data = document.data(),
                    let firstName = data["firstName"] as? String,
                    let lastName = data["lastName"] as? String {
                    let name = Name()
                    name.firstName = firstName
                    name.lastName = lastName
                    self.name = name
                    self.hud.dismiss()
                    self.collectionView.reloadData()
                }
            }
        } else {
            self.hud.dismiss()
//            let alert = UIAlertController(title: AlertTitle.error, message: "Veuillez vous reconnecter", preferredStyle: .alert)
//            let yesAction = UIAlertAction(title: AlertButtonTitle.confirm, style: .default) { (action) in
//
//                let navC = UINavigationController(rootViewController: FirstVC())
//                navC.modalPresentationStyle = .fullScreen
//                self.present(navC, animated: true, completion: nil)
//            }
//
//            alert.addAction(yesAction)
//
//            self.present(alert, animated: true, completion: nil)
        }
    }
    fileprivate func getFavoritesRunnersUID(completion : @escaping (_ favoriteRunners : [String]) -> ()) {
        self.favoriteUIDs.removeAll()
        if let user = Auth.auth().currentUser {            
            let currentUserRef = followerRef.child(user.uid)
            currentUserRef.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    if let childSnap = child as? DataSnapshot,
                        let favorites = childSnap.value as? [String : Any],
                        let runnerUID = favorites["runnerUID"] as? String {
                        
                        self.favoriteUIDs.append(runnerUID)
                    }
                }
                completion(self.favoriteUIDs)
            }
        }
    }
    
    fileprivate func getFavoriteRunners() {
        self.runners.removeAll()
        getFavoritesRunnersUID { (favoritesUID) in
            self.runnerCollection.getDocuments(source: .default) { (_snapshot, _error) in
                guard _error == nil else { return }
                guard let snapshot = _snapshot else { return }
                
                for document in snapshot.documents {
                    let data = document.data()
                    for runnerUID in favoritesUID {
                        if let uid = data["uid"] as? String,
                            uid == runnerUID ,
                            let firstName = data["firstName"] as? String,
                            let lastName = data["lastName"] as? String,
                            let runnerUID = data["uid"] as? String {
                            let runner = Runner()
                            runner.firstName = firstName
                            runner.lastName = lastName
                            runner.uid = runnerUID
                            self.runners.append(runner)
                        }
                    }
                }
            
                self.collectionView.reloadData()
                
            }
        }
    }
}
