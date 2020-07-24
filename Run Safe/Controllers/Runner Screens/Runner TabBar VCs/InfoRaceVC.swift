//
//  InfoRaceVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 17/05/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class InfoRaceVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Infos"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
