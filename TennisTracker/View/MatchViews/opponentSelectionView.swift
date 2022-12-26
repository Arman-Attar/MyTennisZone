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
    @Binding var playerId: [String]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: UserViewModel
    @State var showImagePicker = false
    @State var playerName = ""
    @State var showForm = false
    var body: some View {
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
                            playerName = ""
                        }
                        .padding()
                }
                selectOpponent
            }.sheet(isPresented: $showForm) {
                playerForm
                    .presentationDetents([.medium])
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
            Form{
                HStack {
                    Spacer()
                    Text("Create a temporary player").font(.title3).fontWeight(.bold).padding()
                    Spacer()
                }
                header
                playerNameField.padding(.top)
                buttons
            }.cornerRadius(20)
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
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            Spacer()
                Image("profile")
                .userImageModifier(width: 60, height: 60)
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
    }
}
