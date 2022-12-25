//
//  SelectWinnerView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectWinnerView: View {
    
    @Binding var showWinnerSheet: Bool
    @Binding var winner: String
    
    let player1: Player?
    let player2: Player?
    
    var body: some View {
        ZStack {
            Form{
                Text("Select The Winner").fontWeight(.bold).padding()
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
                    Text(player1?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player1?.uid ?? ""
                    showWinnerSheet.toggle()
                }
                HStack{
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
                    Text(player2?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player2?.uid ?? ""
                    showWinnerSheet.toggle()
                }
                HStack{
                    Spacer()
                    Text("Cancel")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: UIScreen.main.bounds.size.width/1.5)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                        .onTapGesture {
                            showWinnerSheet.toggle()
                        }
                }
            }.cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
        }
    }
}

//struct SelectWinnerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectWinnerView()
//    }
//}
