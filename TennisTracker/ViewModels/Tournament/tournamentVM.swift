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
    @Published var tournaments: [Tournament]?
    @Published var tournament: Tournament?
    @Published var playerList: [Player] = []
    @Published var playersEntered: [Player] = []
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    var currentRound: String = ""
    var firstRound: String = ""
    
    func getTournaments() async {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        do {
            let tournaments = try await TournamentDatabaseManager.shared.getTournaments(userID: uid)
            await MainActor.run(body: { [weak self] in
                self?.tournaments = tournaments
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
                self?.playersEntered = tournament.playersEntered
                self?.listOfMatches = tournament.matches
                if !tournament.matches.isEmpty {
                    self?.firstRound = (self?.listOfMatches[0].matchType)!
                    let last = self!.listOfMatches.endIndex - 1
                    self?.currentRound = self!.listOfMatches[last].matchType
                }
                else{
                    self?.firstRound = getRound(playerCount: (self?.playersEntered.count)!)
                    self?.currentRound = getRound(playerCount: (self?.playerList.count)!)
                }
            })
        } catch {
            print(error)
        }
    }
    
    private func getRound(playerCount: Int) -> String {
        if playerCount == 32 || playerCount == 31 {
            return "R32"
        }
        else if playerCount == 16 || playerCount == 15 {
            return "R16"
        }
        else if playerCount == 8 || playerCount == 7 {
            return "QF"
        }
        else if playerCount == 4 || playerCount == 3 {
            return "SEMI"
        }
        else if playerCount == 2 {
            return "FINAL"
        }
        else {
            return "DONE"
        }
    }
    
    func deleteTournament(tournamentId: String) async -> Bool {
        var deleted = false
        if let tournament = self.tournament {
            do {
                for match in tournament.matches {
                    try await MatchDatabaseManager.shared.deleteSets(matchID: match.id)
                }
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
                bannerURL = try await LeagueDatabaseManager.shared.uploadBanner(image: bannerImage)
            }
            let tournamentData = Tournament(name: tournamentName.lowercased(), playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin, mode: mode, winner: nil, numberOfPlayers: players.count, playersEntered: players, roundLosers: [])
            try await TournamentDatabaseManager.shared.createLeague(tournament: tournamentData)
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
    
    func allMatchesFinished() -> Bool {
        for match in listOfMatches {
            if match.matchOngoing {
                return false
            }
        }
        return true
    }
    
    func removePlayer(player: String) async {
        do {
            guard let tournamentID = self.tournament?.id,
                  let index = self.playerList.firstIndex(where: {$0.displayName == player})
            else {return}
            await getCurrentTournament(tournamentID: tournamentID)
            let playerData: [String: Any] = [
                "uid" : playerList[index].uid as Any,
                "profilePicUrl": playerList[index].profilePicUrl,
                "displayName": playerList[index].displayName,
                "points": playerList[index].points,
                "wins": playerList[index].wins,
                "losses": playerList[index].losses,
            ]
            try await TournamentDatabaseManager.shared.removePlayer(playerData: playerData, tournamentID: tournamentID)
            await MainActor.run(body: {
                self.playerList.remove(at:index)
            })
        } catch {
            print(error)
        }
    }
    
    
    func endRound() async {
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
                    if currentRound == "FINAL" {
                        let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                    } else {
                        while self.playerList.count != 0 {
                            let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                            matches.append(match)
                            await MainActor.run(body: {
                                self.playerList.removeFirst()
                                self.playerList.removeFirst()
                            })
                        }
                    }
                }
                else{
                    while self.playerList.count != 1 {
                        let match = Match(id: UUID().uuidString, date: Utilities.convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                        await MainActor.run(body: {
                            self.playerList.removeFirst()
                            self.playerList.removeFirst()
                        })
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
                } catch {
                    print(error)
                    return
                }
                
            }
            await getCurrentTournament(tournamentID: self.tournament!.id!)
        }
    }
}
