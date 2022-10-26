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

    
    func register(email: String, password: String, userName: String, completionHandler: @escaping (_ data: String) -> Void) {
        auth.createUser(withEmail: email.lowercased(), password: password) { result, err in
            if let err = err {
                completionHandler("Unable to Create User: \(err.localizedDescription)")
                return
            }
            else{
                let userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                self.createUser(email: email, userName: userName) { result in
                    if result {
                        completionHandler("done")
                    } else {
                        completionHandler("Unable to Create User")
                    }
                }
                
            }
        }
    }
    
    private func createUser(email: String, userName: String, completionHandler: @escaping (_ data: Bool) -> Void){
        guard let uid = auth.currentUser?.uid else {
            completionHandler(false)
            return
        }
        let userData = ["email" : email.lowercased(), "uid": uid, "profilePicUrl" : "", "username" : userName.lowercased(), "displayName" : userName, "matchesPlayed" : 0, "matchesWon": 0, "trophies" : 0, "friendsUid" : 0] as [String : Any]
        firestore.collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    func validateUserName(userName: String, completionHandler: @escaping (_ data: Bool) -> Void) {
        firestore.collection("users").whereField("username", isEqualTo: userName.lowercased()).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
            if snapshot!.isEmpty {
                completionHandler(true)
            }
            else{
                completionHandler(false)
            }
        }
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
