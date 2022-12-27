//
//  AddSetView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct AddSetView: View {
    let player1: Player?
    let player2: Player?
    let matchID: String
    
    @ObservedObject var matchVM: MatchViewModel
    @State var player1SetScore = 0
    @State var player2SetScore = 0
    @Binding var noPlayerSelectedAlert: Bool
    @Binding var showSetSheet: Bool
    @Binding var sets: [Set]
    
    var body: some View {
        ZStack {
            NavigationView {
                Form{
                    Text("Enter Set Result").fontWeight(.bold).padding().zIndex(1.0)
                    HStack{
                        if player1?.profilePicUrl ?? "" != ""{
                            WebImage(url: URL(string: player1!.profilePicUrl))
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                            
                        }
                        else {
                            Image("profile")
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                            
                        }
                        
                        Text("VS")
                            .font(.system(size: 20, weight: .bold)).zIndex(1.0)
                        
                        
                        if player2?.profilePicUrl ?? "" != ""{
                            WebImage(url: URL(string: player2!.profilePicUrl))
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                        }
                        else {
                            Image("profile")
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                            
                        }
                    }
                    Picker("\(player1?.displayName ?? "Oponent") Score:", selection: $player1SetScore) {
                        ForEach(0..<8){ set in
                            Text("\(set)")
                        }
                    }.padding()
                    
                    Picker("\(player2?.displayName ?? "Oponent") Score:", selection: $player2SetScore) {
                        ForEach(0..<8){ set in
                            Text("\(set)")
                        }
                    }.padding()
                    
                    HStack{
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                showSetSheet.toggle()
                            }
                        Spacer()
                        Text("Add")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                var setWinner = ""
                                if player1 != nil && player2 != nil {
                                    if player1SetScore > player2SetScore { setWinner = player1?.uid ?? ""}
                                    else { setWinner = player2?.uid ?? ""}
                                    let set = Set(matchId: matchID, winner: setWinner, player1Uid: player1!.uid, player2Uid: player2!.uid, player1Points: player1SetScore, player2Points: player2SetScore)
                                    sets.append(set)
                                    Task {
                                        await matchVM.addSet(p1Points: player1SetScore, p2Points: player2SetScore, set: set)
                                    }
                                } else {
                                    noPlayerSelectedAlert.toggle()
                                }
                                showSetSheet.toggle()
                            }
                    }.padding()
                }.navigationBarHidden(true)
            }
            
        }.cornerRadius(20)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.4)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
    }
}

//struct AddSetView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSetView()
//    }
//}
