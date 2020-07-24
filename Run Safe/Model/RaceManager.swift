//
//  RaceManager.swift
//  Fan Screen 2
//
//  Created by Raphaël Payet on 25/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import UIKit
import CoreLocation

struct RaceCollection : Codable, Hashable {
    var id      : Int
    var type    : String
    var title   : String
    var races   : [Race]
}

struct Race : Codable, Hashable {
    let identifier      = UUID()
    var name            : String
//    var date            : String
    var backgroundImage : String?
    var place           : String
    var distance        : Double?
    var description     : String?
    var type            : String?
}

