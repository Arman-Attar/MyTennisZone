//
//  oponentSelectionView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-27.
//

import SwiftUI
import SDWebImageSwiftUI

struct oponentSelectionView: View {
    @Binding var players: [Player]
    //@State var players: [Player] = []
    @Binding var playerId: [String]
    //@State var playerId: [String] = []
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm = UserViewModel()
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var playerName = ""
    @State var showForm = false
    var body: some View {
        ZStack {
            VStack{
                Text("Choose a player")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .padding(.top)
                
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
        }.fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
}




//struct oponentSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        oponentSelectionView()
//    }
//}

extension oponentSelectionView {
    
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
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding(.horizontal)
                            }
                            else {
                                Image("profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding()
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
                            players.append(Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: 0, wins: 0, losses: 0, played: 0))
                            playerId.append(friend.uid)
                            dismiss()
                        } label: {
                            HStack{
                                if friend.profilePicUrl != "" {
                                    WebImage(url: URL(string: friend.profilePicUrl))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 20)
                                        .padding(.horizontal)
                                }
                                else {
                                    Image("profile")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 20)
                                        .padding()
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
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding()
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
            else {
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding()
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
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
                    updateImage() // this function uploads the image to storage and then creates a player
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
        }.padding()
    }
    
    private func updateImage() {
        let uid = UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else {return}
                createTempPlayer(uid: uid, imageURL: url)
            }
        }
    }
    
    private func createTempPlayer(uid: String, imageURL: URL){
        players.append(Player(uid: uid, profilePicUrl: imageURL.absoluteString, displayName: playerName, points: 0, wins: 0, losses: 0, played: 0))
        playerId.append(uid)
    }
}
