//
//  TestVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 02/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class TestVC: UIViewController {

    var titleLabel = UILabel()
    
    var name : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        titleLabel.text = name
    }
}
