//
//  AllRacesListVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 12/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class AllRacesListVC: UIViewController {
    
    //MARK: - Objects
    var collectionView  : UICollectionView! = nil
    var emptyLabel      = UILabel()

    
    //MARK: - Properties
    var races   : [Race]!
    var type    : String!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = type
    }
}

//MARK: - User Interface

extension AllRacesListVC {
    fileprivate func setupUI() {
        view.backgroundColor = .systemBackground
        if races.isEmpty {
            configureEmptyLabel()
        } else {
            configureCollectionView()
        }
    }
    
    fileprivate func configureEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.widthAnchor.constraint(equalToConstant: 250),
            emptyLabel.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        emptyLabel.text             = "Il n'y a pas de courses dans cette catégorie 🤷🏼‍♂️"
        emptyLabel.textAlignment    = .center
        emptyLabel.numberOfLines    = 0
    }
    
    fileprivate func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93),
                                               heightDimension: .estimated(250))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let padding = CGFloat(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    fileprivate func configureCollectionView() {
        collectionView = UICollectionView(frame : view.bounds, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        collectionView.delegate         = self
        collectionView.dataSource       = self
        collectionView.autoresizingMask = .flexibleHeight
        collectionView.backgroundColor  = .systemBackground
        collectionView.register(RaceCell.self, forCellWithReuseIdentifier: RaceCell.reuseID)
    }
}


//MARK: - Collection View Delegate & DataSource

extension AllRacesListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return races.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RaceCell.reuseID, for: indexPath) as? RaceCell else { fatalError("Unable to dequeue race cell")}
        cell.configure(with: races[indexPath.row])
        return cell
    }
    
    
}
