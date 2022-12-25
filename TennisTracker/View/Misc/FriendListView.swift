//
//  FriendListView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendListView: View {
    
    @EnvironmentObject private var vm: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State var showSheet = false
    
    var body: some View {
        ScrollView {
            ForEach(vm.friends, id: \.uid) {friend in
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
                }.onTapGesture {
                    showSheet.toggle()
                }.sheet(isPresented: $showSheet) {
                    UserSummaryView(isFriend: true, user: friend).environmentObject(vm)
                }
                Divider().padding(.horizontal)
            }
        }.padding(.top)
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView().environmentObject(UserViewModel())
    }
}
