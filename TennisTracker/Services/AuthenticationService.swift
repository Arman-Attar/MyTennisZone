//
//  AuthenticationService.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-03.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage


class FirebaseManager: NSObject, ObservableObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    override init(){
        if !TennisTrackerApp.isAlreadyLaunched{
        FirebaseApp.configure()
            TennisTrackerApp.isAlreadyLaunched = true
        }
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
    
    
    //@Published var signUpStatusMessage = ""
    
    
    // UNABLE TO RETURN THE ERROR MESSAGE TO THE USER FROM HERE, FUNCTIONS ARE IN THE VIEW FOR NOW
//    func createUser(email: String, password: String){
//        auth.createUser(withEmail: email, password: password) { result, err in
//            if let err = err {
//                print(err.localizedDescription)
//                self.signUpStatusMessage = "Unable to Create User: \(err.localizedDescription)"
//                return
//            }
//            else{
//                self.signUpStatusMessage = "OK"
//            }
//        }
//    }
    
//    func logIn(email: String, password: String) {
//        auth.signIn(withEmail: email, password: password)
//    }
}
