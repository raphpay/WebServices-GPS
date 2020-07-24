//
//  SearchRunnerVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 06/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import TinyConstraints
import JGProgressHUD

import UIKit

class SearchRunnerVC: UIViewController {
    
    //TODO: Show error message when no matching race/ runner
    
    enum AnimationState {
        case nothing, race, runner, all
    }
    
    //MARK: - Objects
    var raceTextField       = RSTextField(placeholder: "Course", returnKeyType: .search, keyboardType: .default)
    var raceError           : UILabel = {
       let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    var raceCollectionView : UICollectionView! = nil
    
    var runnerTextField     = RSTextField(placeholder: "Runner", returnKeyType: .search, keyboardType: .default)
    var runnerError : UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    var searchButton = RSButton(backgroundColor: .systemBlue, title: "Rechercher")
    
    var runnerColView : UICollectionView! = nil
    
    let hud = JGProgressHUD(style: .dark)

    //MARK: - Properties
    let padding = CGFloat(20)
    
    var isRaceEntered   = false
    var isRunnerEntered = false
    
    var state : AnimationState!
    
    var races = [Race]()
    var runners = [Runner]()
    var selectedRace : Race!
    
    let eventsRef = Database.database().reference().child("events")
    let runnersCollection = Firestore.firestore().collection("Runner")
    let runnersRef = Database.database().reference().child("runners")
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Rechercher"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

//MARK: - Actions

extension SearchRunnerVC {
    @objc func searchTapped() {
        state = isTextFieldEmpty()
        switch state {
        case .nothing   : nothingAnimation(error: ErrorMessage.noRaceEntered)
        case .race      :
            getRaces { (races) in
                if races.isEmpty {
                    self.nothingAnimation(error: ErrorMessage.noMatchingRace)
                } else {
                    self.raceAnimation()
                }
            }
        case .all       :
            getRunners { (firebaseRunners) in
                if firebaseRunners.isEmpty {
                    self.runnerErrorAnimation(error: ErrorMessage.noMatchingRunner)
                } else {
                    self.getMatchingRunners(for: self.selectedRace.name, with: firebaseRunners) { (filteredRunners) in
                        if filteredRunners.isEmpty {
                            self.runnerErrorAnimation(error: ErrorMessage.noMatchingRunner)
                        } else {
                            self.allAnimation()
                        }
                    }
                }
                
            }
            
        case .runner    : runnerErrorAnimation(error: ErrorMessage.noRunnerEntered)
        default         : nothingAnimation(error: ErrorMessage.noRaceEntered)
            
        }
    }
    
    @objc func seeAllTapped() {
        
    }
}

//MARK: - Collection View Delegate & DataSource

extension SearchRunnerVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == raceCollectionView {
            return races.count
        } else {
            return runners.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == raceCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MiniRaceCell.reuseID, for: indexPath) as? MiniRaceCell else { fatalError("Unable to dequeue mini race cell")}
            cell.configure(with: races[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunnerCell.reuseID, for: indexPath) as? RunnerCell else { fatalError("Unable to dequeue runner cell")}
            cell.configure(runner: runners[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == raceCollectionView {
            runnerAnimation()
            selectedRace = races[indexPath.item]
        } else {
            self.presentRunner(runner: runners[indexPath.item], place: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == raceCollectionView {
//            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseID, for: indexPath) as? Header else { fatalError("Unable to dequeue header")}
//            header.title.text = "Courses"
//            header.seeButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
//            header.separator.isHidden = true
//            return header
            
            return UICollectionReusableView()
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseID, for: indexPath) as? Header else { fatalError("Unable to dequeue header")}
            header.title.text = "Résultats"
            header.seeButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
            header.separator.isHidden = true
            return header
        }
    }
}

//MARK: - TextField Delegate

extension SearchRunnerVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped()
        textField.resignFirstResponder()
        return true
    }
}


//MARK: - Helper Methods

extension SearchRunnerVC {
    fileprivate func isTextFieldEmpty() -> AnimationState {
        guard let race = raceTextField.text, !race.isEmpty else { return .nothing }
        if runnerTextField.alpha == 0 { return .race }
        guard let runner = runnerTextField.text, !runner.isEmpty else { return .runner }
        return .all
    }
}


//MARK: - Firebase

extension SearchRunnerVC {
    fileprivate func getRaces(completion : @escaping (_ races : [Race]) -> ()) {
        self.races.removeAll()
        
        guard let race = raceTextField.text, !race.isEmpty else { return }
        
        eventsRef.observe(.value) { (snapshot) in
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                    let infos = childSnap.value as? [String : Any],
                    let infoName = infos["name"] as? String,
                let place = infos["place"] as? String{
                    if infoName.contains(race) {
                        let race = Race(name: infoName, backgroundImage: infoName, place: place)
                        self.races.append(race)
                    }
                }
            }
            completion(self.races)
            self.raceCollectionView.reloadData()
        }
    }
    fileprivate func getRunners(completion : @escaping (_ runners : [Runner]) -> ()) {
        hud.textLabel.text = "Chargement"
        hud.show(in: self.view)
        
        runnersCollection.getDocuments(source: .default) { (_snapshot, _error) in
            self.runners.removeAll()

            guard _error == nil else {
                print("error checking runners : \(_error!.localizedDescription)")
                return
            }
            guard let snapshot = _snapshot else {
                print("no snapshot")
                return
            }
            
            //Création du tableau de coureurs depuis Firestore
            
            var dataRunners  = [Runner]()
            var runnersNames = [Runner]()
            
            for document in snapshot.documents {
                let data = document.data()
                if let dataFirstName = data["firstName"] as? String,
                    let dataLastName = data["lastName"] as? String,
                    let dataUID = data["uid"] as? String {
                    let dataRunner = Runner()
                    dataRunner.firstName = dataFirstName
                    dataRunner.lastName = dataLastName
                    dataRunner.uid = dataUID
                    dataRunners.append(dataRunner)
                }
            }
            
            //Création des tableaux de coureurs
            
            //Vérification des champs de textes
            guard let name = self.runnerTextField.text, !name.isEmpty else {
                self.hud.dismiss()
                return }
            
            runnersNames = dataRunners.filter { $0.firstName.lowercased().contains(name.lowercased())} + dataRunners.filter { $0.lastName.lowercased().contains(name.lowercased())}
            
            completion(runnersNames)
            
            self.hud.dismiss()
        }
    }
    fileprivate func getMatchingRunners(for race : String, with runnersArray : [Runner], completion : @escaping  (_ runners : [Runner]) -> ()) {

        for runner in runnersArray {
            let currentRunnerRef = runnersRef.child(runner.uid)
            currentRunnerRef.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    if let childSnap = child as? DataSnapshot,
                        let infos = childSnap.value as? [String : Any],
                        let infoRace = infos["race"] as? String,
                        infoRace == race {
                        //We're good to go from here
                        //TODO : Afficher le coureur si match, afficher message d'erreur (4th state) sinon
                        runner.nextRace = race
                        self.runners.append(runner)
                    }
                }
                completion(self.runners)
                self.runnerColView.reloadData()
            }
        }
        
        
    }
}


