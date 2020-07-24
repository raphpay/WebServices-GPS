//
//  RegisterRunnerVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 22/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import TinyConstraints
import JGProgressHUD

import UIKit

class RegisterRunnerVC: UIViewController {
    
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
    
    var races           = [Race]()
    var runners         = [Runner]()
    var selectedRace    : Race!
    
    let eventsRef           = Database.database().reference().child("events")
    let runnersCollection   = Firestore.firestore().collection("Runner")
    let runnersRef          = Database.database().reference().child("runners")
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

extension RegisterRunnerVC {
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
                    self.allAnimation()
                    self.runners = firebaseRunners
                    self.runnerColView.reloadData()
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

extension RegisterRunnerVC : UICollectionViewDelegate, UICollectionViewDataSource {
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
            self.presentInscriptionRunner(runner: runners[indexPath.row], race : selectedRace)
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

extension RegisterRunnerVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped()
        textField.resignFirstResponder()
        return true
    }
}


//MARK: - Helper Methods

extension RegisterRunnerVC {
    fileprivate func isTextFieldEmpty() -> AnimationState {
        guard let race = raceTextField.text, !race.isEmpty else { return .nothing }
        if runnerTextField.alpha == 0 { return .race }
        guard let runner = runnerTextField.text, !runner.isEmpty else { return .runner }
        return .all
    }
}


//MARK: - Firebase

extension RegisterRunnerVC {
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
}

extension RegisterRunnerVC {
    func setupUI() {
        configureTextField()
        configureRaceError()
        configureButton()
        configureRaceColView()
        configureRunnerTextField()
        configureRunnerError()
        configureRunnerColView()
    }
    //Race Field + Error Message
    fileprivate func configureTextField() {
        view.addSubview(raceTextField)
        
        raceTextField.topToSuperview(view.safeAreaLayoutGuide.topAnchor, offset: padding)
        raceTextField.leftToSuperview(view.leftAnchor, offset: padding)
        raceTextField.rightToSuperview(view.rightAnchor, offset: -padding)
        raceTextField.height(50)
        
        raceTextField.delegate = self
    }
    fileprivate func configureRaceError() {
        view.addSubview(raceError)
        
        raceError.topToBottom(of: raceTextField, offset: padding)
        raceError.centerXToSuperview()
    }
    
    //Race Collection View
    fileprivate func createRaceLayout() -> UICollectionViewLayout {
        let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
        let item        = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                               heightDimension: .estimated(100))
        let group   = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem : item, count: 1)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .continuous
        
        let padding = CGFloat(10)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: 0)
        
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
//        let header     = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//
//        section.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    fileprivate func configureRaceColView() {
        raceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createRaceLayout())
        raceCollectionView.autoresizingMask = [.flexibleWidth]
        raceCollectionView.backgroundColor = .systemBackground
        
        raceCollectionView.register(MiniRaceCell.self, forCellWithReuseIdentifier: MiniRaceCell.reuseID)
        raceCollectionView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.reuseID)
        raceCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        raceCollectionView.delegate     = self
        raceCollectionView.dataSource   = self
        
        view.addSubview(raceCollectionView)
        
        raceCollectionView.topToBottom(of: raceTextField, offset: padding)
        raceCollectionView.leftToSuperview()
        raceCollectionView.rightToSuperview()
        raceCollectionView.height(120)
        
        raceCollectionView.alpha = 0
    }
    
    //Runner TextField et Error
    fileprivate func configureRunnerTextField() {
        view.addSubview(runnerTextField)
        
        runnerTextField.topToBottom(of: raceCollectionView, offset: -padding)
        runnerTextField.leftToSuperview(view.leftAnchor, offset: padding)
        runnerTextField.rightToSuperview(view.rightAnchor, offset: -padding)
        runnerTextField.height(50)
        
        runnerTextField.alpha = 0
        
        runnerTextField.delegate = self
    }
    fileprivate func configureRunnerError() {
        view.addSubview(runnerError)
        
        runnerError.topToBottom(of: runnerTextField, offset: 50)
        runnerError.centerXToSuperview()
    }
    
    
    
    //Button
    fileprivate func configureButton() {
        view.addSubview(searchButton)
        
        searchButton.topToBottom(of: raceTextField, offset: padding)
        searchButton.leftToSuperview(view.leftAnchor, offset: padding)
        searchButton.rightToSuperview(view.rightAnchor, offset: -padding)
        searchButton.height(50)
        
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
    }
    
    //Runner Collection View
    fileprivate func createRunnerLayout() -> UICollectionViewLayout {
        let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
        let item        = NSCollectionLayoutItem(layoutSize: itemSize)
        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        let group   = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        
        let padding = CGFloat(10)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let header     = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    fileprivate func configureRunnerColView() {
        runnerColView = UICollectionView(frame: .zero, collectionViewLayout: createRunnerLayout())
        
        runnerColView.backgroundColor = .systemBackground
        runnerColView.autoresizingMask = .flexibleHeight
        
        runnerColView.delegate = self
        runnerColView.dataSource = self
        
        runnerColView.register(RunnerCell.self, forCellWithReuseIdentifier: RunnerCell.reuseID)
        runnerColView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.reuseID)
        
        view.addSubview(runnerColView)
        
        runnerColView.topToBottom(of: searchButton, offset: padding + 180)
        runnerColView.edgesToSuperview(excluding: .top)
        
        runnerColView.alpha = 0
    }
}


