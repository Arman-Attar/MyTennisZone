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
    
    func logIn(email: String, password: String, completionHandler: @escaping (_ data: String) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                completionHandler("Unable to Log In: \(err.localizedDescription)")
            }
            else{
                completionHandler("Sign In")
            }
        }
    }
}
