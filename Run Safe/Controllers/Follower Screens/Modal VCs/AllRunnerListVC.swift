//
//  AllRunnerListVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 07/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class AllRunnerListVC: UIViewController {

    var collectionView : UICollectionView! = nil
    
    var runners = [Runner]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Résultats"
    }
}

extension AllRunnerListVC {
    fileprivate func setupUI() {
        configureColView()
        view.addSubview(collectionView)
    }
    
    fileprivate func createLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            let spacing = CGFloat(10)
            group.interItemSpacing = .fixed(spacing)

            let padding = CGFloat(10)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: padding, trailing: padding)

            let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(80))
            let layoutSectionHeader     = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                                      elementKind: UICollectionView.elementKindSectionHeader,
                                                                                      alignment: .top)
            section.boundarySupplementaryItems = [layoutSectionHeader]
    //        section.orthogonalScrollingBehavior = .groupPagingCentered
        
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
        }
        fileprivate func configureColView() {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
            collectionView.delegate         = self
            collectionView.dataSource       = self
            
            collectionView.autoresizingMask = .flexibleHeight
            collectionView.backgroundColor  = .systemBackground
            
            collectionView.register(RunnerCell.self, forCellWithReuseIdentifier: RunnerCell.reuseID)
            
        }
}


extension AllRunnerListVC  : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunnerCell.reuseID, for: indexPath) as? RunnerCell else { fatalError("unable to dequeue runner cell")}
        cell.configure(runner: runners[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(runners[indexPath.item].lastName)
    }
    
    
}
