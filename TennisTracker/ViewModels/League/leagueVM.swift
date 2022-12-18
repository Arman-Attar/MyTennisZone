//
//  leagueVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-19.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class LeagueViewModel: ObservableObject {
    @Published var leagues: [League]?
    @Published var league: League?
    @Published var playerList: [Player] = []
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    @Published var playerImages: [UIImage?] = []
    @Published var playerIsJoined = false
    
    func getLeagues() async{
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let leagues = try await DatabaseManager.shared.getLeagues(userID: uid)
            await MainActor.run(body: {
                self.leagues = leagues
            })
        } catch {
            print(error)
        }
    }
    
    func getCurrentLeague(leagueId: String) async {
        do {
            let league = try await DatabaseManager.shared.getLeague(leagueID: leagueId)
            await MainActor.run(body: { [weak self] in
                playerList.removeAll()
                self?.league = league
                var players = league.players
                players.sort {
                    $0.points > $1.points
                }
                self?.playerList = players
                self?.listOfMatches = league.matches.reversed()
            })
        } catch {
            print(error)
        }
    }
    
    func loadImages() async{
        do {
            let images = try await ImageLoader.shared.getImages(playerList: self.playerList)
            await MainActor.run(body: {
                self.playerImages = images
            })
        } catch {
            print(error)
        }
    }
    
    func findLeague(leagueName: String, playerID: String) async {
        await MainActor.run(body: {
            self.league = nil
        })
        do {
            if let league = try await DatabaseManager.shared.searchLeague(leagueName: leagueName) {
                await MainActor.run(body: { [weak self] in
                    self?.league = league
                    self?.playerList = league.players
                })
            }
        } catch {
            print(error)
            await MainActor.run(body: {
                self.league = nil
                
            })
        }
        let userStatus = await isUserJoined(playerID: playerID)
        await MainActor.run(body: {
            self.playerIsJoined = userStatus
        })
    }
    
    func isUserJoined(playerID: String) async -> Bool {
        let result = self.playerList.filter{playerID == $0.uid}
        return !result.isEmpty
    }
    
    func joinLeague(uid: String, profilePic: String, displayName: String){
        let playerData = ["uid": uid, "profilePicUrl": profilePic, "displayName": displayName, "points": 0, "wins": 0, "losses": 0] as [String: Any]
        if let currentLeague = league,
           let leagueID = currentLeague.id {
            DatabaseManager.shared.joinLeague(playerData: playerData, leagueID: leagueID, playerID: uid)
        }
    }
    
    func deleteLeague(leagueID: String) async -> Bool {
        var deleted = false
        if let league = self.league {
            do {
                if league.bannerURL != "" {
                    try await deleted = DatabaseManager.shared.deleteLeague(leagueID: leagueID, bannerURL: league.bannerURL)
                } else {
                    try await deleted = DatabaseManager.shared.deleteLeague(leagueID: leagueID, bannerURL: nil)
                }
            } catch {
                print(error)
            }
            
        }
        return deleted
    }
    
    func createLeague(leagueName: String, playerId: [String], admin: String, players: [Player], bannerImage: UIImage?) async -> Bool {
        do {
            var bannerURL = ""
            if let bannerImage = bannerImage {
                bannerURL = try await DatabaseManager.shared.uploadBanner(image: bannerImage)
            }
            let leagueData = League(name: leagueName.lowercased(), playerId: playerId, players: players, matches: [], bannerURL: bannerURL, admin: admin)
            try DatabaseManager.shared.createLeague(league: leagueData)
            return true
        } catch  {
            print(error)
            return false
        }
    }
    
}


