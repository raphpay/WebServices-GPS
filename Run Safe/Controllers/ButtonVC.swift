//
//  ButtonVC.swift
//  Run Safe
//
//  Created by Raphaël Payet on 10/06/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import TinyConstraints

class ButtonVC: UIViewController {
    
    var blueButton = RSButton(backgroundColor: .systemBlue, title: "Bleu")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blueButton)
        
        blueButton.centerInSuperview()
        blueButton.height(44)
        blueButton.width(200)
        blueButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func buttonTapped(_ sender : UIButton) {
        sender.pulsate()
    }
}


