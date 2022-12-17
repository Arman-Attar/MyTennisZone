//
//  createRoundRobinTournment.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import PhotosUI

struct createTournament: View {
    @State var tournamentName = ""
    @State var opponentSelection = false
    @State var noOfGames = ""
    @EnvironmentObject var vm: UserViewModel
    @StateObject var tournamentVM = TournamentViewModel()
    @State var players: [Player] = []
    @State var playerId: [String] = []
    @State var matches: [Match] = []
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var numberOfSets = 2
    var modes = ["Bracket", "Round Robin"]
    @Environment(\.dismiss) var dismiss
    @State var mode = "Bracket"
    @State var matchGeneration = "Random"
    var bracketGeneration = "Random"
    @State var showAlert = false
    @State var photoPermission = false
    var body: some View {
        NavigationView {
            Form{
                leagueBanner.padding(.vertical)
                leagueNameField.padding(.vertical, 10)
                HStack {
                    Spacer()
                    Picker("First To:", selection: $numberOfSets) {
                        ForEach(0..<5){ set in
                            Text("\(set) Sets")
                        }
                    }
                }.padding()
                HStack {
                    Spacer()
                    Picker("Tournament Mode:", selection: $mode) {
                        ForEach(modes, id: \.self){ mode in
                            Text(mode)
                        }
                    }
                }.padding()
                if mode == "Bracket"{
                    HStack{
                        Text("Bracket Generation:").padding(.leading, 8)
                        Spacer()
                        Text("Random").padding(.trailing, 11)
                    }.padding()
                }
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
                HStack {
                    Spacer()
                    createButton.onTapGesture {
                        if verifyNumbOfPlayers(){
                            //generateMatches()
                            Task {
                                let result = await tournamentVM.createTournament(tournamentName: tournamentName, playerId: playerId, admin: vm.user!.uid, players: players, bannerImage: image, mode: mode, setsToWin: numberOfSets)
                                if result {
                                    dismiss()
                                }
                            }
                        }
                        else {
                            showAlert.toggle()
                        }
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $opponentSelection) {
                opponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .onAppear{
                if playerId.isEmpty {
                    players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user?.profilePicUrl ?? "", displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0))
                    playerId.append(vm.user?.uid ?? "")
                }
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert){
                Alert(title: Text("Error!"), message: Text("Number of players are not valid"), dismissButton: .default(Text("Got it!")))
            }
            .sheet(isPresented: $opponentSelection) {
                opponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            .alert(isPresented: $photoPermission) {
                Alert(title: Text("Permission Denied!"), message: Text("Please go into your settings and give photo permissions for TennisTracker"), dismissButton:
                        .default(Text("Got it!")))
            }
        }
        .navigationTitle("Create a tournament")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct createRoundRobinTournment_Previews: PreviewProvider {
    static var previews: some View {
        createTournament().environmentObject(UserViewModel())
    }
}


extension createTournament {
    
    
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
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                            if status == .authorized || status == .limited {
                                showImagePicker.toggle()
                            } else {
                                photoPermission = false
                            }
                        }
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
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                            if status == .authorized || status == .limited {
                                showImagePicker.toggle()
                            } else {
                                photoPermission = false
                            }
                        }
                    }
            }
        }
    }
    
    private var leagueNameField: some View {
        VStack{
            HStack{
                TextField("Enter League Name", text: $tournamentName)
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
    
    private var opponentField: some View {
        HStack{
            if !players.isEmpty {
                Text("Opponent:").padding().frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                
                HStack(spacing: -20) {
                    ForEach(players, id:\.uid) { player in
                        WebImage(url: URL(string: player.profilePicUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                    }
                }
                
                Button {
                    opponentSelection.toggle()
                } label: {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                }
            }
            else {
                Text("Opponent:").padding().frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding(.horizontal)
                
                Button {
                    opponentSelection.toggle()
                } label: {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                }
            }
            
        }.padding(.horizontal)
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
    
    func verifyNumbOfPlayers() -> Bool {
        if playerId.count == 32 || playerId.count == 31 || playerId.count == 16 || playerId.count == 15 || playerId.count == 8 || playerId.count == 7 || playerId.count == 4 || players.count == 3 || players.count == 2{
            return true
        }
        else {
            return false
        }
    }
}
