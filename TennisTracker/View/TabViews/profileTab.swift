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
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var changeDisplayName = false
    @State var showFriendsList = false
    @State var confirmDeleteAlert = false
    @State var permission = false
    @State var isLoading = false
    @EnvironmentObject private var vm: UserViewModel
    var body: some View {
        ZStack{
            NavigationView {
                ScrollView(showsIndicators: false){
                    VStack{
                        header.alert(isPresented: $permission) {
                            Alert(title: Text("Permission Denied!"), message: Text("Please go into your settings and give photo permissions for MyTennisZone"), dismissButton:
                                    .default(Text("Got it!")))
                        }
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
                        FriendListView().environmentObject(vm)
                    })
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    ImagePicker(image: $image)
                }.navigationTitle("Profile")
                    .toolbar {
                        if image != nil{
                            Button {
                                Task {
                                    await vm.updateImage(image: image)
                                    image = nil
                                }
                            } label: {
                                Text("Save")
                                    .padding()
                            }
                        }
                    }
            }.fullScreenCover(isPresented: $vm.isUserSignedOut) {
                signIn()
            }
            if changeDisplayName{
                Rectangle().ignoresSafeArea(.all).opacity(0.5)
                ChangeDisplayNameView(changeDisplayName: $changeDisplayName).environmentObject(vm)
            }
            
            if isLoading {
                LoadingView()
            }
            
        }.alert(isPresented: $confirmDeleteAlert) {
            Alert(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account? All your data will be deleted!"), primaryButton:
                    .destructive(Text("Delete")){
                        isLoading = true
                        Task {
                            await vm.deleteUser()
                            isLoading = false
                        }
                    }, secondaryButton: .cancel())
        }
        .task {
            await vm.getCurrentUser()
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
            NavigationLink(destination: FriendListView().navigationTitle("Friends")) {
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
                    .userImageModifier(width: 200, height: 200)
                    .padding()
            } else {
                if vm.user!.profilePicUrl != "" {
                    WebImage(url: URL(string: vm.user!.profilePicUrl))
                        .userImageModifier(width: 200, height: 200)
                        .padding()
                } else {
                    Image("profile")
                        .userImageModifier(width: 200, height: 200)
                        .padding()
                }
            }
            Text(vm.user?.displayName ?? "")
                .font(.title)
                .fontWeight(.bold)
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
                    .profileTabButtonImageModifier(textColor: Color.black)
                
                Text("Change Display Name")
                    .fontWeight(.semibold)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
                } else {
                    permission.toggle()
                }
            }
            
        } label: {
            HStack{
                Image(systemName: "camera")
                    .profileTabButtonImageModifier(textColor: Color.black)
                Text("Change Profile Picture")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
                    .profileTabButtonImageModifier(textColor: Color.black)
                Text("Log Out")
                    .fontWeight(.semibold)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
                    .profileTabButtonImageModifier(textColor: Color.red)
                Text("Delete Account")
                    .fontWeight(.semibold)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.red)
                    .padding()
            }.padding(.horizontal)
        }
    }
}
