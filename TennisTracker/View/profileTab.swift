//
//  profileTab.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-08.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct profileTab: View {
    @State var profileImage = ""
    @State var showImagePicker = false
    @State var showSaveButton = false
    @State var image: UIImage?
    @State var changeDisplayName = false
    @State var displayName = ""
    @State var showFriendsList = false
    @State var confirmDeleteAlert = false
    @State var invalidDisplayName = false
    @State var permission = false
    @EnvironmentObject private var vm: UserViewModel
    var body: some View {
        ZStack{
            NavigationView {
                ScrollView(showsIndicators: false){
                    VStack{
                        header
                        Divider().padding(.horizontal)
                        statBar
                        VStack{
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
                                friendsList
                            }
                            Spacer()
                        }
                    })
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    ImagePicker(image: $image)
                }.navigationTitle("Profile")
                    .toolbar {
                        if showSaveButton{
                            Button {
                                vm.updateImage(image: image)
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
            .alert(isPresented: $invalidDisplayName) {
                Alert(title: Text("Error!"), message: Text("Invalid display name entered"), dismissButton:
                        .default(Text("Got it!")))
            }
            .alert(isPresented: $confirmDeleteAlert) {
                Alert(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account?"), primaryButton: .destructive(Text("Delete")){
                    vm.deleteUser()
                }, secondaryButton: .cancel())
            }
            .alert(isPresented: $permission) {
                Alert(title: Text("Permission Denied!"), message: Text("Please go into your settings and give photo permissions for TennisTracker"), dismissButton:
                        .default(Text("Got it!")))
            }
            if changeDisplayName{
                Rectangle().ignoresSafeArea(.all).opacity(0.5)
                VStack{
                    Text("Change Display Name").font(.title3).fontWeight(.bold).padding()
                    TextField(" Enter your new display name", text: $displayName).padding().background(Color.gray.opacity(0.3)).cornerRadius(20)
                    HStack{
                        Button {
                            if displayName.isEmpty {
                                invalidDisplayName = true
                            }
                            else{
                                displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                                vm.updateDisplayName(input: displayName) { _ in
                                    changeDisplayName.toggle()
                                }
                            }
                        } label: {
                            VStack{
                                Text("Update")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(20)
                            }
                        }
                        Button {
                            changeDisplayName.toggle()
                        } label: {
                            VStack{
                                Text("Cancel")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(20)
                            }
                        }
                    }.padding()
                }
                .padding()
                .frame(width: UIScreen.main.bounds.midX * 1.5, height: UIScreen.main.bounds.midY / 2)
                .background(Color.white)
                .cornerRadius(30)
            }
            
        }
    }
}



struct profileTab_Previews: PreviewProvider {
    static var previews: some View {
        profileTab().environmentObject(UserViewModel())
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
                    Text("\(vm.user?.friends.count ?? 0)")
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
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized || status == .limited{
                    showImagePicker.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        showSaveButton = true
                    }
                } else {
                    permission.toggle()
                }
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
    
    private var friendsList: some View {
        ForEach(vm.friends, id: \.uid) {friend in
            HStack{
                if friend.profilePicUrl != "" {
                    WebImage(url: URL(string: friend.profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal)
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
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
}
