//
//  TestViewController.swift
//  Run Safe
//
//  Created by Raphaël Payet on 31/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    let races = Bundle.main.decode([RaceCollection].self, from: "collection.json")
    let locations = Bundle.main.decode([Runner].self, from: "location2.json")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for location in locations {
            print(location.firstName)
        }
    }
}
