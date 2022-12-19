//
//  UserDatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-18.
//

import Foundation

class UserDatabaseManager {
    
    static let shared = UserDatabaseManager()
    private init() {}
    
    func fetchCurrentUser(userID: String) async throws -> User {
        do {
            let user = try await FirebaseManager.shared.firestore.collection("users").document(userID).getDocument(as: User.self)
            return user
        } catch  {
            throw error
        }
    }
    
    func fetchUserFriends(friendsUID: [String]) async throws -> [Friend] {
        var friends: [Friend] = []
        do {
            for friendID in friendsUID {
               let friend = try await FirebaseManager.shared.firestore.collection("users").document(friendID).getDocument(as: Friend.self)
                friends.append(friend)
            }
            return friends
        } catch {
            throw error
        }
    }
}
