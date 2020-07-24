//
//  PageManager.swift
//  Run Safe
//
//  Created by Raphaël Payet on 19/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import Foundation

class PageManager {
    
    struct Page : Hashable {
        let identifier = UUID()
        let page : Int
        let name : String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: Page, rhs: Page) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
}
