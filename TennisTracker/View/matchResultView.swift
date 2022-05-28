//
//  addSetsView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct matchResultView: View {
    var player1: Player?
    var player2: Player?
    @State var sets: [Set]?
    var body: some View {
            Form{
                Text("Match Result")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                vsSection
                Section{
                    addSetResult
                    HStack{
                        Spacer()
                        Text("5").font(.system(size: 50, weight: .black))
                        Text("-").font(.system(size: 50, weight: .black))
                        Text("5").font(.system(size: 50, weight: .black))
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text("5").font(.system(size: 50, weight: .black))
                        Text("-").font(.system(size: 50, weight: .black))
                        Text("5").font(.system(size: 50, weight: .black))
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        Text("5").font(.system(size: 50, weight: .black))
                        Text("-").font(.system(size: 50, weight: .black))
                        Text("5").font(.system(size: 50, weight: .black))
                        Spacer()
                    }
                }
            }
    }
}

struct addSetsView_Previews: PreviewProvider {
    static var previews: some View {
        matchResultView()
    }
}

extension matchResultView{
    private var vsSection: some View {
        HStack{
            VStack
            {
//                WebImage(url: URL(string: player1!.profilePicUrl))
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .shadow(radius: 20)
//                    .padding(.horizontal)
                
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding(.horizontal)
                
//                Text(player1!.displayName)
//                    .font(.system(size: 15, weight: .bold))
//                    .multilineTextAlignment(.leading)
//                    .frame(width: 100, height: 50)
                
                Text("TEST")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack
            {
//                WebImage(url: URL(string: player2!.profilePicUrl))
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .shadow(radius: 20)
//                    .padding(.horizontal)
                
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding(.horizontal)
                
                
                Text("TEST")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
//                Text(player2!.displayName)
//                    .font(.system(size: 15, weight: .bold))
//                    .multilineTextAlignment(.leading)
//                    .frame(width: 100, height: 50)
            }
            
        }.padding(.vertical)
    }
    
    private var addSetResult: some View{
        HStack {
            Text("Add Set Result")
                .font(.headline)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "plus").padding()
            }
        }
    }
}
