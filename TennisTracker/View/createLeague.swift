//
//  createLeague.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-17.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct createLeague: View {
    @State var leagueName = ""
    @State var opponentSelection = false
    @EnvironmentObject var vm: UserViewModel
    @State var players: [Player] = []
    @State var playerId: [String] = []
    @State var showImagePicker = false
    @State var image: UIImage?
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack{
        Form{
            leagueBanner.padding(.vertical)
            leagueNameField.padding(.vertical, 10)
            opponentSection
            buttonSection
        }.navigationTitle("Create a tournament")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $opponentSelection) {
                opponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .onAppear{
                players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user!.profilePicUrl, displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0, played: 0))
                playerId.append(vm.user!.uid)
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            if isLoading{
                ZStack{
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .opacity(0.7)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(3)
                    }
            }
            
        }
    }
}

struct createLeague_Previews: PreviewProvider {
    static var previews: some View {
        createLeague().environmentObject(UserViewModel())
    }
}

extension createLeague {
    private var leagueBanner: some View {
        VStack{
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.26, height: UIScreen.main.bounds.height/4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "camera.fill").font(.title).foregroundColor(.white).opacity(0.8).padding([.top, .trailing], 5),
                        alignment: .topTrailing
                    )
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
            else {
                Image("league")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.26, height: UIScreen.main.bounds.height/4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "camera.fill").font(.title).foregroundColor(.white).opacity(0.8).padding([.top, .trailing], 5),
                        alignment: .topTrailing
                    )
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
        }
    }
    
    private var leagueNameField: some View {
        VStack{
            HStack{
                TextField("Enter a Unique League Name", text: $leagueName)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                Image(systemName: "plus")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundColor(.black)
                .padding()
        }
    }
    
    private var opponentSection: some View {
        VStack {
            HStack {
                Text("Players")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Image(systemName: "person.fill.badge.plus")
                
                    .font(.title3)
                    .onTapGesture {
                        opponentSelection.toggle()
                    }
                    .padding()
            }
            HStack(spacing: -20) {
                ForEach(players, id:\.uid) { player in
                    if player.profilePicUrl != "" {
                        WebImage(url: URL(string: player.profilePicUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                    } else {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                }
                }
            }.padding()
        }
    }
    
    private var buttonSection: some View {
        HStack {
            Spacer()
            createButton.onTapGesture {
                isLoading = true
                let admin = vm.user?.uid ?? ""
                var bannerURL = ""
                if image != nil {
                    LeagueViewModel.updateImage(image: image) { url in
                        if url != "" {
                            bannerURL = url
                        }
                        LeagueViewModel.createLeague(bannerURL: bannerURL, leagueName: leagueName, playerId: playerId, admin: admin, players: players) { data in
                            if data {
                                dismiss()
                            }
                        }
                    }
                } else {
                    LeagueViewModel.createLeague(bannerURL: bannerURL, leagueName: leagueName, playerId: playerId, admin: admin, players: players) { data in
                        if data {
                            dismiss()
                        }
                    }
                }
            }
            Spacer()
        }
    }
    
    private var createButton: some View {
        ZStack {
            Text("Create")
                .font(.title2)
                .fontWeight(.heavy)
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: UIScreen.main.bounds.size.width / 2, maxHeight: 20)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.black, lineWidth: 0.8))
                .padding()
        }
    }
}
