//
//  HeadToHeadView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeadToHeadView: View {
    
    let player1: Player?
    let player2: Player?
    
    @Binding var playerNumber: Int
    @Binding var showPlayerList: Bool
    
    var body: some View {
        HStack{
            VStack
            {
                if player1?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: player1!.profilePicUrl))
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 1
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 1
                            showPlayerList.toggle()
                        }
                }
                
                Text(player1?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if player2?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: player2!.profilePicUrl))
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 2
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 2
                            showPlayerList.toggle()
                        }
                }
                
                
                Text(player2?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
}

//struct HeadToHeadView_Previews: PreviewProvider {
//    static var previews: some View {
//        HeadToHeadView()
//    }
//}
