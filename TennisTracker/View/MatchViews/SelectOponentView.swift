//
//  SelectOponentView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectOponentView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var playerNumber: Int
    @Binding var player1: Player?
    @Binding var player2: Player?
    @Binding var showPlayerList: Bool
    
    let playerList: [Player]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(playerList, id: \.uid) { friend in
                        Button {
                            if playerNumber == 1 {
                                player1 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses)
                            }
                            else {
                                player2 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses)
                            }
                            showPlayerList.toggle()
                        } label: {
                            HStack{
                                if friend.profilePicUrl != "" {
                                    WebImage(url: URL(string: friend.profilePicUrl))
                                        .userImageModifier(width: 50, height: 50)
                                        .padding(.horizontal)
                                }
                                else {
                                    Image("profile")
                                        .userImageModifier(width: 50, height: 50)
                                        .padding(.horizontal)
                                }
                                VStack(alignment: .leading){
                                    
                                    Text(friend.displayName)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                        }
                        Divider().padding(.horizontal)
                    }
                }
                Spacer()
            }.padding(.top)
            .navigationTitle("Players")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                        }
                    }
                }
        }
    }
}

//struct SelectOponentView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectOponentView()
//    }
//}
