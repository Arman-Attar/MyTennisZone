//
//  userVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-12.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift



class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var friends: [Friend] = []
    @Published var userSearch: User?
    @Published var isUserSignedOut = false
    @Published var image: UIImage? = nil
    
    
    func getCurrentUser() async {
        guard let userID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let user = try await UserDatabaseManager.shared.fetchCurrentUser(userID: userID)
            await MainActor.run(body: { [weak self] in
                self?.user = user
            })
            await getUserImage(profilePicURL: user.profilePicUrl)
            await getFriends()
        } catch {
            print(error)
        }
    }
    
    private func getUserImage(profilePicURL: String) async {
        do {
            let image = try await ImageLoader.shared.getImage(urlString: profilePicURL)
            if let image = image {
                await MainActor.run(body: { [weak self] in
                    self?.image = image
                })
            }
        } catch {
            print(error)
        }
        
    }
    
    private func getFriends() async {
        guard let user = user else { return }
        do {
            let friends = try await UserDatabaseManager.shared.fetchUserFriends(friendsUID: user.friends)
            await MainActor.run(body: {
                self.friends = friends
            })
        } catch {
            print(error)
        }
    }
        
    func findUser(userName: String, completionHandler: @escaping (_ data: Bool) -> Void){
        if userSearch?.uid != ""{
            userSearch = nil
        }
        FirebaseManager.shared.firestore.collection("users").whereField("username", isEqualTo: userName).getDocuments { snapshot, err in
            if let err = err{
                print(err.localizedDescription)
                completionHandler(false)
                return
            }
            for document in snapshot!.documents{
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    self.userSearch = try JSONDecoder().decode(User.self, from: jsonData)
                } catch{
                    print(error.localizedDescription)
                    completionHandler(false)
                }
            }
            if self.userSearch != nil {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    func addUser(userUid: String, completionHandler: @escaping (_ data: Bool) -> Void){
        if userUid != "" {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
            
            FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["friends" : FieldValue.arrayUnion([userUid])])
            
            FirebaseManager.shared.firestore.collection("users").document(userUid).updateData(["friends" : FieldValue.arrayUnion([uid])])
            
            completionHandler(true)
        }
    }
    
    func friendCheck(friendUid: String, completionHandler: @escaping (_ data: Bool) -> Void){
        if user?.friends.count ?? 0 > 0 {
            if user!.friends.contains(where: {$0 == friendUid}) {
                completionHandler(true)
            }
            else {
                completionHandler(false)
            }
        }
    }
    
    func signOut(){
        do{
            try FirebaseManager.shared.auth.signOut()
            self.isUserSignedOut.toggle()
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    func deleteUserData(uid: String, completionHandler: @escaping (_ data: Bool) -> Void){
        
        FirebaseManager.shared.storage.reference(withPath: uid).delete { err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).delete { err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
        }
        FirebaseManager.shared.firestore.collection("users").getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
            guard let data = snapshot?.documents else {
                completionHandler(false)
                return
            }
            for document in data {
                FirebaseManager.shared.firestore.collection("users").document(document.documentID).updateData(["friends" : FieldValue.arrayRemove([uid])])
            }
        }
        completionHandler(true)
    }
    
    func deleteUser(){
        if let user = FirebaseManager.shared.auth.currentUser {
            deleteUserData(uid: user.uid) { result in
                if result {
                    user.delete { err in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                        else {
                            self.isUserSignedOut.toggle()
                        }
                    }
                }
            }
        }
    }
    
    func updateImage(image: UIImage?) {
        guard let uid = self.user?.uid else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.25) else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else {return}
                self.storeUserImage(imageURL: url)
            }
        }
    }
    
    private func storeUserImage(imageURL: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).updateData(["profilePicUrl" : imageURL.absoluteString]) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
        //self.getCurrentUser { _ in }
    }
    
    func updateDisplayName(input: String, completionHandler: @escaping (_ data: Bool) -> Void){
        guard let uid = self.user?.uid else {
            completionHandler(false)
            return
        }
        FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["displayName" : input]) { err in
            if let err = err{
                print(err.localizedDescription)
                completionHandler(false)
            }
//            self.getCurrentUser { _ in
//                completionHandler(true)
//            }
        }
    }
}
