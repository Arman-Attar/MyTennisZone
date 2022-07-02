//
//  profileTab.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-08.
//

import SwiftUI
import SDWebImageSwiftUI

struct profileTab: View {
    @State var profileImage = ""
    @State var showImagePicker = false
    @State var showSaveButton = false
    @State var image: UIImage?
    @State var changeDisplayName = false
    @State var displayName = ""
    @State var showFriendsList = false
    @State var confirmDeleteAlert = false
    @ObservedObject private var vm = UserViewModel()
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    header
                    Divider().padding(.horizontal)
                    statBar
                    VStack{
                        statRow
                        changeUserRow
                        changeProfilePicRow
                        Divider().padding()
                        logOutRow
                        deleteAccountRow
                    }.padding()
                    Spacer()
                }.sheet(isPresented: $showFriendsList, content: {
                    VStack {
                            Text("Friends")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                        Divider().padding(.horizontal)
                        Spacer()
                        ScrollView {
                            ForEach(vm.friends, id: \.uid) {friend in
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
                                
                                Divider().padding(.horizontal)
                            }
                        }
                        Spacer()
                    }
                })
                .sheet(isPresented: $changeDisplayName) {
                    ZStack {
                        Image("back")
                            .resizable()
                            .ignoresSafeArea()
                            .blur(radius: 2.0, opaque: true)
                            .opacity(0.85)
                        VStack(alignment: .leading){
                            Text("Update Display Name")
                                .font(.title)
                                .fontWeight(.bold)
                        TextField("Enter Display Name", text: $displayName)
                                .frame(width: UIScreen.main.bounds.size.width - 50, height: 50)
                                .foregroundColor(Color.black)
                                .background(Color.gray.opacity(0.4))
                                .padding()
                            Button {
                                displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                                updateDisplayName(input: displayName)
                            } label: {
                                Text("Update")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .padding()
                                    .foregroundColor(.black)
                                    .frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 20)
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.black, lineWidth: 0.8))
                                    .padding()
                                    .offset(y: 9)                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }.navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if showSaveButton{
                        Button {
                            updateImage()
                            showSaveButton = false
                        } label: {
                            Text("Save")
                                .padding()
                        }
                    }
                }
        }.fullScreenCover(isPresented: $vm.isUserSignedOut) {
            signIn()
        }
        .alert(isPresented: $confirmDeleteAlert) {
            Alert(title: Text("Delete Account"), message: Text("Are you sure you want to your account?"), primaryButton: .destructive(Text("Delete")){
                vm.deleteUserData(uid: vm.user!.uid)
                vm.deleteUser()
            }, secondaryButton: .cancel())
        }
    }
    
}



struct profileTab_Previews: PreviewProvider {
    static var previews: some View {
        profileTab()
    }
}



extension profileTab {
    private var statBar: some View {
        HStack{
            Spacer()
            Button {
                showFriendsList.toggle()
            } label: {
                VStack {
                    Text("\(vm.user?.friendsUid.count ?? 0)")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text("Friends")
                        .font(.caption)
                        .foregroundColor(.black)
                }.padding()
            }

            Spacer()
            VStack {
                Text("\(vm.user?.matchesPlayed ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Played")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.user?.matchesWon ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Won")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.user?.trophies ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Trophies")
                    .font(.caption)
            }.padding()
            Spacer()
        }.padding(.horizontal)
    }
    
    private var header: some View {
        VStack{
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding()
            } else {
                if vm.user?.profilePicUrl != "" && image == nil {
                    WebImage(url: URL(string: vm.user?.profilePicUrl ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding()
                }
                
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding()
                }
                
            }
            if displayName == "" && vm.user?.displayName != ""{
            Text(vm.user?.displayName ?? "")
                .font(.title)
                .fontWeight(.bold)
            }
            else {
                Text(displayName)
                    .font(.title)
                    .fontWeight(.bold)
            }
            Text("@\(vm.user?.username ?? "")")
                .font(.body)
                .foregroundColor(Color.gray)
        }
    }
    
    private var statRow: some View{
        HStack{
            NavigationLink(destination: mainPage()) {
                Image(systemName: "list.number")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                
                Text("Match History")
                    .foregroundColor(Color.black)
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.black)
                    .padding()
                
            }.padding(.horizontal)
        }
    }
    
    private var changeUserRow: some View {
        Button {
            changeDisplayName.toggle()
        } label: {
            HStack{
                Image(systemName: "at")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                
                Text("Change Display Name")
                    .foregroundColor(Color.black)
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.black)
                    .padding()
                
            }.padding(.horizontal)
        }
    }
    
    private var changeProfilePicRow: some View {
        Button {
            showImagePicker.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                showSaveButton = true
            }
        } label: {
            HStack{
                
                Image(systemName: "camera")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                
                Text("Change Profile Picture")
                    .foregroundColor(Color.black)
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.black)
                    .padding()
                
            }.padding(.horizontal)
            
        }
    }
    
    private var logOutRow: some View {
        Button {
            vm.signOut()
        } label: {
            HStack{
                    Image(systemName: "arrow.right.square")
                        .font(.title)
                        .foregroundColor(Color.black)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    
                    Text("Log Out")
                        .foregroundColor(Color.black)
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.black)
                        .padding()
                    
            }.padding(.horizontal)
        }
    }
    
    private var deleteAccountRow: some View {
        Button {
            confirmDeleteAlert.toggle()
        } label: {
            HStack{
                    Image(systemName: "arrow.right.square")
                        .font(.title)
                        .foregroundColor(Color.red)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    
                    Text("Delete Account")
                        .foregroundColor(Color.red)
                        .font(.body)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.red)
                        .padding()
                    
            }.padding(.horizontal)
        }
    }
    
    private func updateImage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
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
                storeUserImage(imageURL: url)
            }
        }
    }
    
    private func storeUserImage(imageURL: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).updateData(["profilePicUrl" : imageURL.absoluteString]) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
    }
    
    private func updateDisplayName(input: String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["displayName" : input]) { err in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            changeDisplayName.toggle()
        }
    }
}
