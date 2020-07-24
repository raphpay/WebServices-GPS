
//
//  SearchVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 29/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints

class SearchVC: UIViewController {

    var nameTextField = RSTextField(placeholder: "Nom", returnKeyType: .search, keyboardType: .default)
    var lastNameTextField = RSTextField(placeholder: "Nom 2", returnKeyType: .search, keyboardType: .default)
    var anotherTextField = RSTextField(placeholder: "Test", returnKeyType: .next, keyboardType: .default)
    var searchButton  = RSButton(backgroundColor: .systemPink, title: "Rechercher")
    
    var collectionView : UICollectionView! = nil
    
    var runners = [Runner]()
    var filteredRunners1 = [Runner]()
    var filteredRunners2 = [Runner]()
    var totalRunners    = [Runner]()
    
    let padding = CGFloat(20)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let runner1 = Runner()
        runner1.firstName = "Raph"
        runner1.lastName = "Payet"
        runners.append(runner1)
        
        let runner2 = Runner()
        runner2.firstName = "Julie"
        runner2.lastName = "Payet"
        runners.append(runner2)
        
        let runner3 = Runner()
        runner3.firstName = "Julie"
        runner3.lastName = "Pacull"
        runners.append(runner3)
        
        let runner4 = Runner()
        runner4.firstName = "Pierre"
        runner4.lastName = "Truc-Muche"
        runners.append(runner4)
    
    }
}


//MARK: - User Interface
extension SearchVC {
    fileprivate func setupUI() {
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureSubviews()
        configureConstraints()
    }
    
    fileprivate func configureSubviews() {
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
    }
    
    fileprivate func createLayout() -> UICollectionViewLayout {
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
    fileprivate func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.autoresizingMask = [.flexibleHeight]
        collectionView.backgroundColor  = .systemBackground
        
        collectionView.delegate     = self
        collectionView.dataSource   = self
        
        collectionView.register(RunnerCell.self, forCellWithReuseIdentifier: RunnerCell.reuseID)
    
        view.addSubview(collectionView)
    }
    
    
    
    fileprivate func configureConstraints() {
        let subviews = [nameTextField, lastNameTextField,searchButton]
        
        for subview in subviews  {
            view.addSubview(subview)
            
            subview.leftToSuperview(view.leftAnchor, offset: padding)
            subview.rightToSuperview(view.rightAnchor, offset: -padding)
            subview.height(50)
        }
        
        view.addSubview(collectionView)
        
        nameTextField.topToSuperview(view.topAnchor, offset: 100, usingSafeArea: true)
        
        lastNameTextField.topToBottom(of: nameTextField, offset: padding)
        
        searchButton.topToBottom(of: lastNameTextField, offset: padding)
        
        collectionView.edgesToSuperview(excluding: .top)
        collectionView.topToBottom(of: searchButton, offset: padding)
    }
    
    fileprivate func addTextField() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.searchButton.transform = CGAffineTransform(translationX: 0, y: 50 + self.padding)
                self.collectionView.transform =  CGAffineTransform(translationX: 0, y: 50 + self.padding)
                
                self.view.addSubview(self.anotherTextField)
                
//                NSLayoutConstraint.activate([
//                    self.anotherTextField.topAnchor.constraint(equalTo: self.lastNameTextField.bottomAnchor, constant: self.padding),
//                    self.anotherTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.padding),
//                    self.anotherTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -self.padding),
//                    self.anotherTextField.heightAnchor.constraint(equalToConstant: 50)
//                ])
                
                self.anotherTextField.topToBottom(of: self.lastNameTextField, offset: self.padding)
                self.anotherTextField.leftToSuperview(self.view.leftAnchor, offset: self.padding)
                self.anotherTextField.rightToSuperview(self.view.rightAnchor, offset: -self.padding)
                self.anotherTextField.height(50)
                                 
                
            })
        }
    }
}


//MARK: - Actions
extension SearchVC {
    @objc func searchTapped() {
//        guard let filter = nameTextField.text, !filter.isEmpty else { return }
//        guard let filter2 = lastNameTextField.text, !filter.isEmpty else { return }
//        filteredRunners1 = runners.filter { $0.firstName.lowercased().contains(filter.lowercased())}
//        filteredRunners2 = runners.filter { $0.lastName.lowercased().contains(filter2.lowercased())}
//        totalRunners = filteredRunners2 + filteredRunners1
//        for runner in totalRunners {
//            print(runner.lastName)
//        }
        
        addTextField()
    }
}



//MARK: - Collecvtion View
extension SearchVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredRunners1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RunnerCell.reuseID, for: indexPath) as? RunnerCell else { fatalError("Unable to dequeue runner cell")}
        cell.backgroundColor = .red
        return cell
    }
    
    
}
