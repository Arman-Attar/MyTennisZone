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
    
    
    func getCurrentUser() async {
        guard let userID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let user = try await UserDatabaseManager.shared.fetchCurrentUser(userID: userID)
            await MainActor.run(body: { [weak self] in
                self?.user = user
            })
            await getFriends()
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
    
    func updateImage(image: UIImage?) async {
        guard let userID = self.user?.uid,
              let displayName = self.user?.displayName,
              let image = image,
              let imageData = image.jpegData(compressionQuality: 0.25) else { return }
        do {
            let imageURL = try await UserDatabaseManager.shared.storeUserImage(imageData: imageData, userID: userID)
            try await UserDatabaseManager.shared.updateUserImage(imageURL: imageURL.absoluteString, userID: userID)
            try await LeagueDatabaseManager.shared.updateProfilePicURL(playerID: userID, profilePicURL: imageURL.absoluteString, displayName: displayName)
        } catch {
            print(error)
        }
    }
    
    func updateDisplayName(username: String) async {
        guard let userID = self.user?.uid,
        let picURL = self.user?.profilePicUrl else { return }
        do {
            try await UserDatabaseManager.shared.updateDisplayName(userID: userID, username: username)
            try await LeagueDatabaseManager.shared.updateDisplayName(playerID: userID, profilePicURL: picURL, displayName: username)
        } catch {
            print(error)
        }
    }
}
