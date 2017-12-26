//
//  Firebase Service.swift
//  Channel System
//
//  Created by Warren Hansen on 12/25/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirbaseLink {
    
    func auth()-> User {
        let email = "whansen1@mac.com"
        let password = "wh123456wh"
        var thisUser:User?
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let user = user {
                print(user)
                thisUser = user
            }
        }
        return thisUser!
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func backUp() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
    }
    
}
