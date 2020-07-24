//
//  RunnerProfileVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 17/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD

class RunnerProfileVC: UIViewController {
    
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
    
    var window: UIWindow?
    
    //MARK: - Properties
    
    let runnerCollection = Firestore.firestore().collection("Runner")
    let runnerReference  = Database.database().reference().child("runners")
    let eventReference   = Database.database().reference().child("events")
    
    var listActions = [
        "S'inscrire à une nouvelle course",
        "Changer le mot de passe",
        "Se déconnecter"
    ]
    
    var races = [Race]()
    var raceNames = [String]()
    var name  = Name()
    
    
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
        title = "Profil"
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        getRaces()
    }
}


//MARK: User Interface
extension RunnerProfileVC {
    func setupUI() {
        view.backgroundColor = .white
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
                    groupWidth  = NSCollectionLayoutDimension.fractionalWidth(1)
                    groupHeight = NSCollectionLayoutDimension.estimated(40)
                    columnCount = 1
                
                case 2  :
                    groupWidth  = NSCollectionLayoutDimension.fractionalWidth(1)
                    groupHeight = NSCollectionLayoutDimension.estimated(150)
                    columnCount = 1
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
        collectionView.register(HorizontalNewRaceCell.self, forCellWithReuseIdentifier: HorizontalNewRaceCell.reuseID)
        collectionView.register(Header.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Header.reuseID)
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }

}



//MARK: Actions

extension RunnerProfileVC {
    @objc func seeAllTapped() {
        let allRaces = AllRacesListVC()
        allRaces.races = self.races
        self.present(allRaces, animated: true)
    }
}




//MARK: - CollectionView Delegate & DataSource

extension RunnerProfileVC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0  : return 1
        case 1  : return listActions.count
        case 2  : return races.count
        default : return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 2 :
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseID, for: indexPath) as? Header else { fatalError("Unable to dequeue header")}
            header.backgroundColor = .systemBackground
            header.title.text = "Courses prévues"
            header.seeButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
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
            cell.configure(name: self.name)
            return cell
            
        case 1 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { fatalError("Unable to dequeue List cell")}
            cell.configure(with: listActions[indexPath.item])
            return cell
            
        case 2 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalNewRaceCell.reuseID, for: indexPath) as? HorizontalNewRaceCell else { fatalError("Unable to dequeue race cell")}
            cell.configure(with: races[indexPath.row])
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
            case 0 :
                openWebPage(website: "https://inscriptions.webservices.re/")
            case 1 :
                showUpdatePasswordAlert(title: "Mot de passe", message: "Changer le mot de passe")
            case 2:
                showLogOutAlert()
            default:
                break
            }
        } else if indexPath.section == 2 {
            let specificRace = SpecificRaceVC()
            specificRace.raceName = races[indexPath.row].name
            specificRace.racePlace = races[indexPath.row] .place
            navigationController?.pushViewController(specificRace, animated: true)
        }
    }
    
}

//MARK: - Firebase Account Managing
extension RunnerProfileVC {
    func updatePassword(email : String, completion : @escaping (_ error :  String?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (_error) in
            guard _error == nil else { return }
        }
    }
    
    
    fileprivate func updatePassword(user : User ,email : String, previousPassword : String, newPassword : String, completion : @escaping (_ error :  String?) -> ()) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: previousPassword)
        user.reauthenticate(with: credential) { (_result, _error) in
            guard _error == nil else {
                //Le mot de passe saisi n'est pas le bon, ou autre.
                completion(_error!.localizedDescription)
                return
            }
            
            user.updatePassword(to: newPassword) { (_error) in
                guard _error == nil else {
                    completion(_error!.localizedDescription)
                    return
                }
                
                completion(nil)
            }
        }
        
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            self.showFirstVC()
        } catch let logOutError as NSError {
            self.showSimpleAlert(title: "Erreur", message: "Il y a eu une erreur lors de la déconnexion")
            print("error signing in : \(logOutError.localizedDescription)")
            return
        }
    }
    func deleteAccount(for user : User, password : String) {
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
}


//MARK: - Firebase

extension RunnerProfileVC {

    fileprivate func getUserName() {
        if let user = Auth.auth().currentUser {
            runnerCollection.document(user.uid).getDocument { (_snapshot, _error) in
                guard _error == nil else {
                    print("error getting data : \(_error!.localizedDescription)")
                    self.hud.dismiss()
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
        }
    }
    
    fileprivate func getRacesName(completion : @escaping (_ raceNames : [String]) -> ()) {
        self.raceNames.removeAll()
        if let user = Auth.auth().currentUser {
            let currentRunnerRef = runnerReference.child(user.uid)
            currentRunnerRef.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    if let childSnap = child as? DataSnapshot,
                        let infos = childSnap.value as? [String : Any],
                        let race = infos["race"] as? String {
                        self.raceNames.append(race)
                    }
                }
                completion(self.raceNames)
            }
        }
    }
    
    fileprivate func getRaces() {
        self.races.removeAll()
        getRacesName { (names) in
            self.eventReference.observeSingleEvent(of : .value) { (snapshot) in
                for child in snapshot.children {
                    if let childSnap = child as? DataSnapshot,
                        let infos = childSnap.value as? [String : Any],
                    let name = infos["name"] as? String,
                    let place = infos["place"] as? String,
                    let raceType = infos["type"] as? String {
                        for raceName in self.raceNames {
                            if raceName == name {
                                let race = Race(name: name, place : place, type : raceType)
                                self.races.append(race)
                            }
                        }
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    

}



//MARK: - Alert Controllers

extension RunnerProfileVC {
    
    func showUpdatePasswordAlert(title : String , message : String) {
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
    func showLogOutAlert() {
        let alert = UIAlertController(title: AlertTitle.logOut, message: "Etes-vous sûr de vouloir vous déconnecter ?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirmer", style: .default, handler: { (_) in
            self.logOut()
        })
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    func showForgottenPasswordAlert() {
        
    }
    func showSimpleAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    func sendToHomeScreen(title : String, message : String) {
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



//MARK: Navigation

extension RunnerProfileVC {
    fileprivate func showFirstVC() {
        let navC = UINavigationController(rootViewController: NewLoginVC())
        navC.modalPresentationStyle = .fullScreen
        
        self.present(navC, animated: true)
    }
    
    fileprivate func openWebPage(website : String) {
        let webVC = WebVC()
        webVC.website = website
        navigationController?.pushViewController(webVC, animated: true)
    }
}
