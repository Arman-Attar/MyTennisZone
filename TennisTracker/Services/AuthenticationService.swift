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


class FirebaseManager: ObservableObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
   init(){
       DispatchQueue.main.sync {
           if !TennisTrackerApp.isAlreadyLaunched{
               FirebaseApp.configure()
               TennisTrackerApp.isAlreadyLaunched = true
           }
       }
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
    }

    func createUser(userData: [String : Any], userID: String) async throws {
        do {
            try await firestore.collection("users").document(userID).setData(userData)
        } catch {
            throw error
        }
    }
    
    func validateUsername(username: String) async -> Bool {
        return await withCheckedContinuation { continuation  in
            firestore.collection("users").whereField("username", isEqualTo: username).getDocuments { data, err in
                if err != nil {
                    continuation.resume(returning: false)
                } else if let data = data {
                    if data.isEmpty {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await auth.signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
}
