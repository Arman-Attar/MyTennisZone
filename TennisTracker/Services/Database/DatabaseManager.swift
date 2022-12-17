//
//  DatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-07.
//

import Foundation
import Firebase
import UIKit
import FirebaseFirestoreSwift


class DatabaseManager {
    static let shared = DatabaseManager()
    private init () {}
    
    func getLeagues(userID: String) async throws -> [League] {
        var leagues: [League] = []
        let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: userID).getDocuments()
        for league in data.documents {
            do{
                leagues.append(try league.data(as: League.self))
            }catch{
                throw(error)
            }
        }
        return leagues
    }
    
    func getLeague(leagueID: String) async throws -> League {
        do {
            let league = try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).getDocument(as: League.self)
            return league
        } catch {
            throw error
        }
    }
    
    func searchLeague(leagueName: String) async throws -> League? {
        var league: League? = nil
        do {
            let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("name", isEqualTo: leagueName).getDocuments()
            if let document = data.documents.first {
                league = try document.data(as: League.self)
            }
        } catch {
            throw (error)
        }
        return league
    }
    
    func joinLeague(playerData: [String: Any], leagueID: String, playerID: String){
        FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.arrayUnion([playerData])])
        FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["playerId" : FieldValue.arrayUnion([playerID])])
    }
    
    func deleteLeague(leagueID: String, bannerURL: String?) async throws -> Bool {
        do {
            if let bannerURL = bannerURL {
                let storageRef = FirebaseManager.shared.storage.reference(forURL: bannerURL)
                try await storageRef.delete()
                print("BANNER DELETED")
            }
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).delete()
            return true
        } catch  {
            throw error
        }
    }
    
    func createLeague(league: League) throws{
        do {
            try FirebaseManager.shared.firestore.collection("leagues").addDocument(from: league)
        } catch  {
            throw error
        }
    }
    
    func uploadBanner(image: UIImage) async throws -> String {
        let uid = UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return ""
        }
        do {
            try await ref.putDataAsync(imageData)
            return try await ref.downloadURL().absoluteString
        } catch {
            throw error
        }
    }
}
