//
//  UserDatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-18.
//

import Foundation
import Firebase
import UIKit

actor UserDatabaseManager {
    
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
    
    func fetchSearchedUser(username: String) async throws -> Friend? {
        do {
            let snapshot = try await FirebaseManager.shared.firestore.collection("users").whereField("username", isEqualTo: username).getDocuments()
            let user = try snapshot.documents.first?.data(as: Friend.self)
            return user
        } catch {
            throw error
        }
    }
    
    func addFriend(friendID: String, CurrentUserID: String) async throws {
        do {
            // add the friend id to the current user friends
            try await FirebaseManager.shared.firestore.collection("users").document(CurrentUserID).updateData(["friends" : FieldValue.arrayUnion([friendID])])
            // add the current users id to the friendsk friend list
            try await FirebaseManager.shared.firestore.collection("users").document(friendID).updateData(["friends" : FieldValue.arrayUnion([CurrentUserID])])
        } catch {
            throw error
        }
    }
    
    func deleteUserData(userID: String) async throws {
        //delete user image if he had one
        try? await FirebaseManager.shared.storage.reference(withPath: userID).delete()
        do {
            //delete user data
            print(userID)
            let leagueDocument = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: userID).getDocuments()
            for league in leagueDocument.documents {
                print("inside league")
                let leagueData = try league.data(as: League.self)
                if let player = leagueData.players.first(where: {$0.uid == userID}) {
                    let playerData = ["uid": player.uid, "profilePicUrl": player.profilePicUrl, "displayName": player.displayName, "points": player.points, "wins": player.wins, "losses": player.losses] as [String: Any]
                    print(playerData)
                    try await FirebaseManager.shared.firestore.collection("leagues").document(league.documentID).updateData(["players" : FieldValue.arrayRemove([playerData])])
                }
                try await FirebaseManager.shared.firestore.collection("leagues").document(league.documentID).updateData(["playerId" : FieldValue.arrayRemove([userID])])
            }
            
            let tournamentDocument = try await FirebaseManager.shared.firestore.collection("tournaments").whereField("playerId", arrayContains: userID).getDocuments()
            for tournament in tournamentDocument.documents {
                let tournamentData = try tournament.data(as: Tournament.self)
                if let player = tournamentData.players.first(where: {$0.uid == userID}) {
                    let playerData = ["uid": player.uid, "profilePicUrl": player.profilePicUrl, "displayName": player.displayName, "points": player.points, "wins": player.wins, "losses": player.losses] as [String: Any]
                    try await FirebaseManager.shared.firestore.collection("tournaments").document(tournament.documentID).updateData(["players" : FieldValue.arrayRemove([playerData])])
                }
                try await FirebaseManager.shared.firestore.collection("tournaments").document(tournament.documentID).updateData(["playerId" : FieldValue.arrayRemove([userID])])
            }
            
            try await FirebaseManager.shared.firestore.collection("users").document(userID).delete()
            //remove current user from their friends, friends list
            let friendsData = try await FirebaseManager.shared.firestore.collection("users").whereField("friends", arrayContains: userID).getDocuments()
            for friend in friendsData.documents {
                try await FirebaseManager.shared.firestore.collection("users").document(friend.documentID).updateData(["friends" : FieldValue.arrayRemove([userID])])
            }
            
           
        } catch {
            throw error
        }
    }
    
    func updateDisplayName(userID: String, username: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("users").document(userID).updateData(["displayName" : username])
        } catch {
            throw error
        }
    }
    
    func storeUserImage(imageData: Data, userID: String) async throws -> URL {
        do {
            let ref = FirebaseManager.shared.storage.reference(withPath: userID)
            _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL()
        } catch {
            throw error
        }
    }
    
    func updateUserImage(imageURL: String, userID: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("users").document(userID).updateData(["profilePicUrl" : imageURL])
        } catch {
            throw error
        }
    }
}
