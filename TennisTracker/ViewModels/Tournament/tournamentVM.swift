//
//  tournamentVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-20.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class TournamentViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var tournament: Tournament?
    @Published var playerList: [Player] = []
    //@Published var playersEntered: [Player] = []
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    //@State var topPlayer = ""
    @Published var currentRound: String = ""
    @Published var firstRound: String = ""
    @Published var playerImages: [UIImage?] = []
    
    // REFACTORED
    
    func loadImages() async throws{
        do {
            let images = try await ImageLoader.shared.getImages(playerList: self.playerList)
            await MainActor.run(body: {
                self.playerImages = images
            })
        } catch {
            throw error
        }
    }
    
    func getTournaments() async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        do {
            let tournaments = try await TournamentDatabaseManager.shared.getTournaments(userID: uid)
            await MainActor.run(body: {
                self.tournaments = tournaments
            })
        } catch {
            print(error)
        }
    }
    
    func getCurrentTournament(tournamentID: String) async {
        do {
            let tournament = try await TournamentDatabaseManager.shared.getTournament(tournamentID: tournamentID)
            await MainActor.run(body: { [weak self] in
                playerList.removeAll()
                self?.tournament = tournament
                var players = tournament.players
                players.sort {
                    $0.points > $1.points
                }
                self?.playerList = players
                self?.listOfMatches = tournament.matches
                if !tournament.matches.isEmpty {
                    self?.firstRound = (self?.listOfMatches[0].matchType)!
                }
                else{
                    if self?.playerList.count == 32 || self?.playerList.count == 31 {
                        self?.firstRound = "R32"
                    }
                    else if self?.playerList.count == 16 || self?.playerList.count == 15 {
                        self?.firstRound = "R16"
                    }
                    else if self?.playerList.count == 8 || self?.playerList.count == 7 {
                        self?.firstRound = "QF"
                    }
                    else if self?.playerList.count == 4 || self?.playerList.count == 3 {
                        self?.firstRound = "SEMI"
                    }
                    else if self?.playerList.count == 2 {
                        self?.currentRound = "FINAL"
                    }
                    else {
                        self?.currentRound = "DONE"
                    }
                }
                
                
                if !tournament.matches.isEmpty {
                    let last = self!.listOfMatches.endIndex - 1
                    self?.currentRound = self!.listOfMatches[last].matchType
                }
                else{
                    if self?.playerList.count == 32 || self?.playerList.count == 31 {
                        self?.currentRound = "R32"
                    }
                    else if self?.playerList.count == 16 || self?.playerList.count == 15 {
                        self?.currentRound = "R16"
                    }
                    else if self?.playerList.count == 8 || self?.playerList.count == 7 {
                        self?.currentRound = "QF"
                    }
                    else if self?.playerList.count == 4 || self?.playerList.count == 3 {
                        self?.currentRound = "SEMI"
                    }
                    else if self?.playerList.count == 2 {
                        self?.currentRound = "FINAL"
                    }
                    else {
                        self?.currentRound = "DONE"
                    }
                }
                //self?.playersEntered = self!.playerList
            })
            try await loadImages()
            print(playerImages)
        } catch {
            print(error)
        }
    }
    
    func deleteTournament(tournamentId: String) async -> Bool {
        var deleted = false
        if let tournament = self.tournament {
            do {
                if tournament.bannerURL != "" {
                    try await deleted = TournamentDatabaseManager.shared.deleteTournament(tournamentID: tournamentId, bannerURL: tournament.bannerURL)
                } else {
                    try await deleted = TournamentDatabaseManager.shared.deleteTournament(tournamentID: tournamentId, bannerURL: nil)
                }
            } catch {
                print(error)
            }
            
        }
        return deleted
    }
    
    func createTournament(tournamentName: String, playerId: [String], admin: String, players: [Player], bannerImage: UIImage?, mode: String, setsToWin: Int) async -> Bool {
        do {
            let matches = generateMatches(playerList: players, mode: mode, setsToWin: setsToWin)
            var bannerURL = ""
            if let bannerImage = bannerImage {
                bannerURL = try await DatabaseManager.shared.uploadBanner(image: bannerImage)
            }
            let tournamentData = Tournament(name: tournamentName.lowercased(), playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin, mode: mode, winner: nil, numberOfPlayers: players.count)
            try TournamentDatabaseManager.shared.createLeague(tournament: tournamentData)
            return true
        } catch  {
            print(error)
            return false
        }
    }
    
    private func generateMatches(playerList: [Player], mode: String, setsToWin: Int) -> [Match] {
        var matches: [Match] = []
        var temp = playerList
        if mode == "Round Robin"{
            while temp.count != 1 {
                for i in 1..<temp.count {
                    let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[i].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[i].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: setsToWin, matchType: "Round Robin")
                    matches.append(match)
                }
                temp.removeFirst()
            }
        }
        else if mode == "Bracket"{
            if temp.count % 2 == 0 {
                while temp.count != 0 {
                    let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[1].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: setsToWin, matchType: getCurrentRound(players: playerList))
                    matches.append(match)
                    temp.removeFirst()
                    temp.removeFirst()
                }
            }
            else{
                while temp.count != 1 {
                    let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[1].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: setsToWin, matchType: getCurrentRound(players: playerList))
                    matches.append(match)
                    temp.removeFirst()
                    temp.removeFirst()
                }
                let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: "", player1DisplayName: temp[0].displayName, player2DisplayName: "", player1Score: setsToWin, player2Score: 0, winner: "temp[0].displayName", matchOngoing: false, setsToWin: setsToWin, matchType: getCurrentRound(players: playerList))
                matches.append(match)
            }
        }
        return matches
    }
    
    private func getCurrentRound(players: [Player]) -> String{
        if players.count == 32 || players.count == 31 {
            return "R32"
        }
        else if players.count == 16 || players.count == 15 {
            return "R16"
        }
        else if players.count == 8 || players.count == 7 {
            return "QF"
        }
        else if players.count == 4 || players.count == 3 {
            return "SEMI"
        }
        else {
            return "FINAL"
        }
    }
    
    // TO BE REFACTORED
    
    func allMatchesFinished() -> Bool {
        for match in listOfMatches {
            if match.matchOngoing {
                return false
            }
        }
        return true
    }
    
    private func updatePlayerList(playersToRemove: [String]) async throws {
        for player in playersToRemove {
            guard let index = self.playerList.firstIndex(where: {$0.displayName == player}) else { return }
            let playerData: [String: Any] = [
                "uid" : self.playerList[index].uid as Any,
                "profilePicUrl": self.playerList[index].profilePicUrl,
                "displayName": self.playerList[index].displayName,
                "points": self.playerList[index].points,
                "wins": self.playerList[index].wins,
                "losses": self.playerList[index].losses,
            ]
            do {
                try await TournamentDatabaseManager.shared.removePlayer(playerData: playerData, tournamentID: self.tournament!.id!)
                self.playerList.remove(at: index)
            } catch  {
                throw error
            }
        }
    }
    
    func endRound(playersToRemove: [String]) async {
        do {
            try await updatePlayerList(playersToRemove: playersToRemove)
        } catch {
            print(error)
            return
        }
       
        var matches: [Match] = []
        if self.playerList.count > 0{
            if currentRound == "R32" {
                currentRound = "R16"
            }
            else if currentRound == "R16"{
                currentRound = "R8"
            }
            else if currentRound == "R8"{
                currentRound = "QF"
            }
            else if currentRound == "QF"{
                currentRound = "SEMI"
            }
            else if currentRound == "SEMI" {
                currentRound = "FINAL"
            }
            else{
                currentRound = "DONE"
            }
            if currentRound != "DONE"{
                if self.playerList.count % 2 == 0 {
                    while self.playerList.count != 0 {
                        let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                        if currentRound != "FINAL" {
                            self.playerList.removeFirst()
                            self.playerList.removeFirst()
                        }
                    }
                }
                else{
                    while self.playerList.count != 1 {
                        let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                        self.playerList.removeFirst()
                        self.playerList.removeFirst()
                    }
                    let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                    matches.append(match)
                }
                
                for match in matches {
                    let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName ,"player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                    do {
                        try await MatchDatabaseManager.shared.createMatch(matchData: matchData, competitionID: self.tournament!.id!, competition: match.matchType)
                    } catch {
                        print(error)
                    }
                }
            }
            else {
                do {
                    let finalMatchIndex = listOfMatches.endIndex - 1
                    let finalMatch = listOfMatches[finalMatchIndex]
                    let winner = finalMatch.winner
                    let loser = (winner == finalMatch.player1DisplayName ? finalMatch.player2DisplayName : finalMatch.player1DisplayName )
                    let winnerIndex = playerList.firstIndex(where: {$0.displayName == winner})
                    let winnerID = playerList[winnerIndex!].uid
                    try await TournamentDatabaseManager.shared.tournamentWrapUp(winner: winner, winnerID: winnerID, tournamentID: self.tournament!.id!)
                    try await updatePlayerList(playersToRemove: [loser])
                } catch {
                    print(error)
                    return
                }
                
            }
            await getCurrentTournament(tournamentID: self.tournament!.id!)
        }
    }
}
