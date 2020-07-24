//
//  RunnerRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 11/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints
import FirebaseDatabase

class RunnerRaceVC: UIViewController {
    
    //MARK: - Objects
    var titleLabel : UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Savoye LET", size: 80)
        label.textAlignment = .center
        return label
    }()
    var descriptionLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "American Typewriter", size: 20)
        return label
    }()
    var collectionView : UICollectionView! = nil
    
    
    //MARK: - Properties
    let padding = CGFloat(20)
    let eventsRef = Database.database().reference().child("events")
    var races = [Race]()
    
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //TODO: Get Races from Firebase
        getRaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}


//MARK: - User Interface
extension RunnerRaceVC {
    func setupUI() {
        configureSuperView()
        configureLabels()
        configureCollectionView()
    }
    
    fileprivate func configureSuperView() {
        view.backgroundColor = .systemBackground
    }
    
    fileprivate func configureLabels() {
        let labels = [titleLabel, descriptionLabel]
        for label in labels {
            view.addSubview(label)
            label.leftToSuperview(view.leftAnchor, offset: padding)
            label.rightToSuperview(view.rightAnchor, offset: -padding)
        }
        
        titleLabel.topToSuperview(view.topAnchor, offset: padding)
        titleLabel.height(150)
        titleLabel.text = "Run Safe"
        
        descriptionLabel.topToBottom(of: titleLabel, offset: padding)
        descriptionLabel.height(100)
        descriptionLabel.text = "Explorer les courses disponibles avec notre service et partez courir en toute sécurité."
    }
    
    fileprivate func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem : item, count: 1)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 40
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    fileprivate func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        view.addSubview(collectionView)
        
        collectionView.autoresizingMask = .flexibleWidth
        collectionView.backgroundColor  = .systemBackground
        collectionView.delegate         = self
        collectionView.dataSource       = self
        
        collectionView.register(NewRaceCell.self, forCellWithReuseIdentifier: NewRaceCell.reuseID)
        
        collectionView.bottomToSuperview(view.safeAreaLayoutGuide.bottomAnchor, offset: -padding)
        collectionView.leftToSuperview()
        collectionView.rightToSuperview()
        collectionView.topToBottom(of: descriptionLabel, offset: padding)
    }
}



//MARK: - CollectionView Delegate & DataSource
extension RunnerRaceVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return races.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewRaceCell.reuseID, for: indexPath) as? NewRaceCell else { fatalError("Unable to dequeue race cell")}
        
        cell.configure(race: races[indexPath.row])
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let specificRace = BigRaceVC()
        specificRace.race = races[indexPath.item]
        let navC = UINavigationController(rootViewController: specificRace)
        navC.modalPresentationStyle = .overFullScreen
        navC.modalTransitionStyle = .crossDissolve
        self.show(navC, sender: nil)
    }
}



//MARK: - Firebase

extension RunnerRaceVC {
    fileprivate func getRaces() {
        eventsRef.observeSingleEvent(of : .value) { (snapshot) in
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                    let infos = childSnap.value as? [String : Any],
                    let name = infos["name"] as? String,
                    let place = infos["place"] as? String ,
                let description = infos["description"] as? String,
                let distance = infos["distance"] as? Double,
                    let type = infos["type"] as? String {
                    let race = Race(name: name, place: place, distance: distance, description: description, type: type)
                    self.races.append(race)
                } else { print("else")}
            }
            
            self.collectionView.reloadData()
        }
    }
}

