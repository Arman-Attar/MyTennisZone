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
    @Published var isFriend = false
    @Published var searchedUser: User?
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
    
    func findUser(username: String) async {
        do {
            let user = try await UserDatabaseManager.shared.fetchSearchedUser(username: username)
            if let user = user {
                let isFriend = await checkIfFriend(userID: user.uid)
                await MainActor.run(body: {
                    self.searchedUser = user
                    self.isFriend = isFriend
                })
            } else {
                await MainActor.run(body: {
                    self.searchedUser = nil
                })
            }
        } catch {
            print(error)
            await MainActor.run(body: {
                self.searchedUser = nil
            })
        }
    }
    
    func checkIfFriend(userID: String) async -> Bool {
        guard let user = self.user else { return false }
        return user.friends.contains(where: {$0 == userID})
    }
    
    func addFriend(friendID: String) async {
        guard let user = self.user, let friend = self.searchedUser else { return }
        do {
            try await UserDatabaseManager.shared.addFriend(friendID: friend.uid, CurrentUserID: user.uid)
            await MainActor.run(body: {
                self.isFriend = true
            })
        } catch {
            print(error)
        }
    }
    
    func signOut() {
        do{
            try FirebaseManager.shared.auth.signOut()
            self.isUserSignedOut.toggle()
        }catch{
            print(error)
        }
        
    }
    
    func deleteUserData(userID: String) async throws {
        do {
            try await UserDatabaseManager.shared.deleteUserData(userID: userID)
        } catch {
            throw error
        }
    }
    
    func deleteUser() async {
        if let user = FirebaseManager.shared.auth.currentUser {
            do {
                try await deleteUserData(userID: user.uid)
                try await user.delete()
                await MainActor.run(body: {
                    self.isUserSignedOut.toggle()
                })
            } catch {
                print(error)
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
