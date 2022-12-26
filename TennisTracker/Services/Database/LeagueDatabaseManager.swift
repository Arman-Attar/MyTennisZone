//
//  DatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-07.
//

import Foundation
import Firebase
import UIKit


actor LeagueDatabaseManager {
    static let shared = LeagueDatabaseManager()
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
    
    func searchLeague(leagueName: String) async throws -> [League]? {
        var leagues: [League] = []
        do {
            let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("name", isEqualTo: leagueName).getDocuments()
            for document in data.documents {
                try leagues.append(document.data(as: League.self))
            }
        } catch {
            throw (error)
        }
        if leagues.isEmpty {
            return nil
        } else {
            return leagues
        }
    }
    
    func joinLeague(playerData: [String: Any], leagueID: String, playerID: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.arrayUnion([playerData])])
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["playerId" : FieldValue.arrayUnion([playerID])])
        } catch {
            throw error
        }
    }
    
    func deleteLeague(leagueID: String, bannerURL: String?) async throws -> Bool {
        do {
            if let bannerURL = bannerURL {
                let storageRef = FirebaseManager.shared.storage.reference(forURL: bannerURL)
                try await storageRef.delete()
            }
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).delete()
            return true
        } catch  {
            throw error
        }
    }
    
    func createLeague(league: League) throws {
        do {
            _ = try FirebaseManager.shared.firestore.collection("leagues").addDocument(from: league)
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
            _ = try await ref.putDataAsync(imageData)
            return try await ref.downloadURL().absoluteString
        } catch {
            throw error
        }
    }
    
    func updateProfilePicURL(playerID: String, profilePicURL: String, displayName: String) async throws {
        let leagueData = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: playerID).getDocuments()
        for data in leagueData.documents {
            do{
                var league = try data.data(as: League.self)
                let playerIndex = league.players.firstIndex(where: {$0.uid == playerID})
                for i in 0..<league.matches.count {
                    if league.matches[i].player1DisplayName == displayName {
                        league.matches[i].player1Pic = profilePicURL
                    } else if league.matches[i].player2DisplayName == displayName {
                        league.matches[i].player2Pic = profilePicURL
                    }
                }
                league.players[playerIndex!].profilePicUrl = profilePicURL
                try await FirebaseManager.shared.firestore.collection("leagues").document(league.id!).delete()
                try createLeague(league: league)
            }catch{
                throw(error)
            }
        }
        let tournamentData = try await FirebaseManager.shared.firestore.collection("tournaments").whereField("playerId", arrayContains: playerID).getDocuments()
        for data in tournamentData.documents {
            do{
                
                var tournament = try data.data(as: Tournament.self)
                let playerIndex = tournament.players.firstIndex(where: {$0.uid == playerID})
                tournament.players[playerIndex!].profilePicUrl = profilePicURL
                for i in 0..<tournament.matches.count {
                    if tournament.matches[i].player1DisplayName == displayName {
                        tournament.matches[i].player1Pic = profilePicURL
                    } else if tournament.matches[i].player2DisplayName == displayName {
                        tournament.matches[i].player2Pic = profilePicURL
                    }
                }
                try await FirebaseManager.shared.firestore.collection("tournaments").document(tournament.id!).delete()
                try await TournamentDatabaseManager.shared.createTournament(tournament: tournament)
            }catch{
                throw(error)
            }
        }
    }
    
    func updateDisplayName(playerID: String, profilePicURL: String, displayName: String) async throws {
        let leagueData = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: playerID).getDocuments()
        for data in leagueData.documents {
            do{
                var league = try data.data(as: League.self)
                let playerIndex = league.players.firstIndex(where: {$0.uid == playerID})
                for i in 0..<league.matches.count {
                    if league.matches[i].player1Pic == profilePicURL {
                        league.matches[i].player1DisplayName = displayName
                    } else if league.matches[i].player2Pic == profilePicURL {
                        league.matches[i].player2DisplayName = displayName
                    }
                }
                league.players[playerIndex!].displayName = displayName
                try await FirebaseManager.shared.firestore.collection("leagues").document(league.id!).delete()
                try createLeague(league: league)
            }catch{
                throw(error)
            }
        }
        let tournamentData = try await FirebaseManager.shared.firestore.collection("tournaments").whereField("playerId", arrayContains: playerID).getDocuments()
        for data in tournamentData.documents {
            do{
                
                var tournament = try data.data(as: Tournament.self)
                let playerIndex = tournament.players.firstIndex(where: {$0.uid == playerID})
                for i in 0..<tournament.matches.count {
                    if tournament.matches[i].player1Pic == profilePicURL {
                        tournament.matches[i].player1DisplayName = displayName
                    } else if tournament.matches[i].player2Pic == profilePicURL {
                        tournament.matches[i].player2DisplayName = displayName
                    }
                }
                tournament.players[playerIndex!].displayName = displayName
                try await FirebaseManager.shared.firestore.collection("tournaments").document(tournament.id!).delete()
                try await TournamentDatabaseManager.shared.createTournament(tournament: tournament)
            }catch{
                throw(error)
            }
        }
    }
}