//MARK: - Small Animations

extension RegisterRunnerVC {
    enum ErrorMessage {
        static let noRaceEntered = "Oups ! Veuillez d'abord entrer une course."
        static let noMatchingRace = "Oups ! Cette course n'existe pas."
        static let noRunnerEntered = "Oups ! Veuillez d'abord chercher un coureur"
        static let noMatchingRunner = "Oups ! Ce coureur n'existe pas."
    }
    
    
    fileprivate func moveButtonDown(by offset: CGFloat, raceError : Bool, runnerError : Bool, text : String = "Oups !") {
        self.searchButton.transform = CGAffineTransform(translationX: 0, y: offset)
        self.raceError.alpha    = raceError ? 1     : 0
        self.raceError.isHidden = raceError ? false : true
        self.raceError.text     = raceError ? text  : ""
        
        self.runnerError.alpha  = runnerError ? 1       : 0
        self.runnerError.text   = runnerError ? text    : ""
    }
    
    fileprivate func moveButtonToOrigin() {
        self.searchButton.transform = .identity
        self.raceError.alpha = 0
    }
    
    fileprivate func showRaceColView() {
        self.raceCollectionView.alpha = 1
    }
    
    fileprivate func hideRaceColView() {
        self.raceCollectionView.alpha = 0
    }
    
    fileprivate func showRunnerTextField() {
        runnerTextField.transform = CGAffineTransform(translationX: 0, y: 40)
        runnerTextField.alpha = 1
    }
    
    fileprivate func hideRunnerTextField() {
        runnerTextField.transform = .identity
        runnerTextField.alpha = 0
    }
    
    fileprivate func hideRunnerError() {
        runnerError.alpha = 0
    }
    
    fileprivate func showRunnerColView() {
        runnerColView.alpha = 1
    }
    fileprivate func hideRunnerColView() {
        runnerColView.alpha = 0
    }
}

//MARK: - Overall Animations

extension RegisterRunnerVC {
    func nothingAnimation(error : String) {
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.moveButtonDown(by: 30, raceError: true, runnerError:  false, text : error)
            }
            if self.raceCollectionView.alpha == 1 {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                    self.hideRaceColView()
                    self.hideRunnerTextField()
                    self.hideRunnerError()
                    self.hideRunnerColView()
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    self.moveButtonToOrigin()
                }
            } else {
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    self.moveButtonToOrigin()
                }
            }
        })
    }
    func raceAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.moveButtonDown(by: 120, raceError: false, runnerError: false, text : "")
            self.showRaceColView()
        })
    }
    func runnerAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.showRunnerTextField()
            self.moveButtonDown(by: 200, raceError: false, runnerError: false, text: "")
        })
    }
    func runnerErrorAnimation(error : String) {
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.moveButtonDown(by: 230, raceError: false, runnerError: true, text: error)
            }
            if self.runnerColView.alpha == 1 {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                    self.hideRunnerColView()
                    
                }
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    self.moveButtonDown(by: 230, raceError: false, runnerError: true, text : error)
                }
            } else {
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    self.moveButtonDown(by: 200, raceError: false, runnerError: true, text : error)
                    self.hideRunnerError()
                }
            }
        })
    }
    func allAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.showRunnerColView()
        }
    }
}


