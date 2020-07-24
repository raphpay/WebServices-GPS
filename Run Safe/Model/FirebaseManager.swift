//
//  FirebaseManager.swift
//  Run Safe
//
//  Created by Raphaël Payet on 17/07/2020.
//  Copyright © 2020 Oriapy. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class FirebaseManager {
    
    func signIn(email : String, password : String, completion : @escaping (_ success : Bool) -> ()){
        Auth.auth().signIn(withEmail: email, password: password) { (_result, _error) in
            guard _error == nil else {
                completion(false)
                return }
            guard _result != nil else {
                completion(false)
                return }
            completion(true)
        }
    }
    
    func matchingUser(for type : String, email : String, completion : @escaping (_ matchingUser : Bool) -> ()) {
        let typeDataBase = Firestore.firestore().collection(type)
        typeDataBase.getDocuments(source: .default) { (_snapshot, _error) in
            guard _error == nil else { return }
            guard let snapshot = _snapshot else { return }
            
            for document in snapshot.documents {
                let users = document.data()
                if let userEmail = users["email"] as? String,
                    email == userEmail {
                    if type == "Runner" {
                        completion(true)
                    } else if type == "Follower" {
                        completion(true)
                    } else if type == "Server" {
                        completion(true)
                    }
                }
            }
        }
    }
}

