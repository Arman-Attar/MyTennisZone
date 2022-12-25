//
//  oponentSelectionView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-27.
//

import SwiftUI
import SDWebImageSwiftUI

struct opponentSelectionView: View {
    @Binding var players: [Player]
    //@State var players: [Player] = [] TEST VAR TO GET THE PREVIEW WORKING
    @Binding var playerId: [String]
    //@State var playerId: [String] = [] TEST VAR TO GET THE PREVIEW WORKING
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm = UserViewModel()
    @State var showImagePicker = false
    //@State var image: UIImage?
    @State var playerName = ""
    @State var showForm = false
    var body: some View {
        ZStack {
            VStack{
                HStack {
                    Text("Choose players")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .padding(.top)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.title3)
                            .padding()
                            .padding(.top)
                    }
                }
                HStack {
                    Text("Friends List")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    Image(systemName: "person.fill.badge.plus")
                        .font(.title3)
                        .onTapGesture {
                            showForm.toggle()
                        }
                        .padding()
                }
                selectOpponent
            }
            if showForm{
                Rectangle().ignoresSafeArea().opacity(0.5)
                playerForm
            }
        }
    }
}




//struct opponentSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        opponentSelectionView()
//    }
//}

extension opponentSelectionView {
    
    private var playerForm: some View{
        ZStack{
            Form{
                HStack {
                    Spacer()
                    Text("Create a temporary player").font(.title3).fontWeight(.bold).padding()
                    Spacer()
                }
                header
                playerNameField.padding(.vertical)
                buttons
            }.cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
                .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
        }
    }
    
    private var selectOpponent: some View {
        VStack{
            ScrollView {
                ForEach(vm.friends, id: \.uid) {friend in
                    if players.contains(where: {$0.uid == friend.uid}) {
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
                                Text("@\(friend.username)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button {
                                if let index = players.firstIndex(where: {$0.uid == friend.uid}){
                                    players.remove(at: index)
                                }
                                if let index = playerId.firstIndex(where: {$0 == friend.uid}){
                                    playerId.remove(at: index)
                                }
                            } label: {
                                Text("Remove")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .opacity(0.8)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    else {
                        Button {
                            players.append(Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: 0, wins: 0, losses: 0))
                            playerId.append(friend.uid)
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
                                    Text("@\(friend.username)")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    Divider().padding(.horizontal)
                }
            }
            Spacer()
        }
    }
    
    private var header: some View {
        HStack{
            Text("Player Image")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
            Spacer()
                Image("profile")
                .userImageModifier(width: 100, height: 100)
                .padding()
            Spacer()
        }
    }
    
    private var playerNameField: some View {
        VStack{
            HStack{
                TextField("Player display name", text: $playerName)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.black)
            }.padding(.horizontal).padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding(.vertical)
        }
    }
    
    private var buttons: some View {
        HStack{
            Text("Cancel")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    dismiss()
                }
            Spacer()
            Text("Add")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    createTempPlayer(uid: UUID().uuidString)
                    showForm.toggle()
                }
        }.padding()
    }
    
    private func createTempPlayer(uid: String){
        players.append(Player(uid: uid, profilePicUrl: "", displayName: playerName, points: 0, wins: 0, losses: 0))
        playerId.append(uid)
        print(players)
    }
}
