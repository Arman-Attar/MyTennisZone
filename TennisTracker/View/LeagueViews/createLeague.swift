//
//  createLeague.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-17.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import PhotosUI

struct createLeague: View {
    @State var leagueName = ""
    @State var opponentSelection = false
    @EnvironmentObject var vm: UserViewModel
    @StateObject var leagueVM = LeagueViewModel()
    @State var players: [Player] = []
    @State var playerId: [String] = []
    @State var showImagePicker = false
    @State var image: UIImage?
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    @State var photoPermission = false
    @State var invalidLeagueNameAlert = false
    var body: some View {
        ZStack{
            Form{
                leagueBanner.padding(.vertical)
                leagueNameField.padding(.vertical, 10)
                opponentSection
                buttonSection
            }.navigationTitle("Create a league")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $opponentSelection) {
                    opponentSelectionView(players: $players, playerId: $playerId).environmentObject(vm).padding(.bottom)
                }
                .onAppear{
                    players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user!.profilePicUrl, displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0))
                    playerId.append(vm.user!.uid)
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    ImagePicker(image: $image)
                }
                .alert(isPresented: $photoPermission) {
                    Alert(title: Text("Permission Denied!"), message: Text("Please go into your settings and give photo permissions for TennisTracker"), dismissButton:
                            .default(Text("Got it!")))
                }
                .alert(isPresented: $invalidLeagueNameAlert) {
                    Alert(title: Text("Invalid League Name!"), message: Text("League name cannot be empty"), dismissButton:
                            .default(Text("Got it!")))
                }
            if isLoading{
                    LoadingView()
            }
        }.padding(.bottom)
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
                TextField("Enter League Name", text: $leagueName)
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
                            .userImageModifier(width: 50, height: 50)
                    } else {
                        Image("profile")
                            .userImageModifier(width: 50, height: 50)
                    }
                }
            }.padding()
        }
    }
    
    private var buttonSection: some View {
        HStack {
            Spacer()
            createButton.onTapGesture {
                if leagueName != "" {
                    let admin = vm.user?.uid ?? ""
                    Task{
                        isLoading = true
                        let result = await leagueVM.createLeague(leagueName: leagueName, playerId: playerId, admin: admin, players: players, bannerImage: image)
                        if result {
                            dismiss()
                        } else {
                            isLoading = false
                        }
                    }
                } else {
                    invalidLeagueNameAlert.toggle()
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
