//
//  Enumerations.swift
//  Run Safe
//
//  Created by Raphaël Payet on 18/03/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import Foundation

enum AssetsImages {
    static let sunsetRunner     = "background Imagerunner.sunset"
    static let cormoranFalls    = "cormoran-casscade"
    static let mapPin           = "Running Map Pin"
    static let backRunner       = "back-runner"
    static let foot             = "foot"
    static let frontRunner      = "front-runner"
    static let logo             = "wide-logo"
    static let runFlag          = "runFlag"
}

enum SFSymbols {
    static let list         = "list.bullet"
    static let map          = "map"
    static let mapFill      = "map.fill"
    static let person       = "person"
    static let twoPerson    = "person.2"
    static let personCircle = "person.circle.fill"
    static let star         = "star"
    static let starFill     = "star.fill"
    static let chevron      = "chevron.right"
    static let eye          = "eye"
    static let eyeSlash     = "eye.slash"
    static let plus         = "plus"
    static let arrowUp      = "arrow.up.to.line.alt"
    static let arrowDown    = "arrow.down.to.line.alt"
    static let search       = "magnifyingglass"
    static let registration = "rectangle.and.paperclip"
    static let home         = "house"
}

enum Icons {
    static let menu     = "menuIcon"
    static let runner   = "Runner Button"
    static let running  = "running"
    static let flag     = "checkered-flag"
}

enum ButtonIcons {
    static let flag     = "Finish"
    static let play     = "Play"
    static let stop     = "Stop"
    static let mapPin   = "MapPin"
    static let back     = "BackButton"
}

enum ParserType {
    static let strava       = "trkpt"
    static let viewRanger   = "rtept"
}

enum LottieNames {
    static let bike1 = "best-bike-guide-bicycle"
    static let bike2 = "biking-animation"
    static let rideGreen = "ride-green-back"
    static let bike3 = "roll-it-bicycle"
    static let run = "character-run-cycle"
}

//MARK: - Enumerations
enum UserType {
    case Runner, Follower, Server
}

enum CustomError {
    static let emptyFields      = "Veuillez remplir tous les champs."
    static let mailAndPassword  = "Veuillez vérifier l'adresse mail ou le mot de passe."
    static let status           = "Veuillez vérifier votre statut."
    static let password         = "Veuillez entrer un mot de passe valide."
    static let noAccount        = "Veuillez vous inscrire"
    static let cantSignIn       = "Connexion impossible"
}
